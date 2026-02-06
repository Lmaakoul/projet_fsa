import 'dart:convert';
import 'package:http/http.dart' as http;

// 🟢 الرابط الأساسي للـ API
const String _apiBaseUrl = "http://attendance-system.koyeb.app/api";
// const String _apiBaseUrl = "http://10.0.2.2:8080/api"; // Emulator
// const String _apiBaseUrl = "http://localhost:8080/api"; // Web

class EtudiantService {

  // --- مثال لدالة كانت تسبب الخطأ (مع التصحيح) ---
  // ⚠️ استبدل 'fetchSomeStudentData' و 'your_endpoint' بالأسماء الصحيحة
  Future<List<Map<String, dynamic>>> fetchSomeStudentData(int someId) async {
    // ⚠️ استخدم الـ Endpoint الصحيح
    final url = Uri.parse('$_apiBaseUrl/your_endpoint/$someId');

    try {
      // ⚠️ أضف headers للـ token إذا لزم الأمر
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // استخدام dynamic لتجنب الأخطاء قبل التحقق
        final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

        // --- 🟢 التصحيح هنا 🟢 ---
        // تحقق إذا كان الرد هو Map ويحتوي على مفتاح 'content'
        if (data is Map && data.containsKey('content')) {
          // تأكد أن 'content' هو فعلاً List
          if (data['content'] is List) {
            // قم بتحويل القائمة الداخلية إلى النوع المطلوب
            // (نفترض هنا أنها قائمة من Maps)
            final List<dynamic> contentRaw = data['content'] as List<dynamic>;
            final List<Map<String, dynamic>> studentList = contentRaw
                .whereType<Map<String, dynamic>>() // تجاهل العناصر غير الـ Map
                .toList();
            return studentList;
          } else {
            // إذا كان 'content' ليس List
            print("Error in fetchSomeStudentData: 'content' key exists but is not a List. Data: $data");
            throw Exception("'content' is not a List");
          }
        }
        // تحقق إذا كان الرد هو List مباشرة
        else if (data is List) {
          final List<dynamic> contentRaw = data;
          final List<Map<String, dynamic>> studentList = contentRaw
              .whereType<Map<String, dynamic>>()
              .toList();
          return studentList;
        }
        // إذا كان الرد ليس Map يحتوي على 'content' وليس List
        else {
          print("Error in fetchSomeStudentData: Unexpected data structure. Data: $data");
          throw Exception("Unexpected data structure received from API");
        }
        // --- نهاية التصحيح ---

      } else {
        // التعامل مع أخطاء HTTP (مثل 404, 500)
        print("Error in fetchSomeStudentData: HTTP ${response.statusCode}, Body: ${response.body}");
        throw Exception("Failed to load student data (Status: ${response.statusCode})");
      }
    } catch (e) {
      // التعامل مع أخطاء الشبكة أو التحليل
      print("Error in fetchSomeStudentData: $e");
      throw Exception("Error fetching student data: $e");
    }
  }

// --- ⚠️ أضف هنا باقي الدوال الخاصة بخدمات الطالب ---
// مثال:
// Future<Map<String, dynamic>> fetchStudentDetails(int studentId) async { ... }
// Future<List<dynamic>> fetchStudentAttendance(int studentId) async { ... }
// Future<void> submitJustification(int studentId, Map<String, dynamic> justificationData) async { ... }

} // نهاية الكلاس EtudiantService