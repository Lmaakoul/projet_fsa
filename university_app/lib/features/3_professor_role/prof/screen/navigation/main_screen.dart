import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

// استيراد الـ Widget الخاصة بالشريط السفلي
import '../../widget/bottom_nav_bar.dart';

// ✅ استيراد الصفحات الثلاث (تأكد أن المسارات صحيحة)
import '../calendar/prof_home.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_main_page.dart';

// ✅ استيراد السيرفس الموحد
import 'package:university_app/core/services/professor_service.dart';

class MainScreen extends StatefulWidget {
  final int profId;
  const MainScreen({required this.profId, super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<String> _pageTitles = [
    "Sélectionner la Séance",
    "Notifications",
    "Profil",
  ];

  late final List<Widget> _pages;
  late Future<String> _profNameFuture;

  @override
  void initState() {
    super.initState();

    // تعريف الصفحات التي يتم التنقل بينها
    _pages = [
      ProfHome(profId: widget.profId),        // 0: التقويم
      const NotificationsPage(),              // 1: الإشعارات
      ProfileMainPage(profId: widget.profId), // 2: البروفايل
    ];

    // جلب اسم الأستاذ
    _profNameFuture = ProfessorService().fetchProfFullName(widget.profId);
  }

  // دالة لفتح موقع الجامعة
  Future<void> _launchFsaSite() async {
    final Uri url = Uri.parse('http://www.fsa.ac.ma');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'ouvrir le site : $e")),
        );
      }
    }
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),

      // القائمة الجانبية
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey.shade200,
                              child: Icon(
                                LucideIcons.user,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<String>(
                            future: _profNameFuture,
                            builder: (context, snapshot) {
                              final name = snapshot.data ?? 'Professeur';
                              return Text(
                                name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.globe, color: Colors.blue),
                    title: const Text('Site Faculté (FSA)'),
                    subtitle: const Text("www.fsa.ac.ma", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    onTap: () {
                      Navigator.pop(context);
                      _launchFsaSite();
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.helpCircle, color: Colors.green),
                    title: const Text('Guide d\'utilisation'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(LucideIcons.logOut, color: Colors.red),
                    title: const Text(
                      'Déconnexion',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}