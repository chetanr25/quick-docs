import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:quick_docs/models/document_model.dart';
import 'package:uuid/uuid.dart';

Map<String, IconData> iconMap = {
  'folder': Icons.folder,
  'work': Icons.work,
  'person': Icons.person,
  'home': Icons.home,
  'school': Icons.school,
  'favorite': Icons.favorite,
  'star': Icons.star,
  'settings': Icons.settings,
  'document': Icons.description,
  'note': Icons.note,
};

Map<Icon, String> reverseIconMap = {
  const Icon(Icons.folder): 'folder',
  const Icon(Icons.work): 'work',
  const Icon(Icons.person): 'person',
  const Icon(Icons.home): 'home',
  const Icon(Icons.school): 'school',
  const Icon(Icons.favorite): 'favorite',
  const Icon(Icons.star): 'star',
  const Icon(Icons.settings): 'settings',
  const Icon(Icons.note): 'note',
  const Icon(Icons.description): 'document',
};

class FolderModel {
  final String? id;
  final String name;
  final String description;
  final String color;
  final Icon icon;
  final int documentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  // final bool isDefault;
  final int sortOrder;
  // final List<DocumentModel> documents;

  FolderModel({
    required this.id,
    required this.name,
    this.description = '',
    this.color = '#2196F3',
    this.icon = const Icon(Icons.folder),
    this.documentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    // this.isDefault = false,
    this.sortOrder = 0,
    // this.documents = const [],
  });

  factory FolderModel.createNew({
    required String name,
    String? description,
    String? color,
    Icon? icon,
    int documentsCount = 0,
    bool isDefault = false,
    int sortOrder = 0,
    DateTime? createdAt,
  }) {
    return FolderModel(
      id: const Uuid().v4(),
      name: name,
      description: description ?? '',
      color: color ?? '#2196F3',
      icon: icon ?? const Icon(Icons.folder),
      documentsCount: documentsCount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      // isDefault: false,
      sortOrder: 0,
    );
  }

  factory FolderModel.fromFirestore(data) {
    // print(data);
    return FolderModel(
      id: data['id'] ?? const Uuid().v4(),
      name: data['name'] ?? '', //
      description: data['description'] ?? '', //
      color: data['color'] ?? '#2196F3', //
      icon: Icon(iconMap[data['icon'] ?? 'folder']), //
      documentsCount: data['documentsCount'] ?? 0, //
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), //
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(), //
      // isDefault: data['isDefault'] ?? false,
      sortOrder: data['sortOrder'] ?? 0, //
      // documents: (data['documents'] as List<dynamic>?)
      //         ?.map((docData) => DocumentModel.fromFirestore(docData))
      //         .toList() ??
      //     [],
    );
  }

  Map<String, dynamic> toFirestore() {
    //  factory FolderModel.toFirestore(FolderModel folder) {
    print(icon);
    print(reverseIconMap[icon]);
    return {
      'id': id ?? const Uuid().v4(),
      'name': name,
      'description': description,
      'color': color,
      'icon': reverseIconMap[icon],
      'documentsCount': documentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      // 'isDefault': isDefault,
      'sortOrder': sortOrder,
      // 'documents': documents.map((doc) => doc.toFirestore()).toList(),
    };
  }

  FolderModel copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    Icon? icon,
    int? documentsCount,
    bool? isDefault,
    int? sortOrder,
    List<DocumentModel>? documents,
    DateTime? createdAt,
  }) {
    String uuid = const Uuid().v4();
    // Generate a new ID if not provided
    return FolderModel(
      id: id ?? uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      documentsCount: documentsCount ?? this.documentsCount,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      // isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      // documents: documents ?? this.documents,
    );
  }

  // Create default folders
  static List<FolderModel> getDefaultFolders() {
    final now = DateTime.now();
    return [
      FolderModel(
        id: 'general',
        name: 'General',
        description: 'General documents',
        color: '#2196F3',
        icon: Icon(iconMap['folder']),
        createdAt: now,
        updatedAt: now,
        // isDefault: true,
        sortOrder: 0,
      ),
      FolderModel(
        id: 'work',
        name: 'Work',
        description: 'Work-related documents',
        color: '#FF5722',
        icon: Icon(iconMap['work']),
        createdAt: now,
        updatedAt: now,
        // isDefault: true,
        sortOrder: 1,
      ),
      FolderModel(
        id: 'personal',
        name: 'Personal',
        description: 'Personal documents',
        color: '#4CAF50',
        icon: Icon(iconMap['favorite']),
        createdAt: now,
        updatedAt: now,
        // isDefault: true,
        sortOrder: 2,
      ),
    ];
  }
}
