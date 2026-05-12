-- ============================================================
-- FILE: 07_checkedin_baggage_view.sql
-- PURPOSE: View for identifying the total number of checked-in
--          bags per flight per travel date. Filter by flight
--          number and date at query time.
-- ============================================================

USE SalfordAirwaysDB;
GO

CREATE VIEW dbo.ViewCheckedInBaggage AS
SELECT
    f.FlightID,
    f.FlightNumber,
    f.Origin,
    f.Destination,
    CAST(t.IssueDate AS DATE)       AS TravelDate,
    COUNT(b.BaggageID)              AS TotalCheckedInBaggage,
    SUM(b.Weight)                   AS TotalWeightKg,
    SUM(b.BaggageFee)               AS TotalBaggageFees
FROM SalfordAirways.Flight          f
INNER JOIN SalfordAirways.Ticket    t  ON f.FlightID    = t.FlightID
INNER JOIN SalfordAirways.TicketingSystem ts ON t.TicketID = ts.TicketID
INNER JOIN SalfordAirways.Baggage   b  ON ts.BaggageID  = b.BaggageID
WHERE b.Status = 'CheckedIn'
GROUP BY
    f.FlightID,
    f.FlightNumber,
    f.Origin,
    f.Destination,
    CAST(t.IssueDate AS DATE);
GO

-- ------------------------------------------------------------
-- Example usage:
--
--   -- All checked-in baggage across all flights and dates
--   SELECT * FROM dbo.ViewCheckedInBaggage;
--
--   -- Specific flight on a specific date
--   SELECT * FROM dbo.ViewCheckedInBaggage
--   WHERE FlightNumber = 'FL1'
--   AND   TravelDate   = '2025-04-25';
-- ------------------------------------------------------------
