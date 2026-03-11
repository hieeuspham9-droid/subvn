# SUB.VN - BACKEND API DOCUMENTATION & SETUP GUIDE

## 📋 MỤC LỤC
1. [Cài Đặt & Khởi Chạy](#cài-đặt--khởi-chạy)
2. [Cấu Trúc Thư Mục](#cấu-trúc-thư-mục)
3. [Database Schema](#database-schema)
4. [API Endpoints](#api-endpoints)
5. [Authentication & Security](#authentication--security)
6. [Cronjobs](#cronjobs)
7. [Payment Integration](#payment-integration)
8. [JustAnotherPanel API](#justanotherpanel-api)

---

## 🚀 CÀI ĐẶT & KHỞI CHẠY

### Yêu cầu hệ thống
- Node.js >= 16.x
- MySQL >= 8.0
- NPM hoặc Yarn

### Bước 1: Clone và cài đặt dependencies

```bash
# Clone project
cd sub-vn-backend

# Cài đặt packages
npm install
```

### Bước 2: Cấu hình Database

```bash
# Đăng nhập MySQL
mysql -u root -p

# Import database schema
mysql -u root -p < database-schema.sql

# Hoặc
source database-schema.sql
```

### Bước 3: Cấu hình môi trường

```bash
# Copy file .env.example sang .env
cp .env.example .env

# Chỉnh sửa thông tin trong .env
nano .env
```

**Các biến quan trọng cần thay đổi:**
```env
DB_PASSWORD=your_mysql_password
JWT_SECRET=your_super_secret_key_here
EMAIL_PASSWORD=your_gmail_app_password
JAP_API_KEY=your_justanotherpanel_api_key
MOMO_PARTNER_CODE=your_momo_partner_code
MOMO_ACCESS_KEY=your_momo_access_key
MOMO_SECRET_KEY=your_momo_secret_key
```

### Bước 4: Khởi chạy server

```bash
# Development mode (với nodemon)
npm run dev

# Production mode
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

---

## 📁 CẤU TRÚC THƯ MỤC

```
sub-vn-backend/
├── config/
│   ├── database.js          # Cấu hình kết nối DB
│   └── jwt.js               # Cấu hình JWT
├── controllers/
│   ├── authController.js    # Xử lý đăng nhập, đăng ký
│   ├── userController.js    # Quản lý user
│   ├── orderController.js   # Quản lý đơn hàng
│   ├── serviceController.js # Quản lý dịch vụ
│   └── adminController.js   # Admin functions
├── middleware/
│   ├── auth.js              # Xác thực JWT
│   ├── roleCheck.js         # Kiểm tra quyền (RBAC)
│   ├── rateLimit.js         # Giới hạn request
│   └── errorHandler.js      # Xử lý lỗi
├── models/
│   ├── User.js
│   ├── Order.js
│   ├── Service.js
│   └── Transaction.js
├── routes/
│   ├── auth.js
│   ├── users.js
│   ├── orders.js
│   ├── services.js
│   ├── admin.js
│   └── stats.js
├── services/
│   ├── japAPI.js            # JustAnotherPanel API integration
│   ├── momoAPI.js           # MoMo payment gateway
│   ├── emailService.js      # Gửi email
│   └── cronjob.js           # Cron jobs
├── utils/
│   ├── logger.js            # Logging
│   ├── validator.js         # Validation
│   └── helpers.js           # Helper functions
├── .env                     # Environment variables
├── .env.example             # Environment template
├── package.json
├── server.js                # Main server file
└── database-schema.sql      # Database schema
```

---

## 💾 DATABASE SCHEMA

### Các bảng chính:

#### 1. **users** - Quản lý người dùng
```sql
- id, username, email, password_hash
- balance, total_spent
- role (user, admin, moderator)
- status (active, inactive, banned)
- Bảo mật: login_attempts, locked_until
```

#### 2. **services** - Dịch vụ Sub
```sql
- id, service_code, name
- platform (facebook, tiktok, youtube, instagram...)
- price_per_1000, min_order, max_order
- api_provider, api_service_id
- status, success_rate
```

#### 3. **orders** - Đơn hàng
```sql
- id, order_code, user_id, service_id
- link, quantity, price
- api_order_id (từ JAP)
- status (pending, processing, completed, canceled)
- start_count, current_count, remains
```

#### 4. **transactions** - Giao dịch
```sql
- id, transaction_code, user_id
- type (deposit, withdraw, order_payment, refund)
- amount, balance_before, balance_after
- payment_method (momo, banking, manual)
```

#### 5. **deposits** - Nạp tiền
```sql
- id, transaction_id, user_id
- amount, payment_method
- transfer_image, payment_gateway_id
- status (pending, verified, completed, rejected)
```

#### 6. **security_logs** - Nhật ký bảo mật
```sql
- Theo dõi login attempts
- Suspicious activities
- Risk levels (low, medium, high, critical)
```

---

## 🔐 API ENDPOINTS

### Authentication (`/api/auth`)

#### POST /api/auth/register
Đăng ký tài khoản mới

**Request Body:**
```json
{
  "username": "user123",
  "email": "user@example.com",
  "password": "Password@123",
  "full_name": "Nguyễn Văn A",
  "phone": "0901234567"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đăng ký thành công",
  "data": {
    "user": {
      "id": 1,
      "username": "user123",
      "email": "user@example.com",
      "role": "user"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### POST /api/auth/login
Đăng nhập

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "Password@123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "username": "user123",
      "email": "user@example.com",
      "balance": 250000,
      "role": "user"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Security Features:**
- Rate limiting: Max 10 requests/15 minutes
- Account locking after 5 failed attempts
- Lock duration: 30 minutes
- Security log mọi lần đăng nhập

---

### Services (`/api/services`)

#### GET /api/services
Lấy danh sách dịch vụ

**Query Parameters:**
- `platform` (optional): facebook, tiktok, youtube...
- `status` (optional): active, inactive
- `page` (optional): Số trang (default: 1)
- `limit` (optional): Số items/trang (default: 20)

**Response:**
```json
{
  "success": true,
  "data": {
    "services": [
      {
        "id": 1,
        "service_code": "FB_LIKE_001",
        "name": "Facebook Like [Fast - HQ]",
        "platform": "facebook",
        "type": "like",
        "price_per_1000": 50000,
        "min_order": 100,
        "max_order": 50000,
        "average_time": "0-12 hours",
        "status": "active"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "totalPages": 3
    }
  }
}
```

---

### Orders (`/api/orders`)

#### POST /api/orders
Tạo đơn hàng mới

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "service_id": 1,
  "link": "https://facebook.com/post/123456",
  "quantity": 1000
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đơn hàng đã được tạo thành công",
  "data": {
    "order": {
      "id": 123,
      "order_code": "ORD000000123",
      "service_name": "Facebook Like [Fast - HQ]",
      "link": "https://facebook.com/post/123456",
      "quantity": 1000,
      "price": 50000,
      "status": "pending",
      "created_at": "2024-02-08T10:30:00.000Z"
    },
    "balance": {
      "before": 300000,
      "after": 250000
    }
  }
}
```

**Validations:**
- Kiểm tra số dư đủ không
- Validate min/max order
- Validate URL format
- Anti-spam: Max 5 đơn/phút/user

#### GET /api/orders
Lấy danh sách đơn hàng của user

**Query Parameters:**
- `status`: pending, processing, completed
- `page`, `limit`

#### GET /api/orders/:id
Chi tiết đơn hàng

---

### Deposits (`/api/deposits`)

#### POST /api/deposits
Tạo yêu cầu nạp tiền

**Request Body:**
```json
{
  "amount": 500000,
  "payment_method": "momo"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "deposit_id": 45,
    "amount": 500000,
    "payment_method": "momo",
    "payment_url": "https://payment.momo.vn/...",
    "qr_code": "https://api.sub.vn/qr/...",
    "transfer_info": {
      "bank": "MoMo",
      "phone": "0972562495",
      "name": "SUB.VN",
      "content": "NAPSUB user123"
    }
  }
}
```

---

### Admin (`/api/admin`)

**Yêu cầu role: admin**

#### GET /api/admin/users
Quản lý users

**Query Parameters:**
- `status`: active, inactive, banned
- `role`: user, admin, moderator
- `search`: Tìm theo email/username
- `page`, `limit`

#### PUT /api/admin/users/:id
Cập nhật user (balance, status, role)

```json
{
  "balance": 1000000,
  "status": "active",
  "role": "user"
}
```

#### GET /api/admin/deposits
Danh sách nạp tiền chờ duyệt

#### POST /api/admin/deposits/:id/approve
Duyệt nạp tiền

```json
{
  "action": "approve",  // hoặc "reject"
  "note": "Đã xác nhận chuyển khoản"
}
```

#### GET /api/admin/orders
Quản lý tất cả đơn hàng

---

### Stats (`/api/stats`)

#### GET /api/stats/dashboard
Thống kê tổng quan

**Response:**
```json
{
  "success": true,
  "data": {
    "overview": {
      "total_users": 1247,
      "active_users": 856,
      "total_orders": 15632,
      "completed_orders": 14521,
      "total_revenue": 456789000,
      "total_deposits": 523456000,
      "pending_deposits": 12,
      "user_balance": 66667000
    },
    "today": {
      "new_users": 23,
      "orders": 145,
      "revenue": 12456000,
      "deposits": 45678000
    },
    "charts": {
      "revenue_7days": [...],
      "orders_by_platform": {...}
    }
  }
}
```

---

## 🔒 AUTHENTICATION & SECURITY

### JWT Token
- Expires: 7 days
- Refresh token: Tự động gia hạn khi còn < 1 ngày
- Stored in: HTTP-only cookie hoặc Authorization header

### Rate Limiting
```javascript
// Global: 100 requests/15 minutes
// Auth endpoints: 10 requests/15 minutes
// Order creation: 5 orders/minute/user
// API calls: 200 requests/hour/user
```

### Password Security
- Bcrypt với salt rounds = 10
- Min length: 8 characters
- Require: uppercase, lowercase, number, special char

### Account Protection
- Max login attempts: 5
- Lock duration: 30 minutes
- Email verification required
- 2FA support (optional)

### Anti-Abuse Mechanisms
```javascript
// IP-based rate limiting
// Duplicate order prevention (same link + service trong 5 phút)
// Balance manipulation detection
// Suspicious activity monitoring
// Automated security responses
```

---

## ⏰ CRONJOBS

### 1. Order Status Update (*/5 * * * *)
Chạy mỗi 5 phút

```javascript
// Kiểm tra trạng thái đơn từ JAP API
// Cập nhật start_count, current_count, remains
// Update status: pending -> processing -> completed
// Refund nếu lỗi
// Gửi thông báo cho user
```

### 2. Cancel Pending Orders (0 */6 * * *)
Chạy mỗi 6 giờ

```javascript
// Tự động hủy đơn pending > 24h
// Hoàn tiền cho user
// Ghi log
```

### 3. Balance Check (0 0 * * *)
Chạy hàng ngày lúc 00:00

```javascript
// Kiểm tra số dư JAP API
// Cảnh báo nếu balance thấp
// Gửi email cho admin
```

### 4. Generate Reports (0 0 * * *)
Chạy hàng ngày

```javascript
// Tạo báo cáo doanh thu
// Top users, top services
// Success rate statistics
// Email cho admin
```

---

## 💳 PAYMENT INTEGRATION

### MoMo QR Payment

```javascript
const MoMoAPI = require('./services/momoAPI');

// Tạo payment request
const payment = await MoMoAPI.createPayment({
  amount: 500000,
  orderId: 'DEPOSIT_123',
  orderInfo: 'Nạp tiền SUB.VN',
  redirectUrl: 'https://sub.vn/payment/callback',
  ipnUrl: 'https://api.sub.vn/payment/momo/ipn'
});

// Return payment URL và QR code
```

### Banking Transfer (Manual)
```
Ngân hàng: Vietcombank
STK: 1234567890
Chủ TK: NGUYEN VAN A
Nội dung: NAPSUB {username}
```

User upload ảnh chuyển khoản → Admin duyệt → Cộng tiền

---

## 🔌 JUSTANOTHERPANEL API

### Configuration
```javascript
const JAP_CONFIG = {
  apiUrl: 'https://justanotherpanel.com/api/v2',
  apiKey: process.env.JAP_API_KEY
};
```

### 1. Get Services List
```javascript
POST /api/v2
{
  "key": "YOUR_API_KEY",
  "action": "services"
}
```

### 2. Create Order
```javascript
POST /api/v2
{
  "key": "YOUR_API_KEY",
  "action": "add",
  "service": "123",  // JAP service ID
  "link": "https://facebook.com/post/123",
  "quantity": "1000"
}

Response: {
  "order": "9876543"  // JAP order ID
}
```

### 3. Check Order Status
```javascript
POST /api/v2
{
  "key": "YOUR_API_KEY",
  "action": "status",
  "order": "9876543"
}

Response: {
  "status": "Completed",
  "charge": "0.27819",
  "start_count": "3572",
  "remains": "0"
}
```

### 4. Get Balance
```javascript
POST /api/v2
{
  "key": "YOUR_API_KEY",
  "action": "balance"
}

Response: {
  "balance": "100.84292"
}
```

### Auto Sync Services (Cronjob)
```javascript
// Chạy mỗi ngày lúc 3AM
// Sync services từ JAP
// Update prices, min/max
// Add new services
// Disable unavailable services
```

---

## 📊 REPORTING & ANALYTICS

### Admin Dashboard Metrics
- Real-time users online
- Orders today/week/month
- Revenue charts
- Popular services
- Top spenders
- Success rate by service
- Average order value
- Conversion funnel

### User Analytics
- Order history
- Spending patterns
- Favorite services
- Average order size

### Financial Reports
- Daily/Monthly revenue
- Deposit vs Spending
- Profit margins
- Refund rate
- Payment method distribution

---

## 🚀 DEPLOYMENT

### Production Checklist
- [ ] Set NODE_ENV=production
- [ ] Use strong JWT_SECRET
- [ ] Enable HTTPS
- [ ] Set up database backups
- [ ] Configure email SMTP
- [ ] Set up monitoring (PM2, logging)
- [ ] Enable security headers
- [ ] Rate limiting properly configured
- [ ] Set up cronjobs
- [ ] Configure payment gateways
- [ ] Test all API endpoints
- [ ] Load testing
- [ ] Disaster recovery plan

### Recommended Server
- VPS/Cloud: 2 CPU, 4GB RAM
- OS: Ubuntu 20.04 LTS
- Process manager: PM2
- Reverse proxy: Nginx
- SSL: Let's Encrypt
- Monitoring: PM2 + LogRocket

### PM2 Commands
```bash
pm2 start server.js --name sub-vn-api
pm2 startup
pm2 save
pm2 logs
pm2 monit
```

---

## 📞 SUPPORT

- Email: dwen.khachieu@gmail.com
- Zalo: 0972562495
- Facebook: OnlyLove

---

**Version:** 1.0.0  
**Last Updated:** 2024-02-08
