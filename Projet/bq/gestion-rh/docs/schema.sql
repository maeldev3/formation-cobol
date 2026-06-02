CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    login TEXT NOT NULL UNIQUE,
    pin TEXT NOT NULL
);

INSERT INTO users(login,pin)
VALUES('admin','1234');

CREATE TABLE departments (
    department_id INTEGER PRIMARY KEY AUTOINCREMENT,
    department_name TEXT NOT NULL UNIQUE
);

CREATE TABLE positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_name TEXT NOT NULL,
    base_salary DECIMAL(12,2) NOT NULL
);

INSERT INTO positions
(position_name, base_salary)
VALUES
('Développeur COBOL',1500000);