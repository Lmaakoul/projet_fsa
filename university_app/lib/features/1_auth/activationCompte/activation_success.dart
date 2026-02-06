import 'package:flutter/material.dart';

class ActivationSuccessPage extends StatelessWidget {
  const ActivationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("Activation réussie"),
        backgroundColor: const Color(0xff4c505b),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 20),
              Text(
                'Bienvenue dans ton application de gestion d\'absence',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff4c505b),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Vous avez réussi à activer votre compte.\nCheckez votre email pour confirmer.',
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
