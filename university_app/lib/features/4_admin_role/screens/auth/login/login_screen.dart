import 'package:flutter/material.dart';
import 'package:university_app/core/services/auth_service.dart';

class MyLogin extends StatefulWidget {
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
    // 1. التحقق من الحقول الفارغة
    if (email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ التغيير هنا: حذفنا useMock: true لأننا نستخدم السيرفر الحقيقي فقط
      final userData = await _authService.login(
        email.text.trim(),
        password.text.trim(),
      );

      if (!mounted) return;

      // 2. التحقق من الدور والتوجيه
      final role = (userData['role'] ?? '').toString().toUpperCase();
      final userId = userData['id'];
      final token = userData['token'];

      print("👉 Role detected: $role"); // للتأكد من الدور في الكونسول

      if (role.contains('ADMIN')) {
        // ✅ توجيه المسؤول
        Navigator.pushReplacementNamed(context, '/adminHome',
            arguments: {'adminId': userId, 'token': token});

      } else if (role.contains('PROF')) {
        // ✅ توجيه الأستاذ
        Navigator.pushReplacementNamed(context, '/profHome', // تأكد من اسم الروت عندك
            arguments: {'profId': userId});

      } else if (role.contains('ETUDIANT') || role.contains('STUDENT')) {
        // ✅ توجيه الطالب
        Navigator.pushReplacementNamed(context, '/studentHome', // تأكد من اسم الروت عندك
            arguments: {'etudiantId': userId});

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rôle non autorisé: $role'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // تنظيف رسالة الخطأ لتكون مقروءة
      String errorMsg = e.toString().replaceAll("Exception:", "").trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $errorMsg'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Positioned.fill(
            child: Image.asset(
              'assets/login.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // المحتوى
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/logoFsa.png',
                        height: 60,
                      ),
                    ],
                  ),
                ),
                const Text(
                  "SUIVI INTERACTIF DES PRESENCES",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF190B60),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: email,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email, color: Color(0xFF190B60)),
                            hintText: "Email professionnel",
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF190B60), width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF190B60), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: password,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFF190B60)),
                            hintText: "Mot de passe",
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF190B60), width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF190B60), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF190B60),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text(
                            'Connexion',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // روابط نسيت كلمة السر والتفعيل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text("Activer mon compte", style: TextStyle(decoration: TextDecoration.underline, color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgetPassword'),
                      child: const Text("Mot de passe oublié ?", style: TextStyle(decoration: TextDecoration.underline, color: Colors.black)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}