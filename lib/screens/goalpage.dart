import 'package:flutter/material.dart';
import '../services/database_service.dart';

class GoalDetailsScreen extends StatefulWidget {
  final int userId; // ID του χρήστη
  final int goalId; // ID του goal

  const GoalDetailsScreen({Key? key, required this.userId, required this.goalId})
      : super(key: key);

  @override
  _GoalDetailsScreenState createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  Map<String, dynamic>? goalDetails;
  bool isSelected = false; // Κατάσταση αν το goal είναι επιλεγμένο
  int progress = 0; // Πρόοδος χρήστη στο goal
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGoalDetails();
  }

  Future<void> _fetchGoalDetails() async {
    try {
      final db = await DatabaseService().database;

      // Ανάκτηση των λεπτομερειών του goal
      final goalResult = await db.query(
        'goals',
        where: 'goal_id = ?',
        whereArgs: [widget.goalId],
      );

      // Ανάκτηση της κατάστασης επιλογής και προόδου του goal για τον χρήστη
      final userGoalResult = await db.query(
        'usergoals',
        where: 'user_id = ? AND goal_id = ?',
        whereArgs: [widget.userId, widget.goalId],
      );

      setState(() {
        if (goalResult.isNotEmpty) {
          goalDetails = goalResult.first;
          isSelected = userGoalResult.isNotEmpty;
          progress = userGoalResult.isNotEmpty
              ? (userGoalResult.first['progress'] as int) 
              : 0;
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching goal details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleGoalSelection() async {
    try {
      final db = await DatabaseService().database;

      if (isSelected) {
        // Αποεπιλογή του goal
        await db.delete(
          'usergoals',
          where: 'user_id = ? AND goal_id = ?',
          whereArgs: [widget.userId, widget.goalId],
        );
      } else {
        // Επιλογή του goal
        await db.insert('usergoals', {
          'user_id': widget.userId,
          'goal_id': widget.goalId,
          'progress': progress,
          'is_completed': 0,
        });
      }

      setState(() {
        isSelected = !isSelected;
      });
    } catch (e) {
      print('Error toggling goal selection: $e');
    }
  }

  Widget _buildProgressBar() {
    final target = goalDetails?['target'] as int? ?? 1;
    final double percentage = (progress / target) * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[800],
          color: Colors.amber,
          minHeight: 10,
        ),
        const SizedBox(height: 8),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Future<void> _addRewardIfCompleted() async {
    if (progress >= (goalDetails?['target'] as int)) {
      try {
        final db = await DatabaseService().database;

        // Προσθήκη του reward στο χρυσό του χρήστη
        await db.rawUpdate('''
          UPDATE users
          SET gold = gold + ?
          WHERE user_id = ?
        ''', [goalDetails?['reward'], widget.userId]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal completed! Reward added to your gold!')),
        );
      } catch (e) {
        print('Error adding reward: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (goalDetails == null) {
      return const Scaffold(
        body: Center(child: Text('Goal not found!')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(goalDetails?['title'] ?? 'Goal Details'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Τίτλος
            Text(
              goalDetails?['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Κατηγορία
            Text(
              goalDetails?['category'] ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Περιγραφή
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                goalDetails?['description'] ?? 'No description available',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Πρόοδος
            _buildProgressBar(),
            const SizedBox(height: 16),

            // Reward
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gold:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                Text(
                  '${goalDetails?['reward']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const Spacer(),

            // Επιλογή/Αποεπιλογή Goal
            ElevatedButton(
              onPressed: _toggleGoalSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color.fromARGB(255, 59, 31, 21) : Colors.amber,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isSelected ? 'Deselect Goal' : 'Select Goal',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}