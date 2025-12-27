# Contributing to Quick Docs

Thank you for your interest in contributing to Quick Docs! This document provides guidelines and instructions for contributing to the project. By participating, you agree to abide by our code of conduct and the guidelines outlined below.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)
- [Questions?](#questions)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/quick-docs.git
   cd quick-docs
   ```
3. **Add the upstream repository**:
   ```bash
   git remote add upstream https://github.com/chetanr25/quick-docs.git
   ```
4. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- **Flutter SDK**: >=3.0.0 <4.0.0
- **Dart SDK**: >=3.0.0
- **Python**: 3.8+ (for backend development)
- **Firebase Account**: For authentication and Firestore (you'll need your own project)
- **Azure Account**: For blob storage (optional, for backend development)

### Flutter App Setup

1. Navigate to the Flutter app directory:
   ```bash
   cd quick_doc_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   - Install FlutterFire CLI (if not already installed):
     ```bash
     dart pub global activate flutterfire_cli
     ```
   - Configure Firebase for your project:
     ```bash
     flutterfire configure
     ```
   - This will:
     - Prompt you to select/create a Firebase project
     - Generate `lib/firebase_options.dart` with platform-specific configurations
     - Set up Android (`google-services.json`) and iOS (`GoogleService-Info.plist`) configuration files
   - Make sure you have a Firebase project created in the [Firebase Console](https://console.firebase.google.com/)
   - The CLI will automatically integrate Firebase with your project using your Firebase account

4. Set up environment variables:
   - Create a `.env` file in `quick_doc_app/` directory
   - Add your API base URL:
     ```env
     API_BASE_URL=http://localhost:8000
     # Or your backend API URL
     ```

5. Run the app:
   ```bash
   flutter run
   ```

### Backend API Setup

1. Navigate to the backend directory:
   ```bash
   cd backend_api
   ```

2. Create a virtual environment (recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Set up environment variables:
   - Create a `.env` file in `backend_api/` directory
   - Add your Azure Storage configuration:
     ```env
     AZURE_STORAGE_ACCOUNT_URL=https://yourstorageaccount.blob.core.windows.net
     AZURE_STORAGE_CONTAINER_NAME=quickdocs
     ```
   - **Note**: The backend uses Azure Managed Identity/DefaultAzureCredential for authentication. Make sure you have configured Azure credentials (either via Azure CLI login, environment variables, or managed identity in Azure).

5. Run the backend server:
   ```bash
   python run.py
   # Or using uvicorn directly:
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

The API will be available at `http://localhost:8000`

## Project Structure

```
quick-docs/
├── backend_api/          # FastAPI backend
│   ├── app/
│   │   ├── api/         # API routes and endpoints
│   │   ├── core/        # Configuration and exceptions
│   │   ├── models/      # Pydantic models/schemas
│   │   ├── services/    # Business logic and services
│   │   └── main.py      # FastAPI application entry point
│   ├── requirements.txt
│   └── run.py
│
├── quick_doc_app/        # Flutter mobile app
│   ├── lib/
│   │   ├── core/        # Core utilities and constants
│   │   ├── models/      # Data models
│   │   ├── screens/     # UI screens
│   │   ├── services/    # API and business logic services
│   │   ├── widgets/     # Reusable widgets
│   │   └── main.dart    # App entry point
│   ├── pubspec.yaml
│   └── analysis_options.yaml
│
└── README.md
```

## Development Workflow

1. **Sync with upstream** before starting new work:
   ```bash
   git checkout main
   git pull upstream main
   ```

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # Or for bug fixes:
   git checkout -b fix/bug-description
   ```

3. **Make your changes** following our coding standards

4. **Test your changes** thoroughly (see [Testing](#testing))

5. **Commit your changes** with clear, descriptive messages:
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   # Use conventional commit format (see below)
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request** on GitHub

### Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/) format:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, missing semicolons, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples:
- `feat: add folder organization feature`
- `fix: resolve PDF viewer caching issue`
- `docs: update API documentation`
- `refactor: improve file upload service`

## Coding Standards

### Dart/Flutter Code

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter_lints` package rules (already configured in `analysis_options.yaml`)
- Run the analyzer before committing:
  ```bash
  cd quick_doc_app
  flutter analyze
  ```
- Format code:
  ```bash
  flutter format .
  ```

**Style Guidelines:**
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small
- Prefer composition over inheritance
- Use `const` constructors where possible
- Handle errors appropriately (use try-catch, nullable types)

### Python/FastAPI Code

- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) style guide
- Use type hints for function parameters and return types
- Format code using `black` or similar formatters
- Keep functions focused and maintainable
- Add docstrings to functions and classes
- Handle exceptions properly

**Style Guidelines:**
- Use descriptive variable names
- Keep functions under 50 lines when possible
- Use async/await properly for asynchronous operations
- Validate input using Pydantic models
- Return appropriate HTTP status codes

### General Guidelines

- **Write clear, readable code** - code is read more often than it's written
- **Keep changes focused** - one feature or bug fix per pull request
- **Update documentation** - if you change APIs or add features, update relevant docs
- **Add comments** - explain why, not what (the code should be self-explanatory)

## Testing

### Flutter App Testing

- Write unit tests for business logic and services
- Write widget tests for UI components
- Run tests:
  ```bash
  cd quick_doc_app
  flutter test
  ```

### Backend Testing

- Write unit tests for services and utilities
- Write integration tests for API endpoints
- Run tests:
  ```bash
  cd backend_api
  pytest  # If pytest is set up
  ```

**Testing Guidelines:**
- Aim for meaningful test coverage
- Test edge cases and error scenarios
- Keep tests fast and independent
- Use descriptive test names

## Submitting Changes

### Pull Request Process

1. **Ensure your code is ready:**
   - All tests pass
   - Code follows style guidelines
   - Documentation is updated (if needed)
   - No linter errors

2. **Create a Pull Request:**
   - Use a clear, descriptive title
   - Fill out the PR template (if available)
   - Reference any related issues: `Fixes #123` or `Closes #456`

3. **PR Description should include:**
   - What changes were made
   - Why the changes were needed
   - How to test the changes
   - Screenshots (for UI changes)
   - Any breaking changes

4. **Respond to feedback:**
   - Be open to constructive criticism
   - Make requested changes promptly
   - Ask questions if something is unclear

5. **Maintainers will review:**
   - Code quality and style
   - Functionality and edge cases
   - Test coverage
   - Documentation updates

### Pull Request Guidelines

- Keep PRs focused and reasonably sized
- Rebase on main if there are conflicts
- Ensure CI checks pass
- Wait for approval before merging (unless you're a maintainer)

## Reporting Bugs

If you find a bug, please open an issue with the following information:

1. **Clear description** of the bug
2. **Steps to reproduce** the issue
3. **Expected behavior** vs **Actual behavior**
4. **Environment details:**
   - OS version
   - Flutter/Dart version (for frontend issues)
   - Python version (for backend issues)
   - App version (if applicable)
5. **Screenshots or logs** (if relevant)
6. **Any error messages** or stack traces

**Issue Template:**
```
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment (please complete the following information):**
- OS: [e.g. iOS 17.0, Android 13]
- App Version: [e.g. 1.0.0]
- Flutter Version: [e.g. 3.16.0]

**Additional context**
Add any other context about the problem here.
```

## Suggesting Features

We welcome feature suggestions! Please open an issue with:

1. **Clear description** of the feature
2. **Use case** - why would this be useful?
3. **Proposed solution** (optional, but helpful)
4. **Alternatives considered** (if any)

**Feature Request Template:**
```
**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
```

## Questions?

If you have questions about contributing:

- Open a discussion on GitHub
- Review existing issues and PRs
- Check the README.md for project overview

## Thank You!

Your contributions help make Quick Docs better for everyone. Whether it's code, documentation, bug reports, or feature suggestions, we appreciate your help! 🎉

---

**Note for Maintainers:** This document should be updated as the project evolves. If you notice outdated information, please update it or open an issue.

