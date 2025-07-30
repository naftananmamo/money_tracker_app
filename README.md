# 💰 Abiye App - Family Money Tracker

A Flutter family allowance tracking app designed for parent-child money management.

## 👨‍👧 Features

- **Dual User Interface**: Separate views for parent (Tedi) and child (Abiye)
- **Money Management**: Track balance, add/subtract money with descriptions
- **Task & Category System**: Organize chores and tasks with monetary values
- **Real-time Sync**: Firebase Firestore for cross-device synchronization
- **Child-Friendly Design**: Colorful, intuitive interface with role-based themes

## 🔐 User Roles

### Tedi (Parent) - Admin Access
- Password protected: `Tediab1234`
- Can add/subtract money from shared balance
- Full category and task management
- Blue-themed interface

### Abiye (Child) - View Access
- No password required
- Can view current balance and transaction history
- Can browse categories and tasks (read-only)
- Pink-themed interface

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1+)
- Firebase account and project setup
- Android Studio / VS Code with Flutter plugins

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd abiye_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

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
