-- ============================================================
-- FILE: 11_pending_and_over40_query.sql
-- PURPOSE: Identify passengers with Pending reservations
--          AND/OR passengers aged over 40 years.
-- ============================================================

USE SalfordAirwaysDB;
GO

SELECT
    p.PassengerID,
    p.FirstName,
    p.LastName,
    p.DoB,
    DATEDIFF(YEAR, p.DoB, GETDATE()) -
        CASE
            WHEN (MONTH(GETDATE()) < MONTH(p.DoB))
              OR (MONTH(GETDATE()) = MONTH(p.DoB) AND DAY(GETDATE()) < DAY(p.DoB))
            THEN 1
            ELSE 0
        END                             AS Age,
    r.ReservationID,
    r.Status                            AS ReservationStatus,
    f.FlightNumber,
    f.Origin,
    f.Destination
FROM
    SalfordAirways.Passenger p
JOIN
    SalfordAirways.Reservation r ON p.PassengerID = r.PassengerID
JOIN
    SalfordAirways.Flight f      ON r.FlightID    = f.FlightID
WHERE
    r.Status = 'Pending'
    OR DATEDIFF(YEAR, p.DoB, GETDATE()) > 40
ORDER BY
    Age DESC,
    r.Status;
GO
