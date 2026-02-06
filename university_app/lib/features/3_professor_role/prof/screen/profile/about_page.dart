// المسار: lib/features/3_professor_role/prof/screen/profile/about_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:university_app/core/theme/app_colors.dart'; // يمكن الاستغناء عنه إذا استخدمنا Theme

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ نستخدم لون الثيم الأساسي للتطبيق (اللون الداكن) لضمان التناسق
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          "À propos",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // النص أبيض
          ),
        ),
        // ✅ هنا التغيير: استخدام لون الثيم الأساسي بدلاً من أي لون آخر
        backgroundColor: primaryColor,

        titleSpacing: 0,
        // لون سهم الرجوع أبيض
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            "Ma présence",
                            style: GoogleFonts.roboto(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor, // ✅ استخدام نفس اللون للنص أيضاً
                            ),
                          ),
                        ),
                        // أيقونة القبعة الجامعية بنفس اللون
                        Icon(Icons.school, size: 50, color: primaryColor),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      "est une solution innovante pour la bonne gestion des absences au sein de la faculté des sciences d'Agadir.",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Elle permet aux enseignants et à l'administration de suivre les absences en temps réel et permet aux étudiants de consulter et de justifier leurs absences via une interface intuitive et un système automatisé efficace.",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.center,
                child: Text(
                  "Version 1.0.0",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}