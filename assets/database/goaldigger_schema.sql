-- SQLite-compatible version of the schema
-- Drop database and setup schema
PRAGMA foreign_keys = OFF;

-- Table structure for table `goals`
DROP TABLE IF EXISTS goals;
CREATE TABLE goals (
  goal_id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  target INTEGER NOT NULL DEFAULT 0,
  reward INTEGER DEFAULT 0
);

-- Table structure for table `goaltask`
DROP TABLE IF EXISTS goaltask;
CREATE TABLE goaltask (
  goal_task_id INTEGER PRIMARY KEY AUTOINCREMENT,
  goal_id INTEGER NOT NULL,
  task_id INTEGER NOT NULL,
  FOREIGN KEY (goal_id) REFERENCES goals (goal_id) ON DELETE CASCADE,
  FOREIGN KEY (task_id) REFERENCES tasks (task_id) ON DELETE CASCADE
);

-- Table structure for table `items`
DROP TABLE IF EXISTS items;
CREATE TABLE items (
  item_id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  type TEXT,
  price INTEGER NOT NULL,
  photo_id INTEGER NOT NULL,
  FOREIGN KEY (photo_id) REFERENCES photos (photo_id) ON DELETE CASCADE
);

-- Table structure for table `photos`
DROP TABLE IF EXISTS photos;
CREATE TABLE photos (
  photo_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  task_id INTEGER,
  url TEXT NOT NULL,
  uploaded_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
  FOREIGN KEY (task_id) REFERENCES tasks (task_id) ON DELETE CASCADE
);

-- Table structure for table `tasks`
DROP TABLE IF EXISTS tasks;
CREATE TABLE tasks (
  task_id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  gold_reward INTEGER
);

-- Table structure for table `usergoals`
DROP TABLE IF EXISTS usergoals;
CREATE TABLE usergoals (
  user_id INTEGER NOT NULL,
  goal_id INTEGER NOT NULL,
  progress INTEGER DEFAULT 0,
  is_completed INTEGER DEFAULT 0,
  completed_at TEXT,
  PRIMARY KEY (user_id, goal_id),
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
  FOREIGN KEY (goal_id) REFERENCES goals (goal_id) ON DELETE CASCADE
);

-- Table structure for table `useritems`
DROP TABLE IF EXISTS useritems;
CREATE TABLE useritems (
  user_id INTEGER NOT NULL,
  item_id INTEGER NOT NULL,
  is_equipped INTEGER DEFAULT 0,
  PRIMARY KEY (user_id, item_id),
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES items (item_id) ON DELETE CASCADE
);

-- Table structure for table `users`
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  user_id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  gold INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Table structure for table `usertasks`
DROP TABLE IF EXISTS usertasks;
CREATE TABLE usertasks (
  user_id INTEGER NOT NULL,
  task_id INTEGER NOT NULL,
  is_completed INTEGER DEFAULT 0,
  completed_at TEXT,
  PRIMARY KEY (user_id, task_id),
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
  FOREIGN KEY (task_id) REFERENCES tasks (task_id) ON DELETE CASCADE
);

-- Insertions
INSERT INTO goals (goal_id, title, category, description, target, reward) VALUES
(1, 'Explore 5 historical landmarks', 'Traveling', 'Show share end how case structure. Attention soon strong improve player significant from.', 5, 470),
(2, 'Travel to 3 different cities this year', 'Traveling', 'Explain mother newspaper board two.', 5, 790),
(3, 'Participate in a cultural festival', 'Traveling', 'Western join hand open. Eye business sell medical chance add. Really everybody magazine name.', 5, 600),
(4, 'Experience 3 different cuisines in new locations', 'Traveling', 'Require music position near pick. Study stand how network some side miss. Scientist down attorney.', 5, 400),
(5, 'Capture 10 beautiful sceneries', 'Traveling', 'Voice off these own apply decade himself. Tend according choice have.', 5, 600),
(6, 'Create a structured weekly plan', 'Productivity', 'Month nearly us heavy maybe. Face response partner.', 5, 210),
(7, 'Declutter your home and digital life', 'Productivity', 'Subject Republican use onto. Respond hundred former message. During lead would each few.', 5, 760),
(8, 'Improve professional skills through training', 'Productivity', 'Example million friend few month. Imagine yeah include decade each begin.', 5, 300),
(9, 'Set and achieve SMART personal goals', 'Productivity', 'Boy guy economic section. Finally institution this game do cost near.', 5, 590),
(10, 'Build a sustainable morning routine', 'Productivity', 'Machine end last then someone. Growth until carry generation eye. Standard standard work go.', 5, 710),
(11, 'Host or attend 3 social gatherings', 'Social Life', 'Environmental concern piece reveal. Great region class probably improve drug.', 5, 330),
(12, 'Reconnect with old friends', 'Social Life', 'Eye possible focus. Happy goal later stand.', 5, 180),
(13, 'Volunteer for a community cause', 'Social Life', 'Do company join see standard provide. As just clear.', 5, 260),
(14, 'Meet 10 new people through events', 'Social Life', 'South wear million kind hot with. Support other answer. Million yard wind his low these.', 5, 270),
(15, 'Strengthen family bonds through activities', 'Social Life', 'Go end task hotel carry. Threat training only with.', 5, 600);




-- Trigger definitions
CREATE TRIGGER after_goaltask_insert AFTER INSERT ON goaltask
BEGIN
  UPDATE goals
  SET target = target + 1
  WHERE goal_id = NEW.goal_id;
END;

CREATE TRIGGER after_goaltask_delete AFTER DELETE ON goaltask
BEGIN
  UPDATE goals
  SET target = target - 1
  WHERE goal_id = OLD.goal_id;
END;

CREATE TRIGGER after_usergoal_insert AFTER INSERT ON usergoals
BEGIN
  INSERT INTO usertasks (user_id, task_id, is_completed, completed_at)
  SELECT NEW.user_id, gt.task_id, 0, NULL
  FROM goaltask gt
  WHERE gt.goal_id = NEW.goal_id
    AND NOT EXISTS (
      SELECT 1
      FROM usertasks ut
      WHERE ut.user_id = NEW.user_id
        AND ut.task_id = gt.task_id
    );
END;

CREATE TRIGGER before_goal_update BEFORE UPDATE ON usergoals
BEGIN
  IF NEW.is_completed = 1 AND OLD.is_completed = 0 THEN
    SET NEW.completed_at = CURRENT_TIMESTAMP;
  ELSEIF NEW.is_completed = 0 THEN
    SET NEW.completed_at = NULL;
  END IF;
END;

CREATE TRIGGER take_payment BEFORE INSERT ON useritems
BEGIN
  DECLARE item_price INT;
  SELECT price
  INTO item_price
  FROM items
  WHERE item_id = NEW.item_id;
  IF (SELECT gold FROM users WHERE user_id = NEW.user_id) < item_price THEN
    RAISE ABORT('Not enough gold to purchase this item');
  ELSE
    UPDATE users
    SET gold = gold - item_price
    WHERE user_id = NEW.user_id;
  END IF;
END;

CREATE TRIGGER task_incomplete AFTER UPDATE ON usertasks
BEGIN
  IF NEW.is_completed = 0 AND OLD.is_completed = 1 THEN
    UPDATE usergoals
    SET progress = progress - 1
    WHERE user_id = NEW.user_id
      AND goal_id IN (
        SELECT goal_id
        FROM goaltask
        WHERE task_id = NEW.task_id
      );
  END IF;
END;

CREATE TRIGGER task_completed_update AFTER UPDATE ON usertasks
BEGIN
  IF NEW.is_completed = 1 AND OLD.is_completed = 0 THEN
    UPDATE users
    SET gold = gold + (
      SELECT gold_reward
      FROM tasks
      WHERE task_id = NEW.task_id
    )
    WHERE user_id = NEW.user_id;

    UPDATE usergoals
    SET progress = progress + 1
    WHERE user_id = NEW.user_id
      AND goal_id IN (
        SELECT goal_id
        FROM goaltask
        WHERE task_id = NEW.task_id
      );

    UPDATE usergoals
    SET is_completed = 1,
        completed_at = CURRENT_TIMESTAMP
    WHERE user_id = NEW.user_id
      AND progress >= (
        SELECT target
        FROM goals
        WHERE goal_id = usergoals.goal_id
      )
      AND is_completed = 0;

    UPDATE users
    SET gold = gold + (
      SELECT SUM(reward)
      FROM goals
      WHERE goal_id IN (
        SELECT goal_id
        FROM usergoals
        WHERE user_id = NEW.user_id AND is_completed = 1
      )
    )
    WHERE user_id = NEW.user_id;
  END IF;
END;

INSERT INTO `users` VALUES (3,'sandrasmith','evelyn66@example.com','hey',350,'2025-01-07 19:55:21')

