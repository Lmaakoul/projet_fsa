// المسار: lib/features/3_professor_role/prof/screen/notifications/convocation_examen_page.dart

import 'package:flutter/material.dart';
import '../../service/examen_service.dart'; // Assuming this exists
import '../../service/prof_service.dart'; // We use this for module/parcours fetching

class ConvocationExamenPage extends StatefulWidget {
  final int profId;

  const ConvocationExamenPage({super.key, required this.profId});

  @override
  State<ConvocationExamenPage> createState() => _ConvocationExamenPageState();
}

class _ConvocationExamenPageState extends State<ConvocationExamenPage> {
  // --- State Variables ---
  // 🛑 FIX: Changed Future type to match API return type List<Map<String, dynamic>>
  late Future<List<Map<String, dynamic>>> _parcoursFuture;
  late Future<List<Map<String, dynamic>>> _modulesFuture;

  int? _selectedParcoursId;
  String? _selectedParcoursName;
  String? _selectedModule;

  // Services
  late ExamenService _examenService;
  late ProfService _profService;

  @override
  void initState() {
    super.initState();
    _examenService = ExamenService();
    _profService = ProfService();

    // 1. Start by fetching the professor's parcours (Requires Filiere ID if needed)
    // NOTE: This usually requires first selecting a Filiere, but we'll simplify and mock.
    _parcoursFuture = Future.value([
      {'id': 10, 'nom': 'LFI - Parcours A'},
      {'id': 11, 'nom': 'Master - Parcours B'},
    ]);

    // Initialize modules future to an empty list
    _modulesFuture = Future.value([]);
  }

  // 🛑 FIX: Method now correctly defined to fetch modules by Parcours
  Future<List<Map<String, dynamic>>> _fetchModulesByParcours(int parcoursId) async {
    try {
      // 🛑 Using the corrected method name from ProfService
      return await _profService.fetchModulesByProfAndParcours(widget.profId, parcoursId);
    } catch (e) {
      print("Error fetching modules: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Convocations aux Examens')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- 1. Parcours Dropdown ---
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _parcoursFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final parcoursList = snapshot.data ?? [];

                return DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Sélectionner le Parcours'),
                  value: _selectedParcoursId,
                  items: parcoursList.map((p) {
                    return DropdownMenuItem<int>(
                      value: p['id'] as int, // 🛑 FIX: Ensure type casting
                      child: Text(p['nom']?.toString() ?? 'N/A'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedParcoursId = newValue;
                        _selectedParcoursName = parcoursList.firstWhere((p) => p['id'] == newValue)['nom']?.toString() ?? 'N/A';
                        _selectedModule = null;
                        // Trigger fetching modules for the selected parcours
                        _modulesFuture = _fetchModulesByParcours(newValue);
                      });
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // --- 2. Module Dropdown ---
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _modulesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LinearProgressIndicator());
                }
                final modulesList = snapshot.data ?? [];

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Sélectionner le Module'),
                  value: _selectedModule,
                  hint: const Text('Sélectionner un module'),
                  items: modulesList.map((m) {
                    return DropdownMenuItem<String>(
                      value: m['nom']?.toString() ?? 'N/A', // 🛑 FIX: Use toString()
                      child: Text(m['nom']?.toString() ?? 'N/A'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedModule = newValue;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 30),

            // --- 3. Display Convocations Button (Mock) ---
            ElevatedButton.icon(
              onPressed: (_selectedModule == null)
                  ? null
                  : () {
                // Logic to fetch and display the actual convocations PDF/Data
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Afficher convocation pour $_selectedModule')),
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Afficher Convocation'),
            ),
          ],
        ),
      ),
    );
  }
}