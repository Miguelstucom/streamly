class User {
  final String userId;
  final String email;
  final String name;
  final List<String>? preferredGenres;

  User({
    required this.userId,
    required this.email,
    required this.name,
    this.preferredGenres,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'].toString(),
      email: json['email'],
      name: json['name'],
      preferredGenres:
          json['preferred_genres'] != null
              ? List<String>.from(json['preferred_genres'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'name': name,
      'preferred_genres': preferredGenres,
    };
  }

  // Getters para mantener compatibilidad con el código existente
  String get firstName => name.split(' ').first;
  String get lastName => name.split(' ').last;
  String get username => email.split('@').first;
}
