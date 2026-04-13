# 🌾 Agricultural Services Database
### Ministry of Agriculture — Coffee Growers Management System
**Group 2 | Uganda Christian University | Faculty of Engineering, Design and Technology**

---

## 📋 Table of Contents
- [Project Overview](#project-overview)
- [Database Summary](#database-summary)
- [Project Files](#project-files)
- [Database Schema](#database-schema)
- [Getting Started](#getting-started)
- [User Accounts & Credentials](#user-accounts--credentials)
- [Views](#views)
- [Stored Procedures](#stored-procedures)
- [Triggers](#triggers)
- [Backup & Recovery](#backup--recovery)
- [Sample Data](#sample-data)
- [Testing](#testing)
- [Security Notes](#security-notes)

---

## Project Overview

`agric_services_db` is a relational database system built for the **Ministry of Agriculture** to manage coffee growers and related agricultural services in Uganda. The system tracks farmers, extension workers, input distribution, coffee production records, farm visits, and support requests across multiple districts.

The database was developed in two milestones:

| Milestone | Focus | File |
|-----------|-------|------|
| Milestone 3 | Database structure, tables, constraints, and sample data | `agric_db_milestone3.sql` |
| Milestone 4 | Security, views, user roles, stored procedures, triggers, and backup | `agric_db_milestone4.sql` |

**Technology Stack**
- Database: MySQL 8.0
- Tool: VS Code with MySQL extension
- ERD Design: draw.io
- Language: SQL

---

## Database Summary

| Item | Detail |
|------|--------|
| Database Name | `agric_services_db` |
| Character Set | `utf8mb4` |
| Collation | `utf8mb4_unicode_ci` |
| Total Tables | 13 |
| Total Views | 5 |
| Stored Procedures | 5 |
| Triggers | 7 |
| User Accounts | 4 |
| Sample Records | 8 persons, 5 farmers, 2 workers, 1 staff |

---

## Project Files

```
Group 2 Database/
├── agric_db_milestone3.sql     # Database structure + sample data
├── agric_db_milestone4.sql     # Security, automation & backup
├── GROUP 2 EXAM EERD.drawio    # Enhanced Entity Relationship Diagram
├── Group 2 documentation.docx  # Full project documentation report
└── README.md                   # This file
```

---

## Database Schema

The database follows a **supertype/subtype (generalisation)** design pattern where `person` is the supertype and `farmer`, `extension_worker`, and `ministry_staff` are disjoint subtypes.

### Tables

#### Reference / Lookup Tables
| Table | Description |
|-------|-------------|
| `district` | Uganda districts with region classification |
| `location` | Village → sub-county → county → district hierarchy |
| `coffee_variety` | Robusta, Arabica, Clonal varieties |
| `season` | Crop seasons with start and end dates |

#### Person Supertype & Subtypes
| Table | Description |
|-------|-------------|
| `person` | Supertype — stores shared personal details (NIN, phone, email, DOB) |
| `farmer` | Subtype — farm size, land tenure, registration date, status |
| `extension_worker` | Subtype — district, qualification, specialisation |
| `ministry_staff` | Subtype — department, role title, access level |

#### Input Inventory (Overlapping Specialisation)
| Table | Description |
|-------|-------------|
| `input_item` | Supertype — all agricultural inputs (seedlings, fertilisers, tools) |
| `seedling` | Subtype — variety, age in weeks, nursery source |
| `agric_input` | Subtype — manufacturer, active ingredient, safety notes |

#### Transaction / Event Tables
| Table | Description |
|-------|-------------|
| `production_record` | Coffee harvest records per farmer per season |
| `distribution` | Input items distributed to farmers by workers |
| `farm_visit` | Field visits made by extension workers |
| `support_request` | Farmer requests for pest control, soil advice, etc. |

#### System Tables
| Table | Description |
|-------|-------------|
| `audit_production_log` | Auto-generated audit trail for production record changes |
| `farmer_backup` | Point-in-time snapshot of the farmer table |
| `production_record_backup` | Point-in-time snapshot of production records |

### Key Constraints

```sql
-- Unique constraints
uq_person_nin        -- No duplicate National ID Numbers
uq_person_phone      -- No duplicate phone numbers
uq_variety_name      -- No duplicate coffee variety names
uq_prod_record       -- One record per farmer per variety per season

-- Check constraints
chk_phone_len        -- Phone must be at least 10 characters
chk_farm_size        -- Farm size must be greater than 0
chk_stock            -- Stock quantity cannot go below 0
chk_dist_qty         -- Distribution quantity must be greater than 0
chk_season_dates     -- Season end date must be after start date
chk_resolved_date    -- Resolved date cannot be before date raised
```

---

## Getting Started

### Prerequisites
- MySQL Server 8.0 or higher
- VS Code with the MySQL extension installed
- A root MySQL account

### Installation

**Step 1 — Run Milestone 3 (structure and data)**
```sql
-- In VS Code or MySQL terminal, run:
source /path/to/agric_db_milestone3.sql;
```
This will:
- Drop and recreate `agric_services_db`
- Create all 11 base tables with constraints
- Insert all sample data

**Step 2 — Run Milestone 4 (security and automation)**
```sql
source /path/to/agric_db_milestone4.sql;
```
This will:
- Create all 5 views
- Create all 4 user accounts
- Apply all privileges and grants
- Create all 5 stored procedures
- Create all 7 triggers
- Create audit and backup tables

**Step 3 — Verify installation**
```sql
USE agric_services_db;
SHOW TABLES;
SELECT COUNT(*) FROM farmer;   -- should return 5
SELECT COUNT(*) FROM person;   -- should return 8
```

---

## User Accounts & Credentials

> ⚠️ **Important:** Always create a **new separate connection** in VS Code for each user. Do not reuse an existing root connection. Use host `127.0.0.1` with port `3306`.

| User | Password | Role | Access Level |
|------|----------|------|-------------|
| `agric_admin` | `Admin@Agric2024!` | Database Administrator | Full access to all tables and views |
| `ministry_officer` | `Officer@Min2024!` | Ministry Officer | SELECT + INSERT on all tables, UPDATE on selected tables |
| `extension_user` | `Ext@Worker2024!` | Extension Worker | SELECT on 3 views, INSERT on farm_visit and distribution |
| `readonly_user` | `Read@Only2024!` | Reporting / Dashboard | SELECT on 5 views only — no raw table access |

### Connecting via VS Code
1. Open the MySQL extension panel
2. Click **+** to add a **new connection** (do not reuse existing)
3. Set host to `127.0.0.1`, port `3306`
4. Enter the username and password from the table above
5. Verify you are connected correctly:
```sql
SELECT CURRENT_USER();
-- Must show the user you logged in as
```

### Connecting via Command Line (Windows CMD)
```cmd
mysql -u readonly_user -p agric_services_db
-- Then enter password when prompted
```

### Verify passwords are encrypted
```sql
-- Run as root:
SELECT user, host, plugin, authentication_string
FROM mysql.user
WHERE user IN ('agric_admin','ministry_officer','extension_user','readonly_user');
-- plugin column should show: mysql_native_password
-- authentication_string column shows the SHA-1 hash (not the plain password)
```

---

## Views

Views act as a security layer — users are granted access to views instead of raw tables, hiding sensitive columns and restricting what data is visible.

| View | Purpose | Hides |
|------|---------|-------|
| `vw_farmer_profile` | Public farmer details for general use | NIN, date of birth |
| `vw_production_summary` | Coffee production per farmer per season | Raw table joins |
| `vw_worker_activity` | Extension worker visit/distribution/request counts | Individual records |
| `vw_stock_levels` | Input inventory with stock status flag | Internal item IDs |
| `vw_open_requests` | Only Pending and In Progress support requests | Resolved requests |

```sql
-- Query any view
SELECT * FROM vw_farmer_profile;
SELECT * FROM vw_production_summary;
SELECT * FROM vw_worker_activity;
SELECT * FROM vw_stock_levels;
SELECT * FROM vw_open_requests;
```

---

## Stored Procedures

Stored procedures enforce business logic and allow safe, reusable operations on the database.

### `sp_register_farmer`
Registers a new farmer by inserting into both `person` and `farmer` tables in a single call. Validates NIN uniqueness and farm size before inserting.

```sql
CALL sp_register_farmer(
    'FirstName', 'LastName', 'NIN_HERE',
    'Male', '1990-01-01', '0700000000',
    'email@example.com', 'Village Name',
    1,          -- location_id
    2.50,       -- farm_size_acres
    'Freehold', -- land_tenure
    @new_id     -- OUT parameter: returns new farmer_id
);
SELECT @new_id AS new_farmer_id;
```

### `sp_record_production`
Records a coffee harvest for a farmer in a given season. Validates the farmer is active and the record does not already exist.

```sql
CALL sp_record_production(
    1,            -- farmer_id
    1,            -- variety_id (1=Robusta, 2=Arabica, 3=Clonal)
    3,            -- season_id
    420.00,       -- quantity_kg
    'A',          -- quality_grade (A/B/C/Ungraded)
    '2026-06-10'  -- harvest_date
);
```

### `sp_distribute_item`
Distributes an input item to a farmer and automatically deducts from stock. Validates sufficient stock before proceeding.

```sql
CALL sp_distribute_item(
    1,  -- farmer_id
    3,  -- item_id
    1,  -- worker_id
    1,  -- district_id
    5   -- quantity to distribute
);
```

### `sp_farmer_report`
Returns a full profile report for a farmer including personal details, production history, and distributions received.

```sql
CALL sp_farmer_report(1);  -- pass farmer_id
```

### `sp_resolve_request`
Resolves an open support request and assigns a worker. The `date_resolved` field is set automatically by the `trg_auto_resolve_date` trigger.

```sql
CALL sp_resolve_request(
    2,  -- request_id
    1   -- worker_id
);
```

---

## Triggers

Triggers enforce automated rules that fire before or after data changes.

| Trigger | Table | When | Purpose |
|---------|-------|------|---------|
| `trg_disjoint_worker` | `extension_worker` | BEFORE INSERT | Blocks a person already registered as farmer or staff from being added as a worker |
| `trg_disjoint_staff` | `ministry_staff` | BEFORE INSERT | Blocks a person already registered as farmer or worker from being added as staff |
| `trg_check_visit_date` | `farm_visit` | BEFORE INSERT | Blocks visit dates set in the future |
| `trg_check_stock_before_distribution` | `distribution` | BEFORE INSERT | Blocks distribution if stock is insufficient |
| `trg_deduct_stock_on_distribution` | `distribution` | AFTER INSERT | Automatically reduces stock after a distribution is recorded |
| `trg_auto_resolve_date` | `support_request` | BEFORE UPDATE | Auto-sets `date_resolved` to today when status changes to Resolved; clears it if reopened |
| `trg_audit_production_update` | `production_record` | AFTER UPDATE | Logs any change to `quantity_kg` into `audit_production_log` with old/new values and user |
| `trg_prevent_active_farmer_delete` | `farmer` | BEFORE DELETE | Blocks deletion of a farmer whose status is Active |

---

## Backup & Recovery

### 1. Full Database Backup (run in Windows CMD)
```cmd
mysqldump -u agric_admin -p agric_services_db > C:\backups\agric_full_2026.sql
```

### 2. Structure-Only Backup
```cmd
mysqldump -u agric_admin -p --no-data agric_services_db > C:\backups\agric_schema.sql
```

### 3. Data-Only Backup
```cmd
mysqldump -u agric_admin -p --no-create-info agric_services_db > C:\backups\agric_data.sql
```

### 4. Restore from Backup
```cmd
mysql -u root -p agric_services_db < C:\backups\agric_full_2026.sql
```

### 5. Restore to a Test Database
```sql
-- In MySQL as root:
CREATE DATABASE agric_test_restore;
```
```cmd
-- In CMD:
mysql -u root -p agric_test_restore < C:\backups\agric_full_2026.sql
```

### 6. Refresh In-MySQL Table Snapshots
```sql
DROP TABLE IF EXISTS farmer_backup;
CREATE TABLE farmer_backup AS SELECT * FROM farmer;

DROP TABLE IF EXISTS production_record_backup;
CREATE TABLE production_record_backup AS SELECT * FROM production_record;
```

### Recommended Rotation Policy
| Frequency | Retention |
|-----------|-----------|
| Daily backups | Keep last 7 days |
| Weekly backups | Keep last 4 weeks |
| Monthly backups | Keep last 12 months |

> Store backup files on a **separate physical drive or cloud storage** (Google Drive / Dropbox) — never only on the same machine as the database server.

---

## Sample Data

The database is pre-loaded with realistic Ugandan sample data:

**Districts:** Mukono, Kampala, Masaka, Mbale, Mbarara

**Farmers (5):** John Kabugo, Prossy Namutebi, Robert Ssemakula, Grace Akello, David Omunyu

**Extension Workers (2):** Alice Nantongo (Soil Management), Moses Tumwine (Pest Control)

**Ministry Staff (1):** Harriet Kyomugisha (Database Administrator)

**Input Items (5):** Robusta Seedling Pack, Clonal Seedling Pack, NPK Fertiliser, Dithane Fungicide, Hand Pruning Shears

**Coffee Varieties (3):** Robusta, Arabica, Clonal

**Seasons (3):** Season 1 2024, Season 2 2024, Season 1 2025

---

## Testing

A full test sheet with 31 tests covering both milestones is available in the project documentation. Quick reference:

```sql
-- Test constraints (should all FAIL with errors)
INSERT INTO person (...) VALUES (..., '0701234567', ...); -- duplicate phone
INSERT INTO farmer (...) VALUES (..., -5.0, ...);          -- negative farm size
INSERT INTO distribution (...) VALUES (..., 0, ...);        -- zero quantity

-- Test views
SELECT * FROM vw_farmer_profile;      -- should NOT show NIN or DOB
SELECT * FROM vw_open_requests;       -- should only show non-resolved requests

-- Test triggers
INSERT INTO farm_visit (...) VALUES (..., '2099-01-01', ...); -- future date blocked
DELETE FROM farmer WHERE farmer_id = 1;                        -- active farmer blocked

-- Test stored procedures
CALL sp_register_farmer('Test','User','NIN001','Male','1990-01-01',
  '0799000001',NULL,'Kampala',1,1.0,'Freehold',@id);
SELECT @id;
```

---

## Security Notes

- All user passwords are stored as **SHA-1 hashes** using the `mysql_native_password` plugin — plain text passwords are never stored
- `readonly_user` has **zero access** to raw tables — views only
- Sensitive columns (`nin`, `date_of_birth`) are **excluded from all views**
- The disjoint constraint triggers **prevent a person from holding multiple roles** simultaneously
- Active farmers **cannot be deleted** — status must be set to Inactive first
- All production record changes are **logged to an audit table** with the MySQL user who made the change and a timestamp

---

## Group Members

| Name | Reg. Number | Role |
|------|-------------|------|
|Mutebi Jonah Mark |S24B23/105 | Backup Specialist|
|Mwonge Andrea | S24B23/070| EERD Designer|
| Ntumwa Raymond|S24B23/101 | Stored Procedures and Triggers|
|Beinomujuni P Bryton | S24B23/028 | Tables Creation and Constraint implementation |
|Bukenya Jawadhu Ken | S24B23/063 | Presentation and Documentation|
|Mabiel Malual Mayen Alier | M24B23/037 | Table creation and Constraint implementation|


---

**Uganda Christian University**
Faculty of Engineering, Design and Technology
Department of Computing and Technology
BSc Computer Science 
*Easter Semester 2026*
