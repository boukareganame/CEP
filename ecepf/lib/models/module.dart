class Module {
  final int id;
  final String title;
  final String description;

  Module({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      title: json['titre'], // Assurez-vous que le nom correspond à votre API
      description: json['description'], // Assurez-vous que le nom correspond à votre API
    );
  }
}