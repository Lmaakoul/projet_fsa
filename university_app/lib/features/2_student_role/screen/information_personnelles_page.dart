import 'package:flutter/material.dart';

class InformationPersonnellesPage extends StatelessWidget {
  final int etudiantId;
  const InformationPersonnellesPage({super.key, required this.etudiantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Infos Personnelles"), backgroundColor: const Color(0xFF190B60), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(leading: const Icon(Icons.badge), title: const Text("ID"), subtitle: Text("$etudiantId")),
          const Divider(),
          const ListTile(leading: Icon(Icons.person), title: Text("Nom"), subtitle: Text("Nom Étudiant")),
          const Divider(),
          const ListTile(leading: Icon(Icons.email), title: Text("Email"), subtitle: Text("student@university.com")),
        ],
      ),
    );
  }
}