// lib/core/constants/api_constants.dart

class ApiConstants {
  /// 🌍 الرابط الأساسي لجهازك المحلي (Spring Boot)
  /// استخدم 10.0.2.2 للوصول من محاكي أندرويد
  static const String baseUrl = "http://10.0.2.2:8080";

  // 🔑 AUTHENTICATION ENDPOINTS
  // تم إزالة v1 بناءً على كود الـ AuthController الخاص بك
  static const String loginEndpoint = "/api/auth/login";
  static const String currentUserEndpoint = "/api/auth/me";
  static const String registerStudentEndpoint = "/api/auth/register/student";
  static const String registerProfessorEndpoint = "/api/auth/register/professor";
  static const String registerAdminEndpoint = "/api/auth/register/admin";
  static const String registerSuperAdminEndpoint = "/api/auth/register/super-admin";
  static const String refreshTokenEndpoint = "/api/auth/refresh";
  static const String logoutEndpoint = "/api/auth/logout";

  // 🏢 CORE ACADEMIC ENDPOINTS
  // ملاحظة: تأكد أن باقي الـ Controllers (مثل StudentController) تستخدم أيضاً /api فقط
  static const String studentsEndpoint = "/api/students";
  static const String professorsEndpoint = "/api/professors";
  static const String departmentsEndpoint = "/api/departments";
  static const String groupsEndpoint = "/api/groups";
}