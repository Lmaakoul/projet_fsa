import 'package:flutter/material.dart';

class ActivationErrorPage extends StatelessWidget {
  const ActivationErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8d7da),
      appBar: AppBar(
        backgroundColor: const Color(0xff721c24),
        title: const Text("Erreur d'activation"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, color: Color(0xff721c24), size: 80),
              SizedBox(height: 20),
              Text(
                'Erreur lors de l’activation du compte',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff721c24),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Veuillez vérifier vos informations et réessayer.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
