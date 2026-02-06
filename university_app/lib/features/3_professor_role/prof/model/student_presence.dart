class StudentPresence {
  final String cne;
  final String nom;
  final String prenom;
  final bool present;

  StudentPresence({
    required this.cne,
    required this.nom,
    required this.prenom,
    this.present = false,
  });

  factory StudentPresence.fromJson(Map<String, dynamic> json) {
    return StudentPresence(
      cne: json['cne'],
      nom: json['nom'],
      prenom: json['prenom'],
    );
  }

  StudentPresence copyWith({bool? present}) {
    return StudentPresence(
      cne: cne,
      nom: nom,
      prenom: prenom,
      present: present ?? this.present,
    );
  }
}