-- ============================================================
-- FILE: 05d_update_passenger.sql
-- PURPOSE: Update passenger details — only permitted for
--          passengers who have made at least one prior booking.
--          NULL parameters preserve existing values (ISNULL).
-- ============================================================

USE SalfordAirwaysDB;
GO

CREATE PROCEDURE dbo.UpdateInfoPassenger
    @PassengerID                INT,
    @FirstName                  NVARCHAR(50)    = NULL,
    @LastName                   NVARCHAR(50)    = NULL,
    @Email                      NVARCHAR(100)   = NULL,
    @Meal                       NVARCHAR(20)    = NULL,
    @DoB                        DATE            = NULL,
    @PassengerContactNumber     BIGINT          = NULL,
    @EmergencyContactNumber     BIGINT          = NULL,
    @EmergencyContactName       NVARCHAR(50)    = NULL,
    @RelationshipWithContact    NVARCHAR(15)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Guard: only update passengers who have a prior booking
    IF NOT EXISTS (
        SELECT 1 FROM SalfordAirways.Reservation
        WHERE PassengerID = @PassengerID
    )
    BEGIN
        PRINT 'Passenger has no prior bookings. Update aborted.';
        RETURN;
    END;

    UPDATE SalfordAirways.Passenger
    SET
        FirstName               = ISNULL(@FirstName,               FirstName),
        LastName                = ISNULL(@LastName,                LastName),
        Email                   = ISNULL(@Email,                   Email),
        Meal                    = ISNULL(@Meal,                    Meal),
        DoB                     = ISNULL(@DoB,                     DoB),
        PassengerContactNumber  = ISNULL(@PassengerContactNumber,  PassengerContactNumber),
        EmergencyContactNumber  = ISNULL(@EmergencyContactNumber,  EmergencyContactNumber),
        EmergencyContactName    = ISNULL(@EmergencyContactName,    EmergencyContactName),
        RelationshipWithContact = ISNULL(@RelationshipWithContact, RelationshipWithContact)
    WHERE PassengerID = @PassengerID;

    PRINT 'Passenger details updated successfully.';
END;
GO

-- ------------------------------------------------------------
-- Example usage (passenger with a booking):
--
-- EXEC dbo.UpdateInfoPassenger
--     @PassengerID           = 6,
--     @FirstName             = 'Amna',
--     @LastName              = 'Mir',
--     @Email                 = 'amna.mir.updated@gmail.com',
--     @Meal                  = 'Vegetarian',
--     @DoB                   = '2002-09-30',
--     @PassengerContactNumber= 18007,
--     @EmergencyContactNumber= 1234567896,
--     @EmergencyContactName  = 'Hooria',
--     @RelationshipWithContact = 'Sister';
--
-- Example usage (passenger with NO booking — aborts):
--
-- EXEC dbo.UpdateInfoPassenger
--     @PassengerID = 99,
--     @FirstName   = 'Ghost',
--     @LastName    = 'User';
-- ------------------------------------------------------------
