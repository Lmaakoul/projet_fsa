// File: lib/features/4_admin_role/screens/semestres/semestres_screen.dart
// (Final Corrected Version - Token handled internally + Fixed Overflow)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:university_app/core/models/semestre.dart';
import 'package:university_app/core/services/semestre_service.dart';
import 'package:university_app/core/services/auth_service.dart'; // ✅ Added Auth Service

import 'add_semestre_screen.dart';
import 'edit_semestre_screen.dart';
import 'semestre_details_screen.dart';

class SemestresScreen extends StatefulWidget {
  // ❌ Removed 'token' from constructor
  const SemestresScreen({super.key});

  @override
  State<SemestresScreen> createState() => _SemestresScreenState();
}

class _SemestresScreenState extends State<SemestresScreen> {
  final SemestreService _semestreService = SemestreService();
  final AuthService _authService = AuthService(); // ✅ Init Auth Service

  String? _token; // ✅ Token variable
  late Future<List<Semestre>> _semestresFuture;

  final TextEditingController searchController = TextEditingController();
  List<Semestre> _allSemestres = [];

  @override
  void initState() {
    super.initState();
    _semestresFuture = Future.value([]); // Init empty
    _loadSemestres(); // Load token & data
    searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // --- (GET) Load Token & Semesters ---
  Future<void> _loadSemestres() async {
    // 1. Get Token
    String? savedToken = await _authService.getToken();

    if (savedToken == null || savedToken.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session expirée"), backgroundColor: Colors.red));
      }
      return;
    }

    // 2. Set State & Fetch
    setState(() {
      _token = savedToken;
      _semestresFuture = _semestreService.getAllSemestres(savedToken);
    });
  }

  // --- (POST) Add ---
  void _navigateToAddSemestre() async {
    if (_token == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSemestreScreen(token: _token!), // ✅ Use internal token
      ),
    );
    if (result == true) {
      _loadSemestres();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semestre ajouté avec succès!"), backgroundColor: Colors.green),
        );
      }
    }
  }

  // --- (PUT) Edit ---
  void _navigateToEditSemestre(Semestre semestre) async {
    if (_token == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSemestreScreen(token: _token!, semestre: semestre), // ✅ Use internal token
      ),
    );
    if (result == true) {
      _loadSemestres();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semestre modifié avec succès!"), backgroundColor: Colors.green),
        );
      }
    }
  }

  // --- (Details) ---
  void _navigateToDetails(Semestre semestre) {
    if (_token == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SemestreDetailsScreen(token: _token!, semestre: semestre), // ✅ Use internal token
      ),
    );
  }

  // --- (DELETE) ---
  void _confirmDeleteDialog(Semestre semestre) {
    if (_token == null) return;

    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                title: const Text("Confirmer la suppression"),
                content: Text("Voulez-vous vraiment supprimer '${semestre.name}' ?"),
                actions: [
                  TextButton(
                    onPressed: isDeleting ? null : () => Navigator.pop(dialogContext),
                    child: const Text("Annuler"),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: isDeleting ? null : () async {
                      setDialogState(() => isDeleting = true);

                      // ✅ Use internal token
                      String? errorMessage = await _semestreService.deleteSemestre(
                        token: _token!,
                        semestreId: semestre.id,
                      );

                      if (mounted) {
                        Navigator.pop(dialogContext);
                        _loadSemestres();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(errorMessage ?? "Semestre supprimé"),
                          backgroundColor: errorMessage == null ? Colors.green : Colors.red,
                        ));
                      }
                    },
                    child: isDeleting
                        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                        : const Text("Supprimer"),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF113A47),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Gestion des Semestres",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSemestres,
          )
        ],
      ),
      // ✅ Check token before building body
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
                      hintText: "Rechercher un semestre",
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF113A47),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _navigateToAddSemestre,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3E8EB),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text("Nom du semestre", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF113A47)))),
                  Expanded(flex: 2, child: Text("Année académique", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF113A47)))),
                  Expanded(flex: 2, child: Text("Actions", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF113A47)))),
                ],
              ),
            ),
            const SizedBox(height: 5),

            // List
            Expanded(
              child: FutureBuilder<List<Semestre>>(
                future: _semestresFuture,
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Erreur: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Aucun semestre trouvé"));
                  }

                  _allSemestres = snapshot.data!;
                  final filteredList = _allSemestres
                      .where((s) => (s.name.toLowerCase().contains(searchController.text.toLowerCase()) || (s.filiereName ?? '').toLowerCase().contains(searchController.text.toLowerCase())))
                      .toList();

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final semestre = filteredList[index];
                      return _SemestreRow(
                        key: ValueKey(semestre.id),
                        nom: "${semestre.name} (${semestre.filiereName ?? 'N/A'})",
                        annee: semestre.academicYear,
                        onEdit: () => _navigateToEditSemestre(semestre),
                        onDelete: () => _confirmDeleteDialog(semestre),
                        onTap: () => _navigateToDetails(semestre),
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

// ==========================================================
// ✅ Widget CORRIGÉ (Row with Fixed Overflow)
// ==========================================================
class _SemestreRow extends StatelessWidget {
  final String nom;
  final String annee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SemestreRow({
    super.key,
    required this.nom,
    required this.annee,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
              child: Text(nom, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: Text(annee, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
            ),
            // ✅ Fixed Overflow: Flex matches header (2), FittedBox prevents icon overflow
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.pencil, color: Color(0xFF113A47), size: 20),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
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