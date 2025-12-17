import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal.dart';
import '../services/favorites_service.dart';
import '../widgets/meal_card.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: SafeArea(
        child: Consumer<FavoritesService>(
          builder: (context, favorites, _) {
            final items = favorites.favorites;
            if (items.isEmpty) {
              return const Center(child: Text('No favorites yet'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final fav = items[index];
                final meal = Meal(
                  idMeal: fav.idMeal,
                  strMeal: fav.strMeal,
                  strMealThumb: fav.strMealThumb,
                  ingredients: const {},
                );
                return MealCard(
                  meal: meal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(mealId: fav.idMeal),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}




