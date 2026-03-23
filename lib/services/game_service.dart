import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';
import 'api_service.dart';

const String rawgApiKey = 'xxx';

class GameService {
  final ApiService _api;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  GameService(this._api);

  Future<List<Game>> getTopGames() async {
    final res = await _api.get(
      '/games',
      query: {'key': rawgApiKey, 'ordering': '-rating', 'page_size': 20},
    );
    final results = (res.data as Map<String, dynamic>)['results'] as List<dynamic>;
    return results.map((e) => Game.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Game>> searchGames(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await _api.get(
      '/games',
      query: {'key': rawgApiKey, 'search': query.trim(), 'page_size': 20},
    );
    final results =
        (res.data as Map<String, dynamic>)['results'] as List<dynamic>? ?? [];
    return results.map((e) => Game.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// User-created games: users/{uid}/games/{docId}
  CollectionReference<Map<String, dynamic>> _userGames(String userId) =>
      _db.collection('users').doc(userId).collection('games');

  /// Favorited API games: users/{uid}/favorites/{gameId}
  CollectionReference<Map<String, dynamic>> _userFavorites(String userId) =>
      _db.collection('users').doc(userId).collection('favorites');

  Future<List<Game>> getMyGames(String userId) async {
    final snapshot = await _userGames(userId).get();
    return snapshot.docs
        .map((doc) => Game.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> saveGame(Game game, String userId) async {
    final data = {...game.toJson(), 'ownerId': userId};

    if (game.id.isEmpty) {
      await _userGames(userId).add(data);
    } else {
      await _userGames(userId).doc(game.id).set(data);
    }
  }

  Future<void> deleteGame(String gameId, String userId) async {
    await _userGames(userId).doc(gameId).delete();

    final favDoc = _userFavorites(userId).doc(gameId);
    final favSnapshot = await favDoc.get();
    if (favSnapshot.exists) {
      await favDoc.delete();
    }
  }

  Future<List<Game>> getFavorites(String userId) async {
    final snapshot = await _userFavorites(userId).get();
    return snapshot.docs
        .map((doc) => Game.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> toggleFavorite(Game game, String userId) async {
    final doc = _userFavorites(userId).doc(game.id);
    final snapshot = await doc.get();

    if (snapshot.exists) {
      await doc.delete();
    } else {
      await doc.set({...game.toJson(), 'isFavorite': true});
    }
  }
}
