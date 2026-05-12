-- ============================================================
-- FILE: 12_security_and_permissions.sql
-- PURPOSE: Set up role-based access control (RBAC).
--          Ticketing Supervisors get full DML access.
--          Ticketing Staff get SELECT only.
-- ============================================================

USE SalfordAirwaysDB;
GO

-- ------------------------------------------------------------
-- Step 1: Create SQL Server logins (run against master)
-- ------------------------------------------------------------

-- CREATE LOGIN surbhi_khan    WITH PASSWORD = 'StrongPassword12345#';
-- CREATE LOGIN hammad_saleem  WITH PASSWORD = 'StrongPassword12345#';

-- ------------------------------------------------------------
-- Step 2: Create database users mapped to those logins
-- ------------------------------------------------------------

-- CREATE USER SupervisorUser FOR LOGIN surbhi_khan;
-- CREATE USER StaffUser       FOR LOGIN hammad_saleem;

-- ------------------------------------------------------------
-- Step 3: Grant permissions
--
-- Ticketing Supervisor: full DML on the SalfordAirways schema
-- ------------------------------------------------------------

-- GRANT SELECT, INSERT, UPDATE, DELETE
--     ON SCHEMA::SalfordAirways TO SupervisorUser;

-- ------------------------------------------------------------
-- Ticketing Staff: read-only access
-- ------------------------------------------------------------

-- GRANT SELECT ON SCHEMA::SalfordAirways TO StaffUser;

-- ------------------------------------------------------------
-- Step 4: Test impersonation (verify permissions are correct)
-- ------------------------------------------------------------

-- EXECUTE AS USER = 'SupervisorUser';
-- SELECT * FROM SalfordAirways.Passenger;   -- should succeed
-- INSERT INTO SalfordAirways.Passenger ...  -- should succeed
-- REVERT;

-- EXECUTE AS USER = 'StaffUser';
-- SELECT * FROM SalfordAirways.Passenger;   -- should succeed
-- DELETE FROM SalfordAirways.Passenger ...  -- should FAIL (permission denied)
-- REVERT;

-- ------------------------------------------------------------
-- NOTE: In a production deployment, passwords must be stored
-- as salted hashes (e.g. via HASHBYTES or application-layer
-- hashing). Plaintext passwords shown above are for
-- development/demo purposes only.
-- ------------------------------------------------------------
