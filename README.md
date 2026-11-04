Job Portal Website
A job portal application built with Core PHP 8, MySQL, PDO, Bootstrap 5, and Chart.js. The project is designed for three types of users: Admin, Job Seeker, and Employer.
Repository status: The current GitHub repository contains the files listed below, but its entry-point and setup scripts reference additional folders that are not currently visible in the repository root. See Important setup note before trying to run it.

Features
Job Seeker
- Register and log in.
- Manage a personal profile and profile picture.
- Upload and manage resumes (PDF, DOC, and DOCX).
- Search and filter job listings.
- Apply for jobs and track application status.
- Save/bookmark jobs.
- Receive notifications.
Employer
- Register and associate an account with a company.
- Manage company details and logo.
- Create, edit, close, and delete job listings.
- Submit job listings for administrator approval.
- View applicants and access applicant resumes.
- Update application statuses.
- View hiring statistics.
Administrator
- View dashboard statistics.
- Manage job seeker and employer accounts.
- Suspend or delete accounts.
- Approve, reject, edit, feature, and delete job listings.
- Manage job categories.
- View applications.
- Manage website page content.
- Read contact form messages.
- View reports and charts.
Public Website
- Homepage with latest and featured jobs.
- Job listing, search, filters, and pagination.
- Job detail pages.
- Company pages.
- About and Contact pages.
- Custom 404 page.
Technology Stack
Technology	Purpose
PHP 8.1+	Server-side application
MySQL 5.7+ / MariaDB 10.3+	Relational database
PDO	Database access
HTML5 and CSS3	Page structure and styling
JavaScript	Frontend interactions
Bootstrap 5	Responsive interface
Chart.js	Dashboard charts
Apache	Local web server


Files Currently Visible in the Repository
job-portal-/
├── README.md
├── index.php
├── app.php
├── database.php
├── web.php
├── create_admin.php
├── seed_demo.php
├── job_portal.sql
├── env.example
├── style.css
├── app.js
└── placeholder.svg
The repository also currently contains php-error.log. Error logs should generally not be committed because they can expose paths or application details.
Database
The SQL schema creates a database named job_portal and defines these tables:
Table	Purpose
users	User accounts and roles
job_seekers	Job seeker profiles
companies	Company information
employers	Employer accounts
job_categories	Job categories
jobs	Job listings
resumes	Uploaded resume records
applications	Job applications
saved_jobs	Bookmarked jobs
notifications	User notifications
contact_messages	Contact form submissions
pages	Editable website pages


The schema uses InnoDB, utf8mb4, foreign keys, and unique constraints. A unique constraint on (job_id, job_seeker_id) prevents duplicate applications.
Warning: The SQL script includes DROP TABLE IF EXISTS statements. Importing it into an existing job_portal database can delete the existing tables and their data. Back up your database before importing.

Requirements
- PHP 8.1 or newer.
- MySQL 5.7+ or MariaDB 10.3+.
- Apache (XAMPP is suitable for local development).
- PHP extensions: pdo_mysql, fileinfo, and gd; zip is recommended.
- Apache mod_rewrite and AllowOverride All for the intended routed application.
Installation with XAMPP
1. Install XAMPP and start Apache and MySQL.
2. Clone or download this repository into your XAMPP htdocs directory:
   git clone https://github.com/shivammpandey21/job-portal-.git
3. Create/import the database using phpMyAdmin:
   - Open http://localhost/phpmyadmin/.
   - Choose Import.
   - Select job_portal.sql.
   - Confirm the import.
   The SQL file creates the job_portal database itself.
4. Copy env.example to .env and set the database values for your local environment. The database configuration reads values such as:
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=job_portal
   DB_USERNAME=root
   DB_PASSWORD=
5. Configure the Apache document root and restore the application folders described in the next section before opening the site.
Important Setup Note
The current repository root does not contain all the paths referenced by the PHP entry point and helper scripts.

For example:
- index.php expects config/app.php, app/core/helpers.php, app/controllers/, app/models/, and routes/web.php.
- create_admin.php expects the configuration and database classes under config/ and app/core/; its usage comment refers to scripts/create_admin.php.
- The root currently shows app.php, database.php, and web.php, rather than those expected directory paths.
Therefore, the repository as currently uploaded may not run directly in XAMPP. Restore/upload the missing application directories and place each file at the path expected by the code before following the normal run instructions. Do not assume that moving only the root PHP files will fix these dependencies.

Once the expected structure and Apache configuration are in place, the intended local URL is:
http://localhost/job-portal/
Admin Account and Demo Data
The create_admin.php script is intended to create an administrator account from the command line. Its source comment specifies a minimum password length of 10 characters and prompts for the password rather than putting it in the command itself.

The seed_demo.php file is provided for demo data. Review its code and run it only in a local development database. Do not use demo seed data in production.

Because the current repository paths do not match the paths expected by these scripts, verify and correct their locations before running them.
Security Notes
The application source describes security measures including:
- Password hashing and verification.
- PDO prepared statements.
- CSRF protection for POST requests.
- Escaped output.
- Session hardening and role-based access checks.
- Upload validation and generated filenames.
- Private resume storage with authorization checks.
Before deploying publicly:
- Use HTTPS.
- Set production-only secrets and disable debug output.
- Keep .env, uploaded resumes, and logs out of public web access.
- Do not commit passwords, credentials, or error logs.
- Configure backups and server-side rate limiting.
- Test authentication, authorization, uploads, and database operations.
Testing Status
The repository README states that PHP syntax checks passed in its original development environment, but database integration, file uploads, email delivery, and browser-level workflows were not tested there. Run the application locally and verify the full workflow before deployment.
