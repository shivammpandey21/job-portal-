-- ============================================================
-- Job Portal database schema
-- MySQL 5.7+ / MariaDB 10.3+ (InnoDB, utf8mb4)
-- Import:  mysql -u USER -p < database/job_portal.sql
-- ============================================================
CREATE DATABASE IF NOT EXISTS `job_portal` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `job_portal`;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `pages`, `contact_messages`, `notifications`, `saved_jobs`, `applications`,
    `resumes`, `jobs`, `job_categories`, `employers`, `companies`, `job_seekers`, `users`;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. users: one row per account, role decides the dashboard
CREATE TABLE `users` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(100) NOT NULL,
  `email`      VARCHAR(150) NOT NULL,
  `password`   VARCHAR(255) NOT NULL,            -- password_hash() output
  `role`       ENUM('admin','job_seeker','employer') NOT NULL,
  `status`     ENUM('active','suspended') NOT NULL DEFAULT 'active',
  `last_login_at` DATETIME NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_role_status` (`role`,`status`)
) ENGINE=InnoDB;

-- 2. job_seekers: profile data (1:1 with users)
CREATE TABLE `job_seekers` (
  `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`          INT UNSIGNED NOT NULL,
  `phone`            VARCHAR(20) NULL,
  `headline`         VARCHAR(150) NULL,
  `location`         VARCHAR(120) NULL,
  `bio`              TEXT NULL,
  `skills`           VARCHAR(500) NULL,
  `experience_years` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `education`        VARCHAR(255) NULL,
  `profile_image`    VARCHAR(255) NULL,
  `created_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_job_seekers_user` (`user_id`),
  CONSTRAINT `fk_job_seekers_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. companies
CREATE TABLE `companies` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(150) NOT NULL,
  `slug`        VARCHAR(170) NOT NULL,
  `description` TEXT NULL,
  `industry`    VARCHAR(100) NULL,
  `company_size` ENUM('1-10','11-50','51-200','201-500','501-1000','1000+') NULL,
  `website`     VARCHAR(255) NULL,
  `location`    VARCHAR(120) NULL,
  `logo`        VARCHAR(255) NULL,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_companies_slug` (`slug`),
  KEY `idx_companies_name` (`name`)
) ENGINE=InnoDB;

-- 4. employers: recruiter account (1:1 with users), belongs to a company
CREATE TABLE `employers` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED NOT NULL,
  `company_id`  INT UNSIGNED NULL,
  `phone`       VARCHAR(20) NULL,
  `designation` VARCHAR(100) NULL,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_employers_user` (`user_id`),
  KEY `idx_employers_company` (`company_id`),
  CONSTRAINT `fk_employers_user`    FOREIGN KEY (`user_id`)    REFERENCES `users`(`id`)     ON DELETE CASCADE,
  CONSTRAINT `fk_employers_company` FOREIGN KEY (`company_id`) REFERENCES `companies`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 5. job_categories
CREATE TABLE `job_categories` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(100) NOT NULL,
  `slug`        VARCHAR(120) NOT NULL,
  `description` VARCHAR(255) NULL,
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_categories_name` (`name`),
  UNIQUE KEY `uq_categories_slug` (`slug`)
) ENGINE=InnoDB;

-- 6. jobs
CREATE TABLE `jobs` (
  `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_id`       INT UNSIGNED NOT NULL,
  `employer_id`      INT UNSIGNED NOT NULL,
  `category_id`      INT UNSIGNED NULL,
  `title`            VARCHAR(200) NOT NULL,
  `description`      TEXT NOT NULL,
  `requirements`     TEXT NULL,
  `location`         VARCHAR(120) NOT NULL,
  `employment_type`  ENUM('full_time','part_time','contract','internship','freelance') NOT NULL DEFAULT 'full_time',
  `experience_level` ENUM('entry','junior','mid','senior','lead') NOT NULL DEFAULT 'entry',
  `salary_min`       DECIMAL(12,2) NULL,
  `salary_max`       DECIMAL(12,2) NULL,
  `vacancies`        SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  `deadline`         DATE NULL,
  `status`           ENUM('pending','approved','rejected','closed') NOT NULL DEFAULT 'pending',
  `is_featured`      TINYINT(1) NOT NULL DEFAULT 0,
  `created_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_jobs_company` (`company_id`),
  KEY `idx_jobs_employer` (`employer_id`),
  KEY `idx_jobs_category` (`category_id`),
  KEY `idx_jobs_location` (`location`),
  KEY `idx_jobs_filters` (`status`,`employment_type`,`experience_level`),
  KEY `idx_jobs_salary` (`salary_min`,`salary_max`),
  KEY `idx_jobs_featured` (`is_featured`,`status`),
  KEY `idx_jobs_created` (`created_at`),
  FULLTEXT KEY `ft_jobs_title_desc` (`title`,`description`),
  CONSTRAINT `fk_jobs_company`  FOREIGN KEY (`company_id`)  REFERENCES `companies`(`id`)      ON DELETE CASCADE,
  CONSTRAINT `fk_jobs_employer` FOREIGN KEY (`employer_id`) REFERENCES `employers`(`id`)      ON DELETE CASCADE,
  CONSTRAINT `fk_jobs_category` FOREIGN KEY (`category_id`) REFERENCES `job_categories`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 7. resumes: uploaded files owned by a job seeker
CREATE TABLE `resumes` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `job_seeker_id` INT UNSIGNED NOT NULL,
  `file_name`     VARCHAR(255) NOT NULL,       -- generated unique name on disk
  `original_name` VARCHAR(255) NOT NULL,
  `mime_type`     VARCHAR(100) NOT NULL,
  `file_size`     INT UNSIGNED NOT NULL,
  `is_default`    TINYINT(1) NOT NULL DEFAULT 0,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_resumes_file` (`file_name`),
  KEY `idx_resumes_seeker` (`job_seeker_id`),
  CONSTRAINT `fk_resumes_seeker` FOREIGN KEY (`job_seeker_id`) REFERENCES `job_seekers`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 8. applications: UNIQUE(job, seeker) prevents duplicate applications
CREATE TABLE `applications` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `job_id`        INT UNSIGNED NOT NULL,
  `job_seeker_id` INT UNSIGNED NOT NULL,
  `resume_id`     INT UNSIGNED NULL,
  `cover_letter`  TEXT NULL,
  `status`        ENUM('pending','reviewed','shortlisted','rejected','hired') NOT NULL DEFAULT 'pending',
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_application_job_seeker` (`job_id`,`job_seeker_id`),
  KEY `idx_applications_seeker` (`job_seeker_id`),
  KEY `idx_applications_status` (`status`),
  KEY `idx_applications_resume` (`resume_id`),
  CONSTRAINT `fk_applications_job`    FOREIGN KEY (`job_id`)        REFERENCES `jobs`(`id`)        ON DELETE CASCADE,
  CONSTRAINT `fk_applications_seeker` FOREIGN KEY (`job_seeker_id`) REFERENCES `job_seekers`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_applications_resume` FOREIGN KEY (`resume_id`)     REFERENCES `resumes`(`id`)     ON DELETE SET NULL
) ENGINE=InnoDB;

-- 9. saved_jobs (bookmarks)
CREATE TABLE `saved_jobs` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `job_seeker_id` INT UNSIGNED NOT NULL,
  `job_id`        INT UNSIGNED NOT NULL,
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_saved_seeker_job` (`job_seeker_id`,`job_id`),
  KEY `idx_saved_job` (`job_id`),
  CONSTRAINT `fk_saved_seeker` FOREIGN KEY (`job_seeker_id`) REFERENCES `job_seekers`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_saved_job`    FOREIGN KEY (`job_id`)        REFERENCES `jobs`(`id`)        ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10. notifications
CREATE TABLE `notifications` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    INT UNSIGNED NOT NULL,
  `title`      VARCHAR(150) NOT NULL,
  `message`    VARCHAR(500) NOT NULL,
  `link`       VARCHAR(255) NULL,
  `is_read`    TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notifications_user_read` (`user_id`,`is_read`),
  CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 11. contact_messages
CREATE TABLE `contact_messages` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(100) NOT NULL,
  `email`      VARCHAR(150) NOT NULL,
  `subject`    VARCHAR(200) NOT NULL,
  `message`    TEXT NOT NULL,
  `is_read`    TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_contact_read` (`is_read`)
) ENGINE=InnoDB;

-- 12. pages: editable website content (About Us etc.) for "Manage website content" in admin
CREATE TABLE `pages` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`       VARCHAR(80) NOT NULL,
  `title`      VARCHAR(150) NOT NULL,
  `content`    MEDIUMTEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pages_slug` (`slug`)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Seed data (no user accounts: create the admin with scripts/create_admin.php)
-- ------------------------------------------------------------
INSERT INTO `job_categories` (`name`,`slug`,`description`) VALUES
 ('Information Technology','information-technology','Software, web, data and IT support'),
 ('Marketing & Sales','marketing-sales','Digital marketing, sales and business development'),
 ('Finance & Accounting','finance-accounting','Accounting, banking and finance roles'),
 ('Healthcare','healthcare','Doctors, nurses and medical staff'),
 ('Education','education','Teaching and training roles'),
 ('Design & Creative','design-creative','Graphic, UI/UX and content design'),
 ('Engineering','engineering','Civil, mechanical and electrical engineering'),
 ('Human Resources','human-resources','Recruitment and HR management'),
 ('Customer Support','customer-support','Support and service desk roles'),
 ('Operations & Logistics','operations-logistics','Supply chain, operations and logistics');

INSERT INTO `pages` (`slug`,`title`,`content`) VALUES
 ('about','About Us','<p>We connect talented job seekers with great employers.</p>');
