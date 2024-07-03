# Quick Doc

Quick Doc is your ultimate solution to effortlessly manage, search, and access all your PDF documents across multiple platforms. Whether you're a student, a working professional, or anyone who deals with numerous PDF files, Quick Doc ensures that you never lose track of your important documents again. Say goodbye to the hassle of sifting through thousands of files or struggling to remember file names. Quick Doc's intelligent search and seamless synchronization features bring you the PDFs you need in a flash!

## Table of Contents

- [Features](#features)
- [Benefits](#benefits)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Setting up Firebase](#setting-up-firebase)
    - [Firebase Authentication](#firebase-authentication)
    - [Firebase Storage](#firebase-storage)
    - [Firebase Firestore](#firebase-firestore)
- [Usage](#usage)

## Features

- **Cloud and Local Storage**: Upload PDFs to the cloud for secure storage and access from anywhere, or access PDFs directly from your device's local storage.
- **Advanced Search**: Search for PDFs using keywords, even if you don't remember the exact name. The app uses tokenization and lemmatization to identify similar words and provide accurate search results.
- **Cross-Platform Compatibility**: Access and manage your PDFs seamlessly across Android, iOS, and Web platforms. Changes made on one device reflect instantly on others.
- **Real-Time Sync**: Changes made on one device reflect instantly on all other devices connected to your account.
- **Offline Functionality**: Search and access locally stored PDFs without an internet connection.
- **Automatic Import**: Quick Doc automatically detects PDFs downloaded from messaging apps or the internet, making them readily available in the app.
- **Color-Coded Display**: Easily differentiate between cloud-stored and locally stored PDFs with clear color coding.
- **User-Friendly Interface**: Manage your PDFs with ease through intuitive features like creating folders, renaming files, rearranging documents, and deleting unwanted files.
- **Integrated PDF Viewer**: View your PDFs directly within the app or choose to open them with your preferred external PDF viewer.
- **Offline Caching**: Downloaded PDFs are cached locally for faster access without repeated internet downloads.
- **Multi-Platform Support**: Use Quick Doc on Android, iOS, and Web. Upload PDFs from your Android phone, manage them on your iOS device, and search or view them on the web.
- **User Authentication**: Securely sign in using your email account.

## Benefits

- **Efficiency**: Quickly find the PDFs you need without wasting time searching through folders, even with vague search terms.
- **Reduce Frustration**: Eliminate the hassle of searching through countless files.
- **Convenience**: Seamlessly switch between devices and platforms, with real-time synchronization.
- **Accessibility**: Access your PDFs anytime, anywhere, whether stored locally or in the cloud.
- **Reliability**: Rest assured knowing your documents are securely stored and easily retrievable.
- **Offline Availability**: Work with your PDFs even without an internet connection.

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase account
- Dart

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/quick-doc.git
   cd quick-doc
   ```

### Setting up Firebase

To set up Firebase for Quick Doc, you'll need to configure Firebase Authentication, Firebase Storage, and Firebase Firestore. Follow the steps below for each service:

#### Firebase Authentication

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project (or select an existing one).
3. Navigate to **Authentication** in the left menu.
4. Click **Get Started** and enable **Email/Password** sign-in method.

For more detailed instructions, visit the [Firebase Authentication Documentation](https://firebase.google.com/docs/auth).

#### Firebase Storage

1. In the Firebase Console, navigate to **Storage** in the left menu.
2. Click **Get Started** and select your default storage location.
3. Use the default security rules for development, and adjust them as needed for production.

For more details, check the [Firebase Storage Documentation](https://firebase.google.com/docs/storage).

#### Firebase Firestore

1. In the Firebase Console, navigate to **Firestore Database** in the left menu.
2. Click **Create Database** and select **Start in production mode** or **Start in test mode** based on your requirements.
3. Choose your database location and complete the setup.

For detailed instructions, visit the [Firebase Firestore Documentation](https://firebase.google.com/docs/firestore).

4. **Add Firebase configuration files**:

   - Download the `google-services.json` file for Android and `GoogleService-Info.plist` file for iOS from the Firebase Console.
   - Place these files in the appropriate directories in your Flutter project.

5. **Run the app**:
   ```bash
   flutter run
   ```

## Usage

1. **Authentication**:

   - Sign in using your email account.

2. **Upload PDFs**:

   - Create folders and upload PDFs. Text from the PDFs will be processed for easy searching.

3. **Search PDFs**:

   - Use the search bar to find PDFs using keywords. The app supports searching with exact words and similar words also.

4. **Manage PDFs**:

   - Edit, delete, rename, and reorder files and folders. Changes reflect instantly across all devices.

5. **Local Storage Access**:
   - Quick Doc automatically loads PDFs from your device’s local storage, making them available for search and access without internet.

