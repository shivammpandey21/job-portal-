<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    exit("CLI only.\n");
}

define('BASE_PATH', dirname(__DIR__));
$config = require BASE_PATH . '/config/app.php';
if (($config['env'] ?? 'production') !== 'local') {
    exit("Demo data can only be added when APP_ENV=local.\n");
}

require BASE_PATH . '/app/core/Database.php';

$db = Database::connection();
$companies = [
    [
        'name' => 'Northstar Digital (Demo)',
        'slug' => 'northstar-digital-demo',
        'industry' => 'Technology',
        'location' => 'Remote',
        'category' => 'information-technology',
        'jobs' => [
            ['Senior Product Designer', 'Remote', 'full_time', 'senior', 105000, 135000, true, 1],
            ['Frontend Engineer', 'New York, NY', 'full_time', 'mid', 115000, 145000, false, 2],
        ],
    ],
    [
        'name' => 'Fieldstone Creative (Demo)',
        'slug' => 'fieldstone-creative-demo',
        'industry' => 'Design & Creative',
        'location' => 'Austin, TX',
        'category' => 'design-creative',
        'jobs' => [
            ['Brand & Content Strategist', 'Austin, TX / Hybrid', 'full_time', 'mid', 78000, 98000, true, 3],
            ['Visual Design Intern', 'Remote', 'internship', 'entry', 25, 32, false, 2],
        ],
    ],
    [
        'name' => 'Everwell Care (Demo)',
        'slug' => 'everwell-care-demo',
        'industry' => 'Healthcare',
        'location' => 'Seattle, WA',
        'category' => 'healthcare',
        'jobs' => [
            ['Community Health Program Manager', 'Seattle, WA', 'full_time', 'senior', 92000, 118000, true, 1],
            ['Patient Support Coordinator', 'Seattle, WA / Hybrid', 'full_time', 'junior', 54000, 68000, false, 4],
        ],
    ],
];

$password = rtrim(strtr(base64_encode(random_bytes(18)), '+/', '-_'), '=');
$createdAccounts = [];

try {
    $db->beginTransaction();

    foreach ($companies as $company) {
        $categoryQuery = $db->prepare('SELECT id FROM job_categories WHERE slug = ? LIMIT 1');
        $categoryQuery->execute([$company['category']]);
        $categoryId = $categoryQuery->fetchColumn();
        if ($categoryId === false) {
            throw new RuntimeException("Required category is missing: {$company['category']}");
        }

        $companyQuery = $db->prepare(
            'INSERT INTO companies (name, slug, industry, location) VALUES (?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)'
        );
        $companyQuery->execute([$company['name'], $company['slug'], $company['industry'], $company['location']]);
        $companyId = (int) $db->lastInsertId();

        $email = 'demo+' . str_replace('-', '', $company['slug']) . '@job-portal.test';
        $userQuery = $db->prepare('SELECT id, role FROM users WHERE email = ? LIMIT 1');
        $userQuery->execute([$email]);
        $user = $userQuery->fetch();
        if ($user && $user['role'] !== 'employer') {
            throw new RuntimeException("Demo email is already used by a non-employer account: $email");
        }

        if (!$user) {
            $userQuery = $db->prepare(
                "INSERT INTO users (name, email, password, role, status) VALUES (?, ?, ?, 'employer', 'active')"
            );
            $userQuery->execute([$company['name'] . ' Recruiter', $email, password_hash($password, PASSWORD_DEFAULT)]);
            $userId = (int) $db->lastInsertId();
            $createdAccounts[] = $email;
        } else {
            $userId = (int) $user['id'];
        }

        $employerQuery = $db->prepare('SELECT id FROM employers WHERE user_id = ? LIMIT 1');
        $employerQuery->execute([$userId]);
        $employerId = $employerQuery->fetchColumn();
        if ($employerId === false) {
            $employerQuery = $db->prepare('INSERT INTO employers (user_id, company_id) VALUES (?, ?)');
            $employerQuery->execute([$userId, $companyId]);
            $employerId = $db->lastInsertId();
        } else {
            $updateEmployer = $db->prepare('UPDATE employers SET company_id = ? WHERE id = ?');
            $updateEmployer->execute([$companyId, $employerId]);
        }

        foreach ($company['jobs'] as [$title, $location, $type, $level, $salaryMin, $salaryMax, $featured, $daysAgo]) {
            $exists = $db->prepare('SELECT id FROM jobs WHERE company_id = ? AND title = ? LIMIT 1');
            $exists->execute([$companyId, $title]);
            if ($exists->fetchColumn() !== false) {
                continue;
            }

            $insertJob = $db->prepare(
                "INSERT INTO jobs
                    (company_id, employer_id, category_id, title, description, requirements, location,
                     employment_type, experience_level, salary_min, salary_max, vacancies, status,
                     is_featured, created_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, 'approved', ?, DATE_SUB(NOW(), INTERVAL ? DAY))"
            );
            $insertJob->execute([
                $companyId,
                $employerId,
                $categoryId,
                $title,
                "Demo job listing. Join {$company['name']} and help build thoughtful products and services that make a difference.",
                'Clear communication, relevant experience, and a collaborative approach.',
                $location,
                $type,
                $level,
                $salaryMin,
                $salaryMax,
                $featured ? 1 : 0,
                $daysAgo,
            ]);
        }
    }

    $db->commit();
} catch (Throwable $error) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    fwrite(STDERR, 'Could not add demo data: ' . $error->getMessage() . PHP_EOL);
    exit(1);
}

echo "Demo job listings are ready. Run this script again to safely skip existing jobs.\n";
if ($createdAccounts) {
    echo "New demo employer accounts (local use only):\n";
    foreach ($createdAccounts as $email) {
        echo "  $email\n";
    }
    echo "Temporary password (shared by new accounts): $password\n";
} else {
    echo "Demo employer accounts already exist; their passwords were not changed.\n";
}
echo "Remove the demo companies, jobs, and employer accounts before production deployment.\n";
