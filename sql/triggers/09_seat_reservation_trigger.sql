-- ============================================================
-- FILE: 09_seat_reservation_trigger.sql
-- PURPOSE: Automatically update the matching reservation status
--          to 'Confirmed' when a new ticket is issued.
--          Fires AFTER INSERT on the Ticket table.
-- ============================================================

USE SalfordAirwaysDB;
GO

CREATE TRIGGER trg_SeatReservation
ON SalfordAirways.Ticket
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- For every newly inserted ticket, find the matching reservation
    -- (same passenger + same flight) and confirm it if not already confirmed.
    UPDATE r
    SET    r.Status = 'Confirmed'
    FROM   SalfordAirways.Reservation r
    INNER JOIN inserted i
           ON  r.PassengerID = i.PassengerID
           AND r.FlightID    = i.FlightID
    WHERE  r.Status <> 'Confirmed';
END;
GO

-- ------------------------------------------------------------
-- Demonstration:
--
--   -- 1. Add a passenger with a Pending reservation
--   INSERT INTO SalfordAirways.Passenger
--       VALUES (10,'Rumaysa','Ali',20017,'rumaysa.ali@gmail.com',
--               'Vegetarian','2001-02-23',1234567901,'Jiya','Mother');
--
--   INSERT INTO SalfordAirways.Reservation
--       VALUES (220, 10, 25, 'Pending', '2025-04-30');
--
--   SELECT ReservationID, Status FROM SalfordAirways.Reservation
--   WHERE PassengerID = 10;
--   -- Status: Pending
--
--   -- 2. Issue a ticket — trigger fires automatically
--   INSERT INTO SalfordAirways.Ticket
--       VALUES (121, 10, 25, 220, '2025-04-29', '21:00', 900, 'A19', 'Economy');
--
--   SELECT ReservationID, Status FROM SalfordAirways.Reservation
--   WHERE PassengerID = 10;
--   -- Status: Confirmed  ← updated by trigger
-- ------------------------------------------------------------
