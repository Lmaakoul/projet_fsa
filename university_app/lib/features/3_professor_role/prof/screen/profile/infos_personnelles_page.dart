// المسار: lib/features/3_professor_role/prof/screen/profile/infos_personnelles_page.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استيراد السيرفس الموحد
import 'package:university_app/core/services/professor_service.dart';

// ✅ استيراد المودل (تأكد من مساره)
import 'package:university_app/features/3_professor_role/prof/model/prof_info_model.dart';

class InfoPersonnellePage extends StatefulWidget {
  final int profId;
  const InfoPersonnellePage({Key? key, required this.profId}) : super(key: key);

  @override
  State<InfoPersonnellePage> createState() => _InfoPersonnellePageState();
}

class _InfoPersonnellePageState extends State<InfoPersonnellePage> {
  // ✅ استخدام السيرفس الجديد
  final ProfessorService _professorService = ProfessorService();
  late Future<ProfInfoModel?> _profInfoFuture;

  @override
  void initState() {
    super.initState();
    _profInfoFuture = _professorService.fetchProfProfile(widget.profId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FC),
      appBar: AppBar(
        title: const Text("Informations Personnelles"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ProfInfoModel?>(
        future: _profInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Aucune information trouvée."));
          }

          final prof = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      prof.firstName.isNotEmpty ? prof.firstName[0].toUpperCase() : "P",
                      style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  prof.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  prof.specialization,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),

                _buildInfoCard(LucideIcons.mail, "Email", prof.email),
                _buildInfoCard(LucideIcons.phone, "Téléphone", prof.phoneNumber),
                _buildInfoCard(LucideIcons.graduationCap, "Grade", prof.grade),
                _buildInfoCard(LucideIcons.building, "Département", prof.departmentName),
                _buildInfoCard(LucideIcons.user, "Username", prof.username),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          value.isNotEmpty ? value : "Non renseigné",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ),
    );
  }
}