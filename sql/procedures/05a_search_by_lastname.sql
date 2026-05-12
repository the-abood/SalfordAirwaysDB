-- ============================================================
-- FILE: 05a_search_by_lastname.sql
-- PURPOSE: Search passengers by last name substring,
--          returning tickets sorted by most recently issued.
-- ============================================================

USE SalfordAirwaysDB;
GO

CREATE PROCEDURE dbo.Search_Tickets_By_Last_Name
    @LastNameSubstring NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.PassengerID,
        p.FirstName,
        p.LastName,
        t.TicketID,
        t.IssueDate,
        t.IssueTime,
        t.Class,
        t.SeatNumber,
        f.FlightNumber,
        f.Origin,
        f.Destination
    FROM
        SalfordAirways.Passenger p
    JOIN
        SalfordAirways.Ticket t ON p.PassengerID = t.PassengerID
    JOIN
        SalfordAirways.Flight f ON t.FlightID = f.FlightID
    WHERE
        p.LastName LIKE '%' + @LastNameSubstring + '%'
    ORDER BY
        t.IssueDate DESC,
        t.IssueTime DESC;
END;
GO

-- ------------------------------------------------------------
-- Example usage:
--   EXEC dbo.Search_Tickets_By_Last_Name @LastNameSubstring = 'Jawaid';
--   EXEC dbo.Search_Tickets_By_Last_Name @LastNameSubstring = 'Amjad';
-- ------------------------------------------------------------
