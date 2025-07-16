// import 'text_extraction_result.dart';
// import 'tokenization_result.dart';

// class FileProcessingResult {
//   final String fileId;
//   final String fileUrl;
//   final String filename;
//   final int fileSize;
//   final String contentType;
//   final TextExtractionResult textExtraction;
//   final TokenizationResult tokenization;
//   final double processingTime;
//   final DateTime timestamp;

//   FileProcessingResult({
//     required this.fileId,
//     required this.fileUrl,
//     required this.filename,
//     required this.fileSize,
//     required this.contentType,
//     required this.textExtraction,
//     required this.tokenization,
//     required this.processingTime,
//     required this.timestamp,
//   });

//   factory FileProcessingResult.fromJson(Map<String, dynamic> json) {
//     return FileProcessingResult(
//       fileId: json['file_id'] ?? '',
//       fileUrl: json['file_url'] ?? '',
//       filename: json['filename'] ?? '',
//       fileSize: json['file_size'] ?? 0,
//       contentType: json['content_type'] ?? '',
//       textExtraction:
//           TextExtractionResult.fromJson(json['text_extraction'] ?? {}),
//       tokenization: TokenizationResult.fromJson(json['tokenization'] ?? {}),
//       processingTime: (json['processing_time'] ?? 0.0).toDouble(),
//       timestamp:
//           DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'file_id': fileId,
//       'file_url': fileUrl,
//       'filename': filename,
//       'file_size': fileSize,
//       'content_type': contentType,
//       'text_extraction': textExtraction.toJson(),
//       'tokenization': tokenization.toJson(),
//       'processing_time': processingTime,
//       'timestamp': timestamp.toIso8601String(),
//     };
//   }

//   // For Firestore storage
//   Map<String, dynamic> toFirestore() {
//     return {
//       'file_id': fileId,
//       'file_url': fileUrl,
//       'filename': filename,
//       'file_size': fileSize,
//       'content_type': contentType,
//       'extracted_text': textExtraction.extractedText,
//       'text_length': textExtraction.textLength,
//       'extraction_method': textExtraction.extractionMethod,
//       'tokens': tokenization.tokens,
//       'token_count': tokenization.tokenCount,
//       'unique_tokens': tokenization.uniqueTokens,
//       'tokenization_method': tokenization.method,
//       'processing_time': processingTime,
//       'timestamp': timestamp,
//       'created_at': DateTime.now(),
//     };
//   }
// }
