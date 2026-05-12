-- ============================================================
-- FILE: 13_backup_and_recovery.sql
-- PURPOSE: Full and differential backup strategy for
--          SalfordAirwaysDB with integrity verification.
-- ============================================================

USE master;
GO

-- ------------------------------------------------------------
-- Full database backup (run nightly)
-- WITH CHECKSUM ensures the backup file itself is verifiable.
-- ------------------------------------------------------------

BACKUP DATABASE SalfordAirwaysDB
TO DISK = 'C:\Backups\SalfordAirwaysDB_Full.bak'
WITH
    CHECKSUM,
    COMPRESSION,
    DESCRIPTION = 'SalfordAirwaysDB nightly full backup',
    NAME = 'SalfordAirwaysDB-Full';
GO

-- ------------------------------------------------------------
-- Differential backup (run hourly between full backups)
-- Only pages changed since the last full backup are saved,
-- reducing backup time and storage requirements.
-- ------------------------------------------------------------

BACKUP DATABASE SalfordAirwaysDB
TO DISK = 'C:\Backups\SalfordAirwaysDB_Diff.bak'
WITH
    DIFFERENTIAL,
    CHECKSUM,
    COMPRESSION,
    DESCRIPTION = 'SalfordAirwaysDB hourly differential backup',
    NAME = 'SalfordAirwaysDB-Diff';
GO

-- ------------------------------------------------------------
-- Verify backup integrity without restoring
-- ------------------------------------------------------------

RESTORE VERIFYONLY
FROM DISK = 'C:\Backups\SalfordAirwaysDB_Full.bak'
WITH CHECKSUM;
GO

-- ------------------------------------------------------------
-- Restore from full backup (disaster recovery)
-- WITH REPLACE overwrites an existing database.
-- WITH NORECOVERY leaves the database in a restoring state
-- so a differential or log backup can be applied next.
-- ------------------------------------------------------------

/*
RESTORE DATABASE SalfordAirwaysDB
FROM DISK = 'C:\Backups\SalfordAirwaysDB_Full.bak'
WITH
    REPLACE,
    CHECKSUM,
    NORECOVERY;

-- Then apply the most recent differential backup:
RESTORE DATABASE SalfordAirwaysDB
FROM DISK = 'C:\Backups\SalfordAirwaysDB_Diff.bak'
WITH
    CHECKSUM,
    RECOVERY;
*/
GO
