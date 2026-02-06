import 'package:flutter/material.dart';
import 'package:university_app/core/models/departement.dart';
import 'package:university_app/core/services/departement_service.dart';
import 'package:university_app/core/services/auth_service.dart'; // ✅ ضروري هادي
import 'add_departement_screen.dart';
import 'departement_details_screen.dart';

class DepartementsScreen extends StatefulWidget {
  // ✅ حيدنا token من هنا حيت غنجبدوه من الداخل
  const DepartementsScreen({super.key});

  @override
  State<DepartementsScreen> createState() => _DepartementsScreenState();
}

class _DepartementsScreenState extends State<DepartementsScreen> {
  // الألوان
  final Color myPrimaryColor = const Color(0xFF113A47);
  final Color myAccentColor = const Color(0xFF190B60);

  // الخدمات
  final DepartementService _departementService = DepartementService();
  final AuthService _authService = AuthService();

  // المتغيرات
  String? _token; // هنا غنخبيو التوكن ملي نجبدوه
  late Future<List<Departement>> _departementsFuture;

  @override
  void initState() {
    super.initState();
    // كنعطيو قيمة مبدئية فارغة باش مايوقعش خطأ قبل ما يخدم loadDepartements
    _departementsFuture = Future.value([]);
    _loadDepartements();
  }

  // --- (GET) تحميل البيانات والتوكن ---
  Future<void> _loadDepartements() async {
    // 1. نجبدو التوكن من الذاكرة
    String? savedToken = await _authService.getToken();

    if (savedToken == null || savedToken.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expirée, veuillez vous reconnecter"), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // 2. نخبيو التوكن ونعيطو للسرفيس
    setState(() {
      _token = savedToken;
      _departementsFuture = _departementService.getAllDepartements(savedToken);
    });
  }

  // --- (ADD) صفحة الإضافة ---
  void _navigateToAddScreen() async {
    if (_token == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddDepartementScreen(token: _token!), // كنستعملو التوكن اللي جبدنا
      ),
    );

    if (result == true) {
      _loadDepartements();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Département ajouté ✅"), backgroundColor: Colors.green),
        );
      }
    }
  }

  // --- (EDIT) صفحة التعديل ---
  void _navigateToEditScreen(Departement deptToEdit) async {
    if (_token == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DepartementDetailsScreen(
          departement: deptToEdit,
          token: _token!,
        ),
      ),
    );

    if (result == true) {
      _loadDepartements();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Département mis à jour 🔄"), backgroundColor: Colors.blue),
        );
      }
    }
  }

  // --- (DELETE) حوار الحذف ---
  void _showDeleteConfirmDialog(BuildContext context, Departement deptToEdit) {
    if (_token == null) return;
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: Text('Supprimer le département "${deptToEdit.name}" ?'),
              actions: [
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isDeleting
                      ? null
                      : () async {
                    setDialogState(() => isDeleting = true);
                    bool success = await _departementService.deleteDepartement(
                      token: _token!,
                      departementId: deptToEdit.id,
                    );
                    if (mounted) Navigator.of(dialogContext).pop();

                    if (success) {
                      _loadDepartements();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Supprimé avec succès 🗑️"), backgroundColor: Colors.green),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Erreur de suppression ❌"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: isDeleting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Supprimer', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Gestion Départements"),
        backgroundColor: myPrimaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDepartements,
          ),
        ],
      ),
      // ✅ هنا الحل: كنتسناو التوكن يكون واجد عاد نبينو المستقبل
      body: _token == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Departement>>(
        future: _departementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun département trouvé."));
          }

          final departementsList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: departementsList.length,
            itemBuilder: (context, index) {
              final dept = departementsList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: myPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.business, color: myPrimaryColor),
                  ),
                  title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(dept.code),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmDialog(context, dept),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                  onTap: () => _navigateToEditScreen(dept),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myAccentColor,
        onPressed: _navigateToAddScreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}