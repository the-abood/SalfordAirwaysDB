# ✈️ SalfordAirways — E-Boarding Ticketing Database System

A production-style **Microsoft SQL Server** database system for managing e-boarding number issuance at Salford Airways. Covers passenger management, flight reservations, ticket issuance, baggage tracking, and employee access control — all normalised to **Third Normal Form (3NF)**.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Database Design](#database-design)
- [Schema & Tables](#schema--tables)
- [Features & Examples](#features--examples)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Security Model](#security-model)
- [Backup & Recovery](#backup--recovery)

---

## Project Overview

Salford Airways required a new database backend for their airport ticketing system. The system handles:

- **Employee authentication** (Ticketing Staff vs Ticketing Supervisor roles)
- **Passenger Reservations** — PNR lookup, booking status tracking
- **Ticket Issuance** — e-boarding number generation, seat assignment, class selection
- **Additional Services** — extra baggage (£100/kg), upgraded meal (£20/person), preferred seat (£30/person)
- **Baggage Tracking** — check-in and loading status per flight
- **Revenue Reporting** — per-employee, per-flight revenue views

---

## Database Design

The schema is normalised to **3NF** — every non-key attribute depends on the whole key and nothing but the key.

### Entity Relationship Overview

```
Passenger ──< Reservation >── Flight
Passenger ──< Ticket >────── Flight
Ticket ──────────────────── Reservation
Passenger ──< Baggage
Employee ──< TicketingSystem >── Flight
TicketingSystem >── Ticket
TicketingSystem >── Baggage
```

### Normalisation Walkthrough

| Stage | Action |
|-------|--------|
| **1NF** | All attributes are atomic; no repeating groups. Each table has a defined primary key. |
| **2NF** | Removed partial dependencies — e.g. passenger meal preference belongs to `Passenger`, not `Ticket`. |
| **3NF** | Removed transitive dependencies — flight details removed from `Employee`; baggage fee kept in `Baggage` rather than computed in `TicketingSystem`. |

---

## Schema & Tables

All tables live under the `SalfordAirways` schema.

### `Passenger`
| Column | Type | Constraint | Notes |
|--------|------|-----------|-------|
| PassengerID | INT | PK | Unique passenger identifier |
| FirstName | NVARCHAR(50) | NOT NULL | |
| LastName | NVARCHAR(50) | NOT NULL | |
| PassengerContactNumber | BIGINT | NOT NULL | BIGINT accommodates international numbers |
| Email | NVARCHAR(100) | NOT NULL | |
| Meal | NVARCHAR(20) | CHECK (Vegetarian / Non-Vegetarian) | Dietary preference |
| DoB | DATE | NOT NULL | Used for age calculations |
| EmergencyContactNumber | BIGINT | NULL | Optional |
| EmergencyContactName | NVARCHAR(50) | NULL | Optional |
| RelationshipWithContact | NVARCHAR(15) | NULL | Optional |

### `Employee`
| Column | Type | Constraint | Notes |
|--------|------|-----------|-------|
| EmployeeID | INT | PK | |
| FlightID | INT | FK → Flight | Assigned flight |
| FirstName / LastName | NVARCHAR(50) | NOT NULL | |
| Email | NVARCHAR(100) | | Staff email |
| EmployeeContactNumber | BIGINT | NOT NULL | |
| Username | NVARCHAR(50) | | Login credential |
| Password | NVARCHAR(50) | | Stored hashed in production |
| Role | NVARCHAR(20) | CHECK (Ticketing Staff / Ticketing Supervisor) | Controls permissions |

### `Flight`
| Column | Type | Constraint | Notes |
|--------|------|-----------|-------|
| FlightID | INT | PK | |
| TicketID | INT | FK → Ticket | |
| FlightNumber | NVARCHAR(10) | | e.g. FL1 |
| DepartureTime | DATETIME | | |
| ArrivalTime | DATETIME | | |
| Origin / Destination | NVARCHAR(50) | | |

### `Reservation`
| Column | Type | Constraint | Notes |
|--------|------|-----------|-------|
| ReservationID | INT | PK | |
| PassengerID | INT | FK → Passenger | |
| FlightID | INT | FK → Flight | |
| Status | NVARCHAR(10) | CHECK (Confirmed / Pending / Cancelled) | |
| ReservationDate | DATE | CHECK (≥ GETDATE()) | Cannot be set in the past |

### `Ticket`
| Column | Type | Constraint | Notes |
|--------|------|-----------|-------|
| TicketID | INT | PK | |
| PassengerID | INT | FK → Passenger | |
| FlightID | INT | FK → Flight | |
| ReservationID | INT | FK → Reservation | |
| IssueDate | DATE | | |
| IssueTime | TIME | | Stored separately for querying flexibility |
| Fare | DECIMAL(10,2) | | Base fare |
| SeatNumber | NVARCHAR(10) | NULL | NULL if no preferred seat available |
| Class | NVARCHAR(20) | CHECK (Business / FirstClass / Economy) | |

### `Baggage`
| Column | Type | Constraint | Notes |
|--------|------|-----------|-------|
| BaggageID | INT | PK | |
| PassengerID | INT | FK → Passenger | |
| Weight | DECIMAL(5,2) | | kg |
| Status | NVARCHAR(10) | CHECK (CheckedIn / Loaded) | |
| BaggageFee | DECIMAL(10,2) | | £100 per additional kg |

### `TicketingSystem`
The central hub linking employees, passengers, flights, tickets, and baggage.

| Column | Type | Constraint | Notes |
|--------|------|-----------|-------|
| TicketingID | INT | PK | |
| PassengerID | INT | FK → Passenger | |
| EmployeeID | INT | FK → Employee | Issuing employee |
| FlightID | INT | FK → Flight | |
| TicketID | INT | FK → Ticket | |
| BaggageID | INT | FK → Baggage | |
| E_BoardingNumber | NVARCHAR(15) | NOT NULL | Generated e-boarding number |
| ExtraBaggage | NVARCHAR(1) | CHECK (Y/N) | +£100 |
| UpgradedMeal | NVARCHAR(1) | CHECK (Y/N) | +£20 |
| PreferredSeat | NVARCHAR(1) | CHECK (Y/N) | +£30 |
| TotalFare | DECIMAL(10,2) | | Auto-calculated by trigger |
| PayeeName | NVARCHAR(100) | | |
| MethodOfPayment | NVARCHAR(50) | | Credit Card / Debit Card etc. |

---

## Features & Examples

The system ships with the following database objects. Each is documented as a working example below.

### 🔍 Example 1 — Search Passengers by Last Name

Stored procedure returning tickets sorted by most recently issued:

```sql
EXEC Search_Tickets_By_Last_Name @LastNameSubstring = 'Jawaid';
```

### 🍽️ Example 2 — Business Class Passengers with Meal Requirements (Today)

Inline table-valued function returning today's business class bookings:

```sql
SELECT * FROM dbo.GetBusinessClassPassengersWithMeal();
```

### 👤 Example 3 — Insert a New Employee

```sql
EXEC dbo.InsertNewEmployee
    @EmployeeID = 16,
    @FlightID = 25,
    @FirstName = 'Harry',
    @LastName = 'Potter',
    @Email = 'harry.potter@salford-airways.com',
    @EmployeeContactNumber = 25006,
    @Username = 'harry_potter',
    @Password = 'StrongPassword12345#',
    @Role = 'Ticketing Staff';
```

### ✏️ Example 4 — Update Passenger Details (Requires Prior Booking)

```sql
EXEC dbo.UpdateInfoPassenger
    @PassengerID = 6,
    @Email = 'amna.updated@gmail.com',
    @Meal = 'Vegetarian';
-- Aborts with message if passenger has no prior booking
```

### 📊 Example 5 — Employee Revenue View

```sql
SELECT * FROM dbo.ViewEmployeeRevenue
WHERE EmployeeID = 11;
```
Returns e-boarding count and total revenue (base fare + baggage fee + add-ons) per employee per flight.

### 🎫 Example 6 — Seat Reservation Trigger

When a ticket is inserted, `trg_SeatReservation` automatically updates the matching reservation status from `Pending` → `Confirmed`. No manual update required.

### 🧳 Example 7 — Checked-In Baggage by Date & Flight

```sql
SELECT * FROM dbo.ViewCheckedInBaggage
WHERE FlightNumber = 'FL1' AND TravelDate = '2025-04-25';
```

### 🚨 Example 8a — No-Show Passengers View

Identifies passengers with a `Pending` reservation who have not yet been issued a ticket — useful for gate staff follow-up:

```sql
SELECT * FROM dbo.NoShowPassengers;
```

### 🧒 Example 8b — Under-14 Passengers (Toy Distribution)

Returns confirmed child passengers (age < 14) per flight for cabin crew gift distribution:

```sql
SELECT * FROM dbo.KidsForToyDistribution;
```

---

## Project Structure

```
SalfordAirwaysDB/
│
├── README.md
│
├── sql/
│   ├── schema/
│   │   ├── 01_create_database.sql
│   │   ├── 02_create_tables.sql
│   │   └── 03_constraints.sql
│   │
│   ├── data/
│   │   └── 04_seed_data.sql
│   │
│   ├── procedures/
│   │   ├── 05a_search_by_lastname.sql
│   │   ├── 05b_business_class_meal.sql
│   │   ├── 05c_insert_employee.sql
│   │   └── 05d_update_passenger.sql
│   │
│   ├── views/
│   │   ├── 06_employee_revenue_view.sql
│   │   ├── 07_checkedin_baggage_view.sql
│   │   ├── 08a_no_show_passengers_view.sql
│   │   └── 08b_kids_toy_distribution_view.sql
│   │
│   ├── triggers/
│   │   ├── 09_seat_reservation_trigger.sql
│   │   └── 10_total_fare_trigger.sql
│   │
│   └── functions/
│       └── 11_business_class_meal_udf.sql
│
└── docs/
    └── design_notes.md
```

---

## Getting Started

### Prerequisites

- Microsoft SQL Server 2019+ (or SQL Server Express)
- SQL Server Management Studio (SSMS) 18+

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/SalfordAirwaysDB.git

# 2. Open SSMS and connect to your SQL Server instance

# 3. Run scripts in order:
#    sql/schema/01_create_database.sql
#    sql/schema/02_create_tables.sql
#    sql/schema/03_constraints.sql
#    sql/data/04_seed_data.sql
#    sql/procedures/*.sql
#    sql/views/*.sql
#    sql/triggers/*.sql
#    sql/functions/*.sql
```

### Restore from Backup

```sql
RESTORE DATABASE SalfordAirwaysDB
FROM DISK = 'path\to\SalfordAirwaysDB.bak'
WITH REPLACE, CHECKSUM;
```

---

## Security Model

| Role | Permissions |
|------|------------|
| **Ticketing Supervisor** | SELECT, INSERT, UPDATE, DELETE on `SalfordAirways` schema |
| **Ticketing Staff** | SELECT only on `SalfordAirways` schema |

Role-based access is enforced at the database user level — see `docs/design_notes.md` for the full security strategy including concurrency and backup guidance.

---

## Backup & Recovery

Backups use `WITH CHECKSUM` to guarantee integrity verification:

```sql
BACKUP DATABASE SalfordAirwaysDB
TO DISK = 'C:\Backups\SalfordAirwaysDB.bak'
WITH CHECKSUM;

-- Verify without restoring:
RESTORE VERIFYONLY
FROM DISK = 'C:\Backups\SalfordAirwaysDB.bak'
WITH CHECKSUM;
```

See `docs/design_notes.md` for the full backup schedule and point-in-time recovery strategy.

---

## License

MIT — free to use, extend, and adapt.
