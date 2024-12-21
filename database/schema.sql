-- تنظیم کاراکترست برای پشتیبانی فارسی
SET NAMES utf8mb4;

-- جدول کاربران (بدون تغییر)
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

-- جدول ادویه‌های اصلی (با فیلدهای جدید قیمت)
CREATE TABLE spices (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COLLATE utf8mb4_persian_ci,
    stock_grams DECIMAL(10,2) DEFAULT 0,
    purchase_price_per_gram DECIMAL(10,2) NOT NULL, -- قیمت خرید هر گرم
    sale_price_per_gram DECIMAL(10,2) NOT NULL,     -- قیمت فروش هر گرم
    profit_per_gram DECIMAL(10,2) GENERATED ALWAYS AS (sale_price_per_gram - purchase_price_per_gram) STORED, -- سود هر گرم
    description TEXT COLLATE utf8mb4_persian_ci,
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول انواع بسته‌بندی (با فیلدهای جدید قیمت)
CREATE TABLE packaging_types (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COLLATE utf8mb4_persian_ci,
    weight_grams INT NOT NULL,
    purchase_price DECIMAL(10,2) NOT NULL,      -- قیمت خرید بسته‌بندی
    sale_price DECIMAL(10,2) NOT NULL,          -- قیمت فروش بسته‌بندی
    profit DECIMAL(10,2) GENERATED ALWAYS AS (sale_price - purchase_price) STORED, -- سود بسته‌بندی
    stock INT DEFAULT 0,
    description TEXT COLLATE utf8mb4_persian_ci,
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول محصولات نهایی (با فیلدهای جدید قیمت و سود)
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    spice_id BIGINT UNSIGNED NOT NULL,
    packaging_type_id BIGINT UNSIGNED NOT NULL,
    barcode VARCHAR(50) UNIQUE,
    total_cost DECIMAL(10,2) GENERATED ALWAYS AS (
        (SELECT (s.purchase_price_per_gram * p.weight_grams) + p.purchase_price 
         FROM spices s, packaging_types p 
         WHERE s.id = spice_id AND p.id = packaging_type_id)
    ) STORED,                                   -- هزینه کل (مواد + بسته‌بندی)
    sale_price DECIMAL(10,2) NOT NULL,          -- قیمت فروش محصول نهایی
    profit DECIMAL(10,2) GENERATED ALWAYS AS (sale_price - total_cost) STORED, -- سود کل
    stock INT DEFAULT 0,
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (spice_id) REFERENCES spices(id),
    FOREIGN KEY (packaging_type_id) REFERENCES packaging_types(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول تراکنش‌های انبار ادویه (با فیلدهای قیمت)
CREATE TABLE spice_transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    spice_id BIGINT UNSIGNED NOT NULL,
    type ENUM('in', 'out') NOT NULL,
    amount_grams DECIMAL(10,2) NOT NULL,
    price_per_gram DECIMAL(10,2) NOT NULL,      -- قیمت هر گرم در زمان تراکنش
    total_price DECIMAL(10,2) GENERATED ALWAYS AS (amount_grams * price_per_gram) STORED, -- قیمت کل
    description TEXT COLLATE utf8mb4_persian_ci,
    user_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (spice_id) REFERENCES spices(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول تراکنش‌های انبار بسته‌بندی (با فیلدهای قیمت)
CREATE TABLE packaging_transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    packaging_type_id BIGINT UNSIGNED NOT NULL,
    type ENUM('in', 'out') NOT NULL,
    quantity INT NOT NULL,
    price_per_unit DECIMAL(10,2) NOT NULL,      -- قیمت هر واحد در زمان تراکنش
    total_price DECIMAL(10,2) GENERATED ALWAYS AS (quantity * price_per_unit) STORED, -- قیمت کل
    description TEXT COLLATE utf8mb4_persian_ci,
    user_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (packaging_type_id) REFERENCES packaging_types(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول فرآیند بسته‌بندی (با محاسبات هزینه)
CREATE TABLE packaging_processes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    spice_id BIGINT UNSIGNED NOT NULL,
    packaging_type_id BIGINT UNSIGNED NOT NULL,
    input_grams DECIMAL(10,2) NOT NULL,
    output_quantity INT NOT NULL,
    waste_grams DECIMAL(10,2) DEFAULT 0,
    material_cost DECIMAL(10,2) GENERATED ALWAYS AS (
        (SELECT purchase_price_per_gram * input_grams FROM spices WHERE id = spice_id)
    ) STORED,                                   -- هزینه مواد اولیه
    packaging_cost DECIMAL(10,2) GENERATED ALWAYS AS (
        (SELECT purchase_price * output_quantity FROM packaging_types WHERE id = packaging_type_id)
    ) STORED,                                   -- هزینه بسته‌بندی
    total_cost DECIMAL(10,2) GENERATED ALWAYS AS (material_cost + packaging_cost) STORED, -- هزینه کل
    user_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (spice_id) REFERENCES spices(id),
    FOREIGN KEY (packaging_type_id) REFERENCES packaging_types(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- ایجاد کاربر مدیر پیش‌فرض
INSERT INTO users (username, password, full_name, role, phone) 
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'مدیر سیستم', 'admin', '09123456789');
اطلاعات دیتابیس
