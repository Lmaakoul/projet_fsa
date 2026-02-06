// File: lib/features/4_admin_role/screens/modules/modules_screen.dart
// (Final Corrected Version - Internal Token Management)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:university_app/core/models/module.dart';
import 'package:university_app/core/services/module_service.dart';
import 'package:university_app/core/services/auth_service.dart'; // ✅ Added Auth Service

import 'add_module_screen.dart';
import 'edit_module_screen.dart';
import 'module_details_screen.dart';

class ModulesScreen extends StatefulWidget {
  // ❌ Removed 'token' from constructor
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  final ModuleService _moduleService = ModuleService();
  final AuthService _authService = AuthService(); // ✅ Init Auth Service

  String? _token; // ✅ Token variable
  late Future<List<Module>> _modulesFuture;
  final TextEditingController searchController = TextEditingController();
  List<Module> _allModules = [];

  @override
  void initState() {
    super.initState();
    _modulesFuture = Future.value([]); // Init empty
    _loadModules(); // Load token & data
    searchController.addListener(() => setState(() {}));
  }

  // --- (GET) Load Token & Modules ---
  Future<void> _loadModules() async {
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
      _modulesFuture = _moduleService.getAllModules(savedToken);
    });
  }

  // --- (POST) Add ---
  void _navigateToAddScreen() async {
    if (_token == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddModuleScreen(token: _token!), // ✅ Use internal token
      ),
    );
    if (result == true) _loadModules();
  }

  // --- (PUT) Edit ---
  void _navigateToEditScreen(Module module) async {
    if (_token == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditModuleScreen(token: _token!, module: module), // ✅ Use internal token
      ),
    );
    if (result == true) _loadModules();
  }

  // --- (DELETE) Confirm Dialog ---
  void _showDeleteConfirmDialog(Module module) {
    if (_token == null) return;

    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text("Confirmer"),
                content: Text("Supprimer ${module.title} ?"),
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

                      // ✅ Use internal token
                      bool success = await _moduleService.deleteModule(
                        token: _token!,
                        moduleId: module.id,
                      );

                      setDialogState(() => isDeleting = false);
                      if (mounted) Navigator.pop(dialogContext);

                      if (mounted) {
                        _loadModules();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success ? "Module supprimé" : "Échec: Module assigné à des groupes"),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ));
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

  // --- (Details) ---
  void _navigateToDetails(Module module) {
    if (_token == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleDetailsScreen(
          module: module,
          token: _token!, // ✅ Use internal token
        ),
      ),
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
        title: const Text("Gestion des Modules", style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadModules,
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
            // Search Bar & Add Button
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
                  Expanded(flex: 3, child: Text("Nom du Module", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                  Expanded(flex: 2, child: Text("Filière", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                  Expanded(flex: 2, child: Text("Semestre", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                  Expanded(flex: 2, child: Text("Actions", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                ],
              ),
            ),
            const SizedBox(height: 5),

            // List
            Expanded(
              child: FutureBuilder<List<Module>>(
                future: _modulesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucun module trouvé"));

                  _allModules = snapshot.data!;
                  final filteredList = _allModules.where((m) {
                    final query = searchController.text.toLowerCase();
                    return m.title.toLowerCase().contains(query) || m.code.toLowerCase().contains(query);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final module = filteredList[index];
                      return _ModuleRow(
                        key: ValueKey(module.id),
                        nom: module.title,
                        filiere: module.filiereName ?? 'N/A',
                        semestre: module.semesterName ?? 'N/A',
                        onTapDetails: () => _navigateToDetails(module),
                        onEdit: () => _navigateToEditScreen(module),
                        onDelete: () => _showDeleteConfirmDialog(module),
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

// (Widget Row - Unchanged layout logic)
class _ModuleRow extends StatelessWidget {
  final String nom;
  final String filiere;
  final String semestre;
  final VoidCallback onTapDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ModuleRow({
    super.key,
    required this.nom,
    required this.filiere,
    required this.semestre,
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
              child: Text(filiere, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: Text(semestre, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
            ),
            // Fixed Overflow buttons
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.pencil, color: Color(0xFF113A47), size: 18),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 18),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
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