import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../models/folder_model.dart';
import '../services/home_service.dart';
import '../widgets/document_card.dart';

/// Example screen showing how to use the move document functionality
class DocumentsScreen extends StatefulWidget {
  final List<DocumentModel> documents;
  final List<FolderModel> folders;
  final String? currentFolderId;

  const DocumentsScreen({
    Key? key,
    required this.documents,
    required this.folders,
    this.currentFolderId,
  }) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final HomeService _homeService = HomeService();
  late List<DocumentModel> _documents;
  late List<FolderModel> _folders;

  @override
  void initState() {
    super.initState();
    _documents = List.from(widget.documents);
    _folders = List.from(widget.folders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentFolderId == null
              ? 'All Documents'
              : _getFolderName(widget.currentFolderId!),
        ),
      ),
      body: _documents.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No documents found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final document = _documents[index];
                return DocumentCard(
                  document: document,
                  onMove: () => _moveDocument(document),
                  onDelete: () => _deleteDocument(document, index),
                );
              },
            ),
    );
  }

  String _getFolderName(String folderId) {
    final folder = _folders.firstWhere(
      (f) => f.id == folderId,
      orElse: () => FolderModel.createNew(name: 'Unknown Folder'),
    );
    return folder.name;
  }

  Future<void> _moveDocument(DocumentModel document) async {
    final success = await _homeService.moveDocumentToFolder(
      context,
      document,
      _folders,
    );

    if (success) {
      // Refresh the documents list or update the UI
      // In a real app, you might want to refetch from Firestore
      // or update the local state accordingly
      setState(() {
        // You could remove the document from current view if it was moved to a different folder
        if (widget.currentFolderId != null) {
          _documents.removeWhere((doc) => doc.fileId == document.fileId);
        }
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
      setState(() {
        _documents.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted successfully')),
        );
      }
    }
  }
}

/// Usage example in your home screen or wherever you display documents
class DocumentMoveExample {
  static Future<void> showDocumentsWithMoveFeature(BuildContext context,
      List<DocumentModel> documents, List<FolderModel> folders,
      {String? currentFolderId}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentsScreen(
          documents: documents,
          folders: folders,
          currentFolderId: currentFolderId,
        ),
      ),
    );
  }

  /// Example of how to integrate move functionality into existing DocumentCard usage
  static Widget buildDocumentCardWithMove({
    required BuildContext context,
    required DocumentModel document,
    required List<FolderModel> availableFolders,
    VoidCallback? onDocumentMoved,
    VoidCallback? onDocumentDeleted,
  }) {
    final homeService = HomeService();

    return DocumentCard(
      document: document,
      onMove: () async {
        final success = await homeService.moveDocumentToFolder(
          context,
          document,
          availableFolders,
        );

        if (success) {
          onDocumentMoved?.call();
        }
      },
      onDelete: () async {
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
          onDocumentDeleted?.call();
        }
      },
    );
  }
}
