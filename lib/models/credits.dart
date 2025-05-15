class Credits {
  final int movieId;
  final String title;
  final List<Cast> cast;
  final List<Director> directors;
  final List<Producer> producers;

  Credits({
    required this.movieId,
    required this.title,
    required this.cast,
    required this.directors,
    required this.producers,
  });

  factory Credits.fromJson(Map<String, dynamic> json) {
    return Credits(
      movieId: json['movie_id'],
      title: json['title'],
      cast: (json['cast'] as List).map((x) => Cast.fromJson(x)).toList(),
      directors:
          (json['directors'] as List).map((x) => Director.fromJson(x)).toList(),
      producers:
          (json['producers'] as List).map((x) => Producer.fromJson(x)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movie_id': movieId,
      'title': title,
      'cast': cast.map((x) => x.toJson()).toList(),
      'directors': directors.map((x) => x.toJson()).toList(),
      'producers': producers.map((x) => x.toJson()).toList(),
    };
  }
}

class Cast {
  final int id;
  final String name;
  final String originalName;
  final String? profilePath;
  final String character;
  final int order;

  Cast({
    required this.id,
    required this.name,
    required this.originalName,
    this.profilePath,
    required this.character,
    required this.order,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      originalName: json['original_name'],
      profilePath: json['profile_path'],
      character: json['character'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'profile_path': profilePath,
      'character': character,
      'order': order,
    };
  }
}

class Director {
  final int id;
  final String name;
  final String originalName;
  final String? profilePath;
  final String job;

  Director({
    required this.id,
    required this.name,
    required this.originalName,
    this.profilePath,
    required this.job,
  });

  factory Director.fromJson(Map<String, dynamic> json) {
    return Director(
      id: json['id'],
      name: json['name'],
      originalName: json['original_name'],
      profilePath: json['profile_path'],
      job: json['job'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'profile_path': profilePath,
      'job': job,
    };
  }
}

class Producer {
  final int id;
  final String name;
  final String originalName;
  final String? profilePath;
  final String job;

  Producer({
    required this.id,
    required this.name,
    required this.originalName,
    this.profilePath,
    required this.job,
  });

  factory Producer.fromJson(Map<String, dynamic> json) {
    return Producer(
      id: json['id'],
      name: json['name'],
      originalName: json['original_name'],
      profilePath: json['profile_path'],
      job: json['job'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'profile_path': profilePath,
      'job': job,
    };
  }
}
