# Design Notes — SalfordAirwaysDB

## 1. Normalisation Decisions

### Why 3NF?

The schema is normalised to Third Normal Form to eliminate data anomalies and ensure every attribute depends only on the primary key.

**Key decisions:**

- **Passenger meal preference** lives in `Passenger`, not `Ticket` — it's a property of the person, not the booking. Moving it to `Ticket` would create update anomalies if a passenger's dietary needs change.
- **Baggage fee** lives in `Baggage` — it reflects the actual weight checked in on that trip. The additional service flag `ExtraBaggage` in `TicketingSystem` records whether the service was elected, while `BaggageFee` holds the computed charge.
- **Flight details** were removed from `Employee` — a FK relationship to `Flight` is sufficient. Duplicating origin/destination in `Employee` would violate 3NF (transitive dependency through `FlightID`).
- **SeatNumber is nullable** in `Ticket` — the brief specifies NULL when a preferred seat is unavailable.

---

## 2. Data Integrity

### Constraints Used

| Table | Constraint | Purpose |
|-------|-----------|---------|
| `Passenger.Meal` | CHECK IN ('Vegetarian', 'Non-Vegetarian') | Prevents invalid meal codes |
| `Employee.Role` | CHECK IN ('Ticketing Staff', 'Ticketing Supervisor') | Enforces the two permitted roles |
| `Reservation.Status` | CHECK IN ('Confirmed', 'Pending', 'Cancelled') | Enforces valid lifecycle states |
| `Reservation.ReservationDate` | CHECK (≥ GETDATE()) | Prevents backdated reservations |
| `Ticket.Class` | CHECK IN ('Business', 'FirstClass', 'Economy') | Enforces class values |
| `Baggage.Status` | CHECK IN ('CheckedIn', 'Loaded') | Prevents invalid baggage states |
| `TicketingSystem.E_BoardingNumber` | NOT NULL | Every issued record must have a boarding number |

### Referential Integrity

All foreign keys are explicitly declared. Cascade rules were deliberately omitted — in an airline context, deleting a passenger should not silently cascade to reservations, tickets, and baggage records. Instead, the application layer should handle soft-deletion or archiving.

### Concurrency

In a live ticketing environment, multiple staff members may attempt to issue a ticket for the same seat simultaneously. To address this:

- **Row-level locking**: SQL Server's default READ COMMITTED isolation level prevents dirty reads. For seat assignment, transactions should use `UPDLOCK` hints on the Reservation row:
  ```sql
  BEGIN TRANSACTION;
  SELECT SeatNumber FROM SalfordAirways.Ticket WITH (UPDLOCK, ROWLOCK)
  WHERE FlightID = @FlightID AND SeatNumber = @SeatNumber;
  -- If not taken, proceed with INSERT
  COMMIT;
  ```
- **Unique constraint on SeatNumber + FlightID** in `Ticket` would enforce at the database level that no two passengers share a seat on the same flight — recommended as a future constraint.
- **Optimistic concurrency** (using a `RowVersion` column) can be used in the application layer to detect and retry conflicts without holding locks.

---

## 3. Database Security

### Role-Based Access Control (RBAC)

Two database roles are defined matching the business roles described in the brief:

| Role | Database User | Permissions |
|------|--------------|------------|
| Ticketing Supervisor | SupervisorUser | SELECT, INSERT, UPDATE, DELETE on `SalfordAirways` schema |
| Ticketing Staff | StaffUser | SELECT only on `SalfordAirways` schema |

This means a Ticketing Staff member can look up passenger records and reservations but cannot modify them without supervisor intervention — matching the brief's authentication flow.

### Password Security

Passwords in the `Employee` table are stored as `NVARCHAR(50)` in this development schema. **In production**, passwords must never be stored in plaintext:
- Use application-layer hashing (e.g. bcrypt with a salt) before the value ever reaches the database.
- Alternatively, use SQL Server's `HASHBYTES('SHA2_256', @Password + @Salt)` as a minimum.
- Employee login to the ticketing system should be handled at the application/middleware layer, not by querying the Employee table directly.

### Schema Isolation

All tables are placed under the `SalfordAirways` schema (not `dbo`) so that permissions can be granted at the schema level cleanly. This also prevents accidental name collisions with other system objects.

### Principle of Least Privilege

Views (`ViewEmployeeRevenue`, `ViewCheckedInBaggage`, `NoShowPassengers`, `KidsForToyDistribution`) expose only the columns required for each operational purpose. Staff users should be granted access to views rather than base tables where possible, further limiting their data exposure.

---

## 4. Backup and Recovery

### Strategy

| Backup Type | Frequency | Purpose |
|-------------|-----------|---------|
| Full backup | Nightly (e.g. 02:00) | Complete point-in-time restore baseline |
| Differential backup | Hourly | Captures changes since last full; reduces RTO |

Both backup types use `WITH CHECKSUM` so that the integrity of each backup file can be verified with `RESTORE VERIFYONLY` before a restore is attempted — critical in a time-sensitive disaster scenario.

### Recovery Procedure

1. Verify the backup: `RESTORE VERIFYONLY FROM DISK = '...' WITH CHECKSUM;`
2. Restore the most recent full backup with `NORECOVERY` (leaves DB in restoring state).
3. Apply the most recent differential backup with `RECOVERY` (brings DB online).
4. Validate record counts and spot-check recent transactions.

### Assumptions

- Backups are written to a separate physical volume or network share — storing backups on the same disk as the database defeats the purpose.
- A tested restore runbook exists and is rehearsed at least quarterly.
- The Recovery Point Objective (RPO) is ≤ 1 hour (met by hourly differentials); the Recovery Time Objective (RTO) is ≤ 30 minutes for a restore from the most recent full + differential pair.

---

## 5. Assumptions Made in Design

1. A `FlightID` FK in `Employee` represents the employee's currently assigned flight. An employee is not permanently tied to one flight; this would be expanded to a junction table in a full shift-scheduling system.
2. `BaggageFee` is stored as a flat £100 regardless of weight in the seed data, reflecting the brief's "£100 per kg" charge for *additional* baggage (i.e. excess, not standard allowance).
3. The `TicketingSystem.TotalFare` column is populated automatically by `trg_CalculateTotalFare` and should not be set manually on INSERT.
4. `ReservationDate` constraints have been relaxed in seed data (past dates used for testing purposes); the CHECK constraint applies to new inserts going forward.
5. Emergency contact details on `Passenger` are all optional (NULL) as per the brief.
