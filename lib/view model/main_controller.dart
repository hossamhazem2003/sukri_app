// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:sukri/core/routes/app_routes.dart';
import 'package:sukri/model/models/recipe_model.dart';
import 'package:sukri/model/models/user_model.dart';
import 'package:sukri/model/data/firebase_services.dart';
import 'package:sukri/view/screens/recipe%20details/recipe_details_screen.dart';
import 'package:sukri/view/widgets/dialogs.dart';
import 'package:sukri/view/widgets/recipe_card.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class MainTabsController {
  final FirebaseServices _firebaseServices = FirebaseServices();

  // Controllers for input fields
  final TextEditingController descriptionController = TextEditingController();

  // Loading state
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isLoadingFavorites =
      ValueNotifier(false); // Loading state for favorites

  // Recipe cards state
  final ValueNotifier<List<RecipeCard>> recipeCards = ValueNotifier([]);

  // User state
  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);

  // Favourites
  final ValueNotifier<List<String>> favoriteRecipes = ValueNotifier([]);

  // Recipes
  final ValueNotifier<List<Recipe>> recipes = ValueNotifier([]);

  MainTabsController(BuildContext context) {
    _initialize(context);
  }

  void dispose() {
    descriptionController.dispose(); // Proper disposal
    isLoading.dispose();
    recipeCards.dispose();
  }

  // Initialize data
  void _initialize(BuildContext context) async {
    isLoading.value = true; // Start loading
    await fetchCurrentUser();
    await fetchLast5Favorites();
    await fetchRecipes(context);
    isLoading.value = false; // Stop loading
  }

  // Fetch all recipes
  Future<void> fetchRecipes(BuildContext context) async {
    try {
      final fetchedRecipes = await _firebaseServices.getAllRecipes();
      recipes.value = fetchedRecipes;
    } catch (e) {
      print("Error fetching recipes: $e");
      showErrorDialog(context, "Error fetching recipes: $e");
    }
  }

  /// Search for recipes using the API
  Future<void> searchRecipes(
      BuildContext context, MainTabsController homeController) async {
    final String recipeName = descriptionController.text.trim();
    if (recipeName.isEmpty) {
      showErrorDialog(context, "يرجى إدخال اسم الوصفة");
      return;
    }
    isLoading.value = true;
    try {
      // Make POST request to API
      final response = await http.post(
        Uri.parse('https://e14e-156-207-229-210.ngrok-free.app/search'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'recipe': recipeName}),
      );

      if (response.statusCode == 200) {
        // Parse response and extract recommendations
        final responseData = jsonDecode(response.body);
        final List<dynamic> recommendations = responseData['recommendations'];

        // Log recommendations for debugging
        debugPrint('$recommendations');

        // Limit to the first 5 recipes and update recipe cards
        recipeCards.value = recommendations.map((recipe) {
          return RecipeCard(
            recipeName: recipe['name'],
            time: recipe['time'],
            calories: '${recipe['calories']} سعرات حرارية',
            similarity:
                'نسبة التشابه: ${(recipe['similarity'] * 100).toStringAsFixed(1)}%',
            onTap: () =>
                _navigateToDetails(context, recipe['id'], homeController),
            recipeId: recipe['id'],
            controller: homeController,
          );
        }).toList();
      } else if (response.statusCode == 404) {
        showErrorDialog(context, "لا توجد نتائج للوصفة '$recipeName'.");
      } else {
        showErrorDialog(context, "حدث خطأ أثناء البحث. حاول مرة أخرى.");
      }
    } catch (e) {
      debugPrint('errror ${e.toString()}');
      showErrorDialog(context, "تعذر الاتصال بالخادم. تحقق من تشغيل API.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to the recipe details screen
  void _navigateToDetails(BuildContext context, String recipeId,
      MainTabsController mainController) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(
          recipeId: recipeId,
        ),
      ),
    );
  }

  /// Fetch current user from Firebase and update state
  Future<void> fetchCurrentUser() async {
    try {
      isLoading.value = true;
      User? user = await _firebaseServices.getCurrentUser();
      currentUser.value = user;
      debugPrint('Current user: ${user?.toMap()}');
    } catch (e) {
      debugPrint('Error fetching user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user data
  Future<void> updateUser({
    required String firstName,
    required String lastName,
    String? password,
  }) async {
    final user = currentUser.value;
    if (user == null) return;

    try {
      isLoading.value = true;

      debugPrint('first Step in update user');

      // Update Firestore user data
      await _firebaseServices.updateUser(
        userId: user.id,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          if (password != null && password.isNotEmpty) 'password': password,
        },
      );

      // Optionally update password
      if (password != null && password.isNotEmpty) {
        await _firebaseServices.updatePassword(
            user.email, user.password, password);
      }
      // Refresh local user data
      currentUser.value = User(
        id: user.id,
        firstName: firstName,
        lastName: lastName,
        username: user.username,
        email: user.email,
        password: password ?? user.password,
      );

      debugPrint('User updated successfully.');
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception('Error updating user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch favorite recipes
  Future<void> fetchLast5Favorites() async {
    isLoadingFavorites.value = true; // Start loading favorites
    try {
      favoriteRecipes.value = await _firebaseServices.getLast5FavoriteRecipes();
    } catch (e) {
      return;
    } finally {
      isLoadingFavorites.value = false; // Stop loading favorites
    }
  }

  /// Toggle the favorite status of a recipe
  Future<void> toggleFavorite(String recipeId) async {
    try {
      // Add or remove favorite
      if (favoriteRecipes.value.contains(recipeId)) {
        await _firebaseServices.removeFavoriteRecipe(recipeId);
        fetchLast5Favorites();
        favoriteRecipes.value = List.from(favoriteRecipes.value)
          ..remove(recipeId);
      } else {
        await _firebaseServices.addFavoriteRecipe(recipeId);
        fetchLast5Favorites();
        favoriteRecipes.value = List.from(favoriteRecipes.value)..add(recipeId);
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  /// Logout the user and clear data
  Future<void> logout(BuildContext context) async {
    try {
      isLoading.value = true;
      await _firebaseServices.logout();
      currentUser.value = null;
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.openingScreen, (route) => false);
      debugPrint('User logged out successfully.');
    } catch (e) {
      debugPrint('Error logging out: $e');
      throw Exception('Error logging out: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
