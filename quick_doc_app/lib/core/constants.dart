import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_url_service.dart';

class AppConstants {
  // API Configuration
  static String get baseUrl => ApiUrlService.getBaseUrl();

  static const String apiVersion = 'v1';
  static const String filesEndpoint = '/files/upload';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // File constraints
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> supportedFileTypes = [
    'pdf',
    'txt',
    'docx',
    'doc',
  ];

  // Firestore collections
  static const String documentsCollection = 'documents';
  static const String usersCollection = 'users';

  // Shared preferences keys
  static const String emailKey = 'email';
  static const String processedFilesPathKey = 'processedFilesPath';
  static const String processedFilesNameKey = 'processedFilesName';

  // Error messages
  static const String noInternetMessage = 'No internet connection';
  static const String fileUploadFailedMessage = 'File upload failed';
  static const String fileTooLargeMessage = 'File too large';
  static const String unsupportedFileTypeMessage = 'Unsupported file type';
}

class FirebaseConstants {
  static String email = FirebaseAuth.instance.currentUser?.email ?? '';
  static String name = FirebaseAuth.instance.currentUser?.displayName ?? '';
  static String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  static final firebaseUserDoc = FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .doc(email);
  static final Future<Map<String, dynamic>> firestore =
      firebaseUserDoc.get().then((doc) {
    if (doc.exists) {
      return doc.data() ?? {};
    } else {
      throw Exception('User not found');
    }
  });
}
