# Inventory Management System

A full-stack inventory management application built with Flutter (Riverpod) for the mobile frontend and NestJS (Prisma + PostgreSQL) for the backend.

## Features

### Authentication

- Secure login with JWT tokens
- Role-based access control (Super Admin, Admin, User)
- Super admin can create and manage users

### Inventory Management

- CRUD operations for inventory items
- Search and filter functionality
- Low stock alerts
- Category management
- Real-time inventory status tracking

### User Management (Admin Only)

- Create new users
- Manage user roles and permissions
- Activate/deactivate users

## Tech Stack

### Backend

- **NestJS** - Node.js framework
- **Prisma** - Database ORM
- **PostgreSQL** - Database
- **JWT** - Authentication
- **bcrypt** - Password hashing

### Frontend

- **Flutter** - Mobile framework
- **Riverpod** - State management
- **GoRouter** - Navigation
- **Material Design 3** - UI components

## Setup Instructions

### Prerequisites

- Node.js 18+ and pnpm
- Flutter 3.7+
- PostgreSQL 12+
- Git

### Backend Setup

1. **Navigate to backend directory:**

   ```bash
   cd backend
   ```

2. **Install dependencies:**

   ```bash
   pnpm install
   ```

3. **Set up environment variables:**

   ```bash
   cp .env.example .env
   ```

   Update the `.env` file with your PostgreSQL connection string:

   ```
   DATABASE_URL="postgresql://username:password@localhost:5432/inventory_db?schema=public"
   JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
   JWT_EXPIRATION="24h"
   PORT=3000
   ```

4. **Set up the database:**

   ```bash
   # Generate Prisma client
   pnpm prisma:generate

   # Push database schema
   pnpm prisma:push

   # Seed the super admin user
   pnpm seed
   ```

5. **Start the development server:**
   ```bash
   pnpm start:dev
   ```

The backend will be running at `http://localhost:3000`

### Frontend Setup

1. **Navigate to mobile directory:**

   ```bash
   cd mobile
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Generate model files:**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application:**

   ```bash
   # For development
   flutter run

   # Or for web
   flutter run -d chrome
   ```

## Default Credentials

After seeding the database, you can login with:

- **Username:** `superadmin`
- **Password:** `admin123`

⚠️ **Important:** Change these credentials in production!

## API Endpoints

### Authentication

- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get current user profile
- `POST /api/auth/users` - Create new user (Admin only)
- `GET /api/auth/users` - List all users (Admin only)
- `PATCH /api/auth/users/:id/status` - Update user status (Admin only)

### Inventory

- `GET /api/inventory` - List inventory items (with pagination and filters)
- `POST /api/inventory` - Create new inventory item
- `GET /api/inventory/:id` - Get specific inventory item
- `PATCH /api/inventory/:id` - Update inventory item
- `DELETE /api/inventory/:id` - Delete inventory item
- `GET /api/inventory/stats` - Get inventory statistics
- `GET /api/inventory/low-stock` - Get low stock items

## Project Structure

### Backend (`/backend`)

```
src/
├── auth/                 # Authentication module
│   ├── dto/             # Data transfer objects
│   ├── guards/          # Auth guards
│   ├── strategies/      # Passport strategies
│   └── decorators/      # Custom decorators
├── inventory/           # Inventory module
│   ├── dto/            # Data transfer objects
│   └── inventory.service.ts
├── prisma/             # Prisma service
└── main.ts             # Application entry point
```

### Frontend (`/mobile`)

```
lib/
├── models/             # Data models
├── providers/          # Riverpod providers
├── screens/           # UI screens
├── widgets/           # Reusable widgets
├── services/          # API services
└── main.dart          # Application entry point
```

## Database Schema

### Users Table

- `id` (String, Primary Key)
- `username` (String, Unique)
- `password` (String, Hashed)
- `role` (Enum: SUPER_ADMIN, ADMIN, USER)
- `isActive` (Boolean)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

### Inventory Items Table

- `id` (String, Primary Key)
- `name` (String)
- `description` (String, Optional)
- `sku` (String, Unique)
- `quantity` (Integer)
- `minQuantity` (Integer)
- `price` (Decimal)
- `category` (String, Optional)
- `location` (String, Optional)
- `status` (Enum: IN_STOCK, LOW_STOCK, OUT_OF_STOCK)
- `createdById` (String, Foreign Key)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

## Development

### Backend Development

```bash
# Start in development mode with hot reload
pnpm start:dev

# Run tests
pnpm test

# Database operations
pnpm prisma:studio    # Open Prisma Studio
pnpm prisma:migrate   # Create and apply migrations
```

### Frontend Development

```bash
# Hot reload development
flutter run

# Run tests
flutter test

# Build for production
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Security Notes

- Always use HTTPS in production
- Change default JWT secret
- Update default admin credentials
- Implement rate limiting
- Use environment variables for sensitive data
- Regular security updates

## License

This project is for educational/demonstration purposes.
