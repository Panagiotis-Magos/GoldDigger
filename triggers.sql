DELIMITER //
CREATE TRIGGER task_completed_update_progress
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

CREATE TRIGGER task_incomplete -- for maybe recurring tasks?
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

CREATE TRIGGER before_task_update  -- updates timestamp(for progress diagram)
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

CREATE TRIGGER before_goal_update -- timestamp
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

CREATE TRIGGER after_goaltask_insert -- so as to update the target tasks
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

CREATE TRIGGER update_gold -- give rewards for completed tasks and goals
AFTER UPDATE ON `usertasks`
FOR EACH ROW
BEGIN
  -- Ensure the task is newly marked as completed
  IF NEW.is_completed = 1 AND OLD.is_completed = 0 THEN
    -- Update the user's gold by adding the task's gold_reward
    UPDATE `users`
    SET `gold` = `gold` + (
      SELECT `gold_reward`
      FROM `tasks`
      WHERE `task_id` = NEW.task_id
    )
    WHERE `user_id` = NEW.user_id;

    -- Check if any goal has been completed due to this task
    UPDATE `usergoals` ug
    JOIN (
      SELECT ug.user_goal_id, g.gold_reward
      FROM `usergoals` ug
      JOIN `goaltask` gt ON ug.goal_id = gt.goal_id
      JOIN `goals` g ON ug.goal_id = g.goal_id
      WHERE ug.user_id = NEW.user_id
        AND gt.task_id = NEW.task_id
        AND ug.progress + 1 = g.target -- Progress reaches the target
    ) goal_data ON ug.user_goal_id = goal_data.user_goal_id
    SET ug.is_completed = 1,
        ug.completed_at = NOW();

    -- Update the user's gold by adding the goal's gold_reward
    UPDATE `users`
    SET `gold` = `gold` + (
      SELECT SUM(g.gold_reward)
      FROM `usergoals` ug
      JOIN `goals` g ON ug.goal_id = g.goal_id
      WHERE ug.user_id = NEW.user_id
        AND ug.is_completed = 1
        AND ug.completed_at = NOW()
    )
    WHERE `user_id` = NEW.user_id;
  END IF;
END;
//

CREATE TRIGGER take_payment -- for shop
BEFORE INSERT ON `useritems`
FOR EACH ROW
BEGIN
  DECLARE item_price INT;

  -- Get the price of the item being purchased
  SELECT `price`
  INTO item_price
  FROM `items`
  WHERE `item_id` = NEW.item_id;

  -- Check if the user has enough gold
  IF (SELECT `gold` FROM `users` WHERE `user_id` = NEW.user_id) < item_price THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Not enough gold to purchase this item';
  ELSE
    -- Deduct the item's price from the user's gold
    UPDATE `users`
    SET `gold` = `gold` - item_price
    WHERE `user_id` = NEW.user_id;
  END IF;
END;
//

CREATE TRIGGER after_usergoal_insert -- if a user adds a goal the tasks for this goal are added
AFTER INSERT ON `usergoals` 
FOR EACH ROW
BEGIN
  -- Insert tasks related to the newly added goal into `usertasks`, if not already present
  INSERT INTO `usertasks` (`user_id`, `task_id`, `is_completed`, `completed_at`)
  SELECT NEW.user_id, gt.task_id, 0, NULL
  FROM `goaltask` gt
  WHERE gt.goal_id = NEW.goal_id
    AND NOT EXISTS (
      SELECT 1
      FROM `usertasks` ut
      WHERE ut.user_id = NEW.user_id
        AND ut.task_id = gt.task_id
    );
END;
//

DELIMITER ;
