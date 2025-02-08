import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:sukri/core/routes/app_routes.dart';
import 'package:sukri/core/utils/app_colors.dart';
import 'package:sukri/model/models/recipe_model.dart';
import 'package:sukri/view%20model/recipe_details_controller.dart';
import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String? recipeId;
  final bool? fromScheledTime;
  const RecipeDetailsScreen({super.key, this.recipeId, this.fromScheledTime});

  @override
  _RecipeDetailsScreenState createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen>
    with SingleTickerProviderStateMixin {
  final RecipeDetailsController controller = RecipeDetailsController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool? _fromScheledTime; 

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    controller.fetchRecipeDetails(widget.recipeId!);

    _fromScheledTime = widget.fromScheledTime; // حفظ القيمة عند بدء التشغيل
    debugPrint('recipe id is: ${widget.recipeId}');
    debugPrint('bool is: $_fromScheledTime');
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.caloriesController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final appBarHeight = AppBar().preferredSize.height;
  final topPadding = MediaQuery.of(context).padding.top;
  
  return Directionality(
    textDirection: TextDirection.rtl,
    child: ValueListenableBuilder<Recipe?>(
      valueListenable: controller.recipeDetails,
      builder: (context, recipeDetails, _) {
        if (recipeDetails == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Container(),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: FitnessColors.arrowBackButton,
                    textDirection: TextDirection.ltr,
                  ),
                  onPressed: _handleBackButton,
                ),
              ],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: FitnessColors.baseAppColor,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: FitnessColors.arrowBackButton,
                  textDirection: TextDirection.ltr,
                ),
                onPressed: _handleBackButton,
              ),
            ],
          ),
          body: SizedBox(
            height: screenHeight - appBarHeight - topPadding,
            child: Column(
              children: [
                SizedBox(
                  height: (screenHeight - appBarHeight - topPadding) * 0.45,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          recipeDetails.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _buildActionButtons(recipeDetails),
                        Expanded(
                          child: _buildIngredientsList(recipeDetails.ingredients),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInstructions(recipeDetails),
                          const SizedBox(height: 20),
                          _buildRecipeMetadata(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildActionButtons(Recipe recipeDetails) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: controller.isFavorite,
          builder: (context, isFavorite, _) {
            return GestureDetector(
              onTap: () {
                controller.toggleFavorite();
                if (isFavorite) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }
              },
              child: SizedBox(
                width: 30,
                height: 30,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                    size: 30,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 5),
        ValueListenableBuilder<bool>(
          valueListenable: controller.isTimed,
          builder: (context, isTimed, _) {
            return GestureDetector(
              onTap: () {
                controller.toggleTimedRecipe();
                if (isTimed) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }
              },
              child: SizedBox(
                width: 30,
                height: 30,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    Icons.date_range,
                    color: isTimed ? Colors.blue : Colors.black,
                    size: 30,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildIngredientsList(List<Ingredient> grams) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'المقادير:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: grams.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: buildIngredientCard(
                '${grams[index].grams} جرام من ${grams[index].name}',
              ),
            );
          },
        ),
      ),
    ],
  );
}  // دالة التعامل مع زر الرجوع
  void _handleBackButton() {

    if (_fromScheledTime == true) {
      Navigator.pop(context);
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.pushReplacementNamed(context, AppRoutes.mainContentScreen);
      });
    }
  }


  Widget _buildInstructions(Recipe recipeDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "طريقة التحضير:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: controller.isExpanded,
          builder: (context, isExpanded, _) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: isExpanded
                  ? recipeDetails.preparationSteps.length
                  : min(2, recipeDetails.preparationSteps.length),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(recipeDetails.preparationSteps[index]),
                );
              },
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: controller.isExpanded,
          builder: (context, isExpanded, _) {
            return TextButton(
              onPressed: controller.toggleExpanded,
              child: Text(
                isExpanded ? "إخفاء النص" : "اقرأ المزيد",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecipeMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<Recipe?>(
          valueListenable: controller.recipeDetails,
          builder: (context, recipe, _) {
            if (recipe == null) return const SizedBox();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "عدد الأشخاص: ${recipe.servings}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "السعرات الحرارية: ${recipe.calories}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "مدة التحضير: ${recipe.time}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text(
              "تحديث المقادير",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: controller.caloriesController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onChanged: controller.onCaloriesChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<bool>(
          valueListenable: controller.showUpdateButton,
          builder: (context, showUpdateButton, _) {
            if (!showUpdateButton) return const SizedBox();
            return Center(
              child: ElevatedButton(
                onPressed: controller.updateGrams,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitnessColors.buttonsColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "تحديث المقادير",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildIngredientCard(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width / 2.5,
      decoration: BoxDecoration(
        color: FitnessColors.buttonsColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: AutoSizeText(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          textAlign: TextAlign.center,
          maxLines: 3,
          minFontSize: 10,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
