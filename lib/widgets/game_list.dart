import 'package:flutter/material.dart';
import '../models/game.dart';
import 'game_card.dart';

class GameList extends StatelessWidget {
  final List<Game> games;
  final void Function(Game)? onTap;
  final void Function(Game)? onEdit;
  final bool showEdit;

  const GameList({
    super.key,
    required this.games,
    this.onTap,
    this.onEdit,
    this.showEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const Center(child: Text('No games'));
    }
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return GameCard(
          game: game,
          onTap: onTap != null ? () => onTap!(game) : null,
          onEdit: onEdit != null ? () => onEdit!(game) : null,
          showEdit: showEdit,
        );
      },
    );
  }
}