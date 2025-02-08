// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sukri/model/data/firebase_services.dart';
import 'package:sukri/model/models/recipe_model.dart';
import 'package:sukri/view/widgets/dialogs.dart';

class FavouriteController {
  final FirebaseServices _firebaseServices = FirebaseServices();

  // Loading state
  final ValueNotifier<bool> isLoadingFavorites =
      ValueNotifier(false); // Loading state for favorites

  // Favourites
  final ValueNotifier<List<String>> favoriteRecipes = ValueNotifier([]);

  final ValueNotifier<List<Recipe>> recipes = ValueNotifier([]);

  FavouriteController(BuildContext context) {
    fetchRecipes(context);
    fetchFavorites(context);
  }

  // Fetch all recipes
  Future<void> fetchRecipes(BuildContext context) async {
    try {
      isLoadingFavorites.value = true;
      recipes.value = await _firebaseServices.getAllRecipes(); 
    } catch (e) {
      print("Error fetching recipes: $e");
      showErrorDialog(context, "خطأ في الحصول علي المفضلة: $e");
    } finally {
      isLoadingFavorites.value = false;
    }
  }

  Future<void> fetchFavorites(BuildContext context) async {
    isLoadingFavorites.value = true; // Start loading favorites
    try {
      favoriteRecipes.value = await _firebaseServices.getFavoriteRecipes();
    } catch (e) {
      showErrorDialog(context, "خطأ في الحصول علي المفضلة: $e");
    } finally {
      isLoadingFavorites.value = false; // Stop loading favorites
    }
  }
}
