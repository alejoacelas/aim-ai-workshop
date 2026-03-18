CREATE TABLE IF NOT EXISTS errors (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL DEFAULT (datetime('now')),
  os TEXT,
  shell TEXT,
  command TEXT,
  stdout_snippet TEXT,
  stderr_snippet TEXT,
  exit_code INTEGER,
  explanation TEXT,
  fix_commands TEXT,
  session_id TEXT
);

CREATE TABLE IF NOT EXISTS installs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL DEFAULT (datetime('now')),
  os TEXT,
  success INTEGER NOT NULL DEFAULT 0,
  step TEXT,
  error TEXT
);
