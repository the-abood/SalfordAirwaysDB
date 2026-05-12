-- ============================================================
-- FILE: 08a_no_show_passengers_view.sql
-- PURPOSE: Identify passengers with a Pending reservation who
--          have not yet been issued a ticket. Useful for gate
--          staff follow-up and capacity management.
-- ============================================================

USE SalfordAirwaysDB;
GO

CREATE VIEW dbo.NoShowPassengers AS
SELECT
    r.ReservationID,
    p.PassengerID,
    p.FirstName,
    p.LastName,
    p.Email,
    r.FlightID,
    f.FlightNumber,
    f.Origin,
    f.Destination,
    f.DepartureTime,
    r.Status                AS ReservationStatus,
    r.ReservationDate
FROM SalfordAirways.Reservation     r
INNER JOIN SalfordAirways.Passenger p  ON r.PassengerID = p.PassengerID
INNER JOIN SalfordAirways.Flight    f  ON r.FlightID    = f.FlightID
LEFT  JOIN SalfordAirways.TicketingSystem ts
           ON r.PassengerID = ts.PassengerID
           AND r.FlightID   = ts.FlightID
WHERE r.Status = 'Pending'
  AND ts.TicketingID IS NULL;
GO

-- ------------------------------------------------------------
-- Example usage:
--   SELECT * FROM dbo.NoShowPassengers;
--   SELECT * FROM dbo.NoShowPassengers WHERE FlightNumber = 'FL2';
-- ------------------------------------------------------------
