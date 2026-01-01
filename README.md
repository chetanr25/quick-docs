# Quick Docs - Intelligent Document Manager

<div align="center">

![GitHub language count](https://img.shields.io/github/languages/count/chetanr25/quick-docs)
![GitHub top language](https://img.shields.io/github/languages/top/chetanr25/quick-docs)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109.0-009688?style=flat&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev/)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![Azure](https://img.shields.io/badge/Azure%20Blob%20Storage-12.19.0-0078D4?style=flat&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Firebase](https://img.shields.io/badge/Firebase-5.0+-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com/)

</div>

---

**Quick Docs** is a cross-platform intelligent document management system that revolutionizes how you organize, search, and access files across devices. Whether it's PDFs, Word documents, or text files, Quick Docs transforms them into **searchable**, **synced**, and **instantly accessible** resources.

Unlike traditional file managers that rely solely on filename-based search, **Quick Docs** employs advanced text extraction, intelligent tokenization, and a powerful **Magic Search** engine. Simply type a hint—a phrase, word, or even a vague memory—and Quick Docs instantly scans through your documents, maps tokens intelligently, and retrieves the exact file you need.

With **cloud synchronization**, **real-time updates**, and **offline file support**, Quick Docs seamlessly bridges the gap between convenience and reliability. From lecture notes to contracts to casual WhatsApp PDFs, your documents are always at your fingertips.  

## Table of Contents

- [Introduction](#introduction)
- [What it Solves](#what-it-solves)
- [Core Features](#core-features)
- [Technical Overview](#technical-overview)
- [Supported Files & Limits](#supported-files--limits)
- [Performance & Reliability](#performance--reliability)
- [Download & Demo](#download--demo)
- [Tech Stack](#tech-stack)
- [Contributing](#contributing)
- [License](#license)

---

## Introduction

In today's digital world, documents are everywhere: lecture notes, work reports, bills, e-books, and random PDFs sent over WhatsApp. The real challenge? **Finding them when you actually need them.**

That's where **Quick Docs** comes in.

Our application goes beyond simple filename-based search. With **Magic Search**, you don't need to remember the exact file name or location. Just type a hint—a phrase, a word, even a vague memory—and Quick Docs will instantly scan through your documents, map tokens intelligently, and retrieve the file you're looking for. ⚡

### Key Benefits

- ✅ **No more digging through folders** — Intelligent search finds files instantly
- ✅ **No more endless scrolling** — Skip the "Downloads" or "WhatsApp Documents" chaos
- ✅ **No more lost files** — Say goodbye to "I know I had that PDF somewhere…" moments
- ✅ **Offline-first approach** — Indexes local storage and makes files searchable instantly
- ✅ **Path-agnostic** — Folder structure and filename don't matter anymore

Whether you've just downloaded a PDF from the web, or someone forwarded you a document on WhatsApp, Quick Docs has your back. With **offline functionality**, it indexes local storage and makes files searchable instantly—path, folder, or filename don't matter anymore.

✨ Whether you're a student, a professional, or just someone tired of losing files in the digital mess, Quick Docs makes finding and organizing documents effortless, fast, and reliable.  


## What it Solves

Quick Docs addresses common pain points in document management:

| Problem | Solution |
|---------|----------|
| **Scattered PDFs and notes** across devices | Centralized cloud storage with real-time sync |
| **Slow, filename-only search** that misses relevant content | Full-text search with intelligent tokenization |
| **Manual copy/paste workflows** to extract text | Automatic text extraction from PDFs, DOCX, and TXT files |
| **Inconsistent organization** without folders/tags | Built-in folder management and tagging system |
| **Lack of real-time sync** and offline access | Firebase-powered real-time updates with offline caching |

Quick Docs centralizes documents, extracts content automatically, and makes them searchable and organized across all your devices.

---

## Core Features

### 🔍 Smart Search
- **Full-text search** across content, filename, and tokens
- **Intelligent tokenization** with optional NLP enhancements
- **Magic Search** that finds documents by hints and phrases

### 📤 Upload & Processing
- **Asynchronous upload** and processing powered by FastAPI backend
- **Text extraction** from PDF, DOCX, and TXT files
- **Instant metadata** and token statistics
- **Background processing** for seamless user experience

### 📁 Organization
- **Folder management** with quick move operations
- **Tagging system** for flexible categorization
- **Star/archive** functionality for important documents
- **Document statistics** including views and access times

### 👁️ Viewing & Access
- **In-app PDF viewer** with smooth navigation
- **External app support** for opening files in other applications
- **Offline access** for cached files
- **Cross-platform** support (iOS, Android, Web)

### 🔄 Realtime & Authentication
- **Firebase Authentication** (email/password)
- **Firestore-backed** real-time updates
- **Cloud synchronization** across devices  

---

## Technical Overview

### Architecture

Quick Docs follows a modern, scalable architecture pattern:

```
┌─────────────────┐     ┌──────────────┐     ┌──────────────────┐
│  Flutter App    │────▶│  FastAPI     │────▶│  Azure Blob      │
│  (Frontend)     │     │  (Backend)   │     │  Storage         │
└─────────────────┘     └──────────────┘     └──────────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌──────────────────┐
│  Firebase       │     │  Firestore       │
│  Auth           │     │  (Realtime DB)   │
└─────────────────┘     └──────────────────┘
```

- **Frontend (Flutter/Dart)**: Cross-platform UI, authentication, and client logic
- **Backend (FastAPI)**: File uploads, text extraction, and tokenization services
- **Azure Blob Storage**: Scalable cloud file storage
- **Firebase Firestore**: Real-time metadata synchronization and search indexing

### Data Flow

1. **User selects file** in the Flutter application
2. **App uploads** to FastAPI backend (synchronous or asynchronous)
3. **Backend processes** file: stores in Azure Blob Storage, extracts text, tokenizes content
4. **Backend returns** structured result (file URL, tokens, metadata)
5. **App saves** result to Firestore → UI updates in real-time via stream listeners

### Backend Highlights

- **FastAPI 0.109.0** + Uvicorn for high-performance async operations
- **Azure Storage SDK** (Blob) for reliable file persistence
- **PyPDF2** and **python-docx** for document text extraction
- **Optional spaCy** integration for advanced NLP capabilities
- **Health endpoint** for liveness and readiness checks
- **CORS middleware** for cross-origin requests

### Flutter App Highlights

- **Firebase Auth & Firestore** integration for authentication and real-time data
- **In-app PDF viewer** with intelligent caching mechanism
- **Robust upload client** with comprehensive validation and error handling
- **API URL service** with health-check and intelligent caching
- **Offline-first** architecture with local file caching

### Cloud Components

- **Azure App Service**: Production-ready backend deployment
- **Azure Blob Storage**: Scalable and durable file persistence
- **Firebase**: Authentication and real-time database services  

---

## Supported Files & Limits

### Supported File Types
- ✅ **PDF** - Full support with text extraction
- ✅ **DOCX** - Microsoft Word documents
- ✅ **TXT** - Plain text files
- ⚠️ **DOC** - Legacy format (partial support)

### Processing Capabilities
- **Asynchronous Upload**: Leveraging FastAPI's async capabilities for scalable and fast processing
- **Background Processing**: Files are processed in the background without blocking the UI
- **Large File Support**: Optimized for handling files of various sizes

---

## Performance & Reliability

Quick Docs is built with performance and reliability as core principles:

- ⚡ **Async Processing**: Powered by FastAPI for non-blocking operations
- 🔄 **Cached API Base URL**: Runtime health checks with intelligent caching
- 📡 **Stream-based Updates**: Firestore real-time streams for instant UI updates
- 💾 **Local Caching**: Offline PDF viewing with intelligent cache management
- 🛡️ **Error Handling**: Comprehensive error handling and recovery mechanisms
- 🔒 **Security**: Secure authentication and encrypted file storage

---

## Download & Demo

### Version Comparison

| Version | Features | Trade-offs |
|---------|----------|------------|
| **Old APK** | ✅ Complete offline processing<br>✅ Access to local files (incl. WhatsApp, Downloads, etc.)<br>✅ Offline search support | ❌ Heavy app size (PDF parser bundled)<br>❌ UI/UX less refined |
| **New APK (Current)** | ✅ Enhanced UI/UX<br>✅ Smart search with FastAPI backend<br>✅ Lighter and faster app<br>✅ Supports any document format (backend parsing) | ❌ No local file system processing (deprecated to reduce size & improve performance) |

### Old APK & Demo

- **[Download Old APK (100+ MB)](https://drive.usercontent.google.com/download?id=1-gzwuwJ09xD84Gc5SOsrQK5uaT5eNtc6&export=download&authuser=0)**
- **Cloud Sync Demo:** [Watch Video](https://github.com/user-attachments/assets/76dd9e4c-db7e-46fc-b85c-56ce02367332)
- **Local Storage Demo:** [Watch Video](https://github.com/user-attachments/assets/7ebe8756-3581-44f3-9663-284272d50485)

### New APK 

- **[Download Universal APK (38 MB)](https://github.com/chetanr25/quick-docs/raw/refs/heads/main/quick_doc_app/apk/app-release.apk.zip)**
- **[Download armabi-v7a APK (13 MB)](https://github.com/chetanr25/quick-docs/raw/refs/heads/main/quick_doc_app/apk/app-armeabi-v7a-release.apk.zip)**
- **[Download arm64 APK (14 MB)](https://github.com/chetanr25/quick-docs/raw/refs/heads/main/quick_doc_app/apk/app-arm64-v8a-release.apk.zip)**




---

## Tech Stack

### Backend
- **Python 3.11+** - Modern Python with type hints
- **FastAPI 0.109.0** - High-performance async web framework
- **Uvicorn** - ASGI server implementation
- **PyPDF2** - PDF text extraction
- **python-docx** - DOCX document processing
- **Azure Storage SDK** - Cloud file storage
- **python-dotenv** - Environment configuration

### Frontend
- **Flutter 3.0+** - Cross-platform UI framework
- **Dart 3.0+** - Programming language
- **Firebase SDK** - Authentication and real-time database
- **Syncfusion PDF Viewer** - In-app PDF rendering

### Cloud Infrastructure
- **Azure App Service** - Backend hosting
- **Azure Blob Storage** - File persistence
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time database

---

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:

- Code of conduct
- Development setup
- Pull request process
- Coding standards

---

## License

This project is licensed under the **MIT License**.

See the [LICENSE](LICENSE) file for details.
