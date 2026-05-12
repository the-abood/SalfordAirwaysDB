-- ============================================================
-- FILE: 02_create_tables.sql
-- PURPOSE: Define all tables in the SalfordAirways schema
-- ============================================================

USE SalfordAirwaysDB;
GO

-- ------------------------------------------------------------
-- Passenger
-- Stores traveller profile and contact details.
-- EmergencyContact fields are optional (NULL allowed).
-- BIGINT used for phone numbers to handle international formats.
-- ------------------------------------------------------------
CREATE TABLE SalfordAirways.Passenger (
    PassengerID             INT             PRIMARY KEY,
    FirstName               NVARCHAR(50)    NOT NULL,
    LastName                NVARCHAR(50)    NOT NULL,
    PassengerContactNumber  BIGINT          NOT NULL,
    Email                   NVARCHAR(100)   NOT NULL,
    Meal                    NVARCHAR(20)    CHECK (Meal IN ('Vegetarian', 'Non-Vegetarian')),
    DoB                     DATE            NOT NULL,
    EmergencyContactNumber  BIGINT          NULL,
    EmergencyContactName    NVARCHAR(50)    NULL,
    RelationshipWithContact NVARCHAR(15)    NULL
);
GO

-- ------------------------------------------------------------
-- Flight
-- Identified by a unique FlightID and flight number.
-- DATETIME used for departure/arrival to store date + time together.
-- ------------------------------------------------------------
CREATE TABLE SalfordAirways.Flight (
    FlightID        INT             PRIMARY KEY,
    TicketID        INT             NOT NULL,
    FlightNumber    NVARCHAR(10),
    DepartureTime   DATETIME,
    ArrivalTime     DATETIME,
    Origin          NVARCHAR(50),
    Destination     NVARCHAR(50)
);
GO

-- ------------------------------------------------------------
-- Employee
-- Staff who operate the ticketing system.
-- Role CHECK constraint enforces the two permitted roles.
-- Password should be stored as a hash in production environments.
-- ------------------------------------------------------------
CREATE TABLE SalfordAirways.Employee (
    EmployeeID              INT             PRIMARY KEY,
    FlightID                INT             NOT NULL,
    FirstName               NVARCHAR(50)    NOT NULL,
    LastName                NVARCHAR(50)    NOT NULL,
    Email                   NVARCHAR(100),
    EmployeeContactNumber   BIGINT          NOT NULL,
    Username                NVARCHAR(50),
    Password                NVARCHAR(50),
    Role                    NVARCHAR(20)    CHECK (Role IN ('Ticketing Staff', 'Ticketing Supervisor'))
);
GO

-- ------------------------------------------------------------
-- Reservation
-- Links a passenger to a flight booking.
-- Status tracks the booking lifecycle.
-- ReservationDate constraint added in 03_constraints.sql.
-- ------------------------------------------------------------
CREATE TABLE SalfordAirways.Reservation (
    ReservationID   INT             PRIMARY KEY,
    PassengerID     INT,
    FlightID        INT,
    Status          NVARCHAR(10)    CHECK (Status IN ('Confirmed', 'Pending', 'Cancelled')),
    ReservationDate DATE,
    FOREIGN KEY (PassengerID) REFERENCES SalfordAirways.Passenger(PassengerID),
    FOREIGN KEY (FlightID)    REFERENCES SalfordAirways.Flight(FlightID)
);
GO

-- ------------------------------------------------------------
-- Ticket
-- Issued ticket linking passenger, flight, and reservation.
-- SeatNumber is NULL when no preferred seat is available.
-- Fare stored as DECIMAL(10,2) for monetary precision.
-- IssueDate and IssueTime stored separately for flexible querying.
-- ------------------------------------------------------------
CREATE TABLE SalfordAirways.Ticket (
    TicketID        INT                 PRIMARY KEY,
    PassengerID     INT,
    FlightID        INT,
    ReservationID   INT,
    IssueDate       DATE,
    IssueTime       TIME,
    Fare            DECIMAL(10,2),
    SeatNumber      NVARCHAR(10)        NULL,
    Class           NVARCHAR(20)        CHECK (Class IN ('Business', 'FirstClass', 'Economy')),
    FOREIGN KEY (ReservationID) REFERENCES SalfordAirways.Reservation(ReservationID),
    FOREIGN KEY (FlightID)      REFERENCES SalfordAirways.Flight(FlightID),
    FOREIGN KEY (PassengerID)   REFERENCES SalfordAirways.Passenger(PassengerID)
);
GO

-- ------------------------------------------------------------
-- Baggage
-- Tracks checked-in and loaded baggage per passenger.
-- Weight in kg; BaggageFee calculated at £100/kg for excess.
-- ------------------------------------------------------------
CREATE TABLE SalfordAirways.Baggage (
    BaggageID   INT             PRIMARY KEY,
    PassengerID INT,
    Weight      DECIMAL(5,2),
    Status      NVARCHAR(10)    CHECK (Status IN ('CheckedIn', 'Loaded')),
    BaggageFee  DECIMAL(10,2),
    FOREIGN KEY (PassengerID) REFERENCES SalfordAirways.Passenger(PassengerID)
);
GO

-- ------------------------------------------------------------
-- TicketingSystem
-- Central hub: records e-boarding number issuance, links all
-- entities, and tracks additional service selections.
-- TotalFare is populated automatically by trg_CalculateTotalFare.
-- ------------------------------------------------------------
CREATE TABLE SalfordAirways.TicketingSystem (
    TicketingID     INT                 PRIMARY KEY,
    PassengerID     INT,
    EmployeeID      INT,
    FlightID        INT,
    TicketID        INT,
    BaggageID       INT,
    E_BoardingNumber NVARCHAR(15)       NOT NULL,
    ExtraBaggage    NVARCHAR(1)         CHECK (ExtraBaggage IN ('Y', 'N')),
    UpgradedMeal    NVARCHAR(1)         CHECK (UpgradedMeal IN ('Y', 'N')),
    PreferredSeat   NVARCHAR(1)         CHECK (PreferredSeat IN ('Y', 'N')),
    TotalFare       DECIMAL(10,2),
    PayeeName       NVARCHAR(100),
    MethodOfPayment NVARCHAR(50),
    FOREIGN KEY (PassengerID) REFERENCES SalfordAirways.Passenger(PassengerID),
    FOREIGN KEY (EmployeeID)  REFERENCES SalfordAirways.Employee(EmployeeID),
    FOREIGN KEY (FlightID)    REFERENCES SalfordAirways.Flight(FlightID),
    FOREIGN KEY (TicketID)    REFERENCES SalfordAirways.Ticket(TicketID),
    FOREIGN KEY (BaggageID)   REFERENCES SalfordAirways.Baggage(BaggageID)
);
GO
