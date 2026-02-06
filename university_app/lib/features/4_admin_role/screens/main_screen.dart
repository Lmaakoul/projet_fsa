import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:university_app/core/services/auth_service.dart';

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
  final AuthService _authService = AuthService();

  // تعريف اللون الأساسي ليكون موحداً في الصفحة كلها
  final Color primaryColor = const Color(0xFF190B60);

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // لون خلفية رمادي فاتح جداً واحترافي
      appBar: AppBar(
        title: const Text(
          "Espace Administrateur",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Déconnexion",
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              accountName: const Text("Admin", style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text("admin@university.app"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF190B60)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: primaryColor),
              title: const Text("Paramètres"),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            // الآن لا نحتاج لتمرير الألوان، الدالة ستستخدم التصميم الموحد

            // 1. Départements
            _buildMenuCard(
              context,
              title: "Gestion des Départements",
              icon: Icons.business,
              route: '/departments',
            ),

            // 2. Enseignants
            _buildMenuCard(
              context,
              title: "Gestion des Enseignants",
              icon: Icons.school,
              route: '/professors',
            ),

            // 3. Étudiants
            _buildMenuCard(
              context,
              title: "Gestion des Étudiants",
              icon: Icons.people_alt,
              route: '/students',
            ),

            // 4. Filières
            _buildMenuCard(
              context,
              title: "Gestion des Filières",
              icon: LucideIcons.network,
              route: '/filieres',
            ),

            // 5. Modules
            _buildMenuCard(
              context,
              title: "Gestion des Modules",
              icon: Icons.book,
              route: '/modules',
            ),

            // 6. Groupes
            _buildMenuCard(
              context,
              title: "Gestion des Groupes",
              icon: Icons.groups,
              route: '/groups',
            ),

            // 7. Semestres
            _buildMenuCard(
              context,
              title: "Gestion des Semestres",
              icon: Icons.calendar_month,
              route: '/semesters',
            ),

            // 8. Salles
            _buildMenuCard(
              context,
              title: "Gestion des Salles",
              icon: LucideIcons.doorOpen,
              route: '/salles',
            ),

            // 9. Séances
            _buildMenuCard(
              context,
              title: "Gestion des Séances",
              icon: Icons.schedule,
              route: '/seances',
            ),
          ],
        ),
      ),
    );
  }

  // ودجت البطاقة بتصميم احترافي جديد
  Widget _buildMenuCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required String route,
        // حذفنا معاملات الألوان من هنا لتوحيد التصميم
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // ظل خفيف جداً وناعم
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(context, route, arguments: {
              'token': widget.token,
              'adminId': widget.adminId,
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                // حاوية الأيقونة
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08), // خلفية شفافة جداً من نفس لون البراند
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                      icon,
                      color: primaryColor, // لون الأيقونة موحد (الأزرق الغامق)
                      size: 26
                  ),
                ),
                const SizedBox(width: 16),

                // العنوان
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // Semi-bold looks cleaner
                      color: Color(0xFF2D3748), // لون رمادي غامق جداً للقراءة المريحة
                    ),
                  ),
                ),

                // سهم التوجيه
                Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.grey.shade400
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}