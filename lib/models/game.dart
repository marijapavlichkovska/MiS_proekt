class Game {
  final String id;
  final String title;
  final String description;
  final double rating;
  final String imageUrl;
  final List<String> genres;
  final String? ownerId;
  final bool isFavorite;

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.imageUrl,
    required this.genres,
    required this.ownerId,
    required this.isFavorite,
  });

  bool get isLocal => ownerId != null;

  Game copyWith({
    String? id,
    String? title,
    String? description,
    double? rating,
    String? imageUrl,
    List<String>? genres,
    String? ownerId,
    bool? isFavorite,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      genres: genres ?? this.genres,
      ownerId: ownerId ?? this.ownerId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    final genresRaw = json['genres'];
    List<String> genresList = [];
    if (genresRaw is List) {
      for (final g in genresRaw) {
        if (g is Map) {
          final name = g['name']?.toString();
          if (name != null && name.isNotEmpty) genresList.add(name);
        }
      }
    } else if (genresRaw is String && genresRaw.isNotEmpty) {
      genresList = genresRaw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return Game(
      id: json['id'].toString(),
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ??
          json['backgroundImage'] ??
          json['background_image'] ??
          '',
      genres: genresList,
      ownerId: json['ownerId'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'rating': rating,
        'imageUrl': imageUrl,
        'genres': genres.join(', '),
        'ownerId': ownerId,
      };

  bool hasGenre(String genre) =>
      genres.any((g) => g.toLowerCase() == genre.toLowerCase());
}