// File: lib/features/4_admin_role/screens/groups/groups_screen.dart
// (Final Corrected Version - Internal Token Management)

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:university_app/core/models/group.dart';
import 'package:university_app/core/services/group_service.dart';
import 'package:university_app/core/services/auth_service.dart'; // ✅ Added Auth Service

import 'add_group_screen.dart';
import 'edit_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  // ❌ Removed 'token' from constructor
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService(); // ✅ Init Auth Service

  String? _token; // ✅ Token variable
  late Future<List<Group>> _groupsFuture;
  final TextEditingController searchController = TextEditingController();
  List<Group> _allGroups = [];

  @override
  void initState() {
    super.initState();
    _groupsFuture = Future.value([]); // Init empty
    _loadGroups(); // Load token & data
    searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // --- (GET) Load Token & Groups ---
  Future<void> _loadGroups() async {
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
      _groupsFuture = _groupService.getAllGroups(savedToken);
    });
  }

  // --- (POST) Add ---
  void _navigateToAddScreen() async {
    if (_token == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddGroupScreen(token: _token!), // ✅ Use internal token
      ),
    );
    if (result == true) _loadGroups();
  }

  // --- (PUT) Edit ---
  void _navigateToEditScreen(Group group) async {
    if (_token == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditGroupScreen(token: _token!, group: group), // ✅ Use internal token
      ),
    );
    if (result == true) _loadGroups();
  }

  // --- (DELETE) Confirm Dialog ---
  void _showDeleteConfirmDialog(Group group) {
    if (_token == null) return;

    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text("Confirmer"),
                content: Text("Supprimer le groupe ${group.name} ?"),
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
                      bool success = await _groupService.deleteGroup(
                        token: _token!,
                        groupId: group.id,
                      );

                      setDialogState(() => isDeleting = false);
                      if (mounted) Navigator.pop(dialogContext);

                      if (mounted) {
                        _loadGroups();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success ? "Groupe supprimé" : "Échec de la suppression"),
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
        title: const Text("Gestion des Groupes", style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadGroups)
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
                      hintText: "Rechercher par nom...",
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
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
            const SizedBox(height: 20),

            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(color: headerColor, borderRadius: BorderRadius.circular(5)),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text("Nom du Groupe", style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                  Expanded(flex: 2, child: Text("Actions", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor))),
                ],
              ),
            ),
            const SizedBox(height: 5),

            // List
            Expanded(
              child: FutureBuilder<List<Group>>(
                future: _groupsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucun groupe trouvé"));

                  _allGroups = snapshot.data!;
                  final filteredList = _allGroups.where((g) => g.name.toLowerCase().contains(searchController.text.toLowerCase())).toList();

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final group = filteredList[index];
                      return _GroupRow(
                        name: group.name,
                        onEdit: () => _navigateToEditScreen(group),
                        onDelete: () => _showDeleteConfirmDialog(group),
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

// Widget Row (Unchanged structure, just ensuring imports are correct)
class _GroupRow extends StatelessWidget {
  final String name;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GroupRow({
    required this.name,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE8E8E8)), borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}