// ملف: lib/features/4_admin_role/screens/profile/admin_about_page.dart

import 'package:flutter/material.dart';

class AdminAboutPage extends StatelessWidget {
  const AdminAboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3FD),
      appBar: AppBar(
        title: const Text('A Propos'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logoFsa.png', // (اللوغو لي درنا)
                height: 100,
              ),
              const SizedBox(height: 20),
              Text(
                'Application de Gestion Universitaire',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              const Text(
                'Développée pour l\'administration de la FSA.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}