import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://attendance-system.koyeb.app/api';

class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  MyRegisterState createState() => MyRegisterState();
}

class MyRegisterState extends State<MyRegister> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController cinController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool _isLoading = false;

  Future<void> registerProf() async {
    final String password = passwordController.text.trim();
    final String confirm = confirmPasswordController.text.trim();

    if (password != confirm) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }
    // التحقق من أن الحقول ليست فارغة (يمكن إضافة تحقق أدق)
    if (nomController.text.isEmpty || prenomController.text.isEmpty || cinController.text.isEmpty || emailController.text.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires")),
      );
      return;
    }

    // إظهار مؤشر التحميل
    if (mounted) setState(() => _isLoading = true);

    try {
      // ✅ استخدام الـ Endpoint الصحيح من Swagger
      final url = Uri.parse('$_baseUrl/auth/register/professor');

      // ✅ استخدام طريقة POST وإرسال البيانات كـ JSON
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cin': cinController.text.trim(),
          'nom': nomController.text.trim(),
          'prenom': prenomController.text.trim(),
          'email': emailController.text.trim(),
          'password': password,
          // ⚠️ تأكد إذا كان الباك ايند يحتاج حقولاً إضافية
        }),
      );

      if (!mounted) return; // التحقق بعد الـ await

      print("Register Status Code: ${response.statusCode}"); // للتحقق
      print("Register Response Body: ${response.body}"); // للتحقق

      // ✅ التحقق من نجاح التسجيل (200 OK أو 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // الانتقال لصفحة النجاح
        Navigator.pushReplacementNamed(context, '/activationSuccess'); // استخدام pushReplacement أفضل هنا
      } else {
        // فشل التسجيل (إظهار رسالة خطأ من الباك ايند إن أمكن)
        String errorMessage = 'Erreur lors de l\'enregistrement';
        try {
          final errorData = jsonDecode(response.body);
          // حاول قراءة رسالة الخطأ الشائعة (قد يختلف اسمها حسب الباك ايند)
          errorMessage = errorData['message'] ?? errorData['error'] ?? 'Code: ${response.statusCode}';
        } catch(_){
          errorMessage = 'Réponse invalide du serveur (Code: ${response.statusCode})';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        // الانتقال لصفحة الخطأ (اختياري)
        // Navigator.pushReplacementNamed(context, '/activationError');
      }
    } catch (e) {
      // التعامل مع أخطاء الاتصال بالشبكة
      print('Register network error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de se connecter au serveur: $e'), backgroundColor: Colors.red),
      );
      // الانتقال لصفحة الخطأ (اختياري)
      // Navigator.pushReplacementNamed(context, '/activationError');
    } finally {
      // إخفاء مؤشر التحميل في كل الحالات
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- (دالة dispose كما هي) ---
  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    cinController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // --- (دالة build كما هي، مع إضافة التحقق من _isLoading للزر) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/login.jpg', // أو 'assets/login2.jpg'
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child:
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset('assets/logoFsa.png', height: 60),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "ACTIVER VOTRE COMPTE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF001F54),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildField("Nom", nomController, Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildField("Prénom", prenomController, Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildField("CIN : Carte d'identité Nationale", cinController, Icons.badge_outlined),
                    const SizedBox(height: 15),
                    _buildField(
                        "Email professionnel", emailController, Icons.email_outlined),
                    const SizedBox(height: 15),
                    _buildField("Mot de passe", passwordController, Icons.lock_outline,
                        obscure: true),
                    const SizedBox(height: 15),
                    _buildField("Confirmer le mot de passe",
                        confirmPasswordController, Icons.lock_outline, obscure: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      // 🔹 تعطيل الزر أثناء التحميل
                      onPressed: _isLoading ? null : registerProf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF001F54),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      // 🔹 إظهار مؤشر التحميل داخل الزر
                      child: _isLoading
                          ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text(
                        "S'inscrire",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      // 🔹 تعطيل الزر أثناء التحميل
                      onPressed: _isLoading ? null : () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(
                          color: Color(0xFF001F54),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- (دالة _buildField كما هي) ---
  Widget _buildField(String hint, TextEditingController controller, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF001F54), width: 2),
        ),
      ),
    );
  }
}