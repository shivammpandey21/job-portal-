<?php
declare(strict_types=1);

/**
 * Application configuration
 */

// Load environment variables from .env
if (!function_exists('loadEnv')) {
    function loadEnv(string $file): void
    {
        if (!is_readable($file)) {
            return;
        }

        foreach (file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
            $line = trim($line);

            if ($line === '' || $line[0] === '#' || !str_contains($line, '=')) {
                continue;
            }

            [$key, $value] = explode('=', $line, 2);

            // Remove inline comments and surrounding quotes
            $value = trim(preg_replace('/\s+#.*$/', '', $value));
            $value = trim($value, "\"'");

            $_ENV[trim($key)] = $value;
        }
    }
}

// Read environment variable
if (!function_exists('env')) {
    function env(string $key, $default = null)
    {
        return $_ENV[$key] ?? $default;
    }
}

// Load .env
loadEnv(BASE_PATH . '/.env');

// Infer the application directory when APP_BASE_PATH is not configured.
$scriptDirectory = str_replace('\\', '/', dirname((string) ($_SERVER['SCRIPT_NAME'] ?? '')));
if ($scriptDirectory === '/' || $scriptDirectory === '.') {
    $scriptDirectory = '';
}

// Normalize base path; an empty setting also allows automatic detection.
$configuredBasePath = trim((string) env('APP_BASE_PATH', ''));
$basePath = rtrim($configuredBasePath !== '' ? $configuredBasePath : $scriptDirectory, '/');

if ($basePath === '/public') {
    $basePath = '';
} elseif (str_ends_with($basePath, '/public')) {
    $basePath = substr($basePath, 0, -7);
}

// Normalize application URL
$appUrl = rtrim((string) env('APP_URL', ''), '/');

if (str_ends_with($appUrl, '/public')) {
    $appUrl = substr($appUrl, 0, -7);
}

// Return configuration
return [
    'name'      => env('APP_NAME', 'Job Portal'),
    'env'       => env('APP_ENV', 'production'),
    'debug'     => filter_var(env('APP_DEBUG', 'false'), FILTER_VALIDATE_BOOLEAN),
    'url'       => $appUrl,
    'base_path' => $basePath,
];