// ==============================
// FAVORITE BUTTON WIDGET
// ==============================
import 'package:flutter/material.dart';
import 'package:free_dz/models/free_home.dart';

import '../services/api_helper.dart';

class FavoriteButton extends StatefulWidget {
  final Job job;
  final VoidCallback onChanged;

  const FavoriteButton({
    super.key,
    required this.job,
    required this.onChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _loading = false;

  Future<void> _toggleFavorite() async {
    setState(() => _loading = true);

    try {
      await ApiHelper.post(
        '/projects/${widget.job.id}/favorite',
        {},
      );

      widget.job.isFavorite = !widget.job.isFavorite;
      widget.onChanged();
    } catch (e) {
      debugPrint('Favorite toggle error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return IconButton(
      icon: Icon(
        widget.job.isFavorite
            ? Icons.favorite
            : Icons.favorite_border,
        color: Colors.red,
      ),
      onPressed: _toggleFavorite,
    );
  }
}
