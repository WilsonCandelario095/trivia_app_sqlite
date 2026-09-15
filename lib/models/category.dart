class QuizCategory {
  final int id;
  final String name;
  final String? icon;
  final String? description;
 
  QuizCategory({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });
 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }
 
  factory QuizCategory.fromMap(Map<String, dynamic> map) {
    return QuizCategory(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      description: map['description'] as String?,
    );
  }
}