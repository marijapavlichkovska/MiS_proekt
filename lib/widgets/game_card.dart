import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../provider/game_provider.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool showEdit;

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
    this.onEdit,
    this.showEdit = true,
  });

  Widget _buildThumbnail() {
    const double size = 56;

    if (game.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          game.imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildThumbPlaceholder(size),
        ),
      );
    }
    return _buildThumbPlaceholder(size);
  }

  Widget _buildThumbPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.sports_esports_outlined,
        size: size * 0.5,
        color: Colors.grey[400],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final owned = gameProvider.owns(game);
    final isFav = gameProvider.favorites.any((g) => g.id == game.id);

    return ListTile(
      leading: _buildThumbnail(),
      title: Text(game.title),
      subtitle: Text(
        [
          'Rating: ${game.rating.toStringAsFixed(2)}',
          if (game.genres.isNotEmpty) game.genres.take(3).join(', '),
          if (owned) 'My game',
        ].join(' • '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null,
            ),
            onPressed: () => gameProvider.toggleFavorite(game),
          ),
          if (owned && onEdit != null && showEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}