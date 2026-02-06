class Prof {
  final String nom;
  final String prenom;
  final String matiereEnseigne;

  Prof({required this.nom, required this.prenom, required this.matiereEnseigne});

  factory Prof.fromJson(Map<String, dynamic> json) {
    return Prof(
      nom: json['nom'],
      prenom: json['prenom'],
      matiereEnseigne: json['subject'],
    );
  }
}