-- =====================================================
-- SUB.VN - COMPLETE DATABASE SCHEMA
-- =====================================================

-- Drop existing database if exists
DROP DATABASE IF EXISTS sub_vn;
CREATE DATABASE sub_vn CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sub_vn;

-- =====================================================
-- 1. USERS TABLE - Quản lý người dùng
-- =====================================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    balance DECIMAL(15,2) DEFAULT 0.00,
    total_spent DECIMAL(15,2) DEFAULT 0.00,
    role ENUM('user', 'admin', 'moderator') DEFAULT 'user',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(100),
    reset_token VARCHAR(100),
    reset_token_expires DATETIME,
    last_login DATETIME,
    last_ip VARCHAR(45),
    login_attempts INT DEFAULT 0,
    locked_until DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_status (status),
    INDEX idx_role (role)
) ENGINE=InnoDB;

-- =====================================================
-- 2. SERVICES TABLE - Dịch vụ Sub
-- =====================================================
CREATE TABLE services (
    id INT PRIMARY KEY AUTO_INCREMENT,
    service_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    platform ENUM('facebook', 'tiktok', 'youtube', 'instagram', 'twitter', 'telegram', 'shopee', 'other') NOT NULL,
    type VARCHAR(50) NOT NULL, -- like, follow, view, comment, share, subscriber
    description TEXT,
    price_per_1000 DECIMAL(10,2) NOT NULL,
    min_order INT NOT NULL,
    max_order INT NOT NULL,
    api_provider ENUM('justanotherpanel', 'smmpanel', 'manual', 'other') DEFAULT 'justanotherpanel',
    api_service_id VARCHAR(100), -- ID từ API provider
    average_time VARCHAR(50), -- Thời gian hoàn thành trung bình
    refill_enabled BOOLEAN DEFAULT FALSE,
    guarantee_hours INT DEFAULT 0,
    status ENUM('active', 'inactive', 'maintenance') DEFAULT 'active',
    display_order INT DEFAULT 0,
    total_orders INT DEFAULT 0,
    success_rate DECIMAL(5,2) DEFAULT 100.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_platform (platform),
    INDEX idx_status (status),
    INDEX idx_service_code (service_code)
) ENGINE=InnoDB;

-- =====================================================
-- 3. ORDERS TABLE - Đơn hàng
-- =====================================================
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_code VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    link TEXT NOT NULL,
    quantity INT NOT NULL,
    start_count INT DEFAULT 0,
    current_count INT DEFAULT 0,
    remains INT,
    price DECIMAL(10,2) NOT NULL,
    api_order_id VARCHAR(100), -- Order ID từ API provider
    status ENUM('pending', 'processing', 'completed', 'partial', 'canceled', 'refunded', 'error') DEFAULT 'pending',
    error_message TEXT,
    refund_amount DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT,
    INDEX idx_user_id (user_id),
    INDEX idx_service_id (service_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_order_code (order_code)
) ENGINE=InnoDB;

-- =====================================================
-- 4. TRANSACTIONS TABLE - Giao dịch tài chính
-- =====================================================
CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_code VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    type ENUM('deposit', 'withdraw', 'order_payment', 'refund', 'bonus', 'deduct') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    balance_before DECIMAL(15,2) NOT NULL,
    balance_after DECIMAL(15,2) NOT NULL,
    status ENUM('pending', 'completed', 'failed', 'canceled') DEFAULT 'pending',
    payment_method ENUM('momo', 'banking', 'card', 'manual', 'auto') DEFAULT NULL,
    payment_info TEXT, -- Thông tin chuyển khoản
    order_id INT DEFAULT NULL,
    note TEXT,
    admin_note TEXT,
    processed_by INT DEFAULT NULL, -- Admin xử lý
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    FOREIGN KEY (processed_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- =====================================================
-- 5. DEPOSITS TABLE - Nạp tiền chi tiết
-- =====================================================
CREATE TABLE deposits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT UNIQUE NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_method ENUM('momo', 'banking', 'card') NOT NULL,
    bank_code VARCHAR(50),
    account_number VARCHAR(50),
    account_name VARCHAR(100),
    transfer_content VARCHAR(255),
    transfer_image VARCHAR(255), -- Đường dẫn ảnh chuyển khoản
    payment_gateway_id VARCHAR(100), -- ID từ cổng thanh toán
    status ENUM('pending', 'verified', 'completed', 'rejected') DEFAULT 'pending',
    verified_by INT DEFAULT NULL,
    verified_at DATETIME,
    reject_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB;

-- =====================================================
-- 6. API_PROVIDERS TABLE - Nhà cung cấp API
-- =====================================================
CREATE TABLE api_providers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    api_url VARCHAR(255) NOT NULL,
    api_key VARCHAR(255) NOT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    balance DECIMAL(15,2) DEFAULT 0.00,
    total_orders INT DEFAULT 0,
    success_rate DECIMAL(5,2) DEFAULT 0.00,
    average_response_time INT DEFAULT 0, -- milliseconds
    last_check DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- =====================================================
-- 7. ACTIVITY_LOGS TABLE - Nhật ký hoạt động
-- =====================================================
CREATE TABLE activity_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    metadata JSON, -- Dữ liệu bổ sung
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- =====================================================
-- 8. SECURITY_LOGS TABLE - Nhật ký bảo mật
-- =====================================================
CREATE TABLE security_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    event_type ENUM('login_success', 'login_failed', 'password_reset', 'email_change', 'suspicious_activity', 'account_locked', 'account_unlocked') NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    details TEXT,
    risk_level ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_event_type (event_type),
    INDEX idx_risk_level (risk_level),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- =====================================================
-- 9. RATE_LIMITS TABLE - Giới hạn tốc độ (Anti-abuse)
-- =====================================================
CREATE TABLE rate_limits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    identifier VARCHAR(100) NOT NULL, -- IP or User ID
    action VARCHAR(50) NOT NULL, -- login, order, api_call
    attempt_count INT DEFAULT 1,
    window_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blocked_until DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_identifier_action (identifier, action),
    INDEX idx_identifier (identifier),
    INDEX idx_blocked_until (blocked_until)
) ENGINE=InnoDB;

-- =====================================================
-- 10. NOTIFICATIONS TABLE - Thông báo
-- =====================================================
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type ENUM('order_update', 'deposit_success', 'system', 'promotion', 'warning') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    link VARCHAR(255),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- =====================================================
-- 11. SETTINGS TABLE - Cài đặt hệ thống
-- =====================================================
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE, -- Có thể xem ở frontend không
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_setting_key (setting_key)
) ENGINE=InnoDB;

-- =====================================================
-- 12. COUPONS TABLE - Mã giảm giá
-- =====================================================
CREATE TABLE coupons (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_type ENUM('percentage', 'fixed') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    min_amount DECIMAL(10,2) DEFAULT 0.00,
    max_discount DECIMAL(10,2),
    usage_limit INT DEFAULT NULL, -- NULL = unlimited
    used_count INT DEFAULT 0,
    valid_from DATETIME,
    valid_until DATETIME,
    status ENUM('active', 'inactive', 'expired') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- =====================================================
-- 13. COUPON_USAGE TABLE - Lịch sử sử dụng coupon
-- =====================================================
CREATE TABLE coupon_usage (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coupon_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_coupon_id (coupon_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB;

-- =====================================================
-- 14. TICKETS TABLE - Hỗ trợ khách hàng
-- =====================================================
CREATE TABLE tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_code VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    category ENUM('technical', 'billing', 'order', 'account', 'other') NOT NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('open', 'in_progress', 'waiting_user', 'resolved', 'closed') DEFAULT 'open',
    assigned_to INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    closed_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- =====================================================
-- 15. TICKET_MESSAGES TABLE - Tin nhắn ticket
-- =====================================================
CREATE TABLE ticket_messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    attachments JSON, -- Array of file paths
    is_staff BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_ticket_id (ticket_id)
) ENGINE=InnoDB;

-- =====================================================
-- 16. REFILL_REQUESTS TABLE - Yêu cầu refill
-- =====================================================
CREATE TABLE refill_requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    quantity_lost INT NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'completed') DEFAULT 'pending',
    admin_note TEXT,
    processed_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (processed_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_order_id (order_id),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- =====================================================
-- INSERT DEFAULT DATA
-- =====================================================

-- Default Admin User (password: Admin@123456)
INSERT INTO users (username, email, password_hash, full_name, role, status, email_verified) 
VALUES ('admin', 'admin@sub.vn', '$2b$10$XZ8VE3YGxJhGQF8qLjKWEeqGqH1mVR3xKjH8vqWzNgPzYc5xGFxXi', 'Administrator', 'admin', 'active', TRUE);

-- Default Settings
INSERT INTO settings (setting_key, setting_value, setting_type, description, is_public) VALUES
('site_name', 'SUB.VN', 'string', 'Tên website', TRUE),
('contact_email', 'dwen.khachieu@gmail.com', 'string', 'Email liên hệ', TRUE),
('contact_zalo', '0972562495', 'string', 'Số Zalo', TRUE),
('contact_facebook', 'OnlyLove', 'string', 'Facebook page', TRUE),
('min_deposit', '10000', 'number', 'Số tiền nạp tối thiểu (VNĐ)', TRUE),
('maintenance_mode', 'false', 'boolean', 'Chế độ bảo trì', FALSE),
('max_login_attempts', '5', 'number', 'Số lần đăng nhập sai tối đa', FALSE),
('lock_duration_minutes', '30', 'number', 'Thời gian khóa tài khoản (phút)', FALSE),
('order_auto_cancel_hours', '24', 'number', 'Tự động hủy đơn pending sau (giờ)', FALSE);

-- Sample Services
INSERT INTO services (service_code, name, platform, type, description, price_per_1000, min_order, max_order, api_provider, status) VALUES
('FB_LIKE_001', 'Facebook Like [Fast - HQ]', 'facebook', 'like', 'Tăng like bài viết Facebook nhanh chóng', 50000, 100, 50000, 'justanotherpanel', 'active'),
('FB_FOLLOW_001', 'Facebook Follow [Stable]', 'facebook', 'follow', 'Tăng follow trang Facebook', 70000, 100, 30000, 'justanotherpanel', 'active'),
('TT_FOLLOW_001', 'TikTok Follow [Real Users]', 'tiktok', 'follow', 'Tăng follow TikTok người dùng thật', 80000, 50, 20000, 'justanotherpanel', 'active'),
('TT_LIKE_001', 'TikTok Like [Fast]', 'tiktok', 'like', 'Tăng like video TikTok', 60000, 100, 50000, 'justanotherpanel', 'active'),
('YT_VIEW_001', 'YouTube View [HQ - 4000h]', 'youtube', 'view', 'Tăng view YouTube chất lượng cao', 12000, 1000, 1000000, 'justanotherpanel', 'active'),
('YT_SUB_001', 'YouTube Subscribe [Real]', 'youtube', 'subscriber', 'Tăng subscriber kênh YouTube', 120000, 50, 10000, 'justanotherpanel', 'active'),
('IG_FOLLOW_001', 'Instagram Follow [HQ]', 'instagram', 'follow', 'Tăng follow Instagram chất lượng', 90000, 100, 30000, 'justanotherpanel', 'active'),
('IG_LIKE_001', 'Instagram Like [Fast]', 'instagram', 'like', 'Tăng like ảnh Instagram', 70000, 100, 50000, 'justanotherpanel', 'active');

-- Sample API Provider
INSERT INTO api_providers (name, api_url, api_key, status) VALUES
('JustAnotherPanel', 'https://justanotherpanel.com/api/v2', 'YOUR_API_KEY_HERE', 'active');

-- =====================================================
-- VIEWS FOR REPORTING
-- =====================================================

-- Thống kê tổng quan
CREATE VIEW vw_dashboard_stats AS
SELECT 
    (SELECT COUNT(*) FROM users WHERE role = 'user') as total_users,
    (SELECT COUNT(*) FROM users WHERE role = 'user' AND status = 'active') as active_users,
    (SELECT COUNT(*) FROM orders) as total_orders,
    (SELECT COUNT(*) FROM orders WHERE status = 'completed') as completed_orders,
    (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'deposit' AND status = 'completed') as total_deposits,
    (SELECT COALESCE(SUM(price), 0) FROM orders WHERE status IN ('completed', 'processing')) as total_revenue,
    (SELECT COALESCE(SUM(balance), 0) FROM users) as total_user_balance;

-- Top users theo chi tiêu
CREATE VIEW vw_top_spenders AS
SELECT 
    u.id,
    u.username,
    u.email,
    u.total_spent,
    COUNT(o.id) as order_count,
    u.created_at as member_since
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.role = 'user'
GROUP BY u.id
ORDER BY u.total_spent DESC
LIMIT 100;

-- Thống kê dịch vụ phổ biến
CREATE VIEW vw_popular_services AS
SELECT 
    s.id,
    s.name,
    s.platform,
    s.type,
    COUNT(o.id) as order_count,
    SUM(o.quantity) as total_quantity,
    SUM(o.price) as total_revenue,
    AVG(o.price) as avg_order_value
FROM services s
LEFT JOIN orders o ON s.id = o.service_id
WHERE o.status IN ('completed', 'processing')
GROUP BY s.id
ORDER BY order_count DESC;

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Tạo đơn hàng mới
CREATE PROCEDURE sp_create_order(
    IN p_user_id INT,
    IN p_service_id INT,
    IN p_link TEXT,
    IN p_quantity INT,
    OUT p_order_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_user_balance DECIMAL(15,2);
    DECLARE v_min_order INT;
    DECLARE v_max_order INT;
    DECLARE v_service_status VARCHAR(20);
    DECLARE v_order_code VARCHAR(50);
    
    -- Get service info
    SELECT price_per_1000, min_order, max_order, status
    INTO v_price, v_min_order, v_max_order, v_service_status
    FROM services WHERE id = p_service_id;
    
    -- Validate service
    IF v_service_status IS NULL THEN
        SET p_message = 'Dịch vụ không tồn tại';
        SET p_order_id = 0;
    ELSEIF v_service_status != 'active' THEN
        SET p_message = 'Dịch vụ tạm thời không khả dụng';
        SET p_order_id = 0;
    ELSEIF p_quantity < v_min_order THEN
        SET p_message = CONCAT('Số lượng tối thiểu: ', v_min_order);
        SET p_order_id = 0;
    ELSEIF p_quantity > v_max_order THEN
        SET p_message = CONCAT('Số lượng tối đa: ', v_max_order);
        SET p_order_id = 0;
    ELSE
        -- Calculate price
        SET v_price = (p_quantity / 1000) * v_price;
        
        -- Check user balance
        SELECT balance INTO v_user_balance FROM users WHERE id = p_user_id;
        
        IF v_user_balance < v_price THEN
            SET p_message = 'Số dư không đủ';
            SET p_order_id = 0;
        ELSE
            -- Generate order code
            SET v_order_code = CONCAT('ORD', LPAD(FLOOR(RAND() * 999999999), 9, '0'));
            
            -- Create order
            INSERT INTO orders (order_code, user_id, service_id, link, quantity, price, remains, status)
            VALUES (v_order_code, p_user_id, p_service_id, p_link, p_quantity, v_price, p_quantity, 'pending');
            
            SET p_order_id = LAST_INSERT_ID();
            
            -- Deduct balance
            UPDATE users SET balance = balance - v_price, total_spent = total_spent + v_price
            WHERE id = p_user_id;
            
            -- Create transaction
            INSERT INTO transactions (transaction_code, user_id, type, amount, balance_before, balance_after, order_id, status)
            VALUES (CONCAT('TXN', LPAD(p_order_id, 9, '0')), p_user_id, 'order_payment', v_price, v_user_balance, v_user_balance - v_price, p_order_id, 'completed');
            
            SET p_message = 'Đơn hàng đã được tạo thành công';
        END IF;
    END IF;
END//

DELIMITER ;

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
-- Already included in table definitions above

-- =====================================================
-- DATABASE COMPLETE
-- =====================================================
-- 3. ORDERS TABLE - Quản lý đơn hàng JAP
CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id TEXT NOT NULL,
    link TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    status TEXT DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);