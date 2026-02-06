import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Core & Config ---
import 'package:university_app/core/providers/theme_provider.dart';
import 'package:university_app/core/theme/app_theme.dart';

// --- Auth Imports ---
import 'package:university_app/features/1_auth/connexion/screen/login.dart';
import 'package:university_app/features/1_auth/activationCompte/register.dart';
import 'package:university_app/features/1_auth/connexion/screen/forget_password.dart';

// --- Student Imports ---
import 'package:university_app/features/2_student_role/screen/accueil.dart'; // هذا الملف يحتوي الآن على StudentHomeScreen

// --- Professor Imports ---
import 'package:university_app/features/3_professor_role/prof/screen/navigation/main_screen.dart' as Prof;
import 'package:university_app/features/3_professor_role/prof/screen/scan/scan_qr_page.dart';
import 'package:university_app/features/3_professor_role/prof/screen/scan/scan_barcode_page.dart';
import 'package:university_app/features/3_professor_role/prof/screen/manual_entry/manual_attendance_page.dart';

// --- Admin Imports ---
import 'package:university_app/features/4_admin_role/screens/main_screen.dart';
import 'package:university_app/features/4_admin_role/screens/settings/settings_page.dart';

// --- Admin Sub-Screens Imports ---
import 'package:university_app/features/4_admin_role/screens/departements/departements_screen.dart';
import 'package:university_app/features/4_admin_role/screens/enseignant/enseignants_screen.dart';
import 'package:university_app/features/4_admin_role/screens/etudiants/etudiant_selection_screen.dart';
import 'package:university_app/features/4_admin_role/screens/filieres/filieres_screen.dart';
import 'package:university_app/features/4_admin_role/screens/modules/modules_screen.dart';
import 'package:university_app/features/4_admin_role/screens/groups/groups_screen.dart';
import 'package:university_app/features/4_admin_role/screens/semestres/semestres_screen.dart';
import 'package:university_app/features/4_admin_role/screens/salles/salles_screen.dart';

// ✅ Seances Imports
import 'package:university_app/features/4_admin_role/screens/seances/seances_screen.dart';
import 'package:university_app/features/4_admin_role/screens/seances/seance_list_screen.dart';

// ✅ Presences
import 'package:university_app/features/4_admin_role/screens/presences/presence_selection_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'University App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/login', // نقطة البداية

      routes: {
        // ====================================================
        // 🔐 Auth Routes
        // ====================================================
        '/login': (context) => const MyLogin(),
        '/register': (context) => const MyRegister(),
        '/forgetPassword': (context) => const ForgetPasswordPage(),

        // ====================================================
        // 🎓 Student Routes (التعديل هنا ✅)
        // ====================================================
        '/studentHome': (context) => StudentHomeScreen(
            etudiantId: _getArgument(context, 'etudiantId') ?? 0
        ),
        '/home': (context) => StudentHomeScreen(
            etudiantId: _getArgument(context, 'etudiantId') ?? 0
        ),

        '/qr': (context) => const CodeQRPage(),
        '/justification': (context) => const JustificationPage(),
        '/studentStats': (context) => const StudentStatsPage(),
        '/studentNotifs': (context) => const StudentNotificationsPage(),

        // ====================================================
        // 👨‍🏫 Professor Routes
        // ====================================================
        '/profHome': (context) => Prof.MainScreen(profId: _getArgument(context, 'profId') ?? 0),
        '/scanQR': (context) => const ScanQRPage(),
        '/scanBarcode': (context) => const ScanBarcodePage(),

        // صفحة الحضور اليدوي
        '/manualList': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ManualAttendancePage(
            profId: args?['profId'] ?? 0,
            seanceId: args?['seanceId'] ?? 0,
            groupeId: args?['groupeId'] ?? 0, // الآن هذا يقبل int لأنه يتم تحويله في الـ Service
            moduleId: args?['moduleId'] ?? 0,
            parcoursId: args?['parcoursId'] ?? 0,
            moduleName: args?['module'],
            groupeCode: args?['groupe'],
            seanceLabel: args?['seance'],
            selectedFiliere: args?['filiereName'],
          );
        },

        // ====================================================
        // 🛠️ Admin Routes
        // ====================================================
        '/adminHome': (context) => AdminMainScreen(
          token: _getArgument(context, 'token') ?? '',
          adminId: _getArgument(context, 'adminId') ?? '',
        ),
        '/settings': (context) => const SettingsPage(),

        // --- Admin Sub-Screens ---
        '/departments': (context) => const DepartementsScreen(),
        '/professors': (context) => const EnseignantsScreen(),
        '/students': (context) => const EtudiantSelectionScreen(),
        '/filieres': (context) => const FilieresScreen(),
        '/modules': (context) => const ModulesScreen(),
        '/groups': (context) => const GroupsScreen(),
        '/semesters': (context) => const SemestresScreen(),
        '/salles': (context) => const SallesScreen(),

        // ✅ Seances
        '/seances': (context) => const SeancesScreen(),
        '/seances_list': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return SeanceListScreen(
            moduleId: args?['moduleId'] ?? '',
            groupId: args?['groupId'] ?? '',
            moduleName: args?['moduleName'] ?? '',
            groupName: args?['groupName'] ?? '',
          );
        },

        '/presences': (context) => PresenceSelectionScreen(token: _getArgument(context, 'token') ?? ''),
      },
    );
  }

  // دالة استخراج البيانات بأمان
  T? _getArgument<T>(BuildContext context, String key) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic> && arguments.containsKey(key)) {
      try {
        if (T == int && arguments[key] is String) {
          return int.tryParse(arguments[key] as String) as T?;
        } else if (T == String && arguments[key] is int) {
          return arguments[key].toString() as T?;
        } else if (T == double && arguments[key] is String) {
          return double.tryParse(arguments[key] as String) as T?;
        }
        if (arguments[key] is T) {
          return arguments[key] as T?;
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

// --- Placeholders ---
class CodeQRPage extends StatelessWidget { const CodeQRPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Code QR")), body: const Center(child: Text("Page QR Code"))); }
class JustificationPage extends StatelessWidget { const JustificationPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Justifications")), body: const Center(child: Text("Page Justifications"))); }
class StudentStatsPage extends StatelessWidget { const StudentStatsPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Statistiques")), body: const Center(child: Text("Page Statistiques"))); }
class StudentNotificationsPage extends StatelessWidget { const StudentNotificationsPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Notifications")), body: const Center(child: Text("Page Notifications"))); }