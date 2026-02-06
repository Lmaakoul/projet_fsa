import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:university_app/core/models/salle.dart';
import 'package:university_app/core/services/salle_service.dart';
import 'package:university_app/core/services/auth_service.dart';
import 'add_salle_screen.dart';
import 'edit_salle_screen.dart';

class SallesScreen extends StatefulWidget {
  const SallesScreen({super.key});

  @override
  State<SallesScreen> createState() => _SallesScreenState();
}

class _SallesScreenState extends State<SallesScreen> {
  final SalleService _salleService = SalleService();
  final AuthService _authService = AuthService();

  String? _token;
  late Future<List<Salle>> _sallesFuture;
  final TextEditingController searchController = TextEditingController();

  // المتغير المختار للفلتر
  String _selectedFilter = "Tous";

  @override
  void initState() {
    super.initState();
    _sallesFuture = Future.value([]);
    _loadSalles();
    searchController.addListener(() => setState(() {}));
  }

  Future<void> _loadSalles() async {
    String? savedToken = await _authService.getToken();
    if (savedToken == null) return;
    setState(() {
      _token = savedToken;
      _sallesFuture = _salleService.getAllSalles(savedToken);
    });
  }

  void _navigateToAdd() async {
    if (_token == null) return;
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSalleScreen()));
    if (result == true) _loadSalles();
  }

  void _navigateToEdit(Salle salle) async {
    if (_token == null) return;
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditSalleScreen(token: _token!, salle: salle)));
    if (result == true) _loadSalles();
  }

  void _deleteSalle(String id) async {
    if (_token == null) return;
    bool success = await _salleService.deleteSalle(token: _token!, salleId: id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Supprimé"), backgroundColor: Colors.green));
      _loadSalles();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF113A47);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F3FD),
      appBar: AppBar(
        title: const Text("Gestion des Salles", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSalles)],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _token == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // شريط البحث
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Rechercher...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: FutureBuilder<List<Salle>>(
                future: _sallesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucune salle trouvée"));

                  final allSalles = snapshot.data!;

                  // 🔥 استخراج البلوكات (Buildings) فقط 🔥
                  final Set<String> blocs = allSalles
                      .map((s) => (s.building != null && s.building!.trim().isNotEmpty) ? s.building! : "Autre")
                      .toSet();

                  // ترتيب القائمة: Tous أولاً، ثم الباقي مرتب أبجدياً
                  final List<String> filters = ["Tous", ...blocs.toList()..sort()];

                  // 🔥 تطبيق الفلترة 🔥
                  final filteredList = allSalles.where((s) {
                    final query = searchController.text.toLowerCase();
                    final matchesSearch = s.code.toLowerCase().contains(query) ||
                        (s.building?.toLowerCase().contains(query) ?? false);

                    // فلترة حسب البلوك
                    bool matchesFilter = true;
                    if (_selectedFilter != "Tous") {
                      if (_selectedFilter == "Autre") {
                        matchesFilter = (s.building == null || s.building!.isEmpty);
                      } else {
                        matchesFilter = s.building == _selectedFilter;
                      }
                    }
                    return matchesSearch && matchesFilter;
                  }).toList();

                  return Column(
                    children: [
                      // شريط الفلاتر (Chips)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filters.map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                                selected: isSelected,
                                selectedColor: primaryColor,
                                backgroundColor: Colors.white,
                                onSelected: (bool selected) {
                                  setState(() => _selectedFilter = filter);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // قائمة القاعات
                      Expanded(
                        child: filteredList.isEmpty
                            ? const Center(child: Text("Aucune salle dans ce bloc"))
                            : ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final salle = filteredList[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 2,
                              child: ListTile(
                                leading: Icon(LucideIcons.doorOpen, color: primaryColor),
                                title: Text(salle.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                                // عرض البلوك والنوع
                                subtitle: Text("${salle.building ?? 'N/A'} • ${salle.type} • Cap: ${salle.capacity}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(icon: const Icon(LucideIcons.pencil, color: Colors.blueGrey, size: 20), onPressed: () => _navigateToEdit(salle)),
                                    IconButton(icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20), onPressed: () => _deleteSalle(salle.id)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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