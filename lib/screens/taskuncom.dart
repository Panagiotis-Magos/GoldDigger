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
  bool taskCompleted = false; // Κατάσταση ολοκλήρωσης του task
  bool decidedNoPhoto = false; // Κατάσταση αν ο χρήστης αποφάσισε "No Photo"

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

      // Ανάκτηση της κατάστασης του task για τον χρήστη
      final userTaskResult = await db.query(
        'usertasks',
        where: 'user_id = ? AND task_id = ?',
        whereArgs: [widget.userId, widget.taskId],
      );

      setState(() {
        taskDetails = taskResult.isNotEmpty ? taskResult.first : null;
        taskCompleted = userTaskResult.isNotEmpty &&
            (userTaskResult.first['is_completed'] as int) == 1;
        decidedNoPhoto = userTaskResult.isNotEmpty &&
            (userTaskResult.first['photo_decision'] == 'no');
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

      // Πρόσθεση των χρημάτων στον χρήστη
      final goldReward = taskDetails!['gold_reward'] as int;
      await db.rawUpdate('''
        UPDATE users
        SET gold = gold + ?
        WHERE user_id = ?
      ''', [goldReward, widget.userId]);

      setState(() {
        taskCompleted = true; // Ενημερώνουμε την κατάσταση του task
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task completed! You earned $goldReward gold!')),
      );
    } catch (e) {
      print('Error completing task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete task: $e')),
      );
    }
  }

  Future<void> _handlePhotoDecision(bool uploadPhoto) async {
    try {
      final db = await DatabaseService().database;

      // Ενημέρωση της απόφασης του χρήστη στη βάση δεδομένων
      await db.update(
        'usertasks',
        {'photo_decision': uploadPhoto ? 'yes' : 'no'},
        where: 'user_id = ? AND task_id = ?',
        whereArgs: [widget.userId, widget.taskId],
      );

      setState(() {
        decidedNoPhoto = !uploadPhoto;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            uploadPhoto
                ? 'You chose to upload a photo!'
                : 'You decided not to upload a photo.',
          ),
        ),
      );
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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber),
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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber),
                ),
                Row(
                  children: [
                    Text(
                      '${taskDetails!['gold_reward']}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const Icon(Icons.attach_money, color: Colors.amber),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Spacer(),

            if (decidedNoPhoto)
              Column(
                children: [
                  const Text(
                    'You decided not to upload a photo',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.sentiment_dissatisfied,
                      size: 80, color: Colors.grey),
                ],
              )
            else if (!taskCompleted)
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
                      color: Colors.black),
                ),
              )
            else
              Column(
                children: [
                  const Text(
                    'Great! You completed the task!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text('Yes'),
                      ),
                      ElevatedButton(
                        onPressed: () => _handlePhotoDecision(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text('No'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

