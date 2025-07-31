# Inventory Management System - Setup Guide

## 🚀 Quick Start

This guide will help you set up and run the complete inventory management system with authentication and role-based access control.

## Prerequisites

- **Node.js 18+** and **pnpm**
- **Flutter 3.7+**
- **PostgreSQL 12+**
- **Git**

## Step 1: Database Setup

1. **Install PostgreSQL** if you haven't already
2. **Create a database** named `inventory_db`:
   ```sql
   CREATE DATABASE inventory_db;
   ```
3. **Note your database credentials** (username, password, host, port)

## Step 2: Backend Setup

1. **Navigate to backend directory:**

   ```bash
   cd backend
   ```

2. **Install dependencies:**

   ```bash
   pnpm install
   ```

3. **Configure environment variables:**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your settings:

   ```env
   DATABASE_URL="postgresql://username:password@localhost:5432/inventory_db?schema=public"
   JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
   JWT_EXPIRATION="24h"
   PORT=3000
   ```

4. **Set up the database schema:**

   ```bash
   pnpm prisma:generate
   pnpm prisma:push
   ```

5. **Seed the super admin user:**

   ```bash
   pnpm seed
   ```

6. **Start the backend server:**
   ```bash
   pnpm start:dev
   ```

The backend will be running at `http://localhost:3000`

## Step 3: Frontend Setup

1. **Navigate to mobile directory:**

   ```bash
   cd mobile
   ```

2. **Install Flutter dependencies:**

   ```bash
   flutter pub get
   ```

3. **Generate model files** (if not already done):

   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the Flutter application:**

   ```bash
   # For desktop/web development
   flutter run -d chrome

   # For mobile development (with device/emulator connected)
   flutter run
   ```

## Step 4: First Login

1. **Open the app** in your browser/device
2. **Login with the default super admin credentials:**
   - **Username:** `superadmin`
   - **Password:** `admin123`

⚠️ **Security Note:** Change these credentials immediately in production!

## 🎯 What You Can Do Now

### As Super Admin:

- ✅ **Dashboard:** View inventory statistics and overview
- ✅ **Inventory Management:** Add, edit, delete, and search inventory items
- ✅ **User Management:** Create new users (Admin/User roles)
- ✅ **User Status Control:** Activate/deactivate users
- ✅ **Full Access:** All system features

### Creating Your First Items:

1. Go to **Inventory** section
2. Click the **+** button (floating action button)
3. Fill in item details:
   - Name, SKU, quantity, price (required)
   - Description, category, location (optional)
   - Min quantity for low stock alerts
4. Save and see it in your inventory list

### Adding Team Members:

1. Go to **User Management**
2. Click the **+** button
3. Create users with **Admin** or **User** roles
4. Admins can manage users, Users can only manage inventory

## 📱 Features Overview

### Authentication System

- Secure JWT-based authentication
- Role-based access control (Super Admin, Admin, User)
- Session management with auto-logout

### Inventory Management

- Full CRUD operations on inventory items
- Search and filter functionality
- Low stock alerts and notifications
- Category and location organization
- Real-time inventory status tracking

### User Management (Admin Only)

- Create users with different roles
- Activate/deactivate user accounts
- View user activity and creation dates

### Dashboard

- Real-time inventory statistics
- Quick action cards
- Low stock alerts with badges
- Pull-to-refresh functionality

## 🔧 Development Mode

### Backend Development

```bash
cd backend

# Hot reload development
pnpm start:dev

# Run tests
pnpm test

# Database management
pnpm prisma:studio    # Open Prisma Studio (GUI)
pnpm prisma:migrate   # Create migrations
```

### Frontend Development

```bash
cd mobile

# Hot reload development
flutter run

# Run tests
flutter test

# Build for production
flutter build web      # Web build
flutter build apk      # Android build
```

## 📊 API Endpoints

### Authentication

- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get current user profile
- `POST /api/auth/users` - Create user (Admin only)
- `GET /api/auth/users` - List users (Admin only)
- `PATCH /api/auth/users/:id/status` - Update user status (Admin only)

### Inventory

- `GET /api/inventory` - List inventory items (with pagination, search, filters)
- `POST /api/inventory` - Create inventory item
- `GET /api/inventory/:id` - Get specific item
- `PATCH /api/inventory/:id` - Update item
- `DELETE /api/inventory/:id` - Delete item
- `GET /api/inventory/stats` - Get inventory statistics
- `GET /api/inventory/low-stock` - Get low stock items

## 🔒 Security Features

- Password hashing with bcrypt
- JWT token authentication
- Role-based authorization
- Input validation and sanitization
- CORS protection
- SQL injection protection (Prisma ORM)

## 🎨 UI/UX Features

- Modern Material Design 3
- Responsive design for all screen sizes
- Dark/Light theme support (system default)
- Pull-to-refresh functionality
- Loading states and error handling
- Intuitive navigation with drawer
- Real-time data updates

## 🐛 Troubleshooting

### Backend Issues

- **Database connection failed:** Check your `DATABASE_URL` in `.env`
- **Port already in use:** Change `PORT` in `.env` or stop other services
- **Prisma errors:** Run `pnpm prisma:generate` and `pnpm prisma:push`

### Frontend Issues

- **Dependencies issues:** Run `flutter clean` then `flutter pub get`
- **Build runner errors:** Delete generated files and run build runner again
- **Network errors:** Check if backend is running on correct port

### Common Solutions

- **Clear browser cache** for web development
- **Restart development servers** after major changes
- **Check console logs** for detailed error messages

## 📈 Next Steps

1. **Customize Categories:** Add your own product categories
2. **Configure Notifications:** Set up email notifications for low stock
3. **Export Data:** Add CSV/Excel export functionality
4. **Reports:** Create inventory reports and analytics
5. **Barcode Scanning:** Add barcode support for mobile
6. **Multi-location:** Extend for multiple warehouse locations

## 💡 Tips for Production

1. **Change default credentials**
2. **Use strong JWT secrets**
3. **Set up SSL/HTTPS**
4. **Configure production database**
5. **Set up monitoring and logging**
6. **Regular backups**
7. **Update dependencies regularly**

## 🤝 Support

If you encounter any issues:

1. Check this guide first
2. Look at the README.md for technical details
3. Check the console logs for error messages
4. Ensure all prerequisites are properly installed

Happy inventory management! 🎉
