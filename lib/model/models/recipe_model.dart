import 'dart:convert';

import 'package:flutter/material.dart';

class Recipe {
  final String id;
  final String name;
  final List<String> preparationSteps;
  final List<Ingredient> ingredients;
  final String servings;
  final String time;
  final String calories;
  final bool publish;

  // recipe['id']  ==> recipe.id

  Recipe({
    required this.id,
    required this.name,
    required this.preparationSteps,
    required this.ingredients,
    required this.servings,
    required this.time,
    required this.calories,
    required this.publish,
  });

  // Convert Recipe to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'servings': servings,
      'time': time,
      'calories': calories,
      'preparationSteps': preparationSteps,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Parse طريقة التحضير properly
    List<String> preparationSteps = [];
    if (json['طريقة التحضير'] is String) {
      try {
        // Replace single quotes with double quotes and decode
        String fixedString =
            json['طريقة التحضير'].replaceAll("'", '"'); // Fix invalid JSON
        preparationSteps = List<String>.from(jsonDecode(fixedString));
      } catch (e) {
        debugPrint("Error decoding طريقة التحضير: $e");
      }
    } else if (json['طريقة التحضير'] is List) {
      preparationSteps = List<String>.from(json['طريقة التحضير']);
    }

    List<Ingredient> ingredients = [];
    if (json['المكونات'] is List) {
      ingredients = (json['المكونات'] as List<dynamic>)
          .whereType<Map<String, dynamic>>() 
          .map((ingredient) => Ingredient.fromJson(ingredient))
          .toList();
    }

    return Recipe(
      id: json['id'],
      name: json['اسم الوصفة'],
      preparationSteps: preparationSteps,
      ingredients: ingredients,
      servings: json['عدد الاشخاص'] ?? "غير محدد",
      time: json['الوقت'] ?? "غير محدد",
      calories: json['سعرات الحرارية'] ?? "غير محدد",
      publish: json['publish'] == "1", // Convert string "1" to boolean
    );
  }
}

class Ingredient {
  final String grams;
  final String name;

  Ingredient({
    required this.grams,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'grams': grams,
      'name': name,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      grams: json['الجرامات'] ?? "0",
      name: json['اسم'] ?? "غير محدد",
    );
  }
}
