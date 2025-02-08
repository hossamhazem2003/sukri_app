import 'package:sukri/core/routes/app_routes.dart';
import 'package:sukri/core/utils/app_assets.dart';
import 'package:sukri/core/utils/app_colors.dart';
import 'package:sukri/model/models/recipe_model.dart';
import 'package:sukri/view%20model/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:sukri/view/widgets/favourit_card.dart';

class HomeTab extends StatefulWidget {
  final MainTabsController controller;
  const HomeTab({super.key, required this.controller});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Section
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage(FitnessAssets.person),
                radius: 25,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder(
                    valueListenable: widget.controller.currentUser,
                    builder: (context, user, _) {
                      if (user == null) {
                        return const Center(
                            child: Text("Loading user data..."));
                      }
                      return Text(
                        "مرحباً ${user.firstName} ${user.lastName}",
                        maxLines: 2,
                        softWrap: true,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const Text(
                    'نتمنى لك يوماً صحياً',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tools Section
          const Text(
            'الأدوات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Buttons for Tools
          Row(
            children: [
              Expanded(
                child: buildFeatureCard(
                  "حساب السعرات اليومية",
                  FitnessAssets.calc,
                  FitnessColors.buttonsColor,
                  () {
                    Navigator.pushNamed(context, AppRoutes.calorieCalculationScreen);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: buildFeatureCard(
                  "مواعيد الوجبات",
                  FitnessAssets.clock,
                  FitnessColors.buttonsColor,
                  () {
                    debugPrint("Navigating to meal schedule.");
                    Navigator.pushNamed(context, AppRoutes.timedRecipeScreen);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Favorites Section
          const Text(
            'المفضلة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Favorites List
          ValueListenableBuilder<bool>(
            valueListenable: widget.controller.isLoadingFavorites,
            builder: (context, isLoadingFavorites, _) {
              if (isLoadingFavorites) {
                return const Center(child: CircularProgressIndicator());
              }

              return ValueListenableBuilder<List<Recipe>>(
                valueListenable: widget.controller.recipes,
                builder: (context, allRecipes, _) {
                  return ValueListenableBuilder<List<String>>(
                    valueListenable: widget.controller.favoriteRecipes,
                    builder: (context, favoriteRecipeIds, _) {
                      // Filter the recipes to match favorites
                      List<Recipe> favoriteRecipes = allRecipes
                          .where(
                              (recipe) => favoriteRecipeIds.contains(recipe.id))
                          .toList();

                      if (favoriteRecipes.isEmpty) {
                        return const Center(
                            child: Text('لا يوجد وصفات مفضلة بعد'));
                      }

                      return Column(
                        children: favoriteRecipes.map((recipe) {
                          return buildFavoriteCard({
                            'name': recipe.name,
                            'calories': recipe.calories,
                            'time': recipe.time,
                            'id': recipe.id,
                          },context);
                        }).toList(),
                      );
                    },
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}

// Feature Card for Tools
Widget buildFeatureCard(
    String title, String asset, Color backgroundColor, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 140,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            asset,
            height: 75,
            width: 75,
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}