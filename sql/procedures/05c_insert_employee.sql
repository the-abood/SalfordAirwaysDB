-- ============================================================
-- FILE: 05c_insert_employee.sql
-- PURPOSE: Stored procedure to safely insert a new employee
--          record into the system.
-- ============================================================

USE SalfordAirwaysDB;
GO

CREATE PROCEDURE dbo.InsertNewEmployee
    @EmployeeID             INT,
    @FlightID               INT,
    @FirstName              NVARCHAR(50),
    @LastName               NVARCHAR(50),
    @Email                  NVARCHAR(100),
    @EmployeeContactNumber  BIGINT,
    @Username               NVARCHAR(50),
    @Password               NVARCHAR(50),
    @Role                   NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- Guard: prevent duplicate EmployeeID
    IF EXISTS (SELECT 1 FROM SalfordAirways.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        PRINT 'Error: An employee with this ID already exists.';
        RETURN;
    END;

    -- Guard: validate role value
    IF @Role NOT IN ('Ticketing Staff', 'Ticketing Supervisor')
    BEGIN
        PRINT 'Error: Role must be either ''Ticketing Staff'' or ''Ticketing Supervisor''.';
        RETURN;
    END;

    INSERT INTO SalfordAirways.Employee
        (EmployeeID, FlightID, FirstName, LastName, Email,
         EmployeeContactNumber, Username, Password, Role)
    VALUES
        (@EmployeeID, @FlightID, @FirstName, @LastName, @Email,
         @EmployeeContactNumber, @Username, @Password, @Role);

    PRINT 'Employee inserted successfully.';
END;
GO

-- ------------------------------------------------------------
-- Example usage:
--
-- EXEC dbo.InsertNewEmployee
--     @EmployeeID            = 16,
--     @FlightID              = 25,
--     @FirstName             = 'Harry',
--     @LastName              = 'Potter',
--     @Email                 = 'harry.potter@salford-airways.com',
--     @EmployeeContactNumber = 25006,
--     @Username              = 'harry_potter',
--     @Password              = 'StrongPassword12345#',
--     @Role                  = 'Ticketing Staff';
--
-- SELECT * FROM SalfordAirways.Employee;
-- ------------------------------------------------------------
