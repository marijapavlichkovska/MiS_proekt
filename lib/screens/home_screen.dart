import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/game_provider.dart';
import '../provider/auth_provider.dart';
import '../widgets/game_list.dart';
import '../widgets/search_button.dart';
import '../models/game.dart';
import 'login_screen.dart';
import 'edit_game_screen.dart';
import 'game_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _initialized = false;

  final List<TextEditingController> _searchControllers = [
    TextEditingController(), // controller for top games
    TextEditingController(), // controller for my games
    TextEditingController(), // controller for favorites
  ];
  final List<TextEditingController> _minRatingControllers = [
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
  ];
  final List<TextEditingController> _maxRatingControllers = [
    TextEditingController(text: '5'),
    TextEditingController(text: '5'),
    TextEditingController(text: '5'),
  ];

  TextEditingController get _searchController => _searchControllers[_selectedIndex];
  TextEditingController get _minRatingController => _minRatingControllers[_selectedIndex];
  TextEditingController get _maxRatingController => _maxRatingControllers[_selectedIndex];

  @override
  void initState() {
    super.initState();
    for (final c in _searchControllers) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [..._searchControllers, ..._minRatingControllers, ..._maxRatingControllers]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabChanged(int index, GameProvider games) {
    games.setActiveTab(index);
    setState(() => _selectedIndex = index);
  }

  void _showFilterSheet(BuildContext context, GameProvider games) {
    _minRatingController.text = games.minRating.toString();
    _maxRatingController.text = games.maxRating.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Consumer<GameProvider>(
          builder: (context, games, _) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter by', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text('Rating range (0-5)', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minRatingController,
                          decoration: InputDecoration(
                            labelText: 'Min',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) {
                            final r = double.tryParse(v);
                            if (r != null && r >= 0 && r <= 5) games.setMinRating(r);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _maxRatingController,
                          decoration: InputDecoration(
                            labelText: 'Max',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) {
                            final r = double.tryParse(v);
                            if (r != null && r >= 0 && r <= 5) games.setMaxRating(r);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Sort', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SortOrder>(
                    value: games.sortOrder,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: const [
                      DropdownMenuItem(value: SortOrder.none, child: Text('None')),
                      DropdownMenuItem(value: SortOrder.aToZ, child: Text('A-Z')),
                      DropdownMenuItem(value: SortOrder.zToA, child: Text('Z-A')),
                    ],
                    onChanged: (v) => games.setSortOrder(v ?? SortOrder.none),
                  ),
                  const SizedBox(height: 20),
                  Text('Genre (match any)', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: (games.allGenres.toList()..sort())
                        .map((genre) => FilterChip(
                      label: Text(genre),
                      selected: games.selectedGenres.contains(genre),
                      onSelected: (_) => games.toggleGenre(genre),
                      showCheckmark: true,
                    ))
                        .toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      Provider.of<GameProvider>(context, listen: false).loadAll();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final games = context.watch<GameProvider>();
    final auth = context.read<AuthProvider>();

    final List<(String, List<Game>)> tabs = [
      ('Top Games', games.filteredTopGames),
      ('My Games', games.filteredMyGames),
      ('Favorites', games.filteredFavorites),
    ];

    final (title, list) = tabs[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          games.setSearchQuery('');
                        },
                      )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) => games.setSearchQuery(value),
                  ),
                ),
                if (_selectedIndex == 0)
                  SearchButton(
                    onPressed: _searchController.text.trim().isEmpty
                        ? null
                        : () async {
                      games.setSearchQuery(_searchController.text);
                      await games.searchInApi();
                    },
                    isLoading: games.isSearchingApi,
                  ),
                IconButton(
                  icon: Badge(
                    isLabelVisible: games.selectedGenres.isNotEmpty ||
                        games.minRating > 0 ||
                        games.maxRating < 5 ||
                        games.sortOrder != SortOrder.none,
                    smallSize: 8,
                    child: const Icon(Icons.filter_list),
                  ),
                  onPressed: () => _showFilterSheet(context, games),
                ),
              ],
            ),
          ),
          Expanded(
            child: games.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: games.loadAll,
              child: GameList(
                games: list,
                onTap: (game) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GameDetailScreen(game: game),
                    ),
                  );
                },
                onEdit: (game) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditGameScreen(game: game),
                    ),
                  );
                },
                showEdit: _selectedIndex != 2,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditGameScreen()),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabChanged(index, games),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Top'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Games'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
      ),
    );
  }
}