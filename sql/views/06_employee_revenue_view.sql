-- ============================================================
-- FILE: 06_employee_revenue_view.sql
-- PURPOSE: View showing all e-boarding numbers issued by each
--          employee, the flight they relate to, and a full
--          revenue breakdown including base fare, baggage fee,
--          and all additional service charges.
-- ============================================================

USE SalfordAirwaysDB;
GO

CREATE VIEW dbo.ViewEmployeeRevenue AS
SELECT
    e.EmployeeID,
    e.FirstName                                         AS EmployeeFirstName,
    e.LastName                                          AS EmployeeLastName,
    e.Role,
    f.FlightID,
    f.FlightNumber,
    f.Origin,
    f.Destination,

    -- Individual boarding record details
    ts.E_BoardingNumber,
    p.FirstName + ' ' + p.LastName                      AS PassengerName,
    t.Class,
    t.SeatNumber,
    t.Fare                                              AS BaseFare,
    b.BaggageFee,

    -- Additional service flags and costs
    ts.ExtraBaggage,
    CASE WHEN ts.ExtraBaggage = 'Y' THEN 100.00 ELSE 0 END  AS ExtraBaggageCharge,
    ts.UpgradedMeal,
    CASE WHEN ts.UpgradedMeal  = 'Y' THEN  20.00 ELSE 0 END AS UpgradedMealCharge,
    ts.PreferredSeat,
    CASE WHEN ts.PreferredSeat = 'Y' THEN  30.00 ELSE 0 END AS PreferredSeatCharge,

    -- Computed total for this record
    ts.TotalFare,

    -- Aggregated totals per employee per flight
    COUNT(ts.E_BoardingNumber)
        OVER (PARTITION BY e.EmployeeID, f.FlightID)   AS TotalEBoardingsOnFlight,
    SUM(ts.TotalFare)
        OVER (PARTITION BY e.EmployeeID, f.FlightID)   AS TotalRevenueOnFlight

FROM SalfordAirways.TicketingSystem ts
INNER JOIN SalfordAirways.Employee  e ON ts.EmployeeID  = e.EmployeeID
INNER JOIN SalfordAirways.Ticket    t ON ts.TicketID    = t.TicketID
INNER JOIN SalfordAirways.Flight    f ON ts.FlightID    = f.FlightID
INNER JOIN SalfordAirways.Passenger p ON ts.PassengerID = p.PassengerID
LEFT  JOIN SalfordAirways.Baggage   b ON ts.BaggageID   = b.BaggageID;
GO

-- ------------------------------------------------------------
-- Example usage:
--
--   -- All records
--   SELECT * FROM dbo.ViewEmployeeRevenue;
--
--   -- Revenue for a specific employee
--   SELECT * FROM dbo.ViewEmployeeRevenue WHERE EmployeeID = 11;
--
--   -- Revenue on a specific flight
--   SELECT * FROM dbo.ViewEmployeeRevenue WHERE FlightNumber = 'FL1';
-- ------------------------------------------------------------
