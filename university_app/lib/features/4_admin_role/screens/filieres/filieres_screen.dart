import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:university_app/core/models/filiere.dart';
import 'package:university_app/core/services/filiere_service.dart';
import 'package:university_app/core/services/auth_service.dart'; // ✅ ضروري: استيراد AuthService

import 'add_filiere_screen.dart';
import 'edit_filiere_screen.dart';
import 'filiere_details_screen.dart';

class FilieresScreen extends StatefulWidget {
  // ❌ حيدنا token من Constructor
  const FilieresScreen({super.key});

  @override
  State<FilieresScreen> createState() => _FilieresScreenState();
}

class _FilieresScreenState extends State<FilieresScreen> {
  final FiliereService _filiereService = FiliereService();
  final AuthService _authService = AuthService(); // ✅ تعريف AuthService

  // متغيرات التوكن والبيانات
  String? _token;
  late Future<List<Filiere>> _filieresFuture;

  final TextEditingController searchController = TextEditingController();
  List<Filiere> _allFilieres = [];

  @override
  void initState() {
    super.initState();
    // قيمة مبدئية فارغة
    _filieresFuture = Future.value([]);
    _loadFilieres(); // تحميل البيانات والتوكن
    searchController.addListener(() => setState(() {}));
  }

  // --- (GET) تحميل التوكن والبيانات ---
  Future<void> _loadFilieres() async {
    // 1. جلب التوكن من الذاكرة
    String? savedToken = await _authService.getToken();

    if (savedToken == null || savedToken.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session expirée"), backgroundColor: Colors.red));
      }
      return;
    }

    // 2. تحديث الحالة وجلب الشعب
    setState(() {
      _token = savedToken;
      _filieresFuture = _filiereService.getAllFilieres(savedToken);
    });
  }

  // --- (POST) Ajouter ---
  void _navigateToAddScreen() async {
    if (_token == null) return; // حماية

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => AddFiliereScreen(token: _token!)), // ✅ استخدام _token
    );
    if (result == true) _loadFilieres();
  }

  // --- (PUT) Modifier ---
  void _navigateToEditScreen(Filiere filiere) async {
    if (_token == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => EditFiliereScreen(token: _token!, filiere: filiere)), // ✅ استخدام _token
    );
    if (result == true) _loadFilieres();
  }

  // --- (DELETE) Supprimer ---
  void _showDeleteConfirmDialog(Filiere filiere) {
    if (_token == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer"),
        content: Text("Supprimer ${filiere.name} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              // ✅ استخدام _token
              bool success = await _filiereService.deleteFiliere(token: _token!, filiereId: filiere.id);
              Navigator.pop(context); // إغلاق الحوار

              if (success) {
                _loadFilieres(); // تحديث القائمة
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Filière supprimée"), backgroundColor: Colors.green));
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Échec: Filière assignée à des semestres"), backgroundColor: Colors.red));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // --- (Details) Afficher ---
  void _navigateToDetails(Filiere filiere) async {
    if (_token == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FiliereDetailsScreen(filiere: filiere, token: _token!)), // ✅ استخدام _token
    );
    if (result == true) _loadFilieres();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryAppBarColor = Color(0xFF113A47);
    const Color pageBackgroundColor = Color(0xFFF9F3FD);
    const Color headerColor = Color(0xFFE3E8EB);
    const Color headerTextColor = Color(0xFF113A47);

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Gestion des Filières", style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFilieres,
          )
        ],
      ),
      // ✅ نتحقق من التوكن قبل عرض المحتوى
      body: _token == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Rechercher par nom ou code",
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: primaryAppBarColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _navigateToAddScreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Header Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(color: headerColor, borderRadius: BorderRadius.circular(5)),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text("Nom", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                  Expanded(flex: 2, child: Text("Niveau", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                  Expanded(flex: 3, child: Text("Département", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                  Expanded(flex: 2, child: Text("Actions", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                ],
              ),
            ),
            const SizedBox(height: 5),

            // List
            Expanded(
              child: FutureBuilder<List<Filiere>>(
                future: _filieresFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucune filière trouvée"));

                  _allFilieres = snapshot.data!;
                  final filteredList = _allFilieres.where((f) {
                    final query = searchController.text.toLowerCase();
                    return f.name.toLowerCase().contains(query) || f.code.toLowerCase().contains(query);
                  }).toList();

                  if (filteredList.isEmpty) return const Center(child: Text("Aucun résultat trouvé."));

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final filiere = filteredList[index];
                      return _FiliereRow(
                        key: ValueKey(filiere.id),
                        nom: filiere.name,
                        niveau: filiere.degreeType,
                        departement: filiere.departmentName ?? 'N/A',
                        onTapDetails: () => _navigateToDetails(filiere),
                        onEdit: () => _navigateToEditScreen(filiere),
                        onDelete: () => _showDeleteConfirmDialog(filiere),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// (✅ Widget Row - محفوظ ومصحح)
class _FiliereRow extends StatelessWidget {
  final String nom;
  final String niveau;
  final String departement;
  final VoidCallback onTapDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FiliereRow({
    super.key,
    required this.nom,
    required this.niveau,
    required this.departement,
    required this.onTapDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapDetails,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(nom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: Text(niveau, style: const TextStyle(fontSize: 13, color: Colors.grey), overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 3,
              child: Text(departement, style: const TextStyle(fontSize: 13, color: Colors.grey), overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.pencil, color: Color(0xFF113A47), size: 18),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 18),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}