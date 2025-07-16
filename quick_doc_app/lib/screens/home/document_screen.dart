// Documents List Screen
import 'package:flutter/material.dart';
import 'package:quick_docs/core/constants.dart';
import 'package:quick_docs/models/document_model.dart';
import 'package:quick_docs/models/folder_model.dart';
import 'package:quick_docs/screens/file_upload_screen.dart';
import 'package:quick_docs/services/file_processing_service.dart';
import 'package:quick_docs/services/home_service.dart';
import 'package:quick_docs/utils/snackbar_util.dart';
import 'package:quick_docs/widgets/document_card.dart';

class DocumentsListScreen extends StatefulWidget {
  final List<DocumentModel> documents;
  final List<FolderModel> folders;
  final String folderId;
  final String folderName;

  const DocumentsListScreen({
    Key? key,
    required this.documents,
    required this.folders,
    required this.folderId,
    required this.folderName,
  }) : super(key: key);

  @override
  State<DocumentsListScreen> createState() => _DocumentsListScreenState();
}

class _DocumentsListScreenState extends State<DocumentsListScreen> {
  final HomeService _homeService = HomeService();
  late List<DocumentModel> _documents;

  @override
  void initState() {
    super.initState();
    _documents = List.from(widget.documents);
  }

  @override
  Widget build(BuildContext context) {
    final fileService = FileProcessingService();
    final List<DocumentModel> filteredDocuments = fileService
        .getDocumentsByFolder(documents: _documents, folderId: widget.folderId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileUploadScreen(
                    userEmail: FirebaseConstants.email,
                    folderName: widget.folderName,
                    folderId: widget.folderId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: filteredDocuments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No documents in this folder',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: filteredDocuments.length,
              itemBuilder: (context, index) {
                final document = filteredDocuments[index];
                return DocumentCard(
                  document: document,
                  onDelete: () async {
                    await _deleteDocument(document, index);
                  },
                  onMove: () async {
                    await _moveDocument(document);
                  },
                );
              },
            ),
    );
  }

  Future<void> _moveDocument(DocumentModel document) async {
    final success = await _homeService.moveDocumentToFolder(
      context,
      document,
      widget.folders,
    );

    if (success) {
      // Update local state to reflect the move
      setState(() {
        _documents.removeWhere((d) => d.fileId == document.fileId);
      });
    }
  }

  Future<void> _deleteDocument(DocumentModel document, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content:
            Text('Are you sure you want to delete "${document.filename}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _documents.removeWhere((d) => d.fileId == document.fileId);
        });

        if (mounted) {
          SnackBarUtil.showSuccessSnackBar(
            context: context,
            message: 'Document deleted successfully',
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtil.showErrorSnackBar(
            context: context,
            message: 'Error deleting document: ${e.toString()}',
          );
        }
      }
    }
  }
}
