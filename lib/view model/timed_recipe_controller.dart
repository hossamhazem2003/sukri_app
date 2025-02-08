import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sukri/model/data/firebase_services.dart';

class TimedRecipeController {
  final FirebaseServices _firebaseServices = FirebaseServices();

  // ValueNotifiers to hold the recipes
  ValueNotifier<List<Map<String, dynamic>>> unscheduledRecipes = ValueNotifier([]);
  ValueNotifier<List<Map<String, dynamic>>> dayRecipes = ValueNotifier([]);
  ValueNotifier<List<Map<String, dynamic>>> weekRecipes = ValueNotifier([]);
  ValueNotifier<Map<String, List<Map<String, dynamic>>>> groupedWeekRecipes = ValueNotifier({});

  // Constructor to initialize data automatically
  TimedRecipeController() {
    _initializeData();
  }

  /// Initialize data: fetch all required data on controller instantiation
  Future<void> _initializeData() async {
    await fetchUnscheduledRecipes();
    await fetchDayRecipes(DateTime.now());
    await fetchWeekRecipes(getStartOfWeek(DateTime.now()));
  }

  /// Fetch unscheduled recipes
  Future<void> fetchUnscheduledRecipes() async {
    try {
      final data = await _firebaseServices.getUnscheduledRecipes();
      unscheduledRecipes.value = data;
    } catch (e) {
      return;
    }
  }

  /// Fetch recipes scheduled for a specific day
  Future<void> fetchDayRecipes(DateTime day) async {
    try {
      final data = await _firebaseServices.getRecipesForDay(day);
      dayRecipes.value = data;
    } catch (e) {
      return;
    }
  }

  /// Fetch recipes scheduled for a specific week and group them by day
  Future<void> fetchWeekRecipes(DateTime weekStart) async {
    try {
      final data = await _firebaseServices.getRecipesForWeek(weekStart);
      weekRecipes.value = data;

      // Group recipes by day
      Map<String, List<Map<String, dynamic>>> groupedRecipes = {};
      DateTime today = DateTime.now();

      for (var recipe in data) {
        String scheduledTimeString = recipe['scheduledTime'] ?? '';
        DateTime? scheduledTime;

        // Parse scheduled time
        try {
          scheduledTime = DateTime.parse(scheduledTimeString);
        } catch (e) {
          log("Error parsing scheduledTime: $e");
          continue; // Skip this recipe if parsing fails
        }

        // Determine the label for the day
        String dayLabel;
        if (scheduledTime.year == today.year &&
            scheduledTime.month == today.month &&
            scheduledTime.day == today.day) {
          dayLabel = 'اليوم'; // If scheduled for today
        } else {
          dayLabel = DateFormat.EEEE('ar_SA').format(scheduledTime); // Arabic weekday
        }

        // Add recipe to the appropriate group
        groupedRecipes.putIfAbsent(dayLabel, () => []).add(recipe);
      }

      groupedWeekRecipes.value = groupedRecipes;
    } catch (e) {
      return;
    }
  }

  /// Update recipe schedule (or schedule a new one)
  Future<void> updateRecipeSchedule(String recipeId, DateTime scheduledTime) async {
    try {
      await _firebaseServices.updateRecipeSchedule(recipeId, scheduledTime);

      // Refresh all data after updating
      await fetchUnscheduledRecipes();
      await fetchDayRecipes(DateTime.now());
      await fetchWeekRecipes(getStartOfWeek(DateTime.now()));
    } catch (e) {
      log("Error updating recipe schedule: $e");
    }
  }

  /// Get the start of the week for a given date
  DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1)); // Adjust to Monday as the start
  }
}
