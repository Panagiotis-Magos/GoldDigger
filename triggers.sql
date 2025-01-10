DELIMITER //
CREATE TRIGGER after_task_completed
AFTER UPDATE ON `usertasks`
FOR EACH ROW
BEGIN
  IF NEW.is_completed = 1 AND OLD.is_completed = 0 THEN
    UPDATE `usergoals` ug
    SET ug.progress = ug.progress + 1
    WHERE ug.user_id = NEW.user_id
      AND ug.goal_id IN (
        SELECT gt.goal_id
        FROM `goaltask` gt
        WHERE gt.task_id = NEW.task_id
      );
  END IF;
END;
//

CREATE TRIGGER after_task_incomplete
AFTER UPDATE ON `usertasks`
FOR EACH ROW
BEGIN
  IF NEW.is_completed = 0 AND OLD.is_completed = 1 THEN
    UPDATE `usergoals` ug
    SET ug.progress = ug.progress - 1
    WHERE ug.user_id = NEW.user_id
      AND ug.goal_id IN (
        SELECT gt.goal_id
        FROM `goaltask` gt
        WHERE gt.task_id = NEW.task_id
      );
  END IF;
END;
//

CREATE TRIGGER before_task_update
BEFORE UPDATE ON `usertasks`
FOR EACH ROW
BEGIN
  IF NEW.is_completed = 1 AND OLD.is_completed = 0 THEN
    SET NEW.completed_at = CURRENT_TIMESTAMP;
  ELSEIF NEW.is_completed = 0 THEN
    SET NEW.completed_at = NULL;
  END IF;
END;
//

CREATE TRIGGER before_goal_update
BEFORE UPDATE ON `usergoals`
FOR EACH ROW
BEGIN
  IF NEW.is_completed = 1 AND OLD.is_completed = 0 THEN
    SET NEW.completed_at = CURRENT_TIMESTAMP;
  ELSEIF NEW.is_completed = 0 THEN
    SET NEW.completed_at = NULL;
  END IF;
END;
//

CREATE TRIGGER after_goaltask_insert
AFTER INSERT ON `goaltask`
FOR EACH ROW
BEGIN
  UPDATE `goals`
  SET `target` = `target` + 1
  WHERE `goal_id` = NEW.goal_id;
END;
//

CREATE TRIGGER after_goaltask_delete
AFTER DELETE ON `goaltask`
FOR EACH ROW
BEGIN
  UPDATE `goals`
  SET `target` = `target` - 1
  WHERE `goal_id` = OLD.goal_id;
END;
//

CREATE TRIGGER update_gold
AFTER INSERT ON `usertasks`
FOR EACH ROW
BEGIN
  -- Ensure the task is marked as completed
  IF NEW.is_completed = 1 THEN
    -- Update the user's gold by adding the task's gold_reward
    UPDATE `users`
    SET `gold` = `gold` + (
      SELECT `gold_reward`
      FROM `tasks`
      WHERE `task_id` = NEW.task_id
    )
    WHERE `user_id` = NEW.user_id;
  END IF;
END;
//










