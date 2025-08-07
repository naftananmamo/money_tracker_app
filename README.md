# 💰 Abiye App - Multi-User Family Money Tracker

A comprehensive Flutter family money management app designed for multi-user household allowance and transaction tracking.

## ✨ Key Features

### 👥 Multi-User Management
- **Individual User Accounts**: Create separate accounts for each family member
- **Individual Balances**: Each user maintains their own money balance
- **Targeted Transactions**: Add or subtract money for specific family members
- **User-Specific Transaction History**: Track money flow per individual

### � Advanced Money Management
- **Targeted Money Operations**: Select which family member receives/spends money
- **Transaction Reasons**: Categorize transactions (chores, allowance, purchases, etc.)
- **Detailed Transaction Logging**: Complete history with timestamps and descriptions
- **Real-time Balance Updates**: Instant synchronization across all devices

### 🎨 Dual User Interface
- **Role-Based Access**: Separate views for parent (Tedi) and child (Abiye)
- **Personalized Themes**: Blue theme for parent, vibrant pink theme for child
- **Child-Friendly Design**: Intuitive, colorful interface with large buttons and clear icons

### 📊 Task & Category System
- **Category Management**: Organize tasks into customizable categories (Chores, School Tasks, etc.)
- **Task-Based Rewards**: Assign monetary values to specific tasks
- **Category-Specific Task Lists**: Group related activities together

### 🔄 Real-Time Synchronization
- **Firebase Firestore Integration**: Cross-platform data synchronization
- **Live Updates**: Changes reflect instantly across web, Android, and other platforms
- **Cloud Backup**: Data safely stored in the cloud

## 🔐 User Roles & Access

### 👨 Tedi (Parent) - Full Admin Access
- **Password Protection**: Secured with password `Tediab1234`
- **Family Member Management**: Add/remove family members
- **Money Operations**: Add or subtract money for any family member
- **Category & Task Management**: Full CRUD operations for categories and tasks
- **Transaction Management**: View all family transactions
- **Blue-Themed Interface**: Professional, clean design

### 👧 Abiye (Child) - View & Monitor Access
- **Password-Free Access**: Easy login for child users
- **Balance Viewing**: See all family members' current balances
- **Transaction History**: View recent family money activity
- **Category Browsing**: Read-only access to task categories and rewards
- **Vibrant Pink Interface**: Fun, engaging design optimized for children

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: Version 3.32.5 or higher
- **Dart**: Version 3.8.1 or higher
- **Firebase Account**: For backend data storage and sync
- **Development Environment**: Android Studio, VS Code, or other Flutter-compatible IDE

### Installation & Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/naftananmamo/money_tracker_app.git
   cd abiye_app
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Ensure `firebase_options.dart` is properly configured
   - Verify `google-services.json` is in the `android/app/` directory
   - Check Firebase project connection

4. **Run the Application**
   ```bash
   # Run on connected device/emulator
   flutter run
   
   # Run for web
   flutter run -d chrome
   
   # Build for release
   flutter build apk
   ```

## 🌐 Live Demo

🔗 **Web Application**: [https://abiyeapp.web.app](https://abiyeapp.web.app)

Access the live demo to test features without installation. Data syncs between web and mobile versions.

## 📱 Platform Support

- ✅ **Android**: Full functionality with Firebase sync
- ✅ **Web**: Complete web app deployed on Firebase Hosting
- ✅ **iOS**: iOS compatibility (requires setup)
- ✅ **Windows**: Desktop support available
- ✅ **macOS**: macOS compatibility
- ✅ **Linux**: Linux desktop support

## 🔥 Firebase Setup

This app uses Firebase Firestore for data persistence. The configuration is already included in `lib/firebase_options.dart`.

**Project ID**: `abiyeapp`

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Windows (experimental)
- ✅ macOS

## 🛠️ Development

- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **Database**: Firebase Firestore
- **Architecture**: StatefulWidget with local state management

## 📄 License

This project is for personal/educational use.
