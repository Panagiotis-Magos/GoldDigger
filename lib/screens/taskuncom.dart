import 'package:flutter/material.dart';
import 'package:golddigger/screens/gpsscreen.dart';
import '../services/database_service.dart';
import 'camerascreen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final int userId; // ID of the user
  final int taskId; // ID of the task

  const TaskDetailsScreen({Key? key, required this.userId, required this.taskId})
      : super(key: key);

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  Map<String, dynamic>? taskDetails;
  List<Map<String, dynamic>> relatedGoals = []; // Goals the task contributes to
  bool isLoading = true;
  bool taskCompleted = false; // Task completion status
  bool decidedNoPhoto = false; // Whether the user decided not to upload a photo
  bool decisionPending = true; // Whether the user's decision is pending

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  Future<void> _fetchTaskDetails() async {
    try {
      final db = await DatabaseService().database;

      // Fetch task details
      final taskResult = await db.query(
        'tasks',
        where: 'task_id = ?',
        whereArgs: [widget.taskId],
      );

      // Fetch user's task status
      final userTaskResult = await db.query(
        'usertasks',
        where: 'user_id = ? AND task_id = ?',
        whereArgs: [widget.userId, widget.taskId],
      );

      // Fetch goals that the task contributes to
      final goalsResult = await db.rawQuery('''
        SELECT g.goal_id, g.title, g.category 
        FROM goaltask gt
        JOIN goals g ON gt.goal_id = g.goal_id
        WHERE gt.task_id = ?
      ''', [widget.taskId]);

      setState(() {
        taskDetails = taskResult.isNotEmpty ? taskResult.first : null;
        taskCompleted = userTaskResult.isNotEmpty &&
            (userTaskResult.first['is_completed'] as int) == 1;
        decidedNoPhoto = userTaskResult.isNotEmpty &&
            (userTaskResult.first['photo_decision'] == 'no');
        decisionPending = userTaskResult.isNotEmpty &&
            (userTaskResult.first['photo_decision'] == null);
        relatedGoals = goalsResult; // Store goals that the task contributes to
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching task details or goals: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _completeTask() async {
  // Navigate to the GPS screen with taskId and userId
  final locationVerified = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GPSScreen(
        userId: widget.userId,
        taskId: widget.taskId,
      ),
    ),
  );

  if (locationVerified == true) {
    try {
      // Update the task as completed
      final db = await DatabaseService().database;
      await db.update(
        'usertasks',
        {
          'is_completed': 1,
          'completed_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ? AND task_id = ?',
        whereArgs: [widget.userId, widget.taskId],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task completed successfully!')),
      );

      // Refresh TaskDetailsScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TaskDetailsScreen(
            userId: widget.userId,
            taskId: widget.taskId,
          ),
        ),
      );
    } catch (e) {
      print('Error completing task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete task: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location verification failed.')),
    );
  }
}



  Future<void> _handlePhotoDecision(bool uploadPhoto) async {
    try {
      final db = await DatabaseService().database;

      await db.update(
        'usertasks',
        {'photo_decision': uploadPhoto ? 'yes' : 'no'},
        where: 'user_id = ? AND task_id = ?',
        whereArgs: [widget.userId, widget.taskId],
      );

      setState(() {
        decidedNoPhoto = !uploadPhoto;
        decisionPending = false;
      });

      if (uploadPhoto) {
        final capturedImagePath = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraScreen(userId:widget.userId, taskId: widget.taskId),
          ),
        );

        if (capturedImagePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Photo captured: $capturedImagePath')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You decided not to upload a photo.')),
        );
      }
    } catch (e) {
      print('Error saving photo decision: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (taskDetails == null) {
      return const Scaffold(
        body: Center(child: Text('Task not found!')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(taskDetails!['title']),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Task title and category
            Text(
              taskDetails!['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              taskDetails!['category'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Task description
            Text(
              'Description',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                taskDetails!['description'] ?? 'No description available',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Goals this task contributes to
            Text(
              'Counts Towards Goals',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            ...relatedGoals.map((goal) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.golf_course_rounded, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal['title'],
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),

            const Spacer(),

            // Action buttons based on task and decision states
            if (!taskCompleted)
              ElevatedButton(
                onPressed: _completeTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'COMPLETE TASK',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              )
            else if (decisionPending)
              Column(
                children: [
                  const Text(
                    'Do you want to upload a photo?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _handlePhotoDecision(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        child: const Text('Yes'),
                      ),
                      ElevatedButton(
                        onPressed: () => _handlePhotoDecision(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('No'),
                      ),
                    ],
                  ),
                ],
              )
            else if (decidedNoPhoto)
              Column(
                children: [
                  const Text(
                    'You decided not to upload a photo.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.sentiment_dissatisfied,
                      size: 80, color: Colors.grey),
                ],
              )
            else
              Column(
                children: [
                  const Text(
                    'Photo uploaded successfully!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.check_circle,
                      size: 80, color: Colors.green),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
