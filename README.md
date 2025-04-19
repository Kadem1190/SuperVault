# SuperVault - Inventory Management System


**SuperVault** is a comprehensive inventory management system built with **Flutter**. 

- Track products
- Manage warehouses
- Monitor inventory levels
- Record transactions
- Analyze inventory data

---

## ✨ Features

### 🔐 User Management

- **Role-based Access Control**: Admin and Staff roles with different permissions  
- **User Authentication**: Secure login system  
- **User Profiles**: Manage user information and preferences  

### 📦 Product Management

- **Product Catalog**: Create, view, edit, and delete products  
- **Categories**: Organize products into categories  
- **SKU Management**: Track products with unique SKUs  
- **Product Details**: Store comprehensive product information  

### 🏢 Warehouse Management

- **Multiple Warehouses**: Support for multiple warehouse locations  
- **Warehouse Details**: Track capacity, location, and contact info  
- **Location Tracking**: Organize inventory within specific warehouse areas  

### 📊 Inventory Management

- **Real-time Stock Levels**: View stock across warehouses  
- **Low Stock Alerts**: Notification for low inventory items  
- **Stock Status**: Visual indicators for availability  

### 🔁 Transaction Management

- **Stock Operations**: Record stock-in, stock-out, transfers, and adjustments  
- **Transaction History**: Complete audit trail  
- **Notes and Documentation**: Add details to each transaction  

### 📈 Analytics and Reporting

- **Dashboard**: Key inventory metrics  
- **Stock Movement Charts**: Analyze trends  
- **Warehouse Utilization**: Monitor capacity usage  
- **Category Distribution**: Analyze inventory by category  
- **Activity Logs**: Track all system activities  

### 📶 Offline Capability

- **Local Storage**: Works offline with local database  
- **Sync Capability**: Syncs with remote database when online  

---

## 🛠️ Technologies Used

- **Flutter**: Cross-platform UI framework  
- **Dart**: Programming language  
- **MySQL**: Remote database option  
- **Local Storage**: JSON-based local DB  
- **FL Chart**: Data visualization  
- **UUID**: Unique identifier generation  
- **Crypto**: Password hashing  
- **Google Fonts**: Typography  

---

## 📋 Requirements

- Flutter SDK `>=3.0.0`  
- Dart SDK `>=3.0.0`  
- Android Studio / VS Code with Flutter extension  
- Android SDK for Android builds  
- Xcode for iOS builds  

---

## ⚙️ Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/kadem1190/supervault.git
cd supervault
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Database (Optional for Remote)

Edit the file: `lib/services/database/database_service.dart`

```dart
final String _host = 'your-database-host.com';
final int _port = 3306;
final String _user = 'your-username';
final String _password = 'your-password';
final String _db = 'supervault';
```

### 4. Run the Application

```bash
flutter run
```

---

## 📦 Building for Production

### Android

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

Use Xcode to archive and distribute the app.

---

## 🔧 Configuration

### Local Storage

By default, the app uses local storage when a remote connection is not available.  
Data is stored in the application's documents directory.

### Remote Database Setup

1. Create a MySQL database  
2. Run the SQL script `db.sql` to create necessary tables and seed data  
3. Update connection settings in `lib/services/database/database_service.dart`

---

## 📂 Project Structure

```
lib/
├── main.dart                  # App entry point
├── models/                   # Data models
├── repositories/             # Data access
├── screens/                  # UI screens
│   ├── activity_logs/        # Activity logs
│   ├── analytics/            # Analytics
│   ├── auth/                 # Authentication
│   ├── dashboard/            # Dashboard
│   ├── inventory/            # Inventory management
│   ├── products/             # Product management
│   ├── profile/              # User profiles
│   ├── transactions/         # Transactions
│   └── warehouses/           # Warehouse management
├── services/                 # Business logic
│   ├── analytics/            # Analytics services
│   ├── auth/                 # Auth services
│   └── database/             # DB services
└── utils/                    # Utility functions
```

---

## 🔐 Demo Authentication

Use the following demo credentials to log in:

- **Admin User**
  - Email: [admin@example.com](mailto:admin@example.com)
  - Password: `admin123` *(or as defined in your local db.sql setup)*

---
