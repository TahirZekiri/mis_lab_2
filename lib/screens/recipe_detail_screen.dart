import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String mealId;

  const RecipeDetailScreen({
    super.key,
    required this.mealId,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final MealService _mealService = MealService();
  Meal? _meal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeal();
  }

  Future<void> _loadMeal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final meal = await _mealService.getMealById(widget.mealId);
      setState(() {
        _meal = meal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recipe: $e')),
        );
      }
    }
  }

  Future<void> _launchYouTube(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _meal == null
                ? const Center(child: Text('Recipe not found'))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.network(
                          _meal!.strMealThumb,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, size: 50),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _meal!.strMeal,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_meal!.strCategory != null || _meal!.strArea != null)
                                Row(
                                  children: [
                                    if (_meal!.strCategory != null)
                                      Chip(
                                        label: Text(_meal!.strCategory!),
                                        avatar: const Icon(CupertinoIcons.tag, size: 18),
                                      ),
                                    if (_meal!.strCategory != null &&
                                        _meal!.strArea != null)
                                      const SizedBox(width: 8),
                                    if (_meal!.strArea != null)
                                      Chip(
                                        label: Text(_meal!.strArea!),
                                        avatar: const Icon(
                                          CupertinoIcons.location_solid,
                                          size: 18,
                                        ),
                                      ),
                                  ],
                                ),
                              const SizedBox(height: 24),
                              if (_meal!.strYoutube != null &&
                                  _meal!.strYoutube!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: CupertinoButton.filled(
                                    onPressed: () => _launchYouTube(_meal!.strYoutube),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(CupertinoIcons.play_circle, size: 22),
                                        SizedBox(width: 8),
                                        Text('Watch on YouTube'),
                                      ],
                                    ),
                                  ),
                                ),
                              const Text(
                                'Ingredients',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._meal!.ingredients.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          entry.value.isNotEmpty
                                              ? '${entry.key} - ${entry.value}'
                                              : entry.key,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 24),
                              const Text(
                                'Instructions',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _meal!.strInstructions ?? 'No instructions available',
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

