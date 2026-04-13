-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: agric_services_db
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `agric_input`
--

DROP TABLE IF EXISTS `agric_input`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agric_input` (
  `agric_input_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `manufacturer` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active_ingredient` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `application_rate` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `safety_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`agric_input_id`),
  KEY `fk_agric_item` (`item_id`),
  CONSTRAINT `fk_agric_item` FOREIGN KEY (`item_id`) REFERENCES `input_item` (`item_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agric_input`
--

LOCK TABLES `agric_input` WRITE;
/*!40000 ALTER TABLE `agric_input` DISABLE KEYS */;
INSERT INTO `agric_input` VALUES (1,3,'Yara International','N-P-K compound','50kg per acre','Wear gloves when applying'),(2,4,'Dow AgroSciences','Mancozeb 80% WP','2g per litre water','Avoid inhalation, use mask');
/*!40000 ALTER TABLE `agric_input` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_production_log`
--

DROP TABLE IF EXISTS `audit_production_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_production_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `record_id` int DEFAULT NULL,
  `farmer_id` int DEFAULT NULL,
  `old_quantity_kg` decimal(10,2) DEFAULT NULL,
  `new_quantity_kg` decimal(10,2) DEFAULT NULL,
  `changed_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT (user()),
  `changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_production_log`
--

LOCK TABLES `audit_production_log` WRITE;
/*!40000 ALTER TABLE `audit_production_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_production_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coffee_variety`
--

DROP TABLE IF EXISTS `coffee_variety`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coffee_variety` (
  `variety_id` int NOT NULL AUTO_INCREMENT,
  `variety_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `maturity_period` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`variety_id`),
  UNIQUE KEY `uq_variety_name` (`variety_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coffee_variety`
--

LOCK TABLES `coffee_variety` WRITE;
/*!40000 ALTER TABLE `coffee_variety` DISABLE KEYS */;
INSERT INTO `coffee_variety` VALUES (1,'Robusta','Main Ugandan variety, hardy and high yield','18-24 months'),(2,'Arabica','Highland variety, high quality flavour','24-36 months'),(3,'Clonal','Improved Robusta clone with disease resistance','18-20 months');
/*!40000 ALTER TABLE `coffee_variety` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `distribution`
--

DROP TABLE IF EXISTS `distribution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `distribution` (
  `distribution_id` int NOT NULL AUTO_INCREMENT,
  `farmer_id` int NOT NULL,
  `item_id` int NOT NULL,
  `worker_id` int NOT NULL,
  `district_id` int NOT NULL,
  `quantity_given` decimal(10,2) NOT NULL,
  `distribution_date` date NOT NULL DEFAULT (curdate()),
  PRIMARY KEY (`distribution_id`),
  KEY `fk_dist_farmer` (`farmer_id`),
  KEY `fk_dist_item` (`item_id`),
  KEY `fk_dist_worker` (`worker_id`),
  KEY `fk_dist_district` (`district_id`),
  CONSTRAINT `fk_dist_district` FOREIGN KEY (`district_id`) REFERENCES `district` (`district_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_dist_farmer` FOREIGN KEY (`farmer_id`) REFERENCES `farmer` (`farmer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_dist_item` FOREIGN KEY (`item_id`) REFERENCES `input_item` (`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_dist_worker` FOREIGN KEY (`worker_id`) REFERENCES `extension_worker` (`worker_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_dist_qty` CHECK ((`quantity_given` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `distribution`
--

LOCK TABLES `distribution` WRITE;
/*!40000 ALTER TABLE `distribution` DISABLE KEYS */;
INSERT INTO `distribution` VALUES (1,1,1,1,1,200.00,'2024-02-10'),(2,2,1,1,1,150.00,'2024-02-10'),(3,3,3,1,2,5.00,'2024-03-01'),(4,4,2,2,3,100.00,'2024-01-20'),(5,5,4,2,4,10.00,'2024-03-15'),(6,6,3,1,1,2.00,'2026-04-12');
/*!40000 ALTER TABLE `distribution` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `district`
--

DROP TABLE IF EXISTS `district`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `district` (
  `district_id` int NOT NULL AUTO_INCREMENT,
  `district_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `region` enum('Central','Eastern','Western','Northern') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`district_id`),
  UNIQUE KEY `uq_district_name` (`district_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `district`
--

LOCK TABLES `district` WRITE;
/*!40000 ALTER TABLE `district` DISABLE KEYS */;
INSERT INTO `district` VALUES (1,'Mukono','Central'),(2,'Kampala','Central'),(3,'Masaka','Central'),(4,'Mbale','Eastern'),(5,'Mbarara','Western');
/*!40000 ALTER TABLE `district` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `extension_worker`
--

DROP TABLE IF EXISTS `extension_worker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `extension_worker` (
  `worker_id` int NOT NULL AUTO_INCREMENT,
  `person_id` int NOT NULL,
  `district_id` int NOT NULL,
  `qualification` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `specialisation` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `employment_date` date NOT NULL,
  `status` enum('Active','Inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`worker_id`),
  UNIQUE KEY `uq_worker_person` (`person_id`),
  KEY `fk_worker_district` (`district_id`),
  CONSTRAINT `fk_worker_district` FOREIGN KEY (`district_id`) REFERENCES `district` (`district_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_worker_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `extension_worker`
--

LOCK TABLES `extension_worker` WRITE;
/*!40000 ALTER TABLE `extension_worker` DISABLE KEYS */;
INSERT INTO `extension_worker` VALUES (1,6,1,'BSc Agriculture - Makerere University','Soil Management','2018-04-01','Active'),(2,7,3,'Diploma in Agriculture - NARO','Pest Control','2019-09-15','Active');
/*!40000 ALTER TABLE `extension_worker` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `farm_visit`
--

DROP TABLE IF EXISTS `farm_visit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `farm_visit` (
  `visit_id` int NOT NULL AUTO_INCREMENT,
  `worker_id` int NOT NULL,
  `farmer_id` int NOT NULL,
  `visit_date` date NOT NULL,
  `advice_given` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `issues_found` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `follow_up_required` enum('Yes','No') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'No',
  PRIMARY KEY (`visit_id`),
  KEY `fk_visit_worker` (`worker_id`),
  KEY `fk_visit_farmer` (`farmer_id`),
  CONSTRAINT `fk_visit_farmer` FOREIGN KEY (`farmer_id`) REFERENCES `farmer` (`farmer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_visit_worker` FOREIGN KEY (`worker_id`) REFERENCES `extension_worker` (`worker_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `farm_visit`
--

LOCK TABLES `farm_visit` WRITE;
/*!40000 ALTER TABLE `farm_visit` DISABLE KEYS */;
INSERT INTO `farm_visit` VALUES (1,1,1,'2024-04-05','Advised on proper pruning techniques and spacing','Minor leaf rust observed','Yes'),(2,1,2,'2024-04-12','Discussed soil pH management','Soil too acidic, needs lime','Yes'),(3,2,4,'2024-05-03','Trained on organic pest control methods','Antestia bug infestation mild','No'),(4,2,5,'2024-05-18','Advised on mulching and water retention','Dry spell stress observed','No');
/*!40000 ALTER TABLE `farm_visit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `farmer`
--

DROP TABLE IF EXISTS `farmer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `farmer` (
  `farmer_id` int NOT NULL AUTO_INCREMENT,
  `person_id` int NOT NULL,
  `location_id` int NOT NULL,
  `farm_size_acres` decimal(8,2) NOT NULL,
  `land_tenure` enum('Freehold','Leasehold','Customary','Mailo') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `registration_date` date NOT NULL DEFAULT (curdate()),
  `status` enum('Active','Inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`farmer_id`),
  UNIQUE KEY `uq_farmer_person` (`person_id`),
  KEY `fk_farmer_location` (`location_id`),
  CONSTRAINT `fk_farmer_location` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_farmer_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_farm_size` CHECK ((`farm_size_acres` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `farmer`
--

LOCK TABLES `farmer` WRITE;
/*!40000 ALTER TABLE `farmer` DISABLE KEYS */;
INSERT INTO `farmer` VALUES (1,1,1,2.50,'Freehold','2022-01-15','Active'),(2,2,2,1.00,'Customary','2022-03-20','Active'),(3,3,3,4.75,'Leasehold','2021-11-08','Active'),(4,4,5,0.75,'Customary','2023-05-01','Active'),(5,5,4,3.00,'Mailo','2020-07-12','Active'),(6,9,4,1.50,'Customary','2026-04-12','Active');
/*!40000 ALTER TABLE `farmer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `farmer_backup`
--

DROP TABLE IF EXISTS `farmer_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `farmer_backup` (
  `farmer_id` int NOT NULL DEFAULT '0',
  `person_id` int NOT NULL,
  `location_id` int NOT NULL,
  `farm_size_acres` decimal(8,2) NOT NULL,
  `land_tenure` enum('Freehold','Leasehold','Customary','Mailo') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `registration_date` date NOT NULL DEFAULT (curdate()),
  `status` enum('Active','Inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `farmer_backup`
--

LOCK TABLES `farmer_backup` WRITE;
/*!40000 ALTER TABLE `farmer_backup` DISABLE KEYS */;
INSERT INTO `farmer_backup` VALUES (1,1,1,2.50,'Freehold','2022-01-15','Active'),(2,2,2,1.00,'Customary','2022-03-20','Active'),(3,3,3,4.75,'Leasehold','2021-11-08','Active'),(4,4,5,0.75,'Customary','2023-05-01','Active'),(5,5,4,3.00,'Mailo','2020-07-12','Active');
/*!40000 ALTER TABLE `farmer_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `input_item`
--

DROP TABLE IF EXISTS `input_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `input_item` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `item_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` enum('Seedling','Fertiliser','Pesticide','Tool','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `unit_of_measure` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity_in_stock` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `uq_item_name` (`item_name`),
  CONSTRAINT `chk_stock` CHECK ((`quantity_in_stock` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `input_item`
--

LOCK TABLES `input_item` WRITE;
/*!40000 ALTER TABLE `input_item` DISABLE KEYS */;
INSERT INTO `input_item` VALUES (1,'Robusta Seedling Pack','Seedling','pieces',5000),(2,'Clonal Seedling Pack','Seedling','pieces',3000),(3,'NPK Fertiliser 50kg','Fertiliser','bags',796),(4,'Dithane Fungicide 1kg','Pesticide','kg',400),(5,'Hand Pruning Shears','Tool','pieces',200);
/*!40000 ALTER TABLE `input_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location` (
  `location_id` int NOT NULL AUTO_INCREMENT,
  `village` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sub_county` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `county` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `district_id` int NOT NULL,
  PRIMARY KEY (`location_id`),
  KEY `fk_location_district` (`district_id`),
  CONSTRAINT `fk_location_district` FOREIGN KEY (`district_id`) REFERENCES `district` (`district_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location`
--

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
INSERT INTO `location` VALUES (1,'Namataba','Kasawo','Mukono',1),(2,'Seeta','Seeta','Mukono',1),(3,'Kiteezi','Wakiso','Kampala',2),(4,'Bukomero','Masaka','Masaka',3),(5,'Namawojolo','Mbale','Mbale',4);
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ministry_staff`
--

DROP TABLE IF EXISTS `ministry_staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ministry_staff` (
  `staff_id` int NOT NULL AUTO_INCREMENT,
  `person_id` int NOT NULL,
  `department` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_level` enum('Admin','District','ReadOnly') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ReadOnly',
  PRIMARY KEY (`staff_id`),
  UNIQUE KEY `uq_staff_person` (`person_id`),
  CONSTRAINT `fk_staff_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ministry_staff`
--

LOCK TABLES `ministry_staff` WRITE;
/*!40000 ALTER TABLE `ministry_staff` DISABLE KEYS */;
INSERT INTO `ministry_staff` VALUES (1,8,'Agricultural Information','Database Administrator','Admin');
/*!40000 ALTER TABLE `ministry_staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `person` (
  `person_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nin` varchar(17) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` enum('Male','Female','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_of_birth` date NOT NULL,
  `phone` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`person_id`),
  UNIQUE KEY `uq_person_nin` (`nin`),
  UNIQUE KEY `uq_person_phone` (`phone`),
  CONSTRAINT `chk_phone_len` CHECK ((char_length(`phone`) >= 10))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person`
--

LOCK TABLES `person` WRITE;
/*!40000 ALTER TABLE `person` DISABLE KEYS */;
INSERT INTO `person` VALUES (1,'John','Kabugo','CM90000014250001','Male','1985-04-12','0701234567','jkabugo@email.com','Namataba Village','2026-04-12 19:56:12'),(2,'Prossy','Namutebi','CF88000023140002','Female','1988-07-22','0772345678','pnamutebi@email.com','Seeta, Mukono','2026-04-12 19:56:12'),(3,'Robert','Ssemakula','CM79000034120003','Male','1979-01-05','0783456789',NULL,'Kiteezi, Wakiso','2026-04-12 19:56:12'),(4,'Grace','Akello','CF92000045310004','Female','1992-11-30','0754567890','gakello@email.com','Mbale Town','2026-04-12 19:56:12'),(5,'David','Omunyu','CM86000056280005','Male','1986-03-18','0765678901',NULL,'Mbarara','2026-04-12 19:56:12'),(6,'Alice','Nantongo','CF90000067190006','Female','1990-09-09','0776789012','anantongo@email.com','Kampala','2026-04-12 19:56:12'),(7,'Moses','Tumwine','CM83000078230007','Male','1983-06-14','0707890123',NULL,'Masaka','2026-04-12 19:56:12'),(8,'Harriet','Kyomugisha','CF87000089170008','Female','1987-02-28','0718901234','hkyom@email.com','Mbarara','2026-04-12 19:56:12'),(9,'Kato','Emmanuel','CM95000099010017','Male','1995-08-21','0789999007','kato@email.com','Masaka Town','2026-04-12 19:56:27');
/*!40000 ALTER TABLE `person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `production_record`
--

DROP TABLE IF EXISTS `production_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `production_record` (
  `record_id` int NOT NULL AUTO_INCREMENT,
  `farmer_id` int NOT NULL,
  `variety_id` int NOT NULL,
  `season_id` int NOT NULL,
  `quantity_kg` decimal(10,2) NOT NULL,
  `quality_grade` enum('A','B','C','Ungraded') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Ungraded',
  `harvest_date` date NOT NULL,
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `uq_prod_record` (`farmer_id`,`variety_id`,`season_id`),
  KEY `fk_prod_variety` (`variety_id`),
  KEY `fk_prod_season` (`season_id`),
  CONSTRAINT `fk_prod_farmer` FOREIGN KEY (`farmer_id`) REFERENCES `farmer` (`farmer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_prod_season` FOREIGN KEY (`season_id`) REFERENCES `season` (`season_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_prod_variety` FOREIGN KEY (`variety_id`) REFERENCES `coffee_variety` (`variety_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_quantity` CHECK ((`quantity_kg` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `production_record`
--

LOCK TABLES `production_record` WRITE;
/*!40000 ALTER TABLE `production_record` DISABLE KEYS */;
INSERT INTO `production_record` VALUES (1,1,1,1,480.00,'A','2024-06-10'),(2,1,1,2,520.00,'B','2024-12-05'),(3,2,1,1,210.00,'B','2024-06-15'),(4,3,3,1,890.00,'A','2024-05-28'),(5,4,2,1,120.00,'A','2024-06-20'),(6,5,1,2,640.00,'B','2024-11-30'),(7,6,1,3,350.00,'A','2025-06-15');
/*!40000 ALTER TABLE `production_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `production_record_backup`
--

DROP TABLE IF EXISTS `production_record_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `production_record_backup` (
  `record_id` int NOT NULL DEFAULT '0',
  `farmer_id` int NOT NULL,
  `variety_id` int NOT NULL,
  `season_id` int NOT NULL,
  `quantity_kg` decimal(10,2) NOT NULL,
  `quality_grade` enum('A','B','C','Ungraded') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Ungraded',
  `harvest_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `production_record_backup`
--

LOCK TABLES `production_record_backup` WRITE;
/*!40000 ALTER TABLE `production_record_backup` DISABLE KEYS */;
INSERT INTO `production_record_backup` VALUES (1,1,1,1,480.00,'A','2024-06-10'),(2,1,1,2,520.00,'B','2024-12-05'),(3,2,1,1,210.00,'B','2024-06-15'),(4,3,3,1,890.00,'A','2024-05-28'),(5,4,2,1,120.00,'A','2024-06-20'),(6,5,1,2,640.00,'B','2024-11-30');
/*!40000 ALTER TABLE `production_record_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `season`
--

DROP TABLE IF EXISTS `season`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `season` (
  `season_id` int NOT NULL AUTO_INCREMENT,
  `season_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `year` year NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  PRIMARY KEY (`season_id`),
  UNIQUE KEY `uq_season` (`season_name`,`year`),
  CONSTRAINT `chk_season_dates` CHECK ((`end_date` > `start_date`))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `season`
--

LOCK TABLES `season` WRITE;
/*!40000 ALTER TABLE `season` DISABLE KEYS */;
INSERT INTO `season` VALUES (1,'Season 1',2024,'2024-03-01','2024-06-30'),(2,'Season 2',2024,'2024-10-01','2024-12-31'),(3,'Season 1',2025,'2025-03-01','2025-06-30');
/*!40000 ALTER TABLE `season` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seedling`
--

DROP TABLE IF EXISTS `seedling`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seedling` (
  `seedling_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `variety_id` int NOT NULL,
  `age_weeks` int DEFAULT NULL,
  `source_nursery` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`seedling_id`),
  KEY `fk_seedling_item` (`item_id`),
  KEY `fk_seedling_variety` (`variety_id`),
  CONSTRAINT `fk_seedling_item` FOREIGN KEY (`item_id`) REFERENCES `input_item` (`item_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_seedling_variety` FOREIGN KEY (`variety_id`) REFERENCES `coffee_variety` (`variety_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seedling`
--

LOCK TABLES `seedling` WRITE;
/*!40000 ALTER TABLE `seedling` DISABLE KEYS */;
INSERT INTO `seedling` VALUES (1,1,1,12,'Mukono NAADS Nursery'),(2,2,3,10,'Masaka Coffee Nursery');
/*!40000 ALTER TABLE `seedling` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_request`
--

DROP TABLE IF EXISTS `support_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_request` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `farmer_id` int NOT NULL,
  `worker_id` int DEFAULT NULL,
  `request_type` enum('Pest Control','Soil Advice','Seedling Request','Market Access','Financial Support','Other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('Pending','In Progress','Resolved') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `date_raised` date NOT NULL DEFAULT (curdate()),
  `date_resolved` date DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_req_farmer` (`farmer_id`),
  KEY `fk_req_worker` (`worker_id`),
  CONSTRAINT `fk_req_farmer` FOREIGN KEY (`farmer_id`) REFERENCES `farmer` (`farmer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_req_worker` FOREIGN KEY (`worker_id`) REFERENCES `extension_worker` (`worker_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_resolved_date` CHECK (((`date_resolved` is null) or (`date_resolved` >= `date_raised`)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_request`
--

LOCK TABLES `support_request` WRITE;
/*!40000 ALTER TABLE `support_request` DISABLE KEYS */;
INSERT INTO `support_request` VALUES (1,1,1,'Pest Control','Heavy CBB infestation in main block','Resolved','2024-03-10','2024-03-18'),(2,2,1,'Soil Advice','Yellow leaves, suspected nutrient issue','Resolved','2024-04-15','2026-04-12'),(3,3,NULL,'Seedling Request','Need 300 Clonal seedlings for expansion','Pending','2024-05-01',NULL),(4,5,2,'Market Access','Looking for certified coffee buyers','Resolved','2024-02-20','2024-03-05');
/*!40000 ALTER TABLE `support_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_farmer_profile`
--

DROP TABLE IF EXISTS `vw_farmer_profile`;
/*!50001 DROP VIEW IF EXISTS `vw_farmer_profile`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_farmer_profile` AS SELECT 
 1 AS `farmer_id`,
 1 AS `full_name`,
 1 AS `phone`,
 1 AS `email`,
 1 AS `gender`,
 1 AS `farm_size_acres`,
 1 AS `land_tenure`,
 1 AS `status`,
 1 AS `village`,
 1 AS `sub_county`,
 1 AS `district_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_open_requests`
--

DROP TABLE IF EXISTS `vw_open_requests`;
/*!50001 DROP VIEW IF EXISTS `vw_open_requests`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_open_requests` AS SELECT 
 1 AS `request_id`,
 1 AS `farmer_name`,
 1 AS `sub_county`,
 1 AS `district_name`,
 1 AS `request_type`,
 1 AS `description`,
 1 AS `status`,
 1 AS `date_raised`,
 1 AS `days_open`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_production_summary`
--

DROP TABLE IF EXISTS `vw_production_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_production_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_production_summary` AS SELECT 
 1 AS `farmer_name`,
 1 AS `district_name`,
 1 AS `variety_name`,
 1 AS `season_name`,
 1 AS `year`,
 1 AS `quantity_kg`,
 1 AS `quality_grade`,
 1 AS `harvest_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_stock_levels`
--

DROP TABLE IF EXISTS `vw_stock_levels`;
/*!50001 DROP VIEW IF EXISTS `vw_stock_levels`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_stock_levels` AS SELECT 
 1 AS `item_id`,
 1 AS `item_name`,
 1 AS `item_type`,
 1 AS `unit_of_measure`,
 1 AS `quantity_in_stock`,
 1 AS `total_distributed`,
 1 AS `stock_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_worker_activity`
--

DROP TABLE IF EXISTS `vw_worker_activity`;
/*!50001 DROP VIEW IF EXISTS `vw_worker_activity`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_worker_activity` AS SELECT 
 1 AS `worker_name`,
 1 AS `district_name`,
 1 AS `total_visits`,
 1 AS `total_distributions`,
 1 AS `requests_handled`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_farmer_profile`
--

/*!50001 DROP VIEW IF EXISTS `vw_farmer_profile`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50001 VIEW `vw_farmer_profile` AS select `f`.`farmer_id` AS `farmer_id`,concat(`p`.`first_name`,' ',`p`.`last_name`) AS `full_name`,`p`.`phone` AS `phone`,`p`.`email` AS `email`,`p`.`gender` AS `gender`,`f`.`farm_size_acres` AS `farm_size_acres`,`f`.`land_tenure` AS `land_tenure`,`f`.`status` AS `status`,`l`.`village` AS `village`,`l`.`sub_county` AS `sub_county`,`d`.`district_name` AS `district_name` from (((`farmer` `f` join `person` `p` on((`f`.`person_id` = `p`.`person_id`))) join `location` `l` on((`f`.`location_id` = `l`.`location_id`))) join `district` `d` on((`l`.`district_id` = `d`.`district_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_open_requests`
--

/*!50001 DROP VIEW IF EXISTS `vw_open_requests`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50001 VIEW `vw_open_requests` AS select `sr`.`request_id` AS `request_id`,concat(`p`.`first_name`,' ',`p`.`last_name`) AS `farmer_name`,`l`.`sub_county` AS `sub_county`,`d`.`district_name` AS `district_name`,`sr`.`request_type` AS `request_type`,`sr`.`description` AS `description`,`sr`.`status` AS `status`,`sr`.`date_raised` AS `date_raised`,(to_days(curdate()) - to_days(`sr`.`date_raised`)) AS `days_open` from ((((`support_request` `sr` join `farmer` `f` on((`sr`.`farmer_id` = `f`.`farmer_id`))) join `person` `p` on((`f`.`person_id` = `p`.`person_id`))) join `location` `l` on((`f`.`location_id` = `l`.`location_id`))) join `district` `d` on((`l`.`district_id` = `d`.`district_id`))) where (`sr`.`status` <> 'Resolved') order by `sr`.`date_raised` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_production_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_production_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50001 VIEW `vw_production_summary` AS select concat(`p`.`first_name`,' ',`p`.`last_name`) AS `farmer_name`,`d`.`district_name` AS `district_name`,`cv`.`variety_name` AS `variety_name`,`s`.`season_name` AS `season_name`,`s`.`year` AS `year`,`pr`.`quantity_kg` AS `quantity_kg`,`pr`.`quality_grade` AS `quality_grade`,`pr`.`harvest_date` AS `harvest_date` from ((((((`production_record` `pr` join `farmer` `f` on((`pr`.`farmer_id` = `f`.`farmer_id`))) join `person` `p` on((`f`.`person_id` = `p`.`person_id`))) join `location` `l` on((`f`.`location_id` = `l`.`location_id`))) join `district` `d` on((`l`.`district_id` = `d`.`district_id`))) join `coffee_variety` `cv` on((`pr`.`variety_id` = `cv`.`variety_id`))) join `season` `s` on((`pr`.`season_id` = `s`.`season_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_stock_levels`
--

/*!50001 DROP VIEW IF EXISTS `vw_stock_levels`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50001 VIEW `vw_stock_levels` AS select `i`.`item_id` AS `item_id`,`i`.`item_name` AS `item_name`,`i`.`item_type` AS `item_type`,`i`.`unit_of_measure` AS `unit_of_measure`,`i`.`quantity_in_stock` AS `quantity_in_stock`,coalesce(sum(`dist`.`quantity_given`),0) AS `total_distributed`,(case when (`i`.`quantity_in_stock` = 0) then 'Out of Stock' when (`i`.`quantity_in_stock` < 50) then 'Low Stock' else 'Sufficient' end) AS `stock_status` from (`input_item` `i` left join `distribution` `dist` on((`i`.`item_id` = `dist`.`item_id`))) group by `i`.`item_id`,`i`.`item_name`,`i`.`item_type`,`i`.`unit_of_measure`,`i`.`quantity_in_stock` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_worker_activity`
--

/*!50001 DROP VIEW IF EXISTS `vw_worker_activity`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50001 VIEW `vw_worker_activity` AS select concat(`pw`.`first_name`,' ',`pw`.`last_name`) AS `worker_name`,`d`.`district_name` AS `district_name`,count(distinct `fv`.`visit_id`) AS `total_visits`,count(distinct `dist`.`distribution_id`) AS `total_distributions`,count(distinct `sr`.`request_id`) AS `requests_handled` from (((((`extension_worker` `ew` join `person` `pw` on((`ew`.`person_id` = `pw`.`person_id`))) join `district` `d` on((`ew`.`district_id` = `d`.`district_id`))) left join `farm_visit` `fv` on((`fv`.`worker_id` = `ew`.`worker_id`))) left join `distribution` `dist` on((`dist`.`worker_id` = `ew`.`worker_id`))) left join `support_request` `sr` on((`sr`.`worker_id` = `ew`.`worker_id`))) group by `ew`.`worker_id`,`worker_name`,`d`.`district_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-12 23:48:15
