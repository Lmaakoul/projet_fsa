class AuthResponse {
  final String token;
  final String id;
  final String role;

  AuthResponse({
    required this.token,
    required this.id,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // ✅ 1. استخراج التوكن (نجرب الاحتمالين)
    // بعض السيرفرات ترسل 'token' والبعض 'accessToken'
    final String token = json['token'] ?? json['accessToken'] ?? '';

    // ✅ 2. استخراج الآيدي (وتحويله لنص دائماً لتجنب مشاكل int/string)
    final varRawId = json['userId'] ?? json['id'] ?? '0';
    final String id = varRawId.toString();

    // ✅ 3. استخراج الرول (سواء كان نصاً مباشراً أو داخل قائمة)
    String role = 'UNKNOWN';

    if (json['role'] is String) {
      role = json['role']; // إذا كان نصاً مباشراً: "ROLE_PROFESSOR"
    }
    else if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      role = json['roles'][0].toString(); // إذا كان قائمة: ["ROLE_PROFESSOR"]
    }
    else if (json['userRole'] is String) {
      role = json['userRole'];
    }

    return AuthResponse(
      token: token,
      id: id,
      role: role,
    );
  }
}