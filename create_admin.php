<?php
/**
 * Create (or reset) the admin account from the command line.
 * Usage:  php scripts/create_admin.php "Admin Name" admin@example.com
 * The password is requested interactively so it never lands in shell history or Git.
 */
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    exit('CLI only.');
}

define('BASE_PATH', dirname(__DIR__));
require BASE_PATH . '/config/app.php';
require BASE_PATH . '/app/core/Database.php';

[$script, $name, $email] = $argv + [null, null, null];
if (!$name || !$email || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    exit("Usage: php scripts/create_admin.php \"Admin Name\" admin@example.com\n");
}

echo 'Password (min 10 chars): ';
if (stripos(PHP_OS, 'WIN') !== 0) { system('stty -echo'); }
$password = trim((string) fgets(STDIN));
if (stripos(PHP_OS, 'WIN') !== 0) { system('stty echo'); }
echo "\n";
if (strlen($password) < 10) {
    exit("Password too short.\n");
}

$db   = Database::connection();
$hash = password_hash($password, PASSWORD_DEFAULT);
$db->prepare(
    "INSERT INTO users (name,email,password,role,status) VALUES (?,?,?, 'admin','active')
     ON DUPLICATE KEY UPDATE name = VALUES(name), password = VALUES(password), role = 'admin', status = 'active'"
)->execute([$name, $email, $hash]);

echo "Admin account ready for $email\n";
