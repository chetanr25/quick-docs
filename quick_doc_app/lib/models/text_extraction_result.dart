class TextExtractionResult {
  final String extractedText;
  final int textLength;
  final String extractionMethod;

  TextExtractionResult({
    required this.extractedText,
    required this.textLength,
    required this.extractionMethod,
  });

  factory TextExtractionResult.fromJson(Map<String, dynamic> json) {
    return TextExtractionResult(
      extractedText: json['extracted_text'] ?? '',
      textLength: json['text_length'] ?? 0,
      extractionMethod: json['extraction_method'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extracted_text': extractedText,
      'text_length': textLength,
      'extraction_method': extractionMethod,
    };
  }
}
