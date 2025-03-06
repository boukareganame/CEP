class Cours {
  int? id;
  String titre;
  String description;

  Cours({this.id, required this.titre, required this.description});

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
    };
  }
}
