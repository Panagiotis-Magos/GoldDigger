-- Table: goals
CREATE TABLE IF NOT EXISTS goals (
  goal_id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  target INTEGER NOT NULL DEFAULT 0,
  reward INTEGER DEFAULT 0
);

-- Table: goaltask
CREATE TABLE IF NOT EXISTS goaltask (
  goal_task_id INTEGER PRIMARY KEY AUTOINCREMENT,
  goal_id INTEGER NOT NULL,
  task_id INTEGER NOT NULL,
  FOREIGN KEY (goal_id) REFERENCES goals (goal_id) ON DELETE CASCADE,
  FOREIGN KEY (task_id) REFERENCES tasks (task_id) ON DELETE CASCADE
);

-- Table: items
CREATE TABLE IF NOT EXISTS items (
  item_id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  type TEXT DEFAULT NULL,
  price INTEGER NOT NULL,
  photo_id INTEGER NOT NULL,
  FOREIGN KEY (photo_id) REFERENCES photos (photo_id) ON DELETE CASCADE
);

-- Table: photos
CREATE TABLE IF NOT EXISTS photos (
  photo_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  task_id INTEGER,
  url TEXT NOT NULL,
  uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
  FOREIGN KEY (task_id) REFERENCES tasks (task_id) ON DELETE CASCADE
);

-- Table: tasks
CREATE TABLE IF NOT EXISTS tasks (
  task_id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  gold_reward INTEGER DEFAULT NULL
);

-- Table: usergoals
CREATE TABLE IF NOT EXISTS usergoals (
  user_id INTEGER NOT NULL,
  goal_id INTEGER NOT NULL,
  progress INTEGER DEFAULT 0,
  is_completed INTEGER DEFAULT 0,
  completed_at DATETIME DEFAULT NULL,
  PRIMARY KEY (user_id, goal_id),
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
  FOREIGN KEY (goal_id) REFERENCES goals (goal_id) ON DELETE CASCADE
);

-- Table: useritems
CREATE TABLE IF NOT EXISTS useritems (
  user_id INTEGER NOT NULL,
  item_id INTEGER NOT NULL,
  is_equipped INTEGER DEFAULT 0,
  PRIMARY KEY (user_id, item_id),
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES items (item_id) ON DELETE CASCADE
);

-- Table: users
CREATE TABLE IF NOT EXISTS users (
  user_id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  gold INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table: usertasks
CREATE TABLE IF NOT EXISTS usertasks (
  user_id INTEGER NOT NULL,
  task_id INTEGER NOT NULL,
  is_completed INTEGER DEFAULT 0,
  completed_at DATETIME DEFAULT NULL,
  PRIMARY KEY (user_id, task_id),
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
  FOREIGN KEY (task_id) REFERENCES tasks (task_id) ON DELETE CASCADE
);

-- Trigger: Update Goal Progress After UserTask Completion
CREATE TRIGGER IF NOT EXISTS task_completed_update_progress
AFTER UPDATE ON usertasks
FOR EACH ROW
WHEN NEW.is_completed = 1 AND OLD.is_completed = 0
BEGIN
  UPDATE usergoals
  SET progress = progress + 1
  WHERE user_id = NEW.user_id
    AND goal_id IN (
      SELECT goal_id
      FROM goaltask
      WHERE task_id = NEW.task_id
    );
END;

-- Trigger: Update Goal Progress When Task is Uncompleted
CREATE TRIGGER IF NOT EXISTS task_incomplete
AFTER UPDATE ON usertasks
FOR EACH ROW
WHEN NEW.is_completed = 0 AND OLD.is_completed = 1
BEGIN
  UPDATE usergoals
  SET progress = progress - 1
  WHERE user_id = NEW.user_id
    AND goal_id IN (
      SELECT goal_id
      FROM goaltask
      WHERE task_id = NEW.task_id
    );
END;

-- Trigger: Update User Gold After Completing a Task
CREATE TRIGGER IF NOT EXISTS update_gold
AFTER UPDATE ON usertasks
FOR EACH ROW
WHEN NEW.is_completed = 1 AND OLD.is_completed = 0
BEGIN
  -- Add task reward to user's gold
  UPDATE users
  SET gold = gold + (
    SELECT gold_reward
    FROM tasks
    WHERE task_id = NEW.task_id
  )
  WHERE user_id = NEW.user_id;
END;