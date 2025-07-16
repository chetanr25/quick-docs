import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_docs/models/document_model.dart';
import 'package:quick_docs/models/folder_model.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime lastLogin;
  final int documentsCount;
  final int storageUsed;
  final String subscription;
  final Map<String, dynamic> preferences;
  final List<DocumentModel> documents;
  final List<FolderModel> folders;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.lastLogin,
    this.documentsCount = 0,
    this.storageUsed = 0,
    this.subscription = 'free',
    this.preferences = const {},
    required this.documents,
    required this.folders,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    // try {
    // print((data['folders'] as List<dynamic>?)
    //     ?.map((folder) => FolderModel.fromFirestore(folder))
    //     .toList()[0]
    //     .name);
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      documentsCount: data['documentsCount'] ?? 0,
      storageUsed: data['storageUsed'] ?? 0,
      subscription: data['subscription'] ?? 'free',
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      documents: (data['documents'] as List<dynamic>?)
              ?.map((doc) => DocumentModel.fromFirestore(doc))
              .toList() ??
          <DocumentModel>[],
      folders: (data['folders'] as List<dynamic>?)
              ?.map((folder) => FolderModel.fromFirestore(folder))
              .toList() ??
          <FolderModel>[],
    );
    // } catch (e) {
    //   print(e);
    //   return UserModel(
    //       id: 's',
    //       email: "",
    //       createdAt: DateTime(2020),
    //       displayName: '',
    //       lastLogin: DateTime(2020),
    //       documents: [],
    //       documentsCount: 0,
    //       folders: []);
    // }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'documentsCount': documentsCount,
      'storageUsed': storageUsed,
      'subscription': subscription,
      'preferences': preferences,
      'documents': documents.map((doc) => doc.toFirestore()).toList(),
      'folders': folders.map((folder) => folder.toFirestore()).toList(),
    };
  }

  UserModel copyWith({
    String? displayName,
    DateTime? lastLogin,
    int? documentsCount,
    int? storageUsed,
    String? subscription,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      documentsCount: documentsCount ?? this.documentsCount,
      storageUsed: storageUsed ?? this.storageUsed,
      subscription: subscription ?? this.subscription,
      preferences: preferences ?? this.preferences,
      documents: List<DocumentModel>.from(documents),
      folders: List<FolderModel>.from(folders),
    );
  }

  // Get storage used in human readable format
  String get storageUsedFormatted {
    if (storageUsed < 1024) return '${storageUsed}B';
    if (storageUsed < 1024 * 1024) {
      return '${(storageUsed / 1024).toStringAsFixed(1)}KB';
    }
    return '${(storageUsed / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
