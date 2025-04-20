# Flutter Todo App

A modern Todo application built with Flutter and Supabase, featuring:

- 🔐 Google Sign-In Authentication
- 📝 Create, Read, Update, Delete (CRUD) operations for todos
- 🎨 Dark/Light theme support
- 💾 Persistent storage with Supabase
- 🔄 Real-time updates

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Android Studio / VS Code
- A Supabase account and project

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/todoapp.git
```

2. Navigate to the project directory:
```bash
cd todoapp
```

3. Install dependencies:
```bash
flutter pub get
```

4. Update the Supabase configuration in `lib/main.dart` with your project credentials.

5. Run the app:
```bash
flutter run
```

## Features

- User Authentication
  - Google Sign-In
  - Email/Password Sign-In
  - Sign-Up functionality
- Todo Management
  - Add new todos
  - Mark todos as complete/incomplete
  - Edit existing todos
  - Delete todos
- Theme Support
  - Dynamic theme switching
  - Dark mode support
- Responsive Design
  - Works on both mobile and tablet

## Architecture

The app follows Clean Architecture principles and is organized into the following structure:

```
lib/
  ├── config/           # Configuration files
  ├── core/            # Core functionality
  │   ├── routes/      # Navigation routes
  │   └── theme/       # Theme configuration
  ├── features/        # Feature modules
  │   ├── auth/        # Authentication
  │   ├── tasks/       # Todo management
  │   └── splash/      # Splash screen
  └── main.dart        # Entry point
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
