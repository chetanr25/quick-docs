import 'package:flutter/material.dart';
import 'package:quick_docs/core/constants.dart';
import 'package:quick_docs/models/document_model.dart';
import 'package:quick_docs/screens/home/document_screen.dart';
import '../../models/folder_model.dart';

class NavigationService {
  static void openDocumentsList(
    BuildContext context,
    FolderModel? folder,
    List<DocumentModel> documents,
    List<FolderModel> folders,
  ) {
    if (folder == null) {
      // Open "All Documents"
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentsListScreen(
            documents: documents,
            folders: folders,
            folderId: FirebaseConstants.uid,
            folderName: 'All Documents',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentsListScreen(
          documents: documents,
          folders: folders,
          folderId: folder.id ?? FirebaseConstants.uid,
          folderName: folder.name,
        ),
      ),
    );
  }
}
