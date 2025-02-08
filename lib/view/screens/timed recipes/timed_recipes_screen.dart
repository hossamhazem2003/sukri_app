// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sukri/core/utils/app_colors.dart';
import 'package:sukri/view%20model/timed_recipe_controller.dart';
import 'package:sukri/view/screens/recipe%20details/recipe_details_screen.dart';

class TimedRecipesScreen extends StatefulWidget {
  const TimedRecipesScreen({super.key});

  @override
  _TimedRecipesScreenState createState() => _TimedRecipesScreenState();
}

class _TimedRecipesScreenState extends State<TimedRecipesScreen> {
  final TimedRecipeController _controller = TimedRecipeController();
  bool _isLoading = false; // Track loading state

  Future<void> _scheduleRecipe(String recipeId) async {
    // Step 1: Pick a date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Step 2: Pick a time
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine date and time into a single DateTime object
        DateTime scheduledDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Show loading spinner
        setState(() {
          _isLoading = true;
        });

        // Schedule the recipe with the selected date and time
        await _controller.updateRecipeSchedule(recipeId, scheduledDateTime);

        // Refresh data
        await _controller.fetchUnscheduledRecipes();

        // Hide loading spinner
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: FitnessColors.baseAppColor,
          appBar: AppBar(
            title: const Text(
              "مخطط الوجبات",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            centerTitle: true,
            leading: Container(),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: FitnessColors.arrowBackButton,
                  textDirection: TextDirection.ltr,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
            backgroundColor: FitnessColors.baseAppColor,
            bottom: TabBar(
              dividerColor: FitnessColors.baseAppColor,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              indicatorColor: FitnessColors.buttonsColor,
              tabs: const [
                Tab(text: "غير مجدولة"),
                Tab(text: "اليوم"),
                Tab(text: "الأسبوع"),
              ],
            ),
          ),
          body: Stack(
            children: [
              // Main content (tabs)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TabBarView(
                  children: [
                    _buildUnscheduledRecipes(),
                    _buildDayRecipes(),
                    _buildWeekRecipes(),
                  ],
                ),
              ),

              // Loading overlay
              if (_isLoading)
                Container(
                  color:
                      Colors.black.withOpacity(0.5), // Semi-transparent overlay
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          FitnessColors.buttonsColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnscheduledRecipes() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _controller.unscheduledRecipes,
      builder: (context, recipes, _) {
        if (recipes.isEmpty) {
          return const Center(child: Text("لا توجد وصفات غير مجدولة"));
        }
        return ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            final recipeName = recipe['resipeName'] ?? 'وصفة غير معروفة';
            final recipeId = recipe['recipeId'] ?? '';

            return _buildRecipeCard(recipeName, null, recipeId);
          },
        );
      },
    );
  }

  Widget _buildDayRecipes() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _controller.dayRecipes,
      builder: (context, recipes, _) {
        if (recipes.isEmpty) {
          return const Center(child: Text("لا توجد وصفات مجدولة لهذا اليوم"));
        }
        return ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            final recipeName = recipe['resipeName'] ?? 'وصفة غير معروفة';
            final recipeId = recipe['recipeId'] ?? '';
            final scheduledTimeString = recipe['scheduledTime'];

            DateTime? scheduledTime;
            if (scheduledTimeString != null) {
              scheduledTime = DateTime.parse(scheduledTimeString);
            }

            return _buildRecipeCard(recipeName, scheduledTime, recipeId);
          },
        );
      },
    );
  }

  Widget _buildWeekRecipes() {
    return ValueListenableBuilder<Map<String, List<Map<String, dynamic>>>>(
      valueListenable: _controller.groupedWeekRecipes,
      builder: (context, groupedRecipes, _) {
        if (groupedRecipes.isEmpty) {
          return const Center(child: Text("لا توجد وصفات مجدولة لهذا الأسبوع"));
        }

        // Build the UI for grouped recipes
        return ListView(
          children: groupedRecipes.entries.map((entry) {
            String dayLabel = entry.key;
            List<Map<String, dynamic>> recipesForDay = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day label
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    dayLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                // Recipes for this day
                ...recipesForDay.map((recipe) {
                  final recipeName = recipe['resipeName'] ?? 'وصفة غير معروفة';
                  final recipeId = recipe['recipeId'] ?? '';
                  final scheduledTimeString = recipe['scheduledTime'];

                  DateTime? scheduledTime;
                  if (scheduledTimeString != null) {
                    scheduledTime = DateTime.parse(scheduledTimeString);
                  }
                  return _buildRecipeCard(recipeName, scheduledTime, recipeId);
                }),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRecipeCard(
      String recipeName, DateTime? scheduledTime, String recipeId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          log('${true}');
          return RecipeDetailsScreen(
            recipeId: recipeId,
            fromScheledTime: true,
          );
        }));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 4.0),
        child: Container(
          height: 85, // Set a fixed height for the card
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: ListTile(
            title: Text(
              recipeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: scheduledTime != null
                ? Text(
                    "مجدولة لـ: ${intl.DateFormat('h:mm a').format(scheduledTime)}",
                  )
                : const Text("مجدولة لـ: غير محدد"),
            trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.pinkAccent),
                    onPressed: recipeId.isNotEmpty
                        ? () => _scheduleRecipe(recipeId)
                        : null,
                  ),
          ),
        ),
      ),
    );
  }
}
