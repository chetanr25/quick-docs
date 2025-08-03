# Quick Docs

Quick Docs is a modern document management and text extraction application built with Flutter and FastAPI, featuring cloud storage integration with Azure Blob Storage and Firebase.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
<!-- - [Getting Started](#getting-started) -->
  <!-- - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration) -->
<!-- - [Backend Setup](#backend-setup)
- [App Setup](#frontend-setup)
- [Project Structure](#project-structure)
- [Authentication](#authentication)
- [Storage](#storage) -->
<!-- - [API Documentation](#api-documentation) -->
<!-- - [Development Guide](#development-guide) -->
<!-- - [Deployment](#deployment) -->
- [Contributing](#contributing)
- [License](#license)

## Overview

Quick Docs is a comprehensive document management system that allows users to upload, process, and organize their documents efficiently. It features text extraction, document organization with folders, and secure cloud storage integration.

## Features

<!-- ### Authentication & User Management
- 🔐 Email/Password authentication
- 👤 User profile management
- 🔄 Automatic session management
- 📊 User storage analytics -->

### Document Management
- 📁 Folder organization
- 📄 Document upload and processing
- 🔍 Full-text search capability
- 📱 Mobile-friendly interface
- 📂 Hierarchical folder structure
- 🏷️ Document tagging and categorization

### File Processing
- 📝 Text extraction from multiple file formats
- 💾 Supported formats: PDF, TXT, DOCX, DOC
- 🔄 Background processing for large files
- 📊 Document statistics and analysis

### Storage & Security
- ☁️ Azure Blob Storage integration
- 🔒 Secure file storage
- 🚀 Firebase integration
- 💽 Local caching for better performance

### User Interface
- 🌙 Dark mode support
- 📱 Responsive design
- 🎨 Modern Material Design
- ⚡ Fast and intuitive navigation

## Tech Stack

### App
- Flutter SDK
- Firebase Auth
- Cloud Firestore
- Azure Storage SDK
- Material Design

### Backend (FastAPI)
- FastAPI framework
- Azure Blob Storage
- Python 3.8+

### Cloud Services
- Azure Blob Storage
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Storage

## Getting Started(getting-started)
<!-- 
### Prerequisites

1. Install the following tools:
- Flutter SDK
- Python 3.8+
- Azure Account
- Firebase Account

2. Required Flutter packages:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_auth: ^5.0.0
  http: ^1.4.0
  file_picker: ^10.2.0
  shared_preferences: ^2.2.3
``` -->

### Installation

1. Clone the repository:
```bash
git clone https://github.com/chetanr25/quick-docs.git
cd quick-docs
```

2. Install backend dependencies:
```bash
cd backend_api
pip install -r requirements.txt
```

3. Install flutter dependencies:
```bash
cd quick_doc_app
flutter pub get
```

### Configuration

1. Backend Environment Variables: 
##### [View .env.example](backend_api/.env.example)
```bash
AZURE_STORAGE_ACCOUNT_URL=your_storage_account_url
AZURE_STORAGE_CONTAINER_NAME=your_container_name
ALLOWED_HOSTS=*
```

2. Frontend Environment Variables:
Create a `.env` file in the `quick_doc_app` directory:
```bash
API_BASE_URL=http://localhost:8000
```

## Project Structure
The project follows a standard file structure for both app and backend components, ensuring maintainability and scalability:

### Frontend Structure
```
quick_doc_app/
├── lib/
│   ├── core/           # Core utilities and constants
│   ├── models/         # Data models
│   ├── screens/        # UI screens
│   ├── services/       # Business logic and API services
│   ├── theme/          # App theme and styling
│   ├── utils/          # Utility functions
│   └── widgets/        # Reusable widgets
```

### Backend Structure
```
backend_api/
├── app/
│   ├── api/           # API endpoints
│   ├── core/          # Core configurations
│   ├── models/        # Data models
│   ├── services/      # Business logic
│   └── utils/         # Utility functions
```

## Development Guide

### Running the Backend
```bash
cd backend_api
uvicorn main:app --reload
```

### Running the app (Recommended to use physical devices instead of emulators)
```bash
cd quick_doc_app
flutter run
```

<!-- ## API Documentation

Access the API documentation at `http://localhost:8000/docs` when running the backend server.

### Key Endpoints
- `GET /api/v1/files/storage-health`: Check storage connectivity
- `POST /api/v1/files/upload-sync`: Upload and process files
- `DELETE /api/v1/files/delete/{file_id}`: Delete a file -->

<!-- 
## Deployment
### Backend Deployment
1. Set up Azure App Service
2. Configure environment variables
3. Deploy using Azure DevOps or GitHub Actions

### Frontend Deployment
1. Build the Flutter web app:
\`\`\`bash
flutter build web
\`\`\`
2. Deploy to Firebase Hosting or your preferred hosting service -->

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
