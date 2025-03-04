class Category {
  final String title;
  final String icon;
  final String route;

  Category({required this.title, required this.icon, required this.route});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'],
      icon: json['icon'],
      route: json['route'],
    );
  }
}
