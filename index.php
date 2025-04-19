<?php
// Main entry point for the API
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get the request path
$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);
$path = ltrim($path, '/');
$segments = explode('/', $path);

// Route the request to the appropriate handler
if (count($segments) >= 2) {
    $resource = $segments[0];
    $action = $segments[1];
    
    switch ($resource) {
        case 'auth':
            require_once 'controllers/auth_controller.php';
            $controller = new AuthController();
            break;
        case 'products':
            require_once 'controllers/product_controller.php';
            $controller = new ProductController();
            break;
        case 'inventory':
            require_once 'controllers/inventory_controller.php';
            $controller = new InventoryController();
            break;
        case 'warehouses':
            require_once 'controllers/warehouse_controller.php';
            $controller = new WarehouseController();
            break;
        case 'transactions':
            require_once 'controllers/transaction_controller.php';
            $controller = new TransactionController();
            break;
        case 'activity_logs':
            require_once 'controllers/activity_log_controller.php';
            $controller = new ActivityLogController();
            break;
        case 'analytics':
            require_once 'controllers/analytics_controller.php';
            $controller = new AnalyticsController();
            break;
        default:
            http_response_code(404);
            echo json_encode(array("message" => "Resource not found"));
            exit;
    }
    
    // Call the appropriate method based on the HTTP method and action
    $method = strtolower($_SERVER['REQUEST_METHOD']);
    
    if ($method === 'get' && $action === 'read') {
        $controller->read();
    } elseif ($method === 'post' && $action === 'create') {
        $controller->create();
    } elseif ($method === 'post' && $action === 'login') {
        $controller->login();
    } elseif ($method === 'put' && $action === 'update') {
        $controller->update();
    } elseif ($method === 'delete' && $action === 'delete') {
        $controller->delete();
    } else {
        http_response_code(405);
        echo json_encode(array("message" => "Method not allowed"));
    }
} else {
    // Return API info if no specific resource is requested
    echo json_encode(array(
        "name" => "SuperVault API",
        "version" => "1.0.0",
        "description" => "API for SuperVault Inventory Management System"
    ));
}
?>
