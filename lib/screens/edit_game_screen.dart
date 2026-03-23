import 'package:flutter/material.dart';
import 'package:mis_proekt/widgets/top_notification.dart';
import 'package:provider/provider.dart';

import '../models/game.dart';
import '../provider/game_provider.dart';

class EditGameScreen extends StatefulWidget {
  final Game? game;

  const EditGameScreen({super.key, this.game});

  @override
  State<EditGameScreen> createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late double _rating;
  late String _imageUrl;
  late String _genres;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final game = widget.game;
    _title = game?.title ?? '';
    _description = game?.description ?? '';
    _rating = game?.rating ?? 0;
    _imageUrl = game?.imageUrl ?? '';
    _genres = (game?.genres ?? []).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.game != null;
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Game' : 'Create Game'),
        actions: [
          if (isEditing && widget.game != null && gameProvider.owns(widget.game!))
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final overlay = Overlay.of(context);
                final padding = MediaQuery.paddingOf(context);
                final colorScheme = Theme.of(context).colorScheme;
                final textTheme = Theme.of(context).textTheme;
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete game'),
                    content: const Text('Are you sure you want to delete this game?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await gameProvider.deleteGame(widget.game!);
                  if (mounted) {
                    showTopNotificationWith(
                      overlay: overlay,
                      padding: padding,
                      message: 'Game deleted',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    );
                    navigator.pop();
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v != null && v.trim().isNotEmpty ? null : 'Title is required',
                onSaved: (v) => _title = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 1,
                maxLines: 3,
                onSaved: (v) => _description = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _rating.toString(),
                decoration: const InputDecoration(labelText: 'Rating (0-5)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final value = double.tryParse(v ?? '');
                  if (value == null || value < 0 || value > 5) {
                    return 'Enter a rating between 0 and 5';
                  }
                  return null;
                },
                onSaved: (v) => _rating = double.tryParse(v ?? '0') ?? 0,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _imageUrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
                onSaved: (v) => _imageUrl = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _genres,
                decoration: const InputDecoration(
                  labelText: 'Genres (comma-separated, e.g. Action, RPG)',
                ),
                onSaved: (v) => _genres = v!.trim(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          _formKey.currentState!.save();
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final overlay = Overlay.of(context);
                          final padding = MediaQuery.paddingOf(context);
                          final colorScheme = Theme.of(context).colorScheme;
                          final textTheme = Theme.of(context).textTheme;
                          setState(() => _loading = true);
                          try {
                            final existing = widget.game;
                            final genresList = _genres
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .toList();
                            final game = Game(
                              id: existing?.id ?? '',
                              title: _title,
                              description: _description,
                              rating: _rating,
                              imageUrl: _imageUrl,
                              genres: genresList,
                              ownerId: existing?.ownerId,
                              isFavorite: existing?.isFavorite ?? false,
                            );
                            await gameProvider.saveGame(game);
                            if (mounted) {
                              showTopNotificationWith(
                                overlay: overlay,
                                padding: padding,
                                message: isEditing ? 'Game updated' : 'Game created',
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              );
                              navigator.pop();
                            }
                          } catch (e) {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Failed to save game: $e')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _loading = false);
                            }
                          }
                        },
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Text(isEditing ? 'Save changes' : 'Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

