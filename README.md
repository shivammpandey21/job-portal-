# Job Portal (Core PHP + MySQL)

A job portal with three roles (Admin, Job Seeker, Employer) built with Core PHP 8 (OOP, custom MVC), PDO/MySQL, Bootstrap 5 and Chart.js.

> **Status:** all modules are written, but this code has **not been executed or tested yet** (it was authored in an environment without PHP/MySQL).
> Work through `TESTING.md`, fix anything that fails, and only then deploy (`DEPLOYMENT.md`). Screenshots and a live URL must come from your own run: none are included.

## Features
**Job seeker:** register/login, profile + picture, up to 5 resumes (PDF/DOC/DOCX), search & filter jobs, apply (no duplicates), track status (Pending, Reviewed, Shortlisted, Rejected, Hired), save/bookmark jobs, notifications.
**Employer:** register with company, company profile + logo, post/edit/close/delete jobs (admin approval), view applicants, download resumes, change status, hiring stats.
**Admin:** live dashboard stats, manage job seekers/employers (suspend/delete), approve/reject/edit/feature/delete jobs, manage categories, view all applications, edit website content (About page), read contact messages, reports with charts.
**Public:** home (latest + featured jobs, categories), job listing/search with pagination, job details, company pages, About, Contact, 404.

## Requirements
PHP 8.1+ (required extensions: pdo_mysql, fileinfo, gd; zip recommended), MySQL 5.7+/MariaDB 10.3+, Apache with `mod_rewrite` and `AllowOverride All`.

## Installation (local, e.g. XAMPP)
1. Place the folder at `htdocs/job-portal`.
2. Import the database: `mysql -u root -p < database/job_portal.sql` (or phpMyAdmin > Import).
3. `cp .env.example .env` and set `DB_*` and `APP_BASE_PATH=/job-portal`.
4. Create the admin: `php scripts/create_admin.php "Admin" admin@example.com` (password is prompted, min 10 chars).
5. Make `public/uploads/*` and `storage/` writable by the web server. Keep `storage/resumes` private and do not expose it through Apache.
6. Open `http://localhost/job-portal/`. The project root `.htaccess` forwards requests into `public/`; ensure Apache `mod_rewrite` and `AllowOverride All` are enabled.

There are **no default credentials**: you choose the admin password in step 4.

### Optional demo listings
For a local preview, set `APP_ENV=local` in `.env`, then run `php scripts/seed_demo.php`. This creates fictional sample companies, employer accounts and job listings. The script prints a randomly generated temporary password for any accounts it creates and skips listings already added. Do not run it on production; remove its demo records before deployment.

## Folder structure
```
app/core         Router, Controller, Model, Database, Session, Csrf, Auth, Validator, Upload, helpers
app/controllers  Auth, Dashboard, Home, Page, Job, Seeker, Employer, Resume, Notification, Admin, Error
app/models       User, JobSeeker, Employer, Company, Job, Category, Application, Resume, SavedJob, Notification, Page, ContactMessage
app/views        layouts, auth, home, jobs, pages, seeker, employer, admin, dashboard, errors
config/          app.php, database.php (read from .env)
public/          index.php (document root), assets/, uploads/ (images only)
routes/web.php   all routes
storage/         logs/, resumes/ (private, outside web access)
database/job_portal.sql
```

## Database tables and relationships
| Table | Purpose |
|---|---|
| users | accounts; `role` = admin / job_seeker / employer; `status` active/suspended |
| job_seekers | profile, 1:1 with users |
| employers | recruiter, 1:1 with users, N:1 companies |
| companies | company profile and logo |
| job_categories | categories (1:N jobs) |
| jobs | postings; belongs to company, employer, category; status pending/approved/rejected/closed |
| resumes | uploaded files per job seeker (stored privately) |
| applications | job_seeker applies to job with a resume; **UNIQUE(job_id, job_seeker_id)** prevents duplicates |
| saved_jobs | bookmarks; UNIQUE(job_seeker_id, job_id) |
| notifications | per-user messages |
| contact_messages | contact form submissions |
| pages | admin-editable website content (extra table) |

## Security summary
PDO prepared statements everywhere (real, non-emulated) - `password_hash`/`password_verify` - CSRF token on every POST - output escaped with `e()` - hardened session cookies + ID regeneration on login - role checks in every controller action - login throttling (session-based) - uploads: size limit, extension + real MIME + content checks, random filenames, images re-encoded with GD, resumes stored outside the web root and served only after an authorisation check, uploads folder cannot execute code - secrets only in `.env` (git-ignored).

## Notes / limits
- Job edits by employers return the job to *pending* for re-approval.
- Login throttling is per session; add IP-based limiting at the server/WAF level for production.
- If a form with a file exceeds `post_max_size`, PHP drops the whole POST and you will see the "session expired" page; raise `upload_max_filesize`/`post_max_size` (>= 8M) if needed.
\n## Verification notes\n- PHP syntax check: passed for all PHP source files using PHP 8.4 CLI.\n- Database integration, uploads, email delivery and browser-level interaction tests: not run here. Run the full checklist in `TESTING.md` after importing the schema in XAMPP.\n- Configure SMTP or an email provider before enabling production email workflows.\n- Configure HTTPS, production secrets, backups and server-side rate limiting before public deployment.\n