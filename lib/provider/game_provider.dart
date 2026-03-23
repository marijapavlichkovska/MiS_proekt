import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/game_service.dart';
import 'auth_provider.dart';

enum SortOrder { none, aToZ, zToA }

class TabFilterState {
  String searchQuery = '';
  double minRating = 0;
  double maxRating = 5;
  SortOrder sortOrder = SortOrder.none;
  Set<String> selectedGenres = {};

  void reset() {
    searchQuery = '';
    minRating = 0;
    maxRating = 5;
    sortOrder = SortOrder.none;
    selectedGenres = {};
  }
}

class GameProvider extends ChangeNotifier {
  final GameService _gameService;
  final AuthProvider _auth;

  List<Game> _top = [];
  List<Game> _mine = [];
  List<Game> _favorites = [];
  List<Game> _apiSearchResults = [];
  bool _loading = false;
  bool _searchingApi = false;

  final List<TabFilterState> _tabFilters = [
    TabFilterState(), // filter state for top
    TabFilterState(), // filter state for my games
    TabFilterState(), // filter state for favorites
  ];

  int _activeTab = 0;

  GameProvider(this._gameService, this._auth);

  List<Game> get topGames => _top;
  List<Game> get myGames => _mine;
  List<Game> get favorites => _favorites;
  bool get isLoading => _loading;
  bool get isSearchingApi => _searchingApi;

  TabFilterState get currentFilter => _tabFilters[_activeTab];

  void setActiveTab(int index) {
    _activeTab = index;
    if (index != 0) _apiSearchResults = [];
    notifyListeners();
  }

  String get searchQuery => currentFilter.searchQuery;
  double get minRating => currentFilter.minRating;
  double get maxRating => currentFilter.maxRating;
  SortOrder get sortOrder => currentFilter.sortOrder;
  Set<String> get selectedGenres => Set.from(currentFilter.selectedGenres);

  void setSearchQuery(String value) {
    currentFilter.searchQuery = value.trim().toLowerCase();
    if (currentFilter.searchQuery.isEmpty) _apiSearchResults = [];
    notifyListeners();
  }

  void resetFilters() {
    currentFilter.reset();
    if (_activeTab == 0) _apiSearchResults = [];
    notifyListeners();
  }

  void setSelectedGenres(Set<String> genres) {
    currentFilter.selectedGenres = Set.from(genres);
    notifyListeners();
  }

  void toggleGenre(String genre) {
    if (currentFilter.selectedGenres.contains(genre)) {
      currentFilter.selectedGenres.remove(genre);
    } else {
      currentFilter.selectedGenres.add(genre);
    }
    notifyListeners();
  }

  Set<String> get allGenres {
    final set = <String>{};
    for (final g in [..._top, ..._mine, ..._favorites, ..._apiSearchResults]) {
      for (final genre in g.genres) {
        if (genre.isNotEmpty) set.add(genre);
      }
    }
    return set;
  }

  Future<void> searchInApi() async {
    if (currentFilter.searchQuery.isEmpty) return;
    _searchingApi = true;
    notifyListeners();
    try {
      _apiSearchResults = await _gameService.searchGames(currentFilter.searchQuery);
    } catch (_) {
      _apiSearchResults = [];
    }
    _searchingApi = false;
    notifyListeners();
  }

  void setMinRating(double value) {
    currentFilter.minRating = value;
    notifyListeners();
  }

  void setMaxRating(double value) {
    currentFilter.maxRating = value;
    notifyListeners();
  }

  void setSortOrder(SortOrder value) {
    currentFilter.sortOrder = value;
    notifyListeners();
  }

  List<Game> _applyFilters(List<Game> list, TabFilterState filter) {
    final lower = filter.minRating <= filter.maxRating ? filter.minRating : filter.maxRating;
    final upper = filter.minRating >= filter.maxRating ? filter.minRating : filter.maxRating;

    var result = list.where((g) {
      final matchesSearch = filter.searchQuery.isEmpty ||
          g.title.toLowerCase().contains(filter.searchQuery);
      final matchesRating = g.rating >= lower && g.rating <= upper;
      final matchesGenre = filter.selectedGenres.isEmpty ||
          filter.selectedGenres.any((genre) => g.hasGenre(genre));
      return matchesSearch && matchesRating && matchesGenre;
    }).toList();

    switch (filter.sortOrder) {
      case SortOrder.aToZ:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOrder.zToA:
        result.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOrder.none:
        break;
    }

    return result;
  }

  List<Game> get filteredTopGames {
    final filter = _tabFilters[0];
    if (filter.searchQuery.isNotEmpty && _apiSearchResults.isNotEmpty) {
      return _applyFilters(_apiSearchResults, filter);
    }
    return _applyFilters(_top, filter);
  }

  bool get hasNoTopResults =>
      _tabFilters[0].searchQuery.isNotEmpty &&
          filteredTopGames.isEmpty &&
          !_searchingApi;

  List<Game> get filteredMyGames => _applyFilters(_mine, _tabFilters[1]);
  List<Game> get filteredFavorites => _applyFilters(_favorites, _tabFilters[2]);

  bool owns(Game g) =>
      g.ownerId != null &&
          _auth.user != null &&
          g.ownerId == _auth.user!.id;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();

    _top = await _gameService.getTopGames();

    if (_auth.user != null) {
      _mine = await _gameService.getMyGames(_auth.user!.id);
      _favorites = await _gameService.getFavorites(_auth.user!.id);
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> saveGame(Game game) async {
    if (_auth.user == null) return;
    await _gameService.saveGame(game, _auth.user!.id);
    await loadAll();
  }

  Future<void> deleteGame(Game game) async {
    if (!owns(game) || _auth.user == null) return;
    await _gameService.deleteGame(game.id, _auth.user!.id);
    _mine.removeWhere((g) => g.id == game.id);
    _favorites.removeWhere((g) => g.id == game.id);
    notifyListeners();
    await loadAll();
  }

  Future<void> toggleFavorite(Game game) async {
    if (_auth.user == null) return;
    await _gameService.toggleFavorite(game, _auth.user!.id);
    await loadAll();
  }
}