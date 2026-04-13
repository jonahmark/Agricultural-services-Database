
DROP DATABASE IF EXISTS agric_services_db;
CREATE DATABASE agric_services_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE agric_services_db;


-- 1.1 DISTRICT
CREATE TABLE district (
    district_id     INT AUTO_INCREMENT PRIMARY KEY,
    district_name   VARCHAR(100) NOT NULL,
    region          ENUM('Central','Eastern','Western','Northern') NOT NULL,
    CONSTRAINT uq_district_name UNIQUE (district_name)
);

-- 1.2 LOCATION (village → sub_county → county → district)
CREATE TABLE location (
    location_id     INT AUTO_INCREMENT PRIMARY KEY,
    village         VARCHAR(100) NOT NULL,
    sub_county      VARCHAR(100) NOT NULL,
    county          VARCHAR(100) NOT NULL,
    district_id     INT NOT NULL,
    CONSTRAINT fk_location_district
        FOREIGN KEY (district_id) REFERENCES district(district_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 1.3 COFFEE_VARIETY
CREATE TABLE coffee_variety (
    variety_id      INT AUTO_INCREMENT PRIMARY KEY,
    variety_name    VARCHAR(100) NOT NULL,
    description     TEXT,
    maturity_period VARCHAR(50),
    CONSTRAINT uq_variety_name UNIQUE (variety_name)
);

-- 1.4 SEASON
CREATE TABLE season (
    season_id       INT AUTO_INCREMENT PRIMARY KEY,
    season_name     VARCHAR(50) NOT NULL,
    year            YEAR NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    CONSTRAINT chk_season_dates CHECK (end_date > start_date),
    CONSTRAINT uq_season UNIQUE (season_name, year)
);


-- 2.1 PERSON (supertype for FARMER, EXTENSION_WORKER, MINISTRY_STAFF)
CREATE TABLE person (
    person_id       INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(80) NOT NULL,
    last_name       VARCHAR(80) NOT NULL,
    nin             VARCHAR(17) NOT NULL,
    gender          ENUM('Male','Female','Other') NOT NULL,
    date_of_birth   DATE NOT NULL,
    phone           VARCHAR(15) NOT NULL,
    email           VARCHAR(120),
    address         VARCHAR(200),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_person_nin   UNIQUE (nin),
    CONSTRAINT uq_person_phone UNIQUE (phone),
    CONSTRAINT chk_phone_len   CHECK (CHAR_LENGTH(phone) >= 10)
);



-- 3.1 FARMER (subtype of PERSON)
CREATE TABLE farmer (
    farmer_id           INT AUTO_INCREMENT PRIMARY KEY,
    person_id           INT NOT NULL,
    location_id         INT NOT NULL,
    farm_size_acres     DECIMAL(8,2) NOT NULL,
    land_tenure         ENUM('Freehold','Leasehold','Customary','Mailo') NOT NULL,
    registration_date   DATE NOT NULL DEFAULT (CURDATE()),
    status              ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_farmer_person
        FOREIGN KEY (person_id) REFERENCES person(person_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_farmer_location
        FOREIGN KEY (location_id) REFERENCES location(location_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_farmer_person UNIQUE (person_id),
    CONSTRAINT chk_farm_size CHECK (farm_size_acres > 0)
);

-- 3.2 EXTENSION_WORKER (subtype of PERSON)
CREATE TABLE extension_worker (
    worker_id           INT AUTO_INCREMENT PRIMARY KEY,
    person_id           INT NOT NULL,
    district_id         INT NOT NULL,
    qualification       VARCHAR(150) NOT NULL,
    specialisation      VARCHAR(150),
    employment_date     DATE NOT NULL,
    status              ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_worker_person
        FOREIGN KEY (person_id) REFERENCES person(person_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_worker_district
        FOREIGN KEY (district_id) REFERENCES district(district_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_worker_person UNIQUE (person_id)
);

-- 3.3 MINISTRY_STAFF (subtype of PERSON)
CREATE TABLE ministry_staff (
    staff_id        INT AUTO_INCREMENT PRIMARY KEY,
    person_id       INT NOT NULL,
    department      VARCHAR(150) NOT NULL,
    role_title      VARCHAR(150) NOT NULL,
    access_level    ENUM('Admin','District','ReadOnly') NOT NULL DEFAULT 'ReadOnly',
    CONSTRAINT fk_staff_person
        FOREIGN KEY (person_id) REFERENCES person(person_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_staff_person UNIQUE (person_id)
);



-- 4.1 INPUT_ITEM (supertype — overlapping specialisation)
CREATE TABLE input_item (
    item_id             INT AUTO_INCREMENT PRIMARY KEY,
    item_name           VARCHAR(150) NOT NULL,
    item_type           ENUM('Seedling','Fertiliser','Pesticide','Tool','Other') NOT NULL,
    unit_of_measure     VARCHAR(30) NOT NULL,
    quantity_in_stock   INT NOT NULL DEFAULT 0,
    CONSTRAINT uq_item_name UNIQUE (item_name),
    CONSTRAINT chk_stock CHECK (quantity_in_stock >= 0)
);

-- 4.2 SEEDLING (subtype of INPUT_ITEM — overlapping)
CREATE TABLE seedling (
    seedling_id     INT AUTO_INCREMENT PRIMARY KEY,
    item_id         INT NOT NULL,
    variety_id      INT NOT NULL,
    age_weeks       INT,
    source_nursery  VARCHAR(150),
    CONSTRAINT fk_seedling_item
        FOREIGN KEY (item_id) REFERENCES input_item(item_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_seedling_variety
        FOREIGN KEY (variety_id) REFERENCES coffee_variety(variety_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 4.3 AGRIC_INPUT (subtype of INPUT_ITEM — overlapping)
CREATE TABLE agric_input (
    agric_input_id      INT AUTO_INCREMENT PRIMARY KEY,
    item_id             INT NOT NULL,
    manufacturer        VARCHAR(150),
    active_ingredient   VARCHAR(200),
    application_rate    VARCHAR(100),
    safety_notes        TEXT,
    CONSTRAINT fk_agric_item
        FOREIGN KEY (item_id) REFERENCES input_item(item_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);



-- 5.1 PRODUCTION_RECORD
CREATE TABLE production_record (
    record_id       INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id       INT NOT NULL,
    variety_id      INT NOT NULL,
    season_id       INT NOT NULL,
    quantity_kg     DECIMAL(10,2) NOT NULL,
    quality_grade   ENUM('A','B','C','Ungraded') NOT NULL DEFAULT 'Ungraded',
    harvest_date    DATE NOT NULL,
    CONSTRAINT fk_prod_farmer
        FOREIGN KEY (farmer_id) REFERENCES farmer(farmer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_prod_variety
        FOREIGN KEY (variety_id) REFERENCES coffee_variety(variety_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_prod_season
        FOREIGN KEY (season_id) REFERENCES season(season_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_quantity CHECK (quantity_kg > 0),
    CONSTRAINT uq_prod_record UNIQUE (farmer_id, variety_id, season_id)
);

-- 5.2 DISTRIBUTION (ternary: FARMER + INPUT_ITEM + EXTENSION_WORKER)
CREATE TABLE distribution (
    distribution_id     INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id           INT NOT NULL,
    item_id             INT NOT NULL,
    worker_id           INT NOT NULL,
    district_id         INT NOT NULL,
    quantity_given      DECIMAL(10,2) NOT NULL,
    distribution_date   DATE NOT NULL DEFAULT (CURDATE()),
    CONSTRAINT fk_dist_farmer
        FOREIGN KEY (farmer_id) REFERENCES farmer(farmer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_dist_item
        FOREIGN KEY (item_id) REFERENCES input_item(item_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_dist_worker
        FOREIGN KEY (worker_id) REFERENCES extension_worker(worker_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_dist_district
        FOREIGN KEY (district_id) REFERENCES district(district_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_dist_qty CHECK (quantity_given > 0)
);

-- 5.3 FARM_VISIT
CREATE TABLE farm_visit (
    visit_id            INT AUTO_INCREMENT PRIMARY KEY,
    worker_id           INT NOT NULL,
    farmer_id           INT NOT NULL,
    visit_date          DATE NOT NULL,
    advice_given        TEXT,
    issues_found        TEXT,
    follow_up_required  ENUM('Yes','No') NOT NULL DEFAULT 'No',
    CONSTRAINT fk_visit_worker
        FOREIGN KEY (worker_id) REFERENCES extension_worker(worker_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_visit_farmer
        FOREIGN KEY (farmer_id) REFERENCES farmer(farmer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 5.4 SUPPORT_REQUEST
CREATE TABLE support_request (
    request_id      INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id       INT NOT NULL,
    worker_id       INT,
    request_type    ENUM('Pest Control','Soil Advice','Seedling Request',
                         'Market Access','Financial Support','Other') NOT NULL,
    description     TEXT NOT NULL,
    status          ENUM('Pending','In Progress','Resolved') NOT NULL DEFAULT 'Pending',
    date_raised     DATE NOT NULL DEFAULT (CURDATE()),
    date_resolved   DATE,
    CONSTRAINT fk_req_farmer
        FOREIGN KEY (farmer_id) REFERENCES farmer(farmer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_req_worker
        FOREIGN KEY (worker_id) REFERENCES extension_worker(worker_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_resolved_date
        CHECK (date_resolved IS NULL OR date_resolved >= date_raised)
);



-- Districts
INSERT INTO district (district_name, region) VALUES
('Mukono',    'Central'),
('Kampala',   'Central'),
('Masaka',    'Central'),
('Mbale',     'Eastern'),
('Mbarara',   'Western');

-- Locations
INSERT INTO location (village, sub_county, county, district_id) VALUES
('Namataba',  'Kasawo',   'Mukono',   1),
('Seeta',     'Seeta',    'Mukono',   1),
('Kiteezi',   'Wakiso',   'Kampala',  2),
('Bukomero',  'Masaka',   'Masaka',   3),
('Namawojolo','Mbale',    'Mbale',    4);

-- Coffee varieties
INSERT INTO coffee_variety (variety_name, description, maturity_period) VALUES
('Robusta',  'Main Ugandan variety, hardy and high yield',       '18-24 months'),
('Arabica',  'Highland variety, high quality flavour',            '24-36 months'),
('Clonal',   'Improved Robusta clone with disease resistance',    '18-20 months');

-- Seasons
INSERT INTO season (season_name, year, start_date, end_date) VALUES
('Season 1', 2024, '2024-03-01', '2024-06-30'),
('Season 2', 2024, '2024-10-01', '2024-12-31'),
('Season 1', 2025, '2025-03-01', '2025-06-30');

-- Persons (supertype)
INSERT INTO person (first_name, last_name, nin, gender, date_of_birth, phone, email, address) VALUES
('John',     'Kabugo',    'CM90000014250001', 'Male',   '1985-04-12', '0701234567', 'jkabugo@email.com',   'Namataba Village'),
('Prossy',   'Namutebi',  'CF88000023140002', 'Female', '1988-07-22', '0772345678', 'pnamutebi@email.com', 'Seeta, Mukono'),
('Robert',   'Ssemakula', 'CM79000034120003', 'Male',   '1979-01-05', '0783456789', NULL,                  'Kiteezi, Wakiso'),
('Grace',    'Akello',    'CF92000045310004', 'Female', '1992-11-30', '0754567890', 'gakello@email.com',   'Mbale Town'),
('David',    'Omunyu',    'CM86000056280005', 'Male',   '1986-03-18', '0765678901', NULL,                  'Mbarara'),
('Alice',    'Nantongo',  'CF90000067190006', 'Female', '1990-09-09', '0776789012', 'anantongo@email.com', 'Kampala'),
('Moses',    'Tumwine',   'CM83000078230007', 'Male',   '1983-06-14', '0707890123', NULL,                  'Masaka'),
('Harriet',  'Kyomugisha','CF87000089170008', 'Female', '1987-02-28', '0718901234', 'hkyom@email.com',     'Mbarara');

-- Farmers (subtypes of PERSON — persons 1, 2, 3, 4, 5)
INSERT INTO farmer (person_id, location_id, farm_size_acres, land_tenure, registration_date) VALUES
(1, 1, 2.50,  'Freehold',  '2022-01-15'),
(2, 2, 1.00,  'Customary', '2022-03-20'),
(3, 3, 4.75,  'Leasehold', '2021-11-08'),
(4, 5, 0.75,  'Customary', '2023-05-01'),
(5, 4, 3.00,  'Mailo',     '2020-07-12');

-- Extension workers (persons 6, 7)
INSERT INTO extension_worker (person_id, district_id, qualification, specialisation, employment_date) VALUES
(6, 1, 'BSc Agriculture - Makerere University', 'Soil Management',  '2018-04-01'),
(7, 3, 'Diploma in Agriculture - NARO',         'Pest Control',     '2019-09-15');

-- Ministry staff (person 8)
INSERT INTO ministry_staff (person_id, department, role_title, access_level) VALUES
(8, 'Agricultural Information', 'Database Administrator', 'Admin');

-- Input items
INSERT INTO input_item (item_name, item_type, unit_of_measure, quantity_in_stock) VALUES
('Robusta Seedling Pack',    'Seedling',    'pieces', 5000),
('Clonal Seedling Pack',     'Seedling',    'pieces', 3000),
('NPK Fertiliser 50kg',      'Fertiliser',  'bags',   800),
('Dithane Fungicide 1kg',    'Pesticide',   'kg',     400),
('Hand Pruning Shears',      'Tool',        'pieces', 200);

-- Seedling subtype entries (overlapping — items 1 and 2)
INSERT INTO seedling (item_id, variety_id, age_weeks, source_nursery) VALUES
(1, 1, 12, 'Mukono NAADS Nursery'),
(2, 3, 10, 'Masaka Coffee Nursery');

-- Agric input subtype entries (overlapping — items 3, 4)
INSERT INTO agric_input (item_id, manufacturer, active_ingredient, application_rate, safety_notes) VALUES
(3, 'Yara International', 'N-P-K compound',   '50kg per acre',     'Wear gloves when applying'),
(4, 'Dow AgroSciences',   'Mancozeb 80% WP',  '2g per litre water','Avoid inhalation, use mask');

-- Production records
INSERT INTO production_record (farmer_id, variety_id, season_id, quantity_kg, quality_grade, harvest_date) VALUES
(1, 1, 1, 480.00, 'A', '2024-06-10'),
(1, 1, 2, 520.00, 'B', '2024-12-05'),
(2, 1, 1, 210.00, 'B', '2024-06-15'),
(3, 3, 1, 890.00, 'A', '2024-05-28'),
(4, 2, 1, 120.00, 'A', '2024-06-20'),
(5, 1, 2, 640.00, 'B', '2024-11-30');

-- Distributions
INSERT INTO distribution (farmer_id, item_id, worker_id, district_id, quantity_given, distribution_date) VALUES
(1, 1, 1, 1, 200, '2024-02-10'),
(2, 1, 1, 1, 150, '2024-02-10'),
(3, 3, 1, 2, 5,   '2024-03-01'),
(4, 2, 2, 3, 100, '2024-01-20'),
(5, 4, 2, 4, 10,  '2024-03-15');

-- Farm visits
INSERT INTO farm_visit (worker_id, farmer_id, visit_date, advice_given, issues_found, follow_up_required) VALUES
(1, 1, '2024-04-05', 'Advised on proper pruning techniques and spacing', 'Minor leaf rust observed',        'Yes'),
(1, 2, '2024-04-12', 'Discussed soil pH management',                     'Soil too acidic, needs lime',    'Yes'),
(2, 4, '2024-05-03', 'Trained on organic pest control methods',           'Antestia bug infestation mild',  'No'),
(2, 5, '2024-05-18', 'Advised on mulching and water retention',           'Dry spell stress observed',      'No');

-- Support requests
INSERT INTO support_request (farmer_id, worker_id, request_type, description, status, date_raised, date_resolved) VALUES
(1, 1, 'Pest Control',    'Heavy CBB infestation in main block',      'Resolved',    '2024-03-10', '2024-03-18'),
(2, 1, 'Soil Advice',     'Yellow leaves, suspected nutrient issue',   'In Progress', '2024-04-15', NULL),
(3, NULL,'Seedling Request','Need 300 Clonal seedlings for expansion', 'Pending',    '2024-05-01', NULL),
(5, 2, 'Market Access',   'Looking for certified coffee buyers',       'Resolved',    '2024-02-20', '2024-03-05');




-- Q1: All farmers with full personal details and location
SELECT
    p.first_name, p.last_name, p.nin, p.phone,
    f.farm_size_acres, f.land_tenure, f.status,
    l.village, l.sub_county, d.district_name
FROM farmer f
JOIN person   p ON f.person_id   = p.person_id
JOIN location l ON f.location_id = l.location_id
JOIN district d ON l.district_id = d.district_id;

-- Q2: Total coffee production per farmer per season
SELECT
    CONCAT(p.first_name,' ',p.last_name) AS farmer_name,
    s.season_name, s.year,
    SUM(pr.quantity_kg) AS total_kg,
    pr.quality_grade
FROM production_record pr
JOIN farmer f  ON pr.farmer_id  = f.farmer_id
JOIN person p  ON f.person_id   = p.person_id
JOIN season s  ON pr.season_id  = s.season_id
GROUP BY farmer_name, s.season_name, s.year, pr.quality_grade
ORDER BY total_kg DESC;

-- Q3: Distribution summary — what each farmer has received
SELECT
    CONCAT(p.first_name,' ',p.last_name) AS farmer_name,
    i.item_name, i.item_type,
    d.quantity_given, d.distribution_date,
    CONCAT(pw.first_name,' ',pw.last_name) AS distributed_by
FROM distribution d
JOIN farmer          f  ON d.farmer_id = f.farmer_id
JOIN person          p  ON f.person_id = p.person_id
JOIN input_item      i  ON d.item_id   = i.item_id
JOIN extension_worker w ON d.worker_id = w.worker_id
JOIN person          pw ON w.person_id = pw.person_id;

-- Q4: Open support requests
SELECT
    CONCAT(p.first_name,' ',p.last_name) AS farmer_name,
    sr.request_type, sr.description, sr.status, sr.date_raised
FROM support_request sr
JOIN farmer f ON sr.farmer_id = f.farmer_id
JOIN person p ON f.person_id  = p.person_id
WHERE sr.status != 'Resolved'
ORDER BY sr.date_raised;

-- Q5: Farm visits by extension worker
SELECT
    CONCAT(pw.first_name,' ',pw.last_name) AS worker_name,
    CONCAT(pf.first_name,' ',pf.last_name) AS farmer_name,
    fv.visit_date, fv.follow_up_required, fv.issues_found
FROM farm_visit fv
JOIN extension_worker ew ON fv.worker_id = ew.worker_id
JOIN person pw            ON ew.person_id = pw.person_id
JOIN farmer fa            ON fv.farmer_id = fa.farmer_id
JOIN person pf            ON fa.person_id = pf.person_id
ORDER BY fv.visit_date DESC;
