import 'package:flutter/material.dart';
import '../widget/navigation.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final int _selectedIndex = 3;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/qr');
        break;
      case 2:
        Navigator.pushNamed(context, '/justification');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // AppBar courbée
          ClipPath(
            clipper: CurvedAppBarClipper(),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF547792), Color(0xFF94B4C1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        "Informations Personnelles",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 48), // Pour aligner
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenu principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const ProfilePic(),
                  const SizedBox(height: 10),
                  Text(
                    "Mohamed Taha",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 32),
                  const Info(infoKey: "CNE :", info: "D135298174"),
                  const Info(
                    infoKey: "Année universitaire :",
                    info: "2024/2025",
                  ),
                  const Info(infoKey: "Filière :", info: "SMI"),
                  const Info(infoKey: "Semestre :", info: "S6"),
                  const Info(infoKey: "Groupe :", info: "G2"),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomCurvedNavigationBar(
        index: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
      ),
    );
  }
}

// Classe pour créer la courbe personnalisée
class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50); // Point de départ en haut à gauche
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20, // Point de contrôle pour la courbe
      size.width,
      size.height - 50, // Point d'arrivée en haut à droite
    );
    path.lineTo(size.width, 0); // Retour au bord droit
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Classe pour l'image de profil
class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          // ignore: deprecated_member_use
          color: Theme.of(
            context,
            // ignore: deprecated_member_use
          ).textTheme.bodyLarge!.color!.withOpacity(0.08),
        ),
      ),
      child: const CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(
          "assets/personne.jpg",
        ), // Remplacez par votre image
        backgroundColor: Color(0xFF94B4C1),
      ),
    );
  }
}

// Classe pour afficher les informations clés-valeurs
class Info extends StatelessWidget {
  const Info({super.key, required this.infoKey, required this.info});

  final String infoKey, info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            infoKey,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Theme.of(
                context,
                // ignore: deprecated_member_use
              ).textTheme.bodyLarge!.color!.withOpacity(0.8),
            ),
          ),
          Text(info),
        ],
      ),
    );
  }
}
