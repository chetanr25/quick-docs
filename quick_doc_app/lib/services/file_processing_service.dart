// import 'dart:io';
// import '../models/models.dart';
// import 'api_service.dart';
// import 'firestore_service.dart';
// import 'storage_service.dart';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_docs/core/constants.dart';
import 'package:quick_docs/services/api_service.dart';

import '../models/document_model.dart' show DocumentModel;

class FileProcessingService {
  final ApiService _apiService = ApiService();
  List<DocumentModel> searchDocuments(
      {required List<DocumentModel> documents, required String searchQuery}) {
    List<DocumentModel> filteredDocuments = [];

    List<String> searchQueries = searchQuery.split(' ');
    for (var doc in documents) {
      int matchCount = 0;
      for (String query in searchQueries) {
        if (doc.tokens.contains(query.toLowerCase()) ||
            doc.filename.toLowerCase().contains(query.toLowerCase()) ||
            doc.extractedText.toLowerCase().contains(query.toLowerCase())) {
          matchCount++;
        }
        if (matchCount == searchQueries.length) {
          filteredDocuments.add(doc);
        }
      }
    }

    return filteredDocuments;
  }

  Future<DocumentModel> processAndSaveFile({
    required File file,
    required String userEmail,
    required String? folderId,
    required String? folderName,
    List<String> tags = const [],
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.3);
      final DocumentModel document = await _apiService.uploadAndProcessFile(
        folderId: folderId,
        folderName: folderName,
        file: file,
        email: userEmail,
      );

      onProgress?.call(0.7);

      FirebaseConstants.firebaseUserDoc.update({
        'documentsCount': FieldValue.increment(1),
        'storageUsed': FieldValue.increment(document.fileSize),
        'documents': FieldValue.arrayUnion([document.toFirestore()]),
      });

      onProgress?.call(1.0);
      return document;
    } catch (e) {
      throw Exception('File processing failed: $e');
    }
  }

  List<DocumentModel> getDocumentsByFolder({
    required List<DocumentModel> documents,
    required String folderId,
  }) {
    if (folderId == FirebaseConstants.uid) {
      // If folderId is the user's UID, return all documents
      return documents;
    }
    return documents
        .where((doc) => doc.folderId == folderId)
        .toList(growable: false);
  }
}

// class FileProcessingService {
//   static final FileProcessingService _instance =
//       FileProcessingService._internal();
//   factory FileProcessingService() => _instance;
//   FileProcessingService._internal();

//   final ApiService _apiService = ApiService();
// // final FirestoreService _firestoreService = FirestoreService();
//   final StorageService _storageService = StorageService();

//   Future<DocumentModel> processFile({
//     required File file,
//     required String userEmail,
//     String? folderId,
//   }) async {
//     try {
//       final result = await _apiService.uploadAndProcessFile(
//         file: file,
//         email: userEmail,
//       );

//       // Step 2: Save result to Firestore
//       await _firestoreService.saveFileProcessingResult(
//         result: result,
//         userEmail: userEmail,
//         folderId: folderId,
//       );

//       // Step 3: Save processed file info to local storage
//       await _storageService.saveProcessedFileInfo(
//         fileId: result.fileId,
//         filename: result.filename,
//         filePath: file.path,
//       );

//       return result;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Get user documents from Firestore
//   Stream<List<FileProcessingResult>> getUserDocuments(String userEmail) {
//     return _firestoreService.getUserDocuments(userEmail);
//   }

//   // Get documents by folder
//   Stream<List<FileProcessingResult>> getDocumentsByFolder({
//     required String userEmail,
//     required String folderId,
//   }) {
//     return _firestoreService.getDocumentsByFolder(
//       userEmail: userEmail,
//       folderId: folderId,
//     );
//   }

//   // Search documents
//   Future<List<FileProcessingResult>> searchDocuments({
//     required String userEmail,
//     required String searchQuery,
//   }) {
//     return _firestoreService.searchDocuments(
//       userEmail: userEmail,
//       searchQuery: searchQuery,
//     );
//   }

//   // Delete document
//   Future<void> deleteDocument(String fileId) async {
//     try {
//       await _firestoreService.deleteDocument(fileId);
//       await _storageService.removeProcessedFileInfo(fileId);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Move document to folder
//   Future<void> moveDocumentToFolder({
//     required String fileId,
//     required String folderId,
//   }) {
//     return _firestoreService.updateDocumentFolder(
//       fileId: fileId,
//       folderId: folderId,
//     );
//   }

//   // Get local processed files info
//   Future<List<Map<String, String>>> getLocalProcessedFiles() {
//     return _storageService.getProcessedFiles();
//   }
// }
