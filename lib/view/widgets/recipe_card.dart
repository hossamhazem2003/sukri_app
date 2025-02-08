import 'package:sukri/view%20model/main_controller.dart';
import 'package:flutter/material.dart';

class RecipeCard extends StatefulWidget {
  final String recipeId;
  final String recipeName;
  final String time;
  final String calories;
  final String similarity;
  final VoidCallback onTap;
  final MainTabsController controller; // Pass controller from parent

  const RecipeCard({
    super.key,
    required this.recipeId,
    required this.recipeName,
    required this.time,
    required this.calories,
    required this.similarity,
    required this.onTap,
    required this.controller, // Add controller
  });

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleFavorite() async {
    await widget.controller.toggleFavorite(widget.recipeId);
    // Animate based on favorite status
    if (widget.controller.favoriteRecipes.value.contains(widget.recipeId)) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: widget.controller.favoriteRecipes,
      builder: (context, favorites, _) {
        final isFavorite = favorites.contains(widget.recipeId);

        return InkWell(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipeName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.similarity,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: toggleFavorite,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            size: 18, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          widget.calories,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 18, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          widget.time,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
