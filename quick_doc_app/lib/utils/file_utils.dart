import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  // Open document with default system application
  static Future<void> openDocument(String filePath) async {
    print('Opening document: $filePath');
    if (!fileExists(filePath)) {
      throw FileSystemException('File does not exist', filePath);
    }

    if (!isSupportedFileType(filePath)) {
      throw UnsupportedError('File type not supported');
    }

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          throw Exception('Failed to open file: ${result.message}');
        }
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      throw Exception('Failed to open document: $e');
    }
  }

  // Get file extension
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }

  // Get file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  // Get file name with extension
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Check if file is supported
  static bool isSupportedFileType(String filePath) {
    final extension = getFileExtension(filePath);
    return ['pdf', 'txt', 'docx', 'doc'].contains(extension);
  }

  // Get file icon based on extension
  static String getFileIcon(String filePath) {
    final extension = getFileExtension(filePath);
    switch (extension) {
      case 'pdf':
        return '📄';
      case 'txt':
        return '📝';
      case 'docx':
      case 'doc':
        return '📘';
      default:
        return '📎';
    }
  }

  // Check if file exists
  static bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  // Get file size
  static int getFileSize(String filePath) {
    return File(filePath).lengthSync();
  }
}
