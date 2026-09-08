class NotificationApp {
  final String id;
  final String contenu;
  final bool lu;
  final DateTime createdAt;

  const NotificationApp({
    required this.id,
    required this.contenu,
    required this.lu,
    required this.createdAt,
  });

  factory NotificationApp.fromJson(Map<String, dynamic> json) {
    return NotificationApp(
      id: json['_id'] as String,
      contenu: json['contenu'] as String,
      lu: json['lu'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
