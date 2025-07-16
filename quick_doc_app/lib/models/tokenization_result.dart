class TokenizationResult {
  final List<String> tokens;
  final int tokenCount;
  final int uniqueTokens;
  final String method;

  TokenizationResult({
    required this.tokens,
    required this.tokenCount,
    required this.uniqueTokens,
    required this.method,
  });

  factory TokenizationResult.fromJson(Map<String, dynamic> json) {
    return TokenizationResult(
      tokens: List<String>.from(json['tokens'] ?? []),
      tokenCount: json['token_count'] ?? 0,
      uniqueTokens: json['unique_tokens'] ?? 0,
      method: json['method'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokens': tokens,
      'token_count': tokenCount,
      'unique_tokens': uniqueTokens,
      'method': method,
    };
  }
}
