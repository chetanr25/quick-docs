import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.baseUrl;
  final Duration _timeout = AppConstants.apiTimeout;

  /// Deletes a file from the storage database
  Future<bool> deleteFile(String fileId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/files/delete/$fileId');

      final response = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        return true;
        // final errorData = json.decode(response.body);
        // throw FileUploadException(errorData['message'] ??
        //     'Delete failed with status ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException(AppConstants.noInternetMessage);
    } on FileUploadException {
      rethrow;
    } catch (e) {
      throw FileUploadException(
          'Unexpected error deleting file: ${e.toString()}');
    }
  }

  /// Deletes multiple files from the storage database
  Future<bool> deleteMultipleFiles(List<String> fileIds) async {
    try {
      // Delete files one by one
      for (String fileId in fileIds) {
        print('Deleting file with ID: $fileId');
        await deleteFile(fileId);
      }
      return true;
    } catch (e) {
      // If any file deletion fails, throw the error
      rethrow;
    }
  }

  void deleteFileFromDB() {}

  Future<DocumentModel> uploadAndProcessFile({
    required File file,
    required String email,
    required String? folderId,
    required String? folderName,
  }) async {
    try {
      _validateFile(file);
      final uri = Uri.parse('$_baseUrl/api/v1/files/upload-sync');

      final request = http.MultipartRequest('POST', uri);

      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
        contentType: _getContentType(file.path),
      );

      request.files.add(multipartFile);
      request.fields['email'] = email;

      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Send request with timeout
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // print(jsonData);
        return DocumentModel.fromJson(
          processingResult: jsonData,
          folderId: folderId ?? FirebaseConstants.uid,
          folderName: folderName ?? 'All Documents',
          tags: [],
        );
      } else {
        final errorData = json.decode(response.body);
        throw FileUploadException(errorData['message'] ??
            'Upload failed with status ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException(AppConstants.noInternetMessage);
    } on FileUploadException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw FileUploadException('Unexpected error: ${e.toString()}');
    }
  }

  void _validateFile(File file) {
    if (!file.existsSync()) {
      throw ValidationException('File does not exist');
    }

    final fileSizeInBytes = file.lengthSync();
    if (fileSizeInBytes > AppConstants.maxFileSize) {
      throw ValidationException(AppConstants.fileTooLargeMessage);
    }

    final extension = file.path.split('.').last.toLowerCase();
    if (!AppConstants.supportedFileTypes.contains(extension)) {
      throw ValidationException(AppConstants.unsupportedFileTypeMessage);
    }
  }

  MediaType _getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'txt':
        return MediaType('text', 'plain');
      case 'docx':
        return MediaType('application',
            'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case 'doc':
        return MediaType('application', 'msword');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
