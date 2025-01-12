
import 'package:sqflite/sqflite.dart'; // For SQLite operations
import 'package:path/path.dart';       // For building database file paths
import 'dart:async';                  // Optional, for async/await and streams

//If we dont have the user making goals these are not needed

/*Future<void> afterGoaltaskInsert(Database db, int goalId) async {
  await db.rawUpdate(
    'UPDATE goals SET target = target + 1 WHERE goal_id = ?',
    [goalId],
  );
}

Future<void> afterGoaltaskDelete(Database db, int goalId) async {
  await db.rawUpdate(
    'UPDATE goals SET target = target - 1 WHERE goal_id = ?',
    [goalId],
  );
} */

//Trigger for when a user adds a goal

Future<void> afterUsergoalInsert(Database db, int userId, int goalId) async {
  await db.rawInsert('''
    INSERT INTO usertasks (user_id, task_id, is_completed, completed_at)
    SELECT ?, gt.task_id, 0, NULL
    FROM goaltask gt
    WHERE gt.goal_id = ?
      AND NOT EXISTS (
        SELECT 1 FROM usertasks ut
        WHERE ut.user_id = ? AND ut.task_id = gt.task_id
      )
  ''', [userId, goalId, userId]);
}

//For timestamp in goals

Future<void> beforeGoalUpdate(Database db, Map<String, dynamic> newGoal, Map<String, dynamic> oldGoal) async {
  if (newGoal['is_completed'] == 1 && oldGoal['is_completed'] == 0) {
    newGoal['completed_at'] = DateTime.now().toIso8601String();
  } else if (newGoal['is_completed'] == 0) {
    newGoal['completed_at'] = null;
  }
}

Future<void> takePayment(Database db, int userId, int itemId) async {
  final userGold = Sqflite.firstIntValue(await db.rawQuery(
    'SELECT gold FROM users WHERE user_id = ?',
    [userId],
  ));
  final itemPrice = Sqflite.firstIntValue(await db.rawQuery(
    'SELECT price FROM items WHERE item_id = ?',
    [itemId],
  ));

  if (userGold == null || itemPrice == null || userGold < itemPrice) {
    throw Exception('Not enough gold to purchase this item');
  }

  await db.rawUpdate(
    'UPDATE users SET gold = gold - ? WHERE user_id = ?',
    [itemPrice, userId],
  );

  await db.insert('useritems', {'user_id': userId, 'item_id': itemId});
}

Future<void> beforeTaskUpdate(Database db, Map<String, dynamic> newTask, Map<String, dynamic> oldTask) async {
  if (newTask['is_completed'] == 1 && oldTask['is_completed'] == 0) {
    newTask['completed_at'] = DateTime.now().toIso8601String();
  } else if (newTask['is_completed'] == 0) {
    newTask['completed_at'] = null;
  }
}

Future<void> taskIncomplete(Database db, int userId, int taskId) async {
  await db.rawUpdate('''
    UPDATE usergoals
    SET progress = progress - 1
    WHERE user_id = ?
      AND goal_id IN (
        SELECT goal_id FROM goaltask WHERE task_id = ?
      )
  ''', [userId, taskId]);
}



Future<void> taskCompletedUpdate(Database db, int userId, int taskId) async {
  // Update user's gold
  await db.rawUpdate('''
    UPDATE users
    SET gold = gold + (
      SELECT gold_reward FROM tasks WHERE task_id = ?
    )
    WHERE user_id = ?
  ''', [taskId, userId]);

  // Increment progress for linked goals
  await db.rawUpdate('''
    UPDATE usergoals
    SET progress = progress + 1
    WHERE user_id = ?
      AND goal_id IN (
        SELECT goal_id FROM goaltask WHERE task_id = ?
      )
  ''', [userId, taskId]);

  // Mark goals as completed if progress matches target
  await db.rawUpdate('''
    UPDATE usergoals
    SET is_completed = 1, completed_at = ?
    WHERE user_id = ?
      AND goal_id IN (
        SELECT goal_id FROM goals WHERE goal_id = usergoals.goal_id AND progress >= target
      )
      AND is_completed = 0
  ''', [DateTime.now().toIso8601String(), userId]);

  // Update user's gold with rewards from completed goals
  await db.rawUpdate('''
    UPDATE users
    SET gold = gold + (
      SELECT COALESCE(SUM(reward), 0)
      FROM usergoals
      JOIN goals ON usergoals.goal_id = goals.goal_id
      WHERE usergoals.user_id = ?
        AND usergoals.is_completed = 1
        AND usergoals.completed_at = ?
    )
    WHERE user_id = ?
  ''', [userId, DateTime.now().toIso8601String(), userId]);
}
