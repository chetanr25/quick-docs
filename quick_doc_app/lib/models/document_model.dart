import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String fileId;
  final String filename;
  final String fileUrl;
  final int fileSize;
  final String contentType;

  // Organization
  final String folderId;
  final String folderName;
  final List<String> tags;

  // Processing results
  final String extractedText;
  final int textLength;
  final List<String> tokens;
  final int tokenCount;
  final int uniqueTokens;

  // Metadata
  final double processingTime;
  final DateTime uploadedAt;
  final DateTime? lastAccessedAt;

  final int viewCount;

  DocumentModel({
    required this.fileId,
    required this.filename,
    required this.fileUrl,
    required this.fileSize,
    required this.contentType,
    required this.folderId,
    required this.folderName,
    this.tags = const [],
    required this.extractedText,
    required this.textLength,
    required this.tokens,
    required this.tokenCount,
    required this.uniqueTokens,
    required this.processingTime,
    required this.uploadedAt,
    this.lastAccessedAt,
    this.viewCount = 0,
  });

  factory DocumentModel.fromJson({
    // required String id,
    required Map<String, dynamic> processingResult,
    required String folderId,
    required String folderName,
    List<String> tags = const [],
  }) {
    final tokens =
        List<String>.from(processingResult['tokenization']['tokens'] ?? []);
    final filename = processingResult['filename'] ?? '';

    // Get first few words for preview
    final extractedText =
        processingResult['text_extraction']['extracted_text'] ?? '';

    return DocumentModel(
      fileId: processingResult['file_id'] ?? '',
      filename: filename,
      fileUrl: processingResult['file_url'] ?? '',
      fileSize: processingResult['file_size'] ?? 0,
      contentType: processingResult['content_type'] ?? '',
      folderId: folderId,
      folderName: folderName,
      tags: tags,
      extractedText: extractedText,
      textLength: processingResult['text_extraction']['text_length'] ?? 0,
      tokens: tokens,
      tokenCount: processingResult['tokenization']['token_count'] ?? 0,
      uniqueTokens: processingResult['tokenization']['unique_tokens'] ?? 0,
      processingTime: (processingResult['processing_time'] ?? 0.0).toDouble(),
      uploadedAt: DateTime.parse(
          processingResult['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create from Firestore document
  factory DocumentModel.fromFirestore(Map<String, dynamic> data) {
    // final data = doc.data() as Map<String, dynamic>;

    return DocumentModel(
      fileId: data['fileId'] ?? '',
      filename: data['filename'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileSize: data['fileSize'] ?? 0,
      contentType: data['contentType'] ?? '',
      folderId: data['folderId'] ?? '',
      folderName: data['folderName'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      extractedText: data['extractedText'] ?? '',
      textLength: data['textLength'] ?? 0,
      tokens: List<String>.from(data['tokens'] ?? []),
      tokenCount: data['tokenCount'] ?? 0,
      uniqueTokens: data['uniqueTokens'] ?? 0,
      processingTime: (data['processingTime'] ?? 0.0).toDouble(),
      uploadedAt:
          (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastAccessedAt: (data['lastAccessedAt'] as Timestamp?)?.toDate(),
      viewCount: data['viewCount'] ?? 0,
    );
  }

  // Create DocumentModel from backend JSON response
  factory DocumentModel.fromBackendResponse({
    required Map<String, dynamic> processingResult,
    required String folderId,
    required String folderName,
    List<String> tags = const [],
  }) {
    // Extract nested objects
    final textExtraction =
        processingResult['text_extraction'] as Map<String, dynamic>? ?? {};
    final tokenization =
        processingResult['tokenization'] as Map<String, dynamic>? ?? {};

    // Get tokens list
    final tokens = List<String>.from(tokenization['tokens'] ?? []);

    // Get extracted text
    final extractedText = textExtraction['extracted_text'] ?? '';

    // Parse timestamp
    DateTime uploadedAt;
    try {
      uploadedAt = DateTime.parse(
          processingResult['timestamp'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      uploadedAt = DateTime.now();
    }

    return DocumentModel(
      fileId: processingResult['file_id'] ?? '',
      filename: processingResult['filename']?.trim() ??
          '', // Trim whitespace from filename
      fileUrl: processingResult['file_url'] ?? '',
      fileSize: processingResult['file_size'] ?? 0,
      contentType: processingResult['content_type'] ?? '',
      folderId: folderId,
      folderName: folderName,
      tags: tags,
      extractedText: extractedText,
      textLength: textExtraction['text_length'] ?? 0,
      tokens: tokens,
      tokenCount: tokenization['token_count'] ?? 0,
      uniqueTokens: tokenization['unique_tokens'] ?? 0,
      processingTime: (processingResult['processing_time'] ?? 0.0).toDouble(),
      uploadedAt: uploadedAt,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fileId': fileId,
      'filename': filename,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'contentType': contentType,
      'folderId': folderId,
      'folderName': folderName,
      'tags': tags,
      'extractedText': extractedText,
      'textLength': textLength,
      'tokens': tokens,
      'tokenCount': tokenCount,
      'uniqueTokens': uniqueTokens,
      'processingTime': processingTime,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'lastAccessedAt':
          lastAccessedAt != null ? Timestamp.fromDate(lastAccessedAt!) : null,
      'viewCount': viewCount,
    };
  }

  DocumentModel copyWith({
    String? folderId,
    String? folderName,
    List<String>? tags,
    bool? isStarred,
    bool? isArchived,
    DateTime? lastAccessedAt,
    int? viewCount,
    int? searchMatchCount,
  }) {
    return DocumentModel(
      fileId: fileId,
      filename: filename,
      fileUrl: fileUrl,
      fileSize: fileSize,
      contentType: contentType,
      folderId: folderId ?? this.folderId,
      folderName: folderName ?? this.folderName,
      tags: tags ?? this.tags,
      extractedText: extractedText,
      textLength: textLength,
      tokens: tokens,
      tokenCount: tokenCount,
      uniqueTokens: uniqueTokens,
      processingTime: processingTime,
      uploadedAt: uploadedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  // Get file size in human readable format
  String get fileSizeFormatted {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  // Get text preview
  String get textPreview {
    if (extractedText.length <= 100) return extractedText;
    return '${extractedText.substring(0, 100)}...';
  }
}
