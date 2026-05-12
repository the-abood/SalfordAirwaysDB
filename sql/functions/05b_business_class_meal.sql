-- ============================================================
-- FILE: 05b_business_class_meal.sql
-- PURPOSE: Inline table-valued function returning all business
--          class passengers with meal requirements whose
--          reservation date matches the current system date.
-- ============================================================

USE SalfordAirwaysDB;
GO

CREATE FUNCTION dbo.GetBusinessClassPassengersWithMeal()
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.PassengerID,
        p.FirstName,
        p.LastName,
        p.Meal,
        r.ReservationID,
        r.ReservationDate,
        f.FlightID,
        f.FlightNumber,
        f.Origin,
        f.Destination,
        t.Class,
        t.SeatNumber
    FROM
        SalfordAirways.Passenger p
    JOIN
        SalfordAirways.Reservation r ON p.PassengerID = r.PassengerID
    JOIN
        SalfordAirways.Ticket t ON r.ReservationID = t.ReservationID
    JOIN
        SalfordAirways.Flight f ON t.FlightID = f.FlightID
    WHERE
        t.Class = 'Business'
        AND CONVERT(DATE, r.ReservationDate) = CONVERT(DATE, GETDATE())
);
GO

-- ------------------------------------------------------------
-- Example usage:
--   SELECT * FROM dbo.GetBusinessClassPassengersWithMeal();
-- ------------------------------------------------------------
