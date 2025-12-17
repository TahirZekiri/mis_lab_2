import 'meal.dart';

class MealPreview {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;

  const MealPreview({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
  });

  factory MealPreview.fromMeal(Meal meal) {
    return MealPreview(
      idMeal: meal.idMeal,
      strMeal: meal.strMeal,
      strMealThumb: meal.strMealThumb,
    );
  }

  factory MealPreview.fromJson(Map<String, dynamic> json) {
    return MealPreview(
      idMeal: json['idMeal'] as String? ?? '',
      strMeal: json['strMeal'] as String? ?? '',
      strMealThumb: json['strMealThumb'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealThumb': strMealThumb,
    };
  }
}




