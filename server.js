// =====================================================
// SUB.VN API - MAIN SERVER FILE
// =====================================================

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const serviceRoutes = require('./routes/services');
const orderRoutes = require('./routes/orders');
const transactionRoutes = require('./routes/transactions');
const depositRoutes = require('./routes/deposits');
const adminRoutes = require('./routes/admin');
const statsRoutes = require('./routes/stats');
const japRoutes = require('./routes/jap');

// Import middlewares
const { errorHandler } = require('./middleware/errorHandler');
const { notFound } = require('./middleware/notFound');

// Import cronjobs
const { initCronjobs } = require('./services/cronjobs');

// Initialize Express
const app = express();
app.use(express.static(__dirname));
app.use(cors());
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/sub-website.html');
});

app.get('/index.html', (req, res) => {
    res.sendFile(__dirname + '/sub-website.html');
});
app.use('/api/jap', japRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/services', serviceRoutes); 
app.use('/api/orders', orderRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/deposits', depositRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/stats', statsRoutes);
const PORT = process.env.PORT || 3000;

// =====================================================
// MIDDLEWARE SETUP
// =====================================================

// Security headers
app.use(helmet());

// CORS
app.use(cors({
    origin: process.env.NODE_ENV === 'production' 
        ? ['https://sub.vn', 'https://www.sub.vn'] 
        : '*',
    credentials: true
}));

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging
if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
} else {
    app.use(morgan('combined'));
}

// Rate limiting
const limiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
    message: 'Quá nhiều request từ IP này, vui lòng thử lại sau.'
});
app.use('/api/', limiter);

// Stricter rate limit for auth endpoints
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 10, // 10 requests per 15 minutes
    message: 'Quá nhiều lần đăng nhập thất bại, vui lòng thử lại sau 15 phút.'
});

// =====================================================
// ROUTES
// =====================================================

app.use('/api/jap', japRoutes);
// Homepage
app.get("/", (req, res) => {
  res.sendFile(__dirname + "/sub-website.html");
});
// Health check
app.get('/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV
    });
});

// API Routes
app.use('/api/auth', authLimiter, authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/orders', orderRoutes.router || orderRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/deposits', depositRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/stats', statsRoutes);


app.use('/api/jap', japRoutes);

// API Documentation
app.get('/api', (req, res) => {
    res.json({
        name: 'SUB.VN API',
        version: '1.0.0',
        description: 'Social Media Marketing Panel API',
        endpoints: {
            auth: {
                'POST /api/auth/register': 'Đăng ký tài khoản mới',
                'POST /api/auth/login': 'Đăng nhập',
                'POST /api/auth/logout': 'Đăng xuất',
                'POST /api/auth/forgot-password': 'Quên mật khẩu',
                'POST /api/auth/reset-password': 'Đặt lại mật khẩu',
                'GET /api/auth/verify-email/:token': 'Xác thực email'
            },
            users: {
                'GET /api/users/profile': 'Lấy thông tin profile',
                'PUT /api/users/profile': 'Cập nhật profile',
                'PUT /api/users/change-password': 'Đổi mật khẩu',
                'GET /api/users/balance': 'Xem số dư'
            },
            services: {
                'GET /api/services': 'Danh sách dịch vụ',
                'GET /api/services/:id': 'Chi tiết dịch vụ',
                'GET /api/services/platform/:platform': 'Dịch vụ theo platform'
            },
            orders: {
                'POST /api/orders': 'Tạo đơn hàng mới',
                'GET /api/orders': 'Danh sách đơn hàng',
                'GET /api/orders/:id': 'Chi tiết đơn hàng',
                'GET /api/orders/status/:orderCode': 'Kiểm tra trạng thái đơn'
            },
            deposits: {
                'POST /api/deposits': 'Tạo yêu cầu nạp tiền',
                'GET /api/deposits': 'Lịch sử nạp tiền',
                'POST /api/deposits/verify': 'Xác nhận đã chuyển khoản'
            },
            admin: {
                'GET /api/admin/users': 'Quản lý users',
                'PUT /api/admin/users/:id': 'Cập nhật user',
                'DELETE /api/admin/users/:id': 'Xóa user',
                'GET /api/admin/orders': 'Quản lý đơn hàng',
                'GET /api/admin/deposits': 'Quản lý nạp tiền',
                'POST /api/admin/deposits/:id/approve': 'Duyệt nạp tiền',
                'POST /api/admin/services': 'Thêm dịch vụ mới',
                'PUT /api/admin/services/:id': 'Cập nhật dịch vụ'
            },
            stats: {
                'GET /api/stats/dashboard': 'Thống kê tổng quan',
                'GET /api/stats/revenue': 'Thống kê doanh thu',
                'GET /api/stats/users': 'Thống kê users',
                'GET /api/stats/orders': 'Thống kê đơn hàng'
            }
        }
    });
});

// =====================================================
// ERROR HANDLING
// =====================================================

// 404 handler
app.use(notFound);
app.use(errorHandler);

// Global error handler
app.use(errorHandler);

// =====================================================
// START SERVER
// =====================================================
app.get("/", (req, res) => {
  res.sendFile(__dirname + "/sub-website.html");
});
app.listen(PORT, () => {
    console.log(`
╔═══════════════════════════════════════════════════╗
║           SUB.VN API SERVER                       ║
╚═══════════════════════════════════════════════════╝
    
✅ Server running on port ${PORT}
🌍 Environment: ${process.env.NODE_ENV}
📡 API Endpoint: http://localhost:${PORT}/api
📊 Health Check: http://localhost:${PORT}/health
    
Contact: ${process.env.CONTACT_EMAIL}
Zalo: ${process.env.CONTACT_ZALO}
    `);

    // Initialize cronjobs
    if (process.env.ENABLE_CRONJOBS === 'true') {
        initCronjobs();
        console.log('✅ Cronjobs initialized');
    }
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
    console.error('❌ UNHANDLED REJECTION! Shutting down...');
    console.error(err);
    process.exit(1);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
    console.error('❌ UNCAUGHT EXCEPTION! Shutting down...');
    console.error(err);
    process.exit(1);
});

app.use(cors({
  origin: '*'
}));
