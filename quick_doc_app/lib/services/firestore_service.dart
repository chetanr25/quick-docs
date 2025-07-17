import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_docs/core/constants.dart';
import 'package:quick_docs/models/folder_model.dart';

class FirestoreService {
  static void createFolder(FolderModel folder) {
    Map<String, dynamic> folderData = folder.toFirestore();

    FirebaseConstants.firebaseUserDoc.update({
      'folders': FieldValue.arrayUnion([folderData]),
    });
  }

  static void deleteFolder(FolderModel folder) {
    Map<String, dynamic> folderData = folder.toFirestore();
    FirebaseConstants.firebaseUserDoc.update({
      'folders': FieldValue.arrayRemove([folderData]),
    });
  }

  static void renameFolder(FolderModel folder, String newName) {
    Map<String, dynamic> folderData = folder.toFirestore();
    folderData['name'] = newName;

    FirebaseConstants.firebaseUserDoc.update({
      'folders': FieldValue.arrayRemove([folder.toFirestore()]),
    });

    FirebaseConstants.firebaseUserDoc.update({
      'folders': FieldValue.arrayUnion([folderData]),
    });
  }

  static Future<void> moveDocument(
      String documentId, String newFolderId, String newFolderName) async {
    try {
      // Get current user document
      final userDocSnapshot = await FirebaseConstants.firebaseUserDoc.get();

      if (!userDocSnapshot.exists) {
        throw Exception('User document not found');
      }

      final userData = userDocSnapshot.data() as Map<String, dynamic>;
      final documents =
          List<Map<String, dynamic>>.from(userData['documents'] ?? []);

      // Find and update the specific document
      final documentIndex =
          documents.indexWhere((doc) => doc['fileId'] == documentId);

      if (documentIndex == -1) {
        throw Exception('Document not found');
      }

      // Update document's folder information
      documents[documentIndex]['folderId'] = newFolderId;
      documents[documentIndex]['folderName'] = newFolderName;

      // Update the entire documents array in Firestore
      await FirebaseConstants.firebaseUserDoc.update({
        'documents': documents,
      });

      print(
          'Document moved successfully: $documentId to folder: $newFolderName');
    } catch (e) {
      print('Error moving document: $e');
      throw Exception('Failed to move document: $e');
    }
  }

  static Future<void> moveDocumentToNoFolder(String documentId) async {
    await moveDocument(documentId, '', '');
  }

  static void deleteFilesInFolder(
      List<Map<String, dynamic>> filesData, FolderModel folder) {
    // Remove all documents in the folder
    FirebaseConstants.firebaseUserDoc.update({
      'documents': FieldValue.arrayRemove(filesData),
    });

    // Delete the folder itself
    deleteFolder(folder);
  }
}
