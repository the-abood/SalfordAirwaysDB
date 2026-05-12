-- ============================================================
-- FILE: 04_seed_data.sql
-- PURPOSE: Populate all tables with representative test data
-- ============================================================

USE SalfordAirwaysDB;
GO

-- ------------------------------------------------------------
-- Passengers (9 records — covers various ages, meals, and
-- emergency contact scenarios including NULLs)
-- ------------------------------------------------------------
INSERT INTO SalfordAirways.Passenger VALUES
(1, 'Abdullah', 'Jawaid',  20037, 'abdullah.jawaid@gmail.com',  'Vegetarian',     '1970-10-10', 1234567891, 'Fazal',  'Brother'),
(2, 'Bilal',    'Jawaid',  20060, 'bilal.arshad@gmail.com',     'Non-Vegetarian', '1970-01-10', 1234567892, 'Haris',  'Brother'),
(3, 'Nasir',    'Amjad',   20062, 'nasir.amjad@gmail.com',      'Vegetarian',     '2020-11-02', 1234567893, 'Zara',   'Sister'),
(4, 'Ahmad',    'Faraz',   20032, 'ahmad.faraz@gmail.com',      'Non-Vegetarian', '2001-12-12', 1234567894, 'Ayaz',   'Friend'),
(5, 'Ayesha',   'Aman',    18068, 'ayesha.aman@gmail.com',      'Vegetarian',     '2012-03-04', 1234567895, 'Abdu',   'Friend'),
(6, 'Amna',     'Mir',     18007, 'amna.mir@gmail.com',         'Non-Vegetarian', '2002-09-30', 1234567896, 'Hooria', 'Mother'),
(7, 'Aliyan',   'Butt',    18023, 'aliyan.butt@gmail.com',      'Vegetarian',     '2000-11-12', 1234567897, 'Ayaz',   'Father'),
(8, 'Jassim',   'Omar',    29001, 'jassim.omar@gmail.com',      'Vegetarian',     '2000-11-12', 1234567898, 'Omar',   'Father'),
(9, 'Zara',     'Amjad',   17001, 'zara.amjad@gmail.com',       'Vegetarian',     '1997-06-05', 1234567899, 'Amjad',  'Father');
GO

-- ------------------------------------------------------------
-- Flights (5 records)
-- ------------------------------------------------------------
INSERT INTO SalfordAirways.Flight VALUES
(21, 111, 'FL1', '2025-04-25 08:00', '2025-04-25 12:00', 'London',   'New York'),
(22, 112, 'FL2', '2025-04-26 14:00', '2025-04-26 21:00', 'Nigeria',  'Dubai'),
(23, 113, 'FL3', '2025-04-27 05:00', '2025-04-27 09:30', 'Pakistan', 'Qatar'),
(24, 115, 'FL4', '2025-04-28 23:00', '2025-04-29 04:00', 'Italy',    'Germany'),
(25, 117, 'FL5', '2025-04-29 02:00', '2025-04-29 06:00', 'Poland',   'Greece');
GO

-- ------------------------------------------------------------
-- Employees (5 records — 1 Supervisor, 4 Staff)
-- ------------------------------------------------------------
INSERT INTO SalfordAirways.Employee VALUES
(11, 21, 'Surbhi',    'Khan',      'surbhi.khan@salford-airways.com',      25001, 'surbhi_khan',      'StrongPassword12345#', 'Ticketing Supervisor'),
(12, 22, 'M. Hammad', 'Saleem',    'hammad.saleem@salford-airways.com',    25002, 'hammad_saleem',    'StrongPassword12345#', 'Ticketing Staff'),
(13, 23, 'Azadeh',    'Mohammadi', 'azadeh.mohammadi@salford-airways.com', 25003, 'azadeh_mohammadi', 'StrongPassword12345#', 'Ticketing Staff'),
(14, 24, 'Mo',        'Saraee',    'mo.saraee@salford-airways.com',        25004, 'mo_saraee',        'StrongPassword12345#', 'Ticketing Staff'),
(15, 25, 'Aaron',     'David',     'aaron.david@salford-airways.com',      25005, 'aaron_david',      'StrongPassword12345#', 'Ticketing Staff');
GO

-- ------------------------------------------------------------
-- Reservations (9 records)
-- ------------------------------------------------------------
INSERT INTO SalfordAirways.Reservation VALUES
(211, 1, 21, 'Confirmed', '2025-04-16'),
(212, 2, 22, 'Confirmed', '2025-04-16'),
(213, 3, 23, 'Confirmed', '2025-04-16'),
(214, 4, 21, 'Confirmed', '2025-04-16'),
(215, 5, 24, 'Confirmed', '2025-04-16'),
(216, 6, 22, 'Pending',   '2025-04-15'),
(217, 7, 25, 'Confirmed', '2025-04-16'),
(218, 8, 21, 'Confirmed', '2025-04-16'),
(219, 9, 23, 'Confirmed', '2025-04-16');
GO

-- ------------------------------------------------------------
-- Tickets (8 records)
-- Passenger 6 (Amna Mir) has no ticket yet — used to test
-- the no-show passengers view.
-- ------------------------------------------------------------
INSERT INTO SalfordAirways.Ticket VALUES
(111, 1, 21, 211, '2025-04-25', '06:00', 1000.00, 'E11', 'Business'),
(112, 2, 22, 212, '2025-04-26', '12:00', 1100.00, 'A12', 'Economy'),
(113, 3, 23, 213, '2025-04-27', '03:00', 1200.00, 'E15', 'Business'),
(115, 5, 24, 215, '2025-04-28', '12:00', 1100.00, 'B21', 'Economy'),
(117, 7, 25, 217, '2025-04-29', '21:00',  900.00, 'B22', 'Economy'),
(118, 8, 21, 218, '2025-04-25', '12:00',  700.00, 'A12', 'Economy'),
(119, 9, 23, 219, '2025-04-27', '03:00', 1200.00, 'E14', 'Business'),
(120, 4, 21, 214, '2025-04-25', '16:41', 1000.00, 'A17', 'Economy');
GO

-- ------------------------------------------------------------
-- Baggage (8 records)
-- ------------------------------------------------------------
INSERT INTO SalfordAirways.Baggage VALUES
(311, 1, 15.00, 'CheckedIn', 100.00),
(312, 2, 12.50, 'Loaded',    100.00),
(313, 3, 10.00, 'CheckedIn', 100.00),
(314, 5, 20.50, 'Loaded',    100.00),
(315, 7, 20.00, 'CheckedIn', 100.00),
(316, 8, 20.00, 'CheckedIn', 100.00),
(317, 9, 20.00, 'CheckedIn', 100.00),
(318, 4, 15.00, 'CheckedIn', 100.00);
GO

-- ------------------------------------------------------------
-- TicketingSystem (8 records)
-- TotalFare is NULL here; trg_CalculateTotalFare populates it.
-- ------------------------------------------------------------
INSERT INTO SalfordAirways.TicketingSystem VALUES
(411, 1, 11, 21, 111, 311, 'EBD123', 'Y', 'N', 'Y', NULL, 'Abdullah Jawaid', 'Credit Card'),
(412, 2, 12, 22, 112, 312, 'EBD456', 'N', 'Y', 'N', NULL, 'Bilal Jawaid',    'Debit Card'),
(413, 3, 13, 23, 113, 313, 'EBD789', 'Y', 'N', 'Y', NULL, 'Nasir Amjad',     'Credit Card'),
(414, 5, 14, 24, 115, 314, 'EBD012', 'N', 'Y', 'N', NULL, 'Ayesha Aman',     'Debit Card'),
(415, 7, 15, 25, 117, 315, 'EBD345', 'Y', 'N', 'Y', NULL, 'Aliyan Butt',     'Credit Card'),
(416, 8, 11, 21, 118, 316, 'EBD678', 'N', 'N', 'N', NULL, 'Jassim Omar',     'Debit Card'),
(417, 9, 13, 23, 119, 317, 'EBD901', 'Y', 'N', 'Y', NULL, 'Zara Amjad',      'Credit Card'),
(418, 4, 11, 21, 120, 318, 'EBD234', 'Y', 'Y', 'Y', NULL, 'Ahmad Faraz',     'Debit Card');
GO
