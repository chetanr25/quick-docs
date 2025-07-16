import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../screens/pdf_viewer.dart';
import '../utils/file_utils.dart';

/// A service class that handles opening different types of documents
/// Currently supports PDF files and can be extended for other document types
class DocumentOpenerService {
  /// Opens a document based on its type and location
  ///
  /// [context] - Build context for navigation
  /// [document] - The document model containing file information
  /// [forceExternal] - If true, opens the document in external app instead of in-app viewer
  static Future<void> openDocument(
    BuildContext context,
    DocumentModel document, {
    bool forceExternal = false,
  }) async {
    try {
      final fileExtension = _getFileExtension(document.filename);
      // print(fileExtension);
      // final isUrl = _isUrl(document.fileUrl);

      // If user wants to force external opening or it's a URL
      // if (forceExternal || isUrl) {
      //   await _openExternal(document.fileUrl);
      //   return;
      // }

      // Handle different file types with in-app viewers
      switch (fileExtension.toLowerCase()) {
        case 'pdf':
          print('Opening PDF document: ${document.filename}');
          await _openPdfInApp(context, document);
          break;
        case 'doc':
        case 'docx':
          // TODO: Implement Word document viewer
          await _openUnsupportedDocument(context, document);
          break;
        case 'txt':
          // TODO: Implement text file viewer
          await _openUnsupportedDocument(context, document);
          break;
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'gif':
        case 'bmp':
        case 'webp':
          // TODO: Implement image viewer
          await _openUnsupportedDocument(context, document);
          break;
        case 'xls':
        case 'xlsx':
          // TODO: Implement Excel viewer
          await _openUnsupportedDocument(context, document);
          break;
        case 'ppt':
        case 'pptx':
          // TODO: Implement PowerPoint viewer
          await _openUnsupportedDocument(context, document);
          break;
        // default:
        //   // Fallback to external opening
        //   await _openExternal(document.fileUrl);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error opening document: ${e.toString()}');
    }
  }

  /// Opens a PDF document using the in-app PDF viewer
  static Future<void> _openPdfInApp(
      BuildContext context, DocumentModel document) async {
    print('Opening PDF in app: ${document.filename}');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewer(document: document),
      ),
    );
  }

  /// Opens a document in an external application
  static Future<void> _openExternal(String fileUrl) async {
    final uri = Uri.parse(fileUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not launch URL: $fileUrl');
    }
  }

  /// Handles unsupported document types by showing options to user
  static Future<void> _openUnsupportedDocument(
      BuildContext context, DocumentModel document) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Open ${_getFileExtension(document.filename).toUpperCase()} File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'This file type is not yet supported by our in-app viewer.'),
            const SizedBox(height: 16),
            Text(
              'File: ${document.filename}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Size: ${FileUtils.formatFileSize(document.fileSize)}'),
            Text('Type: ${document.contentType}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'external'),
            child: const Text('Open Externally'),
          ),
        ],
      ),
    );

    if (result == 'external') {
      await _openExternal(document.fileUrl);
    }
  }

  /// Extracts file extension from filename
  static String _getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  // /// Checks if the file path is a URL
  // static bool _isUrl(String path) {
  //   return path.startsWith('http://') || path.startsWith('https://');
  // }

  /// Shows an error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Gets a user-friendly name for the document type
  static String getDocumentTypeName(String filename) {
    final extension = _getFileExtension(filename).toLowerCase();

    switch (extension) {
      case 'pdf':
        return 'PDF Document';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'txt':
        return 'Text File';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return 'Image File';
      case 'xls':
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint Presentation';
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'Video File';
      case 'mp3':
      case 'wav':
      case 'flac':
        return 'Audio File';
      case 'zip':
      case 'rar':
      case '7z':
        return 'Archive File';
      default:
        return 'Document';
    }
  }

  /// Checks if a document type is supported for in-app viewing
  static bool isSupported(String filename) {
    final extension = _getFileExtension(filename).toLowerCase();

    switch (extension) {
      case 'pdf':
        return true; // Currently only PDF is fully supported
      case 'doc':
      case 'docx':
      case 'txt':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'xls':
      case 'xlsx':
      case 'ppt':
      case 'pptx':
        return false; // Planned for future implementation
      default:
        return false;
    }
  }

  /// Gets the appropriate icon for a document type
  static String getDocumentIcon(String filename) {
    final extension = _getFileExtension(filename).toLowerCase();

    switch (extension) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📃';
      case 'txt':
        return '📝';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return '🖼️';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '📽️';
      case 'mp4':
      case 'avi':
      case 'mov':
        return '🎥';
      case 'mp3':
      case 'wav':
      case 'flac':
        return '🎵';
      case 'zip':
      case 'rar':
      case '7z':
        return '📦';
      default:
        return '📄';
    }
  }
}
