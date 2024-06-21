CREATE DATABASE SampleDB;
USE SampleDB;
GO

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName NVARCHAR(50)
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    DepartmentID INT,
    Salary DECIMAL(18, 2),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
INSERT INTO Departments (DepartmentID, DepartmentName) VALUES 
(1, 'Human Resources'),
(2, 'Finance'),
(3, 'IT');

INSERT INTO Employees (EmployeeID, FirstName, LastName, DepartmentID, Salary) VALUES 
(1, 'John', 'Doe', 1, 50000),
(2, 'Jane', 'Smith', 2, 60000),
(3, 'Jim', 'Brown', 3, 70000),
(4, 'Jake', 'Davis', 1, 55000),
(5, 'Julia', 'Johnson', 2, 62000);


CREATE PROCEDURE GetEmployeesByDepartment
    @DepartmentID INT
AS
BEGIN
    SELECT EmployeeID, FirstName, LastName, Salary
    FROM Employees
    WHERE DepartmentID = @DepartmentID;
END;
GO
CREATE FUNCTION GetAnnualSalary (@EmployeeID INT)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @AnnualSalary DECIMAL(18, 2);
    SELECT @AnnualSalary = Salary * 12
    FROM Employees
    WHERE EmployeeID = @EmployeeID;
    RETURN @AnnualSalary;
END;
GO


CREATE PROCEDURE UpdateSalaries
    @PercentageIncrease DECIMAL(5, 2)
AS
BEGIN
    DECLARE @EmployeeID INT;
    DECLARE @CurrentSalary DECIMAL(18, 2);
    DECLARE @NewSalary DECIMAL(18, 2);
    
    DECLARE salary_cursor CURSOR FOR
    SELECT EmployeeID, Salary
    FROM Employees;
    
    OPEN salary_cursor;
    FETCH NEXT FROM salary_cursor INTO @EmployeeID, @CurrentSalary;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @NewSalary = @CurrentSalary * (1 + @PercentageIncrease / 100);
        UPDATE Employees
        SET Salary = @NewSalary
        WHERE EmployeeID = @EmployeeID;
        
        FETCH NEXT FROM salary_cursor INTO @EmployeeID, @CurrentSalary;
    END;
    
    CLOSE salary_cursor;
    DEALLOCATE salary_cursor;
END;
GO


EXEC GetEmployeesByDepartment @DepartmentID = 1;

SELECT dbo.GetAnnualSalary(1) AS AnnualSalary;

EXEC UpdateSalaries @PercentageIncrease = 10;

CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY,
    ProjectName NVARCHAR(100),
    StartDate DATE,
    EndDate DATE
);

CREATE TABLE EmployeeProjects (
    EmployeeID INT,
    ProjectID INT,
    PRIMARY KEY (EmployeeID, ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);
INSERT INTO Projects (ProjectID, ProjectName, StartDate, EndDate) VALUES
(1, 'Project A', '2024-01-01', '2024-06-30'),
(2, 'Project B', '2024-02-01', '2024-12-31');

INSERT INTO EmployeeProjects (EmployeeID, ProjectID) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 1);

CREATE PROCEDURE GetProjectsByEmployee
    @EmployeeID INT
AS
BEGIN
    SELECT P.ProjectID, P.ProjectName, P.StartDate, P.EndDate
    FROM Projects P
    INNER JOIN EmployeeProjects EP ON P.ProjectID = EP.ProjectID
    WHERE EP.EmployeeID = @EmployeeID;
END;
GO


CREATE PROCEDURE AddNewEmployee
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @DepartmentID INT,
    @Salary DECIMAL(18, 2)
AS
BEGIN
    INSERT INTO Employees (FirstName, LastName, DepartmentID, Salary)
    VALUES (@FirstName, @LastName, @DepartmentID, @Salary);
END;
GO
CREATE PROCEDURE GetEmployeesAboveSalary
    @SalaryThreshold DECIMAL(18, 2)
AS
BEGIN
    SELECT EmployeeID, FirstName, LastName, DepartmentID, Salary
    FROM Employees
    WHERE Salary > @SalaryThreshold;
END;
GO
