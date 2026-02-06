import 'package:flutter/material.dart';

class AProposPage extends StatelessWidget {
  const AProposPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("À Propos"), backgroundColor: const Color(0xFF190B60), foregroundColor: Colors.white),
      body: const Center(child: Text("Application Université v1.0")),
    );
  }
}