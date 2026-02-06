import 'dart:convert'; // لا تحتاج إليه فعلياً هنا
import 'package:flutter/material.dart';
import 'package:university_app/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// لا تحتاج إلى استيراد 'dart:convert' طالما أنك لا تستخدمه مباشرة في هذا الملف

class MyLogin extends StatefulWidget {
  // ✅ التصحيح: لا تحتاج لتغيير شيء هنا إذا كنت تستخدم صيغة Flutter الحديثة
  // المشكلة قد تكون في استدعائها من مكان آخر. لكننا نتركها كما هي.
  const MyLogin({super.key});

  @override
  MyLoginState createState() => MyLoginState();
}

class MyLoginState extends State<MyLogin> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> loginUser() async {
    // 1. التحقق من المدخلات
    if (email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.orange));
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      // 2. تسجيل الدخول (Login)
      final Map<String, dynamic> loginResponse = await _authService.login(
        email.text.trim(),
        password.text.trim(),
      );

      // 3. الحصول على التوكن (محفوظ تلقائياً في AuthService)
      String? token = loginResponse['token'];
      if (token == null) {
        throw Exception("Token manquant dans الاستجابة");
      }

      // 4. جلب بيانات المستخدم الحقيقية من /me
      // 🛑 تصحيح: getUserInfo لا تأخذ التوكن كوسيط في الكود المحدث
      final Map<String, dynamic>? userInfo = await _authService.getUserInfo();

      if (mounted) setState(() => _isLoading = false);

      if (userInfo != null) {
        // ✅ قراءة الآيدي (userId أو id)
        // هذا الجزء صحيح، لكن الآيدي يفترض أنه تم حفظه مسبقاً في AuthService
        String rawId = userInfo['id']?.toString() ?? '0';

        // ✅✅✅ قراءة الدور من القائمة (حسب Swagger) ✅✅✅
        String role = 'UNKNOWN';

        if (userInfo['roles'] != null) {
          List<dynamic> rolesList = userInfo['roles'];
          if (rolesList.isNotEmpty) {
            role = rolesList[0].toString();
          }
        }

        print("🔍 Données reçues Swagger: ID=$rawId, Roles=${userInfo['roles']}");
        print("👉 Rôle Final détecté: $role");

        // ⚠️ ملاحظة: حفظ الآيدي مرة أخرى هنا ليس ضرورياً إذا كان قد تم حفظه في AuthService
        // لكن نتركه للتأكد
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', rawId);

        // 5. التوجيه (Routing)
        String? targetRoute;
        Map<String, dynamic>? arguments;

        // التحقق من الدور (استخدمنا contains لتكون مرنة مع "ROLE_ADMIN" أو "ADMIN")
        if (role.toUpperCase().contains('ADMIN')) {
          targetRoute = '/adminHome';
          arguments = {'adminId': rawId, 'token': token};
        }
        // يفترض أن تكون الـ IDs في الـ API هي UUIDs (Strings)، ليس أرقاماً.
        // نتركها Strings أفضل بدلاً من التحويل إلى int
        else if (role.toUpperCase().contains('PROFESSOR') || role.toUpperCase().contains('PROF')) {
          targetRoute = '/profHome';
          arguments = {'profId': rawId};
        }
        else if (role.toUpperCase().contains('STUDENT') || role.toUpperCase().contains('ETUDIANT')) {
          targetRoute = '/studentHome';
          arguments = {'etudiantId': rawId};
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rôle non autorisé: $role"), backgroundColor: Colors.red));
          return;
        }

        // التنقل
        if (mounted && targetRoute != null) {
          Navigator.pushReplacementNamed(context, targetRoute, arguments: arguments);
        }
      } else {
        // يمكن أن يحدث هذا إذا كان التوكن صحيحاً لكن الـ API لم يرجع البيانات
        throw Exception("Impossible de récupérer les infos utilisateur (/me). Vérifiez le token.");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // تنظيف رسالة الخطأ
        String msg = e.toString().replaceAll("Exception:", "").trim();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $msg"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 ملاحظة: الكود الخاص بالـ UI (_buildField, Scaffold, Stack) صحيح ومُنظم.
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/login.jpg', fit: BoxFit.cover)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [Image.asset('assets/logoFsa.png', height: 60)]),
                      const SizedBox(height: 20),
                      const Text("SUIVI INTERACTIF DES PRESENCES", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF190B60))),
                      const SizedBox(height: 30),
                      _buildField("Email professionnel", email, Icons.email_outlined),
                      const SizedBox(height: 15),
                      _buildField("Mot de passe", password, Icons.lock_outline, obscure: true),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _isLoading ? null : loginUser,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF190B60), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 5),
                        child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Connexion', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      // ... باقي الكود (أزرار التفعيل والنسيان) ...
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 10.0,
                        children: [
                          TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text("Activer mon compte", style: TextStyle(color: Color(0xFF190B60), fontWeight: FontWeight.bold))),
                          TextButton(onPressed: () => Navigator.pushNamed(context, '/forgetPassword'), child: const Text("Mot de passe oublié ?", style: TextStyle(color: Color(0xFF190B60), fontWeight: FontWeight.bold))),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💡 يمكنك وضع هذه الدالة في ملف /utils/ui_helpers.dart إذا كنت تستخدمها في أماكن أخرى
  Widget _buildField(String hint, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF190B60), width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
    );
  }
}