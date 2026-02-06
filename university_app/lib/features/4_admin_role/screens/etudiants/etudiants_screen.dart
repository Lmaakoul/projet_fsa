import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:university_app/core/models/student.dart';
import 'package:university_app/core/services/student_service.dart';
import 'package:university_app/core/services/auth_service.dart'; // ✅ Added Auth Service

import 'add_etudiant_screen.dart';
import 'edit_etudiant_screen.dart';
import 'etudiant_details_screen.dart';

const Color primaryAppBarColor = Color(0xFF0A4F48);
const Color pageBackgroundColor = Color(0xFFF7F7F7);
const Color textFieldBorderColor = Color(0xFFDDE2E5);
const Color headerColor = Color(0xFFE3E8EB);
const Color headerTextColor = Color(0xFF113A47);

class EtudiantsScreen extends StatefulWidget {
  // ❌ Removed 'token' from here
  final String groupeId;
  final String groupeCode;
  final String filiereId;

  const EtudiantsScreen({
    super.key,
    // required this.token, // ❌ Deleted
    required this.groupeId,
    required this.groupeCode,
    required this.filiereId,
  });

  @override
  State<EtudiantsScreen> createState() => _EtudiantsScreenState();
}

class _EtudiantsScreenState extends State<EtudiantsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final StudentService _studentService = StudentService();
  final AuthService _authService = AuthService(); // ✅ Init Auth Service

  String? _token; // ✅ Variable to hold token
  late Future<List<Student>> _studentsFuture;
  List<Student> _allStudents = [];

  @override
  void initState() {
    super.initState();
    _studentsFuture = Future.value([]); // Init with empty future
    _loadStudents(); // Load token and data
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- (GET) Load Token & Data ---
  Future<void> _loadStudents() async {
    // 1. Get Token securely
    String? savedToken = await _authService.getToken();

    if (savedToken == null || savedToken.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expirée"), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // 2. Set state and fetch data
    setState(() {
      _token = savedToken;
      _studentsFuture = _studentService.getStudentsByGroup(savedToken, widget.groupeId);
    });
  }

  // --- (ADD) Navigate to Add Screen ---
  void _navigateToAddScreen() async {
    if (_token == null) return; // Guard clause

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEtudiantScreen(
          token: _token!, // ✅ Use stored token
          // Note: If you need to pass group/filiere ID to add screen, do it here:
          // groupeId: widget.groupeId,
          // filiereId: widget.filiereId
        ),
      ),
    );
    if (result == true) {
      _loadStudents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Étudiant ajouté ✅"), backgroundColor: Colors.green));
      }
    }
  }

  // --- (DELETE) Confirm Dialog ---
  void _showDeleteConfirmDialog(Student student) {
    if (_token == null) return;
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text("Confirmer"),
                content: Text("Supprimer ${student.fullName} ?"),
                actions: [
                  TextButton(
                      onPressed: isDeleting ? null : () => Navigator.pop(dialogContext),
                      child: const Text("Annuler")
                  ),
                  TextButton(
                    child: isDeleting
                        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                        : const Text("Supprimer", style: TextStyle(color: Colors.red)),
                    onPressed: isDeleting ? null : () async {
                      setDialogState(() => isDeleting = true);

                      bool success = await _studentService.deleteStudent(
                        token: _token!, // ✅ Use stored token
                        studentId: student.id,
                      );

                      setDialogState(() => isDeleting = false);
                      if (mounted) Navigator.pop(dialogContext);

                      if (mounted) {
                        if (success) {
                          _loadStudents();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${student.fullName} supprimé"), backgroundColor: Colors.green),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Échec: Étudiant assigné (Notes/Absence)"), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }

  // --- (EDIT) Navigate to Edit Screen ---
  void _navigateToEditScreen(Student studentToEdit) async {
    if (_token == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditEtudiantScreen(
          token: _token!, // ✅ Use stored token
          studentToEdit: studentToEdit,
        ),
      ),
    );
    if (result == true) {
      _loadStudents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mise à jour réussie 🔄"), backgroundColor: Colors.blue));
      }
    }
  }

  // --- (DETAILS) Navigate to Details ---
  void _navigateToDetails(Student student) {
    // Details usually doesn't need token unless it fetches more data,
    // but if it does, pass _token!
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EtudiantDetailsScreen(
          student: student,
          groupeCode: widget.groupeCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryAppBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.groupeCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStudents,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      // ✅ Check token before building body
      body: _token == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: textFieldBorderColor, width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Rechercher par CNE ou Nom...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _navigateToAddScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAppBarColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(color: headerColor, borderRadius: BorderRadius.circular(5)),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('CNE', style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                Expanded(flex: 3, child: Text('Nom complet', style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                Expanded(flex: 2, child: Text('Filière', style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                Expanded(flex: 2, child: Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
              ],
            ),
          ),
          const SizedBox(height: 5),

          Expanded(
            child: FutureBuilder<List<Student>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erreur: ${snapshot.error}", textAlign: TextAlign.center));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun étudiant trouvé pour ce groupe."));
                }

                _allStudents = snapshot.data!;

                final String query = _searchController.text.toLowerCase();
                final List<Student> displayList = _allStudents.where((student) {
                  return student.fullName.toLowerCase().contains(query) ||
                      student.cne.toLowerCase().contains(query);
                }).toList();

                if (displayList.isEmpty) {
                  return const Center(child: Text("Aucun résultat trouvé pour cette recherche."));
                }

                return ListView.builder(
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final student = displayList[index];
                    return _StudentRow(
                      key: ValueKey(student.id),
                      cne: student.cne,
                      nom: student.fullName,
                      filiere: student.filiereName ?? 'N/A',
                      onTapDetails: () => _navigateToDetails(student),
                      onEdit: () => _navigateToEditScreen(student),
                      onDelete: () => _showDeleteConfirmDialog(student),
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

class _StudentRow extends StatelessWidget {
  final String cne;
  final String nom;
  final String filiere;
  final VoidCallback onTapDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudentRow({
    super.key,
    required this.cne,
    required this.nom,
    required this.filiere,
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
              flex: 2,
              child: Text(cne, style: const TextStyle(fontSize: 14)),
            ),
            Expanded(
              flex: 3,
              child: Text(nom, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            Expanded(
              flex: 2,
              child: Text(filiere, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ),
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