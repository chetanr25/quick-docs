
# Quick Docs - Intelligent Document Manager

Quick Docs is a cross-platform **document manager** that helps you **organize, search, and instantly access** files across devices.  
Whether it’s PDFs, Word docs, or text files. Quick Docs makes them **searchable**, **synced**, and **accessible anytime**, **anywhere**.  

Unlike traditional apps that only search by filename, **Quick Docs** goes deeper. It **extracts text, tokenizes content, and powers a “Magic Search”** that can find any document by just a hint. Forgot the file name? No problem. Quick Docs will map the word, phrase, or token you remember and instantly retrieve the right document.  

With **cloud sync, realtime updates, and offline file support**, Quick Docs bridges the gap between **convenience** and **reliability**. From lecture notes to contracts to casual WhatsApp PDFs, your documents are always at your fingertips.  

---

## Table of Contents
- [Introduction](#introduction)
- [What it Solves](#-what-it-solves)
- [Core Features](#-core-features)
- [Technical Overview](#-technical-overview)
- [Supported Files & Limits](#-supported-files--limits)
- [Performance & Reliability](#-performance--reliability)
- [Download & Demo](#-download--demo)
- [Tech Stack](#-tech-stack)
- [License](#-license)

---

## Introduction

In today’s world, documents are everywhere lecture notes, work reports, bills, e-books, and random PDFs sent over WhatsApp. The real challenge? **Finding them when you actually need them.**  

That’s where **Quick Docs** comes in.  
Our app goes beyond simple filename-based search. With **Magic Search**, you don’t need to remember the exact file name or location. Just type a hint a phrase, a word, even a vague memory and Quick Docs will instantly scan through your documents, map tokens intelligently, and bring up the file you’re looking for. ⚡  

- No more digging through folders.  
- No more scrolling endlessly in “Downloads” or “WhatsApp Documents.”  
- No more “I know I had that PDF somewhere…” moments.  

Even if you’ve just downloaded a PDF from the web, or someone forwarded you a document on WhatsApp, Quick Docs has your back. With **offline functionality**, it indexes local storage and makes files searchable instantly — path, folder, or filename don’t matter anymore.  

✨ Whether you’re a student, a professional, or just someone tired of losing files in the digital mess, Quick Docs makes finding and organizing documents effortless, fast, and reliable.  


## 🔍 What it Solves
- Scattered PDFs and notes across devices  
- Slow, filename-only search that misses relevant content  
- Manual copy/paste workflows to extract text  
- Inconsistent organization without folders/tags  
- Lack of real-time sync and offline access  

Quick Docs centralizes documents, extracts content automatically, and makes them searchable and organized on mobile.

---

## ⚡ Core Features
- **Smart Search**
  - Full-text search across content, filename, and tokens  
  - Basic tokenization with optional NLP enhancements  
- **Upload & Processing**
  - Asynchronously upload and process in our backend servers powered by FastAPI
  - Text extraction from PDF, DOCX, TXT  
  - Instant metadata & token stats  
- **Organization**
  - Folders, tags, quick move between folders  
  - Star/archive, document stats (views, access times)  
- **Viewing & Access**
  - In-app PDF viewer + external open support  
  - Offline access for cached files  
- **Realtime & Auth**
  - Firebase Auth (email/password)  
  - Firestore-backed realtime updates  

---

## 🛠 Technical Overview

### Architecture
- **Frontend (Flutter/Dart)**: UI, auth, client logic  
- **Backend (FastAPI)**: uploads, text extraction, tokenization  
- **Azure Blob Storage**: file storage  
- **Firebase Firestore**: realtime metadata & search  

### Data Flow
1. User selects file in app  
2. App uploads to FastAPI (sync or async)  
3. Backend stores file (Azure), extracts text, tokenizes  
4. Backend returns structured result (file URL, tokens, metadata)  
5. App saves result to Firestore → UI updates in realtime  

### Backend Highlights
- FastAPI + Uvicorn  
- Azure Storage SDK (Blob)  
- PyPDF2, python-docx  
- Optional spaCy for NLP  
- Health endpoint for liveness checks  

### Flutter app Highlights
- Firebase Auth & Firestore integration  
- In-app PDF viewer with caching mechanism
- Robust upload client with validation & error handling  
- API URL service with health-check & caching  

### Cloud Components
- **Azure App Service** - deploy backend  
- **Azure Blob Storage** - persist files  
- **Firebase** - auth + realtime data  

---

## 📂 Supported Files & Limits
- **File types:** PDF, DOCX, TXT (legacy DOC partial support)  
- **Async Upload:** Leveraging FastAPI, the app supports asynchronous upload and processing for better scalable and fast response solution

---

## ⚡ Performance & Reliability
- Async processing powered by FastAPI
- Cached API base URL with runtime health checks  
- Stream-based Firestore UI updates  
- Local caching for offline PDF viewing  

---

## 📥 Download & Demo

### Trade-offs: Old vs New Version

| Version | Features | Trade-offs |
|---------|----------|------------|
| **Old APK** | ✅ Complete offline processing<br>✅ Access to local files (incl. WhatsApp, Downloads, etc.)<br>✅ Offline search support | ❌ Heavy app size (PDF parser bundled)<br>❌ UI/UX less refined |
| **New APK (Current Code)** | ✅ Enhanced UI/UX<br>✅ Smart search with FastAPI backend<br>✅ Lighter and faster app<br>✅ Supports any document format (backend parsing) | ❌ No local file system processing (deprecated to reduce size & improve performance) |

---

### 📥 Old APK & Demo
- **[Download Old APK (100+ MB))](https://drive.usercontent.google.com/download?id=1-gzwuwJ09xD84Gc5SOsrQK5uaT5eNtc6&export=download&authuser=0)**  
- **Cloud Sync Demo:** [Watch Video](https://github.com/user-attachments/assets/76dd9e4c-db7e-46fc-b85c-56ce02367332)  
- **Local Storage Demo:** [Watch Video](https://github.com/user-attachments/assets/7ebe8756-3581-44f3-9663-284272d50485)  

---

### 🚀 New APK & Demo
- **[Download Universal APK (38 MB)](https://github.com/chetanr25/quick-docs/raw/refs/heads/main/quick_doc_app/apk/app-release.apk.zip)**
- **[Download armabi-v7a APK (13 MB)](https://github.com/chetanr25/quick-docs/raw/refs/heads/main/quick_doc_app/apk/app-armeabi-v7a-release.apk.zip)**
- **[Download arm64 APK (14 MB)](https://github.com/chetanr25/quick-docs/raw/refs/heads/main/quick_doc_app/apk/app-arm64-v8a-release.apk.zip)**




---

## 🧑‍💻 Tech Stack
- **Backend:** Python 3, FastAPI, Uvicorn, python-multipart, PyPDF2, python-docx, azure-storage-blob, azure-identity, python-dotenv  
- **Frontend:** Flutter, Dart
- **Cloud:** Azure App Service, Azure Blob Storage, Firebase  

---

## 📜 License
This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for details.
