class EtudiantCne {
  final String nom;
  final String prenom;
  final String groupe;

  EtudiantCne({
    required this.nom,
    required this.prenom,
    required this.groupe,
  });

  factory EtudiantCne.fromJson(Map<String, dynamic> json) {
    return EtudiantCne(
      nom: json['nom'],
      prenom: json['prenom'],
      groupe: json['groupe'],
    );
  }
}