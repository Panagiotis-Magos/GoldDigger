import 'package:flutter/material.dart';
import '../services/database_service.dart';

class TaskDetailsScreen extends StatefulWidget {
  final int userId; // ID του χρήστη
  final int taskId; // ID του task

  const TaskDetailsScreen({Key? key, required this.userId, required this.taskId})
      : super(key: key);

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  Map<String, dynamic>? taskDetails;
  List<Map<String, dynamic>> relatedGoals = [];
  bool isLoading = true;
  bool taskCompleted = false; // Νέα μεταβλητή για την κατάσταση ολοκλήρωσης
  bool decidedNoPhoto = false; // Νέα μεταβλητή για την επιλογή "No Photo"

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  Future<void> _fetchTaskDetails() async {
    try {
      final db = await DatabaseService().database;

      // Ανάκτηση των λεπτομερειών του task
      final taskResult = await db.query(
        'tasks',
        where: 'task_id = ?',
        whereArgs: [widget.taskId],
      );

      // Ανάκτηση των στόχων στους οποίους συνεισφέρει το task
      final goalsResult = await db.rawQuery('''
        SELECT goals.title 
        FROM goaltask 
        INNER JOIN goals ON goaltask.goal_id = goals.goal_id
        WHERE goaltask.task_id = ?
      ''', [widget.taskId]);

      setState(() {
        taskDetails = taskResult.isNotEmpty ? taskResult.first : null;
        relatedGoals = goalsResult;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching task details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _completeTask() async {
    try {
      final db = await DatabaseService().database;

      // Ενημέρωση της κατάστασης του task ως completed
      await db.update(
        'usertasks',
        {
          'is_completed': 1,
          'completed_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ? AND task_id = ?',
        whereArgs: [widget.userId, widget.taskId],
      );

      setState(() {
        taskCompleted = true; // Ενημερώνουμε την κατάσταση του task
      });
    } catch (e) {
      print('Error completing task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete task: $e')),
      );
    }
  }

  void _handlePhotoDecision(bool uploadPhoto) {
    if (uploadPhoto) {
      Navigator.pushNamed(context, '/uploadPhoto', arguments: {
        'userId': widget.userId,
        'taskId': widget.taskId,
      });
    } else {
      setState(() {
        decidedNoPhoto = true; // Ο χρήστης αποφάσισε να μην ανεβάσει φωτογραφία
      });
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                Text(
                  taskCompleted ? 'COMPLETED' : 'NOT COMPLETED',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: taskCompleted ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gold:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                Row(
                  children: [
                    Text(
                      '${taskDetails!['gold_reward']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Icon(Icons.attach_money, color: Colors.amber),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Counts towards:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            const SizedBox(height: 8),
            ...relatedGoals.map((goal) => Row(
                  children: [
                    const Icon(Icons.check, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      goal['title'],
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                )),
            const Spacer(),

            if (!taskCompleted && !decidedNoPhoto)
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),

            if (taskCompleted && !decidedNoPhoto)
              Column(
                children: [
                  const Text(
                    'Great! You completed the task!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Do you want to take a photo?',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _handlePhotoDecision(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text('Yes'),
                      ),
                      ElevatedButton(
                        onPressed: () => _handlePhotoDecision(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text('No'),
                      ),
                    ],
                  ),
                ],
              ),

            if (decidedNoPhoto)
              Column(
                children: [
                  const Text(
                    'You decided not to upload a photo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
