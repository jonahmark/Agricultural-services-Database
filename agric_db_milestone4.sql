
USE agric_services_db;


-- 1.1 Public farmer profile (hides NIN and date of birth)
CREATE OR REPLACE VIEW vw_farmer_profile AS
SELECT
    f.farmer_id,
    CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    -- Concat means add
    p.phone,
    p.email,
    p.gender,
    f.farm_size_acres,
    f.land_tenure,
    f.status,
    l.village,
    l.sub_county,
    d.district_name
FROM farmer f
JOIN person   p ON f.person_id   = p.person_id
JOIN location l ON f.location_id = l.location_id
JOIN district d ON l.district_id = d.district_id;

-- 1.2 Production summary per farmer (for ministry reporting)
CREATE OR REPLACE VIEW vw_production_summary AS
SELECT
    CONCAT(p.first_name, ' ', p.last_name) AS farmer_name,
    d.district_name,
    cv.variety_name,
    s.season_name,
    s.year,
    pr.quantity_kg,
    pr.quality_grade,
    pr.harvest_date
FROM production_record pr
JOIN farmer        f  ON pr.farmer_id  = f.farmer_id
JOIN person        p  ON f.person_id   = p.person_id
JOIN location      l  ON f.location_id = l.location_id
JOIN district      d  ON l.district_id = d.district_id
JOIN coffee_variety cv ON pr.variety_id = cv.variety_id
JOIN season        s  ON pr.season_id  = s.season_id;

-- 1.3 Extension worker activity view
CREATE OR REPLACE VIEW vw_worker_activity AS
SELECT
    CONCAT(pw.first_name, ' ', pw.last_name) AS worker_name,
    d.district_name,
    COUNT(DISTINCT fv.visit_id)      AS total_visits,
    COUNT(DISTINCT dist.distribution_id) AS total_distributions,
    COUNT(DISTINCT sr.request_id)    AS requests_handled
FROM extension_worker ew
JOIN person      pw   ON ew.person_id   = pw.person_id
JOIN district    d    ON ew.district_id = d.district_id
LEFT JOIN farm_visit     fv   ON fv.worker_id  = ew.worker_id
LEFT JOIN distribution   dist ON dist.worker_id = ew.worker_id
LEFT JOIN support_request sr  ON sr.worker_id  = ew.worker_id
GROUP BY ew.worker_id, worker_name, d.district_name;

-- 1.4 Input stock level view (for inventory monitoring)
CREATE OR REPLACE VIEW vw_stock_levels AS
SELECT
    i.item_id,
    i.item_name,
    i.item_type,
    i.unit_of_measure,
    i.quantity_in_stock,
    COALESCE(SUM(dist.quantity_given), 0) AS total_distributed,
    -- coalensce is used to atleast show  a zero to avoid null
    CASE
        WHEN i.quantity_in_stock = 0          THEN 'Out of Stock'
        WHEN i.quantity_in_stock < 50         THEN 'Low Stock'
        ELSE                                       'Sufficient'
    END AS stock_status
FROM input_item i
LEFT JOIN distribution dist ON i.item_id = dist.item_id
GROUP BY i.item_id, i.item_name, i.item_type,
         i.unit_of_measure, i.quantity_in_stock;

-- 1.5 Open support requests (for dashboard)
CREATE OR REPLACE VIEW vw_open_requests AS
SELECT
    sr.request_id,
    CONCAT(p.first_name, ' ', p.last_name) AS farmer_name,
    l.sub_county,
    d.district_name,
    sr.request_type,
    sr.description,
    sr.status,
    sr.date_raised,
    DATEDIFF(CURDATE(), sr.date_raised)    AS days_open
FROM support_request sr
JOIN farmer   f ON sr.farmer_id  = f.farmer_id
JOIN person   p ON f.person_id   = p.person_id
JOIN location l ON f.location_id = l.location_id
JOIN district d ON l.district_id = d.district_id
WHERE sr.status != 'Resolved'
ORDER BY sr.date_raised ASC;



-- Drop users if they already exist (clean re-run)
DROP USER IF EXISTS 'agric_admin'@'localhost';
DROP USER IF EXISTS 'ministry_officer'@'localhost';
DROP USER IF EXISTS 'extension_user'@'localhost';
DROP USER IF EXISTS 'readonly_user'@'localhost';

-- 2.1 ADMIN — full privileges (Ministry DBA)
CREATE USER 'agric_admin'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Admin@Agric2024!';
GRANT ALL PRIVILEGES ON agric_services_db.* TO 'agric_admin'@'localhost' WITH GRANT OPTION;

-- 2.2 MINISTRY OFFICER — can read all data and insert records
--     Cannot drop tables or manage users
CREATE USER 'ministry_officer'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Officer@Min2024!';
GRANT SELECT, INSERT ON agric_services_db.* TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.district TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.location TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.coffee_variety TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.season TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.extension_worker TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.ministry_staff TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.input_item TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.seedling TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.agric_input TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.production_record TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.distribution TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.farm_visit TO 'ministry_officer'@'localhost';
GRANT UPDATE ON agric_services_db.support_request TO 'ministry_officer'@'localhost';

-- 2.3 EXTENSION WORKER USER — can only see their assigned data
--     and insert farm visits, distributions, support request updates
CREATE USER 'extension_user'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Ext@Worker2024!';
GRANT SELECT ON agric_services_db.vw_farmer_profile    TO 'extension_user'@'localhost';
GRANT SELECT ON agric_services_db.vw_stock_levels      TO 'extension_user'@'localhost';
GRANT SELECT ON agric_services_db.vw_open_requests     TO 'extension_user'@'localhost';
GRANT INSERT ON agric_services_db.farm_visit           TO 'extension_user'@'localhost';
GRANT INSERT ON agric_services_db.distribution         TO 'extension_user'@'localhost';
GRANT SELECT, UPDATE ON agric_services_db.support_request TO 'extension_user'@'localhost';

-- 2.4 READ-ONLY USER — for reporting tools, dashboards
CREATE USER 'readonly_user'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Read@Only2024!';
-- Explicitly revoke ALL privileges first to ensure a clean slate
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'readonly_user'@'localhost';
FLUSH PRIVILEGES;
-- Grant SELECT only on views (NOT on raw tables)
GRANT SELECT ON agric_services_db.vw_farmer_profile     TO 'readonly_user'@'localhost';
GRANT SELECT ON agric_services_db.vw_production_summary TO 'readonly_user'@'localhost';
GRANT SELECT ON agric_services_db.vw_worker_activity    TO 'readonly_user'@'localhost';
GRANT SELECT ON agric_services_db.vw_stock_levels       TO 'readonly_user'@'localhost';
GRANT SELECT ON agric_services_db.vw_open_requests      TO 'readonly_user'@'localhost';
FLUSH PRIVILEGES;


-- ============================================================
-- SECTION 3: STORED PROCEDURES (code reuse)
-- ============================================================

DELIMITER $$

-- 3.1 Register a new farmer (handles PERSON + FARMER in one call)
DROP PROCEDURE IF EXISTS sp_register_farmer;
CREATE PROCEDURE sp_register_farmer(
    IN  p_first_name        VARCHAR(80),
    IN  p_last_name         VARCHAR(80),
    IN  p_nin               VARCHAR(17),
    IN  p_gender            ENUM('Male','Female','Other'),
    IN  p_dob               DATE,
    IN  p_phone             VARCHAR(15),
    IN  p_email             VARCHAR(120),
    IN  p_address           VARCHAR(200),
    IN  p_location_id       INT,
    IN  p_farm_size_acres   DECIMAL(8,2),
    IN  p_land_tenure       ENUM('Freehold','Leasehold','Customary','Mailo'),
    OUT p_new_farmer_id     INT
)
BEGIN
    DECLARE v_person_id INT;

    -- Check if NIN already exists
    IF EXISTS (SELECT 1 FROM person WHERE nin = TRIM(p_nin)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A person with this NIN already exists.';
    END IF;

    -- Validate farm size
    IF p_farm_size_acres <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Farm size must be greater than zero.';
    END IF;

    -- Insert into PERSON first
    INSERT INTO person (first_name, last_name, nin, gender,
                        date_of_birth, phone, email, address)
    VALUES (p_first_name, p_last_name, TRIM(p_nin), p_gender,
            p_dob, p_phone, p_email, p_address);

    SET v_person_id = LAST_INSERT_ID();

    -- Insert into FARMER subtype
    INSERT INTO farmer (person_id, location_id, farm_size_acres,
                        land_tenure, registration_date)
    VALUES (v_person_id, p_location_id, p_farm_size_acres,
            p_land_tenure, CURDATE());

    SET p_new_farmer_id = LAST_INSERT_ID();

    SELECT CONCAT('Farmer registered successfully. Farmer ID: ',
                   p_new_farmer_id) AS message;
END$$

-- 3.2 Record coffee production for a farmer
DROP PROCEDURE IF EXISTS sp_record_production;
CREATE PROCEDURE sp_record_production(
    IN p_farmer_id      INT,
    IN p_variety_id     INT,
    IN p_season_id      INT,
    IN p_quantity_kg    DECIMAL(10,2),
    IN p_quality_grade  ENUM('A','B','C','Ungraded'),
    IN p_harvest_date   DATE
)
BEGIN
    -- Check farmer exists and is active
    IF NOT EXISTS (
        SELECT 1 FROM farmer
        WHERE farmer_id = p_farmer_id AND status = 'Active'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Farmer not found or is inactive.';
    END IF;

    -- Check quantity is positive
    IF p_quantity_kg <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Production quantity must be greater than zero.';
    END IF;

    -- Check for duplicate record in same season
    IF EXISTS (
        SELECT 1 FROM production_record
        WHERE farmer_id = p_farmer_id
          AND variety_id = p_variety_id
          AND season_id  = p_season_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A production record already exists for this farmer, variety and season.';
    END IF;

    INSERT INTO production_record
        (farmer_id, variety_id, season_id, quantity_kg, quality_grade, harvest_date)
    VALUES
        (p_farmer_id, p_variety_id, p_season_id, p_quantity_kg,
         p_quality_grade, p_harvest_date);

    SELECT CONCAT('Production record saved. Record ID: ',
                   LAST_INSERT_ID()) AS message;
END$$

-- 3.3 Distribute items to a farmer (with stock deduction)
DROP PROCEDURE IF EXISTS sp_distribute_item;
CREATE PROCEDURE sp_distribute_item(
    IN p_farmer_id      INT,
    IN p_item_id        INT,
    IN p_worker_id      INT,
    IN p_district_id    INT,
    IN p_quantity       DECIMAL(10,2)
)
BEGIN
    DECLARE v_stock INT;

    -- Check available stock
    SELECT quantity_in_stock INTO v_stock
    FROM input_item WHERE item_id = p_item_id;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Item not found in inventory.';
    END IF;

    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Distribution quantity must be greater than zero.';
    END IF;

    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock to complete this distribution.';
    END IF;

    -- Record distribution
    INSERT INTO distribution
        (farmer_id, item_id, worker_id, district_id,
         quantity_given, distribution_date)
    VALUES
        (p_farmer_id, p_item_id, p_worker_id, p_district_id,
         p_quantity, CURDATE());

    -- Deduct from stock
    UPDATE input_item
    SET quantity_in_stock = quantity_in_stock - p_quantity
    WHERE item_id = p_item_id;

    SELECT CONCAT('Distribution recorded. Remaining stock: ',
                   v_stock - p_quantity) AS message;
END$$

-- 3.4 Get full farmer report by farmer_id
DROP PROCEDURE IF EXISTS sp_farmer_report;
CREATE PROCEDURE sp_farmer_report(
    IN p_farmer_id INT
)
BEGIN
    -- Personal & farm details
    SELECT
        CONCAT(p.first_name, ' ', p.last_name) AS full_name,
        p.nin, p.phone, p.gender,
        f.farm_size_acres, f.land_tenure,
        f.registration_date, f.status,
        l.village, l.sub_county, d.district_name
    FROM farmer f
    JOIN person   p ON f.person_id   = p.person_id
    JOIN location l ON f.location_id = l.location_id
    JOIN district d ON l.district_id = d.district_id
    WHERE f.farmer_id = p_farmer_id;

    -- Production history
    SELECT
        cv.variety_name, s.season_name, s.year,
        pr.quantity_kg, pr.quality_grade, pr.harvest_date
    FROM production_record pr
    JOIN coffee_variety cv ON pr.variety_id = cv.variety_id
    JOIN season         s  ON pr.season_id  = s.season_id
    WHERE pr.farmer_id = p_farmer_id
    ORDER BY pr.harvest_date DESC;

    -- Items received
    SELECT
        i.item_name, i.item_type,
        dist.quantity_given, dist.distribution_date
    FROM distribution dist
    JOIN input_item i ON dist.item_id = i.item_id
    WHERE dist.farmer_id = p_farmer_id
    ORDER BY dist.distribution_date DESC;

    -- Support requests
    SELECT
        sr.request_type, sr.status,
        sr.date_raised, sr.date_resolved
    FROM support_request sr
    WHERE sr.farmer_id = p_farmer_id
    ORDER BY sr.date_raised DESC;
END$$

-- 3.5 Resolve a support request
DROP PROCEDURE IF EXISTS sp_resolve_request;
CREATE PROCEDURE sp_resolve_request(
    IN p_request_id INT,
    IN p_worker_id  INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM support_request
        WHERE request_id = p_request_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Support request not found.';
    END IF;

    UPDATE support_request
    SET
        status        = 'Resolved',
        worker_id     = p_worker_id,
        date_resolved = CURDATE()
    WHERE request_id = p_request_id;

    SELECT 'Support request marked as resolved.' AS message;
END$$

DELIMITER ;


DELIMITER $$

-- 4.1 Prevent duplicate person across subtypes (disjoint enforcement)
--     Fires before inserting a new farmer — checks the person is
--     not already an extension worker or ministry staff
DROP TRIGGER IF EXISTS trg_disjoint_farmer;
CREATE TRIGGER trg_disjoint_farmer
BEFORE INSERT ON farmer
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM extension_worker WHERE person_id = NEW.person_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This person is already registered as an Extension Worker.';
    END IF;
    IF EXISTS (SELECT 1 FROM ministry_staff WHERE person_id = NEW.person_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This person is already registered as Ministry Staff.';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_disjoint_worker;
CREATE TRIGGER trg_disjoint_worker
BEFORE INSERT ON extension_worker
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM farmer WHERE person_id = NEW.person_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This person is already registered as a Farmer.';
    END IF;
    IF EXISTS (SELECT 1 FROM ministry_staff WHERE person_id = NEW.person_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This person is already registered as Ministry Staff.';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_disjoint_staff;
CREATE TRIGGER trg_disjoint_staff
BEFORE INSERT ON ministry_staff
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM farmer WHERE person_id = NEW.person_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This person is already registered as a Farmer.';
    END IF;
    IF EXISTS (SELECT 1 FROM extension_worker WHERE person_id = NEW.person_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This person is already registered as an Extension Worker.';
    END IF;
END$$

-- 4.1b Enforce visit_date cannot be in the future (replaces CHECK constraint)
DROP TRIGGER IF EXISTS trg_check_visit_date;
CREATE TRIGGER trg_check_visit_date
BEFORE INSERT ON farm_visit
FOR EACH ROW
BEGIN
    IF NEW.visit_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Visit date cannot be in the future.';
    END IF;
END$$

-- 4.2 Auto-deduct stock when a distribution is inserted manually
--     (complements sp_distribute_item for direct inserts)
DROP TRIGGER IF EXISTS trg_deduct_stock_on_distribution;
CREATE TRIGGER trg_deduct_stock_on_distribution
AFTER INSERT ON distribution
FOR EACH ROW
BEGIN
    UPDATE input_item
    SET quantity_in_stock = quantity_in_stock - NEW.quantity_given
    WHERE item_id = NEW.item_id;
END$$

-- 4.3 Prevent stock going below zero
DROP TRIGGER IF EXISTS trg_check_stock_before_distribution;
CREATE TRIGGER trg_check_stock_before_distribution
BEFORE INSERT ON distribution
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    SELECT quantity_in_stock INTO v_stock
    FROM input_item WHERE item_id = NEW.item_id;

    IF v_stock < NEW.quantity_given THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot distribute: insufficient stock for this item.';
    END IF;
END$$

-- 4.4 Auto-set date_resolved when status changes to Resolved
DROP TRIGGER IF EXISTS trg_auto_resolve_date;
CREATE TRIGGER trg_auto_resolve_date
BEFORE UPDATE ON support_request
FOR EACH ROW
BEGIN
    IF NEW.status = 'Resolved' AND OLD.status != 'Resolved' THEN
        SET NEW.date_resolved = CURDATE();
    END IF;
    -- If reopened, clear the resolved date
    IF NEW.status != 'Resolved' AND OLD.status = 'Resolved' THEN
        SET NEW.date_resolved = NULL;
    END IF;
END$$

-- 4.5 Log table for production record changes (audit trail)
CREATE TABLE IF NOT EXISTS audit_production_log (
    log_id          INT AUTO_INCREMENT PRIMARY KEY,
    record_id       INT,
    farmer_id       INT,
    old_quantity_kg DECIMAL(10,2),
    new_quantity_kg DECIMAL(10,2),
    changed_by      VARCHAR(100) DEFAULT (USER()),
    changed_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_audit_production_update;
CREATE TRIGGER trg_audit_production_update
AFTER UPDATE ON production_record
FOR EACH ROW
BEGIN
    IF OLD.quantity_kg != NEW.quantity_kg THEN
        INSERT INTO audit_production_log
            (record_id, farmer_id, old_quantity_kg, new_quantity_kg, changed_by)
        VALUES
            (OLD.record_id, OLD.farmer_id, OLD.quantity_kg,
             NEW.quantity_kg, USER());
    END IF;
END$$

-- 4.6 Prevent deletion of active farmers
DROP TRIGGER IF EXISTS trg_prevent_active_farmer_delete;
CREATE TRIGGER trg_prevent_active_farmer_delete
BEFORE DELETE ON farmer
FOR EACH ROW
BEGIN
    IF OLD.status = 'Active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot delete an active farmer. Set status to Inactive first.';
    END IF;
END$$

DELIMITER ;


-- ============================================================
-- SECTION 5: BACKUP & RECOVERY STRATEGY
-- ============================================================

-- NOTE: The commands below are run from the terminal/command line,
-- NOT inside MySQL. They are documented here for reference.

/*
====================================================================
BACKUP COMMANDS (run in terminal / command prompt)
====================================================================

1. FULL DATABASE BACKUP (run daily)
   mysqldump -u agric_admin -p agric_services_db > backup_agric_$(date +%F).sql

2. STRUCTURE-ONLY BACKUP (schema without data)
   mysqldump -u agric_admin -p --no-data agric_services_db > schema_backup.sql

3. DATA-ONLY BACKUP (data without structure)
   mysqldump -u agric_admin -p --no-create-info agric_services_db > data_backup.sql

4. RESTORE FROM BACKUP
   mysql -u agric_admin -p agric_services_db < backup_agric_2024-06-01.sql

5. AUTOMATED DAILY BACKUP (Linux cron job — runs at 2:00 AM daily)
   crontab -e
   0 2 * * * mysqldump -u agric_admin -pAdmin@Agric2024! agric_services_db > /backups/agric_$(date +\%F).sql

6. WINDOWS TASK SCHEDULER (save as backup.bat)
   mysqldump -u agric_admin -pAdmin@Agric2024! agric_services_db > C:\backups\agric_%date%.sql

====================================================================
RECOVERY STRATEGY
====================================================================
- Keep daily backups for the last 7 days
- Keep weekly backups for the last 4 weeks
- Keep monthly backups for the last 12 months
- Store backups on a separate physical drive or cloud (Google Drive/Dropbox)
- Test recovery monthly by restoring to a test database:
    mysql -u root -p -e "CREATE DATABASE agric_test_restore;"
    mysql -u root -p agric_test_restore < backup_agric_2024-06-01.sql

====================================================================
*/

-- In-MySQL backup table snapshot (for quick table-level recovery)
CREATE TABLE IF NOT EXISTS farmer_backup AS SELECT * FROM farmer;
CREATE TABLE IF NOT EXISTS production_record_backup AS SELECT * FROM production_record;



-- Test 3.1: Register a new farmer
CALL sp_register_farmer(
    'Kato', 'Emmanuel', 'CM95000099010017',
    'Male', '1995-08-21',
    '0789999007', 'kato@email.com', 'Masaka Town',
    4, 1.50, 'Customary',
    @new_id
);
SELECT @new_id AS new_farmer_id;

-- Test 3.2: Record production
CALL sp_record_production(@new_id, 1, 3, 350.00, 'A', '2025-06-15');

-- Test 3.3: Distribute item
CALL sp_distribute_item(@new_id, 3, 1, 1, 2);

-- Test 3.4: Full farmer report
CALL sp_farmer_report(@new_id);

-- Test 3.5: Resolve a support request
CALL sp_resolve_request(2, 1);

-- Verify views
SELECT * FROM vw_farmer_profile;
SELECT * FROM vw_production_summary;
SELECT * FROM vw_worker_activity;
SELECT * FROM vw_stock_levels;
SELECT * FROM vw_open_requests;

-- Check audit log
SELECT * FROM audit_production_log;