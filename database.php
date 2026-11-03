<?php
/**
 * Database configuration. Credentials are read from .env only.
 */
declare(strict_types=1);

return [
    'host'    => env('DB_HOST', '127.0.0.1'),
    'port'    => env('DB_PORT', '3306'),
    'name'    => env('DB_DATABASE', env('DB_NAME', 'job_portal')),
    'user'    => env('DB_USERNAME', env('DB_USER', 'root')),
    'pass'    => env('DB_PASSWORD', env('DB_PASS', '')),
    'charset' => 'utf8mb4',
];
