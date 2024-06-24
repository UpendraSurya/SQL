-- Create the database
CREATE DATABASE Day;

-- Use the database
USE Day;

-- Create a sample table for employees
CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Salary DECIMAL(10, 2)
);

-- Create another sample table for departments
CREATE TABLE Departments (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName VARCHAR(50)
);

-- Insert sample data into Employees
INSERT INTO Employees (FirstName, LastName, Salary) VALUES
('John', 'Doe', 60000.00),
('Jane', 'Smith', 70000.00);

-- Insert sample data into Departments
INSERT INTO Departments (DepartmentName) VALUES
('HR'),
('Engineering');

-- Start a transaction
START TRANSACTION;

-- Update employee salary
UPDATE Employees SET Salary = 75000.00 WHERE FirstName = 'John';

-- Create a savepoint
SAVEPOINT BeforeSalaryUpdate;

-- Another update
UPDATE Employees SET Salary = 80000.00 WHERE FirstName = 'Jane';

-- Rollback to the savepoint
ROLLBACK TO BeforeSalaryUpdate;

-- Commit the transaction
COMMIT;

-- Create a trigger to log changes to employee salaries
CREATE TABLE SalaryChanges (
    ChangeID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT,
    OldSalary DECIMAL(10, 2),
    NewSalary DECIMAL(10, 2),
    ChangeDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER BeforeSalaryUpdate
BEFORE UPDATE ON Employees
FOR EACH ROW
BEGIN
    IF OLD.Salary <> NEW.Salary THEN
        INSERT INTO SalaryChanges (EmployeeID, OldSalary, NewSalary)
        VALUES (OLD.EmployeeID, OLD.Salary, NEW.Salary);
    END IF;
END $$

DELIMITER ;

-- Update an employee's salary to see the trigger in action
UPDATE Employees SET Salary = 85000.00 WHERE FirstName = 'John';

-- Create a view to show employees with their department names
CREATE VIEW EmployeeDetails AS
SELECT e.EmployeeID, e.FirstName, e.LastName, e.Salary, d.DepartmentName
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID;

-- Query the view
SELECT * FROM EmployeeDetails;

-- Start a new transaction
START TRANSACTION;

-- Insert a new employee
INSERT INTO Employees (FirstName, LastName, Salary) VALUES ('Alice', 'Johnson', 65000.00);

-- Insert a new department
INSERT INTO Departments (DepartmentName) VALUES ('Marketing');

-- Commit the transaction
COMMIT;

-- Start another transaction
START TRANSACTION;

-- Insert another employee
INSERT INTO Employees (FirstName, LastName, Salary) VALUES ('Bob', 'Williams', 60000.00);

-- Oops, we made a mistake, let's rollback
ROLLBACK;

-- Check the tables to see that Bob was not inserted
SELECT * FROM Employees;
SELECT * FROM Departments;

-- Create a log table for new employees
CREATE TABLE EmployeeLogs (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT,
    Action VARCHAR(50),
    ActionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER AfterEmployeeInsert
AFTER INSERT ON Employees
FOR EACH ROW
BEGIN
    INSERT INTO EmployeeLogs (EmployeeID, Action) VALUES (NEW.EmployeeID, 'INSERT');
END $$

DELIMITER ;

-- Insert a new employee to see the trigger in action
INSERT INTO Employees (FirstName, LastName, Salary) VALUES ('Charlie', 'Brown', 55000.00);

-- Check the EmployeeLogs table
SELECT * FROM EmployeeLogs;

-- Create a trigger to log deleted employees
DELIMITER $$

CREATE TRIGGER AfterEmployeeDelete
AFTER DELETE ON Employees
FOR EACH ROW
BEGIN
    INSERT INTO EmployeeLogs (EmployeeID, Action) VALUES (OLD.EmployeeID, 'DELETE');
END $$

DELIMITER ;

-- Delete an employee to see the trigger in action
DELETE FROM Employees WHERE FirstName = 'Alice';

-- Check the EmployeeLogs table
SELECT * FROM EmployeeLogs;


