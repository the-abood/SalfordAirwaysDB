-- ============================================================
-- FILE: 03_constraints.sql
-- PURPOSE: Add additional constraints for data integrity
-- ============================================================

USE SalfordAirwaysDB;
GO

-- ------------------------------------------------------------
-- Reservation date must not be in the past.
-- CAST(GETDATE() AS DATE) strips the time component so that
-- a reservation made today is still considered valid.
-- ------------------------------------------------------------
ALTER TABLE SalfordAirways.Reservation
ADD CONSTRAINT Check_ReservationDate
CHECK (ReservationDate >= CAST(GETDATE() AS DATE));
GO

-- ------------------------------------------------------------
-- Verify constraint is working — shows Valid/Invalid status
-- for existing records (useful during testing).
-- ------------------------------------------------------------
SELECT
    ReservationID,
    PassengerID,
    FlightID,
    ReservationDate,
    Status,
    CASE
        WHEN ReservationDate >= CAST(GETDATE() AS DATE)
        THEN 'Valid Reservation'
        ELSE 'Invalid Reservation'
    END AS ReservationStatus
FROM SalfordAirways.Reservation;
GO
