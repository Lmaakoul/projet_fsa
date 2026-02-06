import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:university_app/core/models/professor.dart';
import 'package:university_app/core/services/professor_service.dart';
import 'package:university_app/core/services/auth_service.dart'; // ✅ إضافة AuthService

import 'add_enseignant_screen.dart';
import 'edit_enseignant_screen.dart';
import 'enseignant_details_screen.dart';

class EnseignantsScreen extends StatefulWidget {
  // ❌ حذفنا required this.token
  const EnseignantsScreen({super.key});

  @override
  State<EnseignantsScreen> createState() => _EnseignantsScreenState();
}

class _EnseignantsScreenState extends State<EnseignantsScreen> {
  final ProfessorService _professorService = ProfessorService();
  final AuthService _authService = AuthService(); // ✅ تعريف AuthService

  // متغير لتخزين التوكن
  String? _token;
  late Future<List<Professor>> _professorsFuture;

  final TextEditingController searchController = TextEditingController();
  List<Professor> _allProfessors = [];
  List<Professor> _filteredProfessors = [];

  @override
  void initState() {
    super.initState();
    _professorsFuture = Future.value([]); // قيمة مبدئية لتجنب الأخطاء
    _loadProfessors(); // تحميل البيانات
    searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // --- (GET) تحميل الأساتذة مع جلب التوكن ---
  Future<void> _loadProfessors() async {
    // 1. جلب التوكن من الذاكرة
    String? savedToken = await _authService.getToken();

    if (savedToken == null || savedToken.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expirée"), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // 2. تحديث الحالة وجلب البيانات
    setState(() {
      _token = savedToken;
      _professorsFuture = _professorService.getAllProfessors(savedToken);
    });
  }

  void _filterList() {
    final query = searchController.text.toLowerCase();
    setState(() {
      _filteredProfessors = _allProfessors.where((prof) {
        return prof.fullName.toLowerCase().contains(query) ||
            prof.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  // --- (ADD) ---
  void _navigateToAddScreen() async {
    if (_token == null) return; // حماية

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEnseignantScreen(token: _token!), // ✅ استخدام _token
      ),
    );
    if (result == true) {
      _loadProfessors();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text("Enseignant ajouté avec succès"),
            backgroundColor: Colors.green,
          ));
      }
    }
  }

  // --- (EDIT) ---
  void _navigateToEditScreen(Professor prof) async {
    if (_token == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditEnseignantScreen(
          professor: prof,
          token: _token!, // ✅ استخدام _token
        ),
      ),
    );

    if (result == true) {
      _loadProfessors();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text("Enseignant mis à jour avec succès"),
            backgroundColor: Colors.green,
          ));
      }
    }
  }

  // --- (DETAILS) ---
  void _navigateToDetails(Professor prof) {
    if (_token == null) return;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnseignantDetailsScreen(
                professor: prof,
                token: _token! // ✅ استخدام _token
            )
        )
    ).then((result) {
      if (result == true) {
        _loadProfessors();
      }
    });
  }

  // --- (DELETE) ---
  void _showDeleteConfirmDialog(BuildContext context, Professor prof) {
    if (_token == null) return;
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Confirmation de suppression'),
              content: Text('Êtes-vous sûr de vouloir supprimer "${prof.fullName}" ?'),
              actions: [
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: isDeleting ? null : () async {
                    setDialogState(() => isDeleting = true);

                    bool success = await _professorService.deleteProfessor(
                      token: _token!, // ✅ استخدام _token
                      professorId: prof.id,
                    );

                    setDialogState(() => isDeleting = false);
                    Navigator.of(dialogContext).pop();

                    if (success) {
                      _loadProfessors();
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                            content: Text("Enseignant supprimé avec succès"),
                            backgroundColor: Colors.green,
                          ));
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                            content: Text("Échec: L'enseignant est tjrs assigné à des modules."),
                            backgroundColor: Colors.red,
                          ));
                      }
                    }
                  },
                  child: isDeleting
                      ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                      : const Text('Supprimer'),
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
        title: const Text("Gestion des Enseignants", style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProfessors,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      // ✅ نتحقق من التوكن قبل عرض الواجهة
      body: _token == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Rechercher par nom ou email",
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Colors.grey, width: 0.3)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(color: primaryAppBarColor, borderRadius: BorderRadius.circular(25)),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _navigateToAddScreen,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(color: headerColor, borderRadius: BorderRadius.circular(5)),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text( "Nom complet", style: TextStyle( fontWeight: FontWeight.bold, color: headerTextColor,),),),
                Expanded(flex: 3, child: Text( "Département", style: TextStyle( fontWeight: FontWeight.bold, color: headerTextColor,),),),
                Expanded(flex: 2, child: Text( "Rôle", style: TextStyle( fontWeight: FontWeight.bold, color: headerTextColor,),),),
                Expanded(flex: 2, child: Text( "Actions", textAlign: TextAlign.center, style: TextStyle( fontWeight: FontWeight.bold, color: headerTextColor,),),),
              ],
            ),
          ),
          const SizedBox(height: 5),

          Expanded(
            child: FutureBuilder<List<Professor>>(
              future: _professorsFuture,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Erreur de chargement: ${snapshot.error}", textAlign: TextAlign.center),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Aucun enseignant trouvé."),
                  );
                }

                _allProfessors = snapshot.data!;
                final List<Professor> displayList = searchController.text.isEmpty
                    ? _allProfessors
                    : _filteredProfessors;

                if (displayList.isEmpty) {
                  return const Center(child: Text("Aucun résultat trouvé pour cette recherche."));
                }

                return ListView.builder(
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final prof = displayList[index];
                    return _EnseignantRow(
                      key: ValueKey(prof.id),
                      nom: prof.fullName,
                      departement: prof.departmentName ?? 'N/A',
                      role: prof.grade ?? 'N/A',
                      onTapDetails: () => _navigateToDetails(prof),
                      onEdit: () => _navigateToEditScreen(prof),
                      onDelete: () => _showDeleteConfirmDialog(context, prof),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EnseignantRow extends StatelessWidget {
  final String nom;
  final String departement;
  final String role;
  final VoidCallback onTapDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EnseignantRow({
    super.key,
    required this.nom,
    required this.departement,
    required this.role,
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
            Expanded(flex: 3, child: Text(nom, style: const TextStyle(fontSize: 16))),
            Expanded(flex: 3, child: Text(departement, style: const TextStyle(fontSize: 16))),
            Expanded(flex: 2, child: Text(role, style: const TextStyle(fontSize: 16))),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.pencil, color: Color(0xFF113A47), size: 20),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}