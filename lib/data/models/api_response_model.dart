class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? userId;
  final String? expiresAt;
  final String? token;
  final bool? verificationRequired;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.userId,
    this.expiresAt,
    this.token,
    this.verificationRequired,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(Map<String, dynamic> json)? fromJson
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['user'] != null && fromJson != null ? fromJson(json['user']) : null,
      userId: json['user_id'],
      expiresAt: json['expires_at'],
      token: json['token'],
      verificationRequired: json['verification_required'],
    );
  }
} 