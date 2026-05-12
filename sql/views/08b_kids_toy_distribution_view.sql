-- ============================================================
-- FILE: 08b_kids_toy_distribution_view.sql
-- PURPOSE: Identify confirmed passengers under the age of 14
--          for cabin crew toy/gift distribution.
--          Age is calculated dynamically using GETDATE() so
--          the view stays accurate without manual updates.
-- ============================================================

USE SalfordAirwaysDB;
GO

CREATE VIEW dbo.KidsForToyDistribution AS
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
        END                         AS Age,
    r.FlightID,
    f.FlightNumber,
    f.Origin,
    f.Destination,
    f.DepartureTime
FROM SalfordAirways.Passenger       p
INNER JOIN SalfordAirways.Reservation r ON p.PassengerID = r.PassengerID
INNER JOIN SalfordAirways.Flight      f ON r.FlightID    = f.FlightID
WHERE
    DATEDIFF(YEAR, p.DoB, GETDATE()) < 14
    AND r.Status = 'Confirmed';
GO

-- ------------------------------------------------------------
-- Example usage:
--   SELECT * FROM dbo.KidsForToyDistribution;
--   SELECT * FROM dbo.KidsForToyDistribution
--   WHERE FlightNumber = 'FL3' ORDER BY Age;
-- ------------------------------------------------------------
