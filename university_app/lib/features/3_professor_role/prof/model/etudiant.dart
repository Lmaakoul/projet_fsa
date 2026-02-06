class Etudiant {
  int? id;
  String cne;
  String nom;
  String prenom;
  bool isRattrapage;
  final String? groupe;
  final String? groupeOrigine;

  Etudiant({
    this.id,
    required this.cne,
    required this.nom,
    required this.prenom,
    this.isRattrapage = false,
    this.groupe,
    this.groupeOrigine,
  });

  factory Etudiant.fromMap(Map<String, dynamic> map) {
    return Etudiant(
      id: map['id'],
      cne: map['cne'],
      nom: map['nom'],
      prenom: map['prenom'],
      isRattrapage: map['is_rattrapage'] == 1 || map['is_rattrapage'] == true,
      groupe: map['groupe'],
      groupeOrigine: map['groupe_origine'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cne': cne,
      'nom': nom,
      'prenom': prenom,
      'is_rattrapage': isRattrapage ? 1 : 0,
      'groupe': groupe,
    };
  }
}