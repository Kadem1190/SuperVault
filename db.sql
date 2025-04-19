-- Create database
CREATE DATABASE IF NOT EXISTS supervault;
USE supervault;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'staff') NOT NULL DEFAULT 'staff',
    avatar_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    category_id VARCHAR(36) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Create warehouses table
CREATE TABLE IF NOT EXISTS warehouses (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    capacity INT NOT NULL,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create inventory table
CREATE TABLE IF NOT EXISTS inventory (
    id VARCHAR(36) PRIMARY KEY,
    product_id VARCHAR(36) NOT NULL,
    warehouse_id VARCHAR(36) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    location VARCHAR(100) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    UNIQUE KEY product_warehouse (product_id, warehouse_id)
);

-- Create transactions table
CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(36) PRIMARY KEY,
    product_id VARCHAR(36) NOT NULL,
    warehouse_id VARCHAR(36) NOT NULL,
    destination_warehouse_id VARCHAR(36),
    user_id VARCHAR(36) NOT NULL,
    type ENUM('stock_in', 'stock_out', 'transfer', 'adjustment') NOT NULL,
    quantity INT NOT NULL,
    notes TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (destination_warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create activity_logs table
CREATE TABLE IF NOT EXISTS activity_logs (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    activity_type ENUM('create', 'read', 'update', 'delete') NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(36) NOT NULL,
    description TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Insert demo data: users
INSERT INTO users (id, name, email, password, role) VALUES
('1', 'Admin User', 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'), -- password: password123
('2', 'John Smith', 'john@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'staff'), -- password: password123
('3', 'Jane Doe', 'jane@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'staff'), -- password: password123
('4', 'Robert Johnson', 'robert@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'staff'); -- password: password123

-- Insert demo data: categories
INSERT INTO categories (id, name) VALUES
('1', 'Electronics'),
('2', 'Clothing'),
('3', 'Home Goods'),
('4', 'Office Supplies');

-- Insert demo data: products
INSERT INTO products (id, name, sku, description, category_id, price) VALUES
('1', 'Wireless Headphones', 'WH-1001', 'High-quality wireless headphones with noise cancellation', '1', 149.99),
('2', 'Bluetooth Speaker', 'BS-2002', 'Portable Bluetooth speaker with 20-hour battery life', '1', 79.99),
('3', 'USB-C Cable', 'UC-3003', 'Durable USB-C charging cable, 2m length', '1', 12.99),
('4', 'Office Chair', 'OC-4004', 'Ergonomic office chair with lumbar support', '4', 199.99),
('5', 'Desk Lamp', 'DL-5005', 'LED desk lamp with adjustable brightness', '3', 34.99),
('6', 'Cotton T-Shirt', 'CT-6001', 'Premium cotton t-shirt, various sizes', '2', 19.99);

-- Insert demo data: warehouses
INSERT INTO warehouses (id, name, address, contact_person, contact_phone, capacity) VALUES
('1', 'Warehouse A', '123 Main St, New York, NY 10001', 'John Smith', '(555) 123-4567', 600),
('2', 'Warehouse B', '456 Park Ave, Los Angeles, CA 90001', 'Jane Doe', '(555) 987-6543', 500),
('3', 'Warehouse C', '789 Oak St, Chicago, IL 60007', 'Robert Johnson', '(555) 456-7890', 700);

-- Insert demo data: inventory
INSERT INTO inventory (id, product_id, warehouse_id, quantity, location) VALUES
('1', '1', '1', 5, 'Shelf A-12'),
('2', '2', '2', 0, 'Shelf B-05'),
('3', '3', '1', 120, 'Shelf A-03'),
('4', '4', '3', 8, 'Section C-02'),
('5', '5', '2', 25, 'Shelf B-10');
