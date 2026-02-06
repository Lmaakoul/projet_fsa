import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ---------------------------------------------------------------------------
// 1️⃣ Main Container Screen
// ---------------------------------------------------------------------------
class AdminMainScreen extends StatefulWidget {
  final String token;
  final String adminId;

  const AdminMainScreen({
    super.key,
    required this.token,
    required this.adminId,
  });

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;
  final Color primaryColor = const Color(0xFF190B60);
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminDashboard(),
      const Scaffold(body: Center(child: Text("Page Notifications"))),
      const Scaffold(body: Center(child: Text("Page Profil"))),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Espace Administrateur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 20),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: FaIcon(FontAwesomeIcons.house, size: 20)), label: 'Accueil'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: FaIcon(FontAwesomeIcons.bell, size: 20)), label: 'Notifs'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: FaIcon(FontAwesomeIcons.user, size: 20)), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2️⃣ Dashboard Content
// ---------------------------------------------------------------------------
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    const Color primaryColor = Color(0xFF190B60);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ تم حذف اللوغو والاسم من هنا. القائمة تبدأ مباشرة.

          _buildMenuCard(context, "Gestion des Départements", FontAwesomeIcons.building, () {
            Navigator.pushNamed(context, '/departments');
          }),
          _buildMenuCard(context, "Gestion des Enseignants", FontAwesomeIcons.chalkboardUser, () {
            Navigator.pushNamed(context, '/professors');
          }),
          _buildMenuCard(context, "Gestion des Étudiants", FontAwesomeIcons.graduationCap, () {
            Navigator.pushNamed(context, '/students');
          }),
          _buildMenuCard(context, "Gestion des Filières", FontAwesomeIcons.sitemap, () {
            Navigator.pushNamed(context, '/filieres');
          }),
          _buildMenuCard(context, "Gestion des Modules", FontAwesomeIcons.bookOpen, () {
            Navigator.pushNamed(context, '/modules');
          }),
          _buildMenuCard(context, "Gestion des Groupes", FontAwesomeIcons.users, () {
            Navigator.pushNamed(context, '/groups');
          }),
          _buildMenuCard(context, "Gestion des Semestres", FontAwesomeIcons.calendarDays, () {
            Navigator.pushNamed(context, '/semesters');
          }),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    const Color primaryColor = Color(0xFF190B60);
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: FaIcon(icon, color: primaryColor, size: 20)),
                const SizedBox(width: 20),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)))),
                const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}