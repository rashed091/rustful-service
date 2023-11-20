-- Your SQL goes here
CREATE TABLE users (
  id uuid PRIMARY KEY default gen_random_uuid(),
  name TEXT NOT NULL,
  age INT NOT NULL
)
