import 'package:sukri/model/models/recipe_model.dart';
import 'package:sukri/model/data/firebase_services.dart';
import 'package:flutter/material.dart';

class RecipeDetailsController {
  final FirebaseServices _firebaseServices = FirebaseServices();
  final TextEditingController caloriesController = TextEditingController();
  ValueNotifier<Recipe?> recipeDetails = ValueNotifier(null);
  ValueNotifier<bool> showUpdateButton = ValueNotifier(false);
  ValueNotifier<bool> isFavorite = ValueNotifier(false);
  ValueNotifier<bool> isExpanded = ValueNotifier(false);
  ValueNotifier<bool> isTimed = ValueNotifier(false); // New ValueNotifier for timed recipes

  /// Fetch recipe details
  Future<void> fetchRecipeDetails(String recipeId) async {
    try {
      // Fetch the recipe by ID
      Recipe? recipe = await _firebaseServices.getRecipeById(recipeId);
      recipeDetails.value = recipe;

      // Check if this recipe is a favorite
      if (recipe != null) {
        await _checkIfFavorite(recipeId);
        await _checkIfTimed(recipeId); // Check if the recipe is timed
      }
    } catch (e) {
      debugPrint("Error fetching recipe details: $e");
      recipeDetails.value = null;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    final recipeId = recipeDetails.value?.id;
    if (recipeId == null) return;

    try {
      if (isFavorite.value) {
        // Remove from favorites
        await _firebaseServices.removeFavoriteRecipe(recipeId);
        isFavorite.value = false;
      } else {
        // Add to favorites
        await _firebaseServices.addFavoriteRecipe(recipeId);
        isFavorite.value = true;
      }
    } catch (e) {
      debugPrint("Error toggling favorite status: $e");
    }
  }

  /// Toggle timed recipe status
  Future<void> toggleTimedRecipe() async {
    final recipeId = recipeDetails.value?.id;
    final recipeName = recipeDetails.value?.name;
    if (recipeId == null) return;

    try {
      if (isTimed.value) {
        // Remove from timed recipes
        await _firebaseServices.removeTimedRecipe(recipeId);
        isTimed.value = false;
      } else {
        // Add to timed recipes
        await _firebaseServices.addTimedRecipe(recipeId, recipeName ?? 'بدون اسم',null);
        isTimed.value = true;
      }
    } catch (e) {
      debugPrint("Error toggling timed recipe status: $e");
    }
  }

  /// Check if the current recipe is a favorite
  Future<void> _checkIfFavorite(String recipeId) async {
    try {
      final favorites = await _firebaseServices.getLast5FavoriteRecipes();
      isFavorite.value = favorites.contains(recipeId);
    } catch (e) {
      debugPrint("Error checking favorite status: $e");
      isFavorite.value = false;
    }
  }

  /// Check if the current recipe is timed
  Future<void> _checkIfTimed(String recipeId) async {
    try {
      final timedRecipes = await _firebaseServices.getTimedRecipes();
      isTimed.value = timedRecipes.any((recipe) => recipe['recipeId'] == recipeId);
    } catch (e) {
      debugPrint("Error checking timed recipe status: $e");
      isTimed.value = false;
    }
  }

  void toggleExpanded() {
    isExpanded.value = !isExpanded.value;
  }

  void onCaloriesChanged(String value) {
    showUpdateButton.value = value.isNotEmpty && double.tryParse(value) != null;
  }

  void updateGrams() {
    double? newCalories = double.tryParse(caloriesController.text);
    if (newCalories != null && newCalories > 0 && recipeDetails.value != null) {
      Recipe updatedRecipe = adjustGrams(recipeDetails.value!, newCalories);
      recipeDetails.value = updatedRecipe;
      showUpdateButton.value = false;
    }
  }

  Recipe adjustGrams(Recipe recipe, double newCalories) {
    // Extract original calories
    double originalCalories =
        double.tryParse(recipe.calories.split(' ').first) ?? 0.0;
    if (originalCalories == 0.0) {
      debugPrint('No original calories found, skipping adjustment.');
      return recipe;
    }

    // Calculate adjustment ratio
    double ratio = newCalories / originalCalories;
    debugPrint('Adjustment Ratio: $ratio');

    // Regular expressions for finding numbers
    RegExp numberRegex = RegExp(r'(\d+(?:\.\d+)?(?:-\d+(?:\.\d+)?)?)');

    // Function to update numbers in text
    String updateNumbersInText(String text) {
      return text.replaceAllMapped(numberRegex, (match) {
        String numStr = match.group(1)!;
        if (numStr.contains('-')) {
          List<String> range = numStr.split('-');
          double start = double.parse(range[0]);
          double end = double.parse(range[1]);
          return '${formatNumber(start * ratio)}-${formatNumber(end * ratio)}';
        } else {
          double num = double.parse(numStr);
          return formatNumber(num * ratio);
        }
      });
    }

    // Update ingredients
    List<Ingredient> updatedIngredients = recipe.ingredients.map((ingredient) {
      // Update both grams and name
      String updatedGrams = updateNumbersInText(ingredient.grams);
      String updatedName = updateNumbersInText(ingredient.name);

      return Ingredient(
        grams: updatedGrams,
        name: updatedName,
      );
    }).toList();

    // Return updated recipe
    return Recipe(
      id: recipe.id,
      name: recipe.name,
      ingredients: updatedIngredients,
      servings: recipe.servings,
      time: recipe.time,
      calories: newCalories.toStringAsFixed(0),
      preparationSteps: recipe.preparationSteps,
      publish: recipe.publish,
    );
  }

  // Helper function to format numbers
  String formatNumber(double number) {
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(1);
  }
}