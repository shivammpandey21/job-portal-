<?php
declare(strict_types=1);

define('BASE_PATH', dirname(__DIR__));

$config = require BASE_PATH . '/config/app.php';
if (!is_array($config)) {
    throw new RuntimeException('Application configuration must return an array.');
}
$GLOBALS['app_config'] = $config;

error_reporting(E_ALL);

ini_set(
    'display_errors',
    $config['debug'] ? '1' : '0'
);

ini_set('log_errors', '1');

ini_set(
    'error_log',
    BASE_PATH . '/storage/logs/php-error.log'
);

require BASE_PATH . '/app/core/helpers.php';

// Autoloader
spl_autoload_register(function (string $class): void {
    foreach (['app/core', 'app/controllers', 'app/models'] as $dir) {
        $file = BASE_PATH . "/$dir/$class.php";

        if (is_file($file)) {
            require $file;
            return;
        }
    }
});

Session::start();

$router = new Router();

require BASE_PATH . '/routes/web.php';

try {
    $router->dispatch(
        $_SERVER['REQUEST_METHOD'],
        $_SERVER['REQUEST_URI']
    );
} catch (Throwable $ex) {
    error_log(
        $ex->getMessage() . ' in ' .
        $ex->getFile() . ':' . $ex->getLine()
    );

    http_response_code(500);

    if ($config['debug']) {
        echo '<pre>' . e((string) $ex) . '</pre>';
    } else {
        (new ErrorController())->serverError();
    }
}