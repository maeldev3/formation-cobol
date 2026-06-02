-- Tables
CREATE TABLE departments (
    department_id INTEGER PRIMARY KEY AUTOINCREMENT,
    department_name TEXT NOT NULL UNIQUE
);

CREATE TABLE positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_name TEXT NOT NULL,
    base_salary DECIMAL(12,2) NOT NULL
);

CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    department_id INTEGER NOT NULL,
    position_id INTEGER NOT NULL,
    hire_date TEXT DEFAULT (date('now')),
    FOREIGN KEY(department_id) REFERENCES departments(department_id),
    FOREIGN KEY(position_id) REFERENCES positions(position_id)
);

CREATE TABLE attendance (
    attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    date TEXT DEFAULT (date('now')),
    check_in TEXT,
    check_out TEXT,
    status TEXT DEFAULT 'PRESENT',
    FOREIGN KEY(employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE leaves (
    leave_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    start_date TEXT,
    end_date TEXT,
    reason TEXT,
    status TEXT DEFAULT 'PENDING',
    FOREIGN KEY(employee_id) REFERENCES employees(employee_id)
);


-- Insertions valides
INSERT INTO departments (department_name) VALUES ('Informatique');
INSERT INTO departments (department_name) VALUES ('Ressources Humaines');

INSERT INTO positions (position_name, base_salary) VALUES ('Développeur COBOL', 1500000);
INSERT INTO positions (position_name, base_salary) VALUES ('Analyste', 1200000);
INSERT INTO positions (position_name, base_salary) VALUES ('Chef de projet', 2000000);

INSERT INTO employees (first_name, last_name, department_id, position_id)
VALUES ('Jean', 'Rakoto', 1, 1);

INSERT INTO employees (first_name, last_name, department_id, position_id)
VALUES ('Marie', 'Ravelo', 1, 2);

INSERT INTO employees (first_name, last_name, department_id, position_id)
VALUES ('Paul', 'Andria', 2, 3);



INSERT INTO attendance (employee_id, check_in, status)
VALUES (1, '08:00', 'PRESENT');

INSERT INTO leaves (employee_id, start_date, end_date, reason)
VALUES (1, '2026-06-10', '2026-06-15', 'Vacances');

