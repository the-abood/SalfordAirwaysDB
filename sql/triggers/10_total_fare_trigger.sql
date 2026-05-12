-- ============================================================
-- FILE: 10_total_fare_trigger.sql
-- PURPOSE: Automatically calculate and populate TotalFare
--          in TicketingSystem after a new record is inserted.
--          Sums base fare, baggage fee, and optional service
--          charges (extra baggage £100, upgraded meal £20,
--          preferred seat £30).
-- ============================================================

USE SalfordAirwaysDB;
GO

CREATE TRIGGER trg_CalculateTotalFare
ON SalfordAirways.TicketingSystem
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ts
    SET ts.TotalFare =
        ISNULL(t.Fare,        0) +
        ISNULL(b.BaggageFee,  0) +
        CASE WHEN i.ExtraBaggage = 'Y' THEN 100.00 ELSE 0 END +
        CASE WHEN i.UpgradedMeal = 'Y' THEN  20.00 ELSE 0 END +
        CASE WHEN i.PreferredSeat= 'Y' THEN  30.00 ELSE 0 END

    FROM  SalfordAirways.TicketingSystem ts
    INNER JOIN inserted i
           ON  ts.TicketingID = i.TicketingID
    LEFT  JOIN SalfordAirways.Ticket   t ON i.TicketID  = t.TicketID
    LEFT  JOIN SalfordAirways.Baggage  b ON i.BaggageID = b.BaggageID;
END;
GO

-- ------------------------------------------------------------
-- Pricing reference:
--   Extra baggage  → +£100
--   Upgraded meal  → +£20
--   Preferred seat → +£30
--
-- Example: BaseFare £1000 + BaggageFee £100 + ExtraBaggage Y
--          + PreferredSeat Y = £1,230 total
-- ------------------------------------------------------------
