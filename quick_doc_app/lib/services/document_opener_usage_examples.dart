// Example Usage of DocumentOpenerService
//
// This file shows different ways to use the DocumentOpenerService
// throughout your application for opening various document types.

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/document_opener_service.dart';

class DocumentOpenerUsageExamples {
  /// Basic usage - Open a document with default behavior
  static Future<void> basicUsage(
      BuildContext context, DocumentModel document) async {
    await DocumentOpenerService.openDocument(context, document);
  }

  /// Force external opening - Always open in external app
  static Future<void> forceExternalUsage(
      BuildContext context, DocumentModel document) async {
    await DocumentOpenerService.openDocument(
      context,
      document,
      forceExternal: true,
    );
  }

  /// Check if document is supported before opening
  static Future<void> smartUsage(
      BuildContext context, DocumentModel document) async {
    if (DocumentOpenerService.isSupported(document.filename)) {
      // Document has in-app viewer support
      await DocumentOpenerService.openDocument(context, document);
    } else {
      // Show dialog asking user how they want to open unsupported file
      await DocumentOpenerService.openDocument(context, document);
    }
  }

  /// Get document information
  static void getDocumentInfo(DocumentModel document) {
    String icon = DocumentOpenerService.getDocumentIcon(document.filename);
    String typeName =
        DocumentOpenerService.getDocumentTypeName(document.filename);
    bool isSupported = DocumentOpenerService.isSupported(document.filename);

    print('Document: ${document.filename}');
    print('Icon: $icon');
    print('Type: $typeName');
    print('Supported: $isSupported');
  }

  /// Example widget that uses the service
  static Widget buildDocumentListTile(
      BuildContext context, DocumentModel document) {
    return ListTile(
      leading: Text(
        DocumentOpenerService.getDocumentIcon(document.filename),
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(document.filename),
      subtitle:
          Text(DocumentOpenerService.getDocumentTypeName(document.filename)),
      trailing: DocumentOpenerService.isSupported(document.filename)
          ? const Icon(Icons.visibility, color: Colors.green)
          : const Icon(Icons.open_in_new, color: Colors.grey),
      onTap: () => DocumentOpenerService.openDocument(context, document),
    );
  }

  /// Example of showing document options before opening
  static Future<void> showDocumentOptions(
      BuildContext context, DocumentModel document) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Open ${document.filename}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DocumentOpenerService.getDocumentTypeName(document.filename)),
            const SizedBox(height: 16),
            if (DocumentOpenerService.isSupported(document.filename))
              const Text('This document can be viewed in-app'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancel'),
          ),
          if (DocumentOpenerService.isSupported(document.filename))
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'internal'),
              child: const Text('View in App'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'external'),
            child: const Text('Open Externally'),
          ),
        ],
      ),
    );

    switch (result) {
      case 'internal':
        await DocumentOpenerService.openDocument(context, document);
        break;
      case 'external':
        await DocumentOpenerService.openDocument(context, document,
            forceExternal: true);
        break;
    }
  }
}

// Usage in your widgets:

class ExampleDocumentList extends StatelessWidget {
  final List<DocumentModel> documents;

  const ExampleDocumentList({Key? key, required this.documents})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return DocumentOpenerUsageExamples.buildDocumentListTile(
            context, document);
      },
    );
  }
}

class ExampleDocumentGrid extends StatelessWidget {
  final List<DocumentModel> documents;

  const ExampleDocumentGrid({Key? key, required this.documents})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return Card(
          child: InkWell(
            onTap: () => DocumentOpenerService.openDocument(context, document),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DocumentOpenerService.getDocumentIcon(document.filename),
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    document.filename,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DocumentOpenerService.getDocumentTypeName(
                        document.filename),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
