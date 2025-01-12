import 'package:flutter/material.dart';
import './routes/app_routes.dart';
import 'utils/theme.dart';
import 'services/database_service.dart'; 
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';



Future<void> clearDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'golddigger.db');

  print('Deleting database at $path...');
  await deleteDatabase(path);
  print('Database deleted.');
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Clear database for development/testing purposes
  //await clearDatabase();
  final dbService = DatabaseService();
  await dbService.database; // Ensure the database is initialized
  runApp(GoldDiggerApp());
}

class GoldDiggerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoldDigger',
      theme: AppTheme.lightTheme, // Apply custom theme
      initialRoute: AppRoutes.intro,//Start with the Intro screen
      routes: AppRoutes.routes, // Use centralized routes
    );
  }
}



/*CREATE TRIGGER after_goaltask_insert
AFTER INSERT ON goaltask
BEGIN
  UPDATE goals 
  SET target = target + 1
  WHERE goal_id = NEW.goal_id;
END;

CREATE TRIGGER after_goaltask_delete
AFTER DELETE ON goaltask
BEGIN
  UPDATE goals 
  SET target = target - 1
  WHERE goal_id = OLD.goal_id;
END;

--Triggers for usergoals

CREATE TRIGGER after_usergoal_insert
AFTER INSERT ON usergoals
BEGIN
  -- Insert tasks related to the newly added goal into `usertasks`
  INSERT INTO usertasks (user_id, task_id, is_completed, completed_at)
  SELECT NEW.user_id, gt.task_id, 0, NULL
  FROM goaltask gt
  WHERE gt.goal_id = NEW.goal_id
    AND NOT EXISTS (
      SELECT 1 FROM usertasks ut
      WHERE ut.user_id = NEW.user_id
        AND ut.task_id = gt.task_id
    );
END;

CREATE TRIGGER before_goal_update
BEFORE UPDATE ON usergoals
BEGIN
  -- If the goal is marked as completed
  IF NEW.is_completed = 1 AND OLD.is_completed = 0 THEN
    SET NEW.completed_at = CURRENT_TIMESTAMP;
  -- If the goal is marked as incomplete
  ELSEIF NEW.is_completed = 0 THEN
    SET NEW.completed_at = NULL;
  END IF;
END;

-- Useritems triggers
CREATE TRIGGER take_payment
BEFORE INSERT ON useritems
BEGIN
  -- Check if the user has enough gold
  SELECT CASE
    WHEN (
      SELECT users.gold
      FROM users
      WHERE users.user_id = NEW.user_id
    ) < (
      SELECT items.price
      FROM items
      WHERE items.item_id = NEW.item_id
    )
    THEN
      RAISE(FAIL, 'Not enough gold to purchase this item')
  END;

  -- Deduct the item's price from the user's gold
  UPDATE users
  SET users.gold = users.gold - (
    SELECT items.price
    FROM items
    WHERE items.item_id = NEW.item_id
  )
  WHERE users.user_id = NEW.user_id;
END;



--usertasks triggers
CREATE TRIGGER before_task_update
BEFORE UPDATE ON usertasks
BEGIN
  -- Ensure the task is newly marked as completed or reset
  IF NEW.is_completed = 1 AND OLD.is_completed = 0 THEN
    SET NEW.completed_at = CURRENT_TIMESTAMP;
  ELSEIF NEW.is_completed = 0 THEN
    SET NEW.completed_at = NULL;
  END IF;
END;

CREATE TRIGGER task_incomplete
AFTER UPDATE ON usertasks
BEGIN
  -- Decrement progress if a task is marked as incomplete
  IF NEW.is_completed = 0 AND OLD.is_completed = 1 THEN
    UPDATE usergoals ug
    SET ug.progress = ug.progress - 1
    WHERE ug.user_id = NEW.user_id
      AND ug.goal_id IN (
        SELECT gt.goal_id
        FROM goaltask gt
        WHERE gt.task_id = NEW.task_id
      );
  END IF;
END;

CREATE TRIGGER task_completed_update
AFTER UPDATE ON usertasks
BEGIN
  -- Ensure the task is newly marked as completed
  IF NEW.is_completed = 1 AND OLD.is_completed = 0 THEN
    -- 1. Update user's gold by adding the task's reward
    UPDATE users u
    SET u.gold = u.gold + (
      SELECT t.gold_reward
      FROM tasks t
      WHERE t.task_id = NEW.task_id
    )
    WHERE u.user_id = NEW.user_id;

    -- 2. Increment progress for usergoals linked to this task
    UPDATE usergoals ug
    SET ug.progress = ug.progress + 1
    WHERE ug.user_id = NEW.user_id
      AND ug.goal_id IN (
        SELECT gt.goal_id
        FROM goaltask gt
        WHERE gt.task_id = NEW.task_id
      );

    -- 3. Mark goals as completed if progress reaches the target
    UPDATE usergoals ug
    SET ug.is_completed = 1,
        ug.completed_at = CURRENT_TIMESTAMP
    WHERE ug.user_id = NEW.user_id
      AND ug.goal_id IN (
        SELECT g.goal_id
        FROM goals g
        WHERE ug.goal_id = g.goal_id
          AND ug.progress >= g.target
      )
      AND ug.is_completed = 0;

    -- 4. Update the user's gold by adding rewards for completed goals
    UPDATE users u
/ 
    SET u.gold = u.gold + (
      SELECT COALESCE(SUM(g.reward), 0)
      FROM usergoals ug
      JOIN goals g ON ug.goal_id = g.goal_id
      WHERE ug.user_id = NEW.user_id
        AND ug.is_completed = 1
        AND ug.completed_at = CURRENT_TIMESTAMP
    )
    WHERE u.user_id = NEW.user_id;
  END IF;
END;
*/