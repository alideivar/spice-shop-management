-- تنظیم کاراکترست برای پشتیبانی فارسی
SET NAMES utf8mb4;

-- جدول کاربران
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL COLLATE utf8mb4_persian_ci,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL COLLATE utf8mb4_persian_ci,
    role ENUM('admin', 'seller', 'marketer') NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول ادویه‌های اصلی
CREATE TABLE spices (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COLLATE utf8mb4_persian_ci,
    stock_grams DECIMAL(10,2) DEFAULT 0,
    base_price_per_gram DECIMAL(10,2) NOT NULL,
    description TEXT COLLATE utf8mb4_persian_ci,
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول انواع بسته‌بندی
CREATE TABLE packaging_types (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COLLATE utf8mb4_persian_ci,
    weight_grams INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    description TEXT COLLATE utf8mb4_persian_ci,
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول محصولات نهایی (ادویه + بسته‌بندی)
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    spice_id BIGINT UNSIGNED NOT NULL,
    packaging_type_id BIGINT UNSIGNED NOT NULL,
    barcode VARCHAR(50) UNIQUE,
    final_price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (spice_id) REFERENCES spices(id),
    FOREIGN KEY (packaging_type_id) REFERENCES packaging_types(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول تراکنش‌های انبار ادویه
CREATE TABLE spice_transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    spice_id BIGINT UNSIGNED NOT NULL,
    type ENUM('in', 'out') NOT NULL,
    amount_grams DECIMAL(10,2) NOT NULL,
    description TEXT COLLATE utf8mb4_persian_ci,
    user_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (spice_id) REFERENCES spices(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول تراکنش‌های انبار بسته‌بندی
CREATE TABLE packaging_transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    packaging_type_id BIGINT UNSIGNED NOT NULL,
    type ENUM('in', 'out') NOT NULL,
    quantity INT NOT NULL,
    description TEXT COLLATE utf8mb4_persian_ci,
    user_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (packaging_type_id) REFERENCES packaging_types(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول فرآیند بسته‌بندی
CREATE TABLE packaging_processes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    spice_id BIGINT UNSIGNED NOT NULL,
    packaging_type_id BIGINT UNSIGNED NOT NULL,
    input_grams DECIMAL(10,2) NOT NULL,
    output_quantity INT NOT NULL,
    waste_grams DECIMAL(10,2) DEFAULT 0,
    user_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (spice_id) REFERENCES spices(id),
    FOREIGN KEY (packaging_type_id) REFERENCES packaging_types(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- ایجاد کاربر مدیر پیش‌فرض
INSERT INTO users (username, password, full_name, role, phone) 
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'مدیر سیستم', 'admin', '09123456789');
اضافه کردن ساختار اولیه دیتابیس
