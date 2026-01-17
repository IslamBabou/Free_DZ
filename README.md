# Free_DZ

[![Flutter](https://img.shields.io/badge/Flutter-3.10.1-blue.svg)](https://flutter.dev/)

A comprehensive freelancing platform built with Flutter, connecting clients and freelancers in Algeria. The app provides a seamless experience for posting jobs, offering services, and managing freelance projects.

## Features

- **Dual User Roles**: Separate interfaces for clients and freelancers with tailored experiences
- **Job Management**: Clients can post jobs with detailed requirements, budgets, and categories
- **Service Marketplace**: Freelancers can create and showcase their services
- **Proposal System**: Streamlined proposal submission and management
- **In-App Messaging**: Direct communication between clients and freelancers
- **Profile Management**: Comprehensive profiles with skills, portfolios, and ratings
- **Theme Support**: Built-in light and dark mode support
- **Secure Data Storage**: Local data persistence with encryption
- **Cross-Platform**: Supports Android, iOS, Web, and Desktop

## Getting Started

### Prerequisites

- Flutter SDK (^3.10.1) - [Installation Guide](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter extensions
- A running backend API server

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/free_dz.git
   cd free_dz
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   
   Update the `baseUrl` in `lib/services/api_helper.dart` to point to your backend server:
   ```dart
   static const String baseUrl = 'https://free-dz.onrender.com:8000/api';
   ```
   or keep the hosting url 

4. **Run the application:**
   ```bash
   flutter run
   ```

   For specific platforms:
   ```bash
   flutter run -d android  # Android
   flutter run -d chrome   # Web
   flutter run -d linux    # Linux
   ```

### Usage

1. **User Registration**: Choose between client or freelancer account type during signup
2. **Client Workflow**:
   - Post new jobs with title, description, budget, and category
   - Browse available freelancers and their services
   - Review incoming proposals and select freelancers
   - Communicate through the messaging system
3. **Freelancer Workflow**:
   - Complete profile setup with skills and experience
   - Create service listings with pricing and descriptions
   - Browse available jobs and submit tailored proposals
   - Manage ongoing projects and communications

## API Integration

The application requires a REST API backend for data persistence and real-time features. The API handles:
- User authentication and authorization
- Job and service CRUD operations
- Proposal management
- Messaging functionality
- File uploads for profiles and portfolios

Ensure your backend server is running and accessible before using the app.

## Support

- [Flutter Documentation](https://flutter.dev/docs) - Official Flutter guides and API reference
- [GitHub Issues](https://github.com/yourusername/free_dz/issues) - Report bugs and request features
- [Flutter Community](https://flutter.dev/community) - Get help from the Flutter community

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to get started.

## Maintainers

- [Islam Babou](https://github.com/IslamBabou) - Project Lead

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for more information.
