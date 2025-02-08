import 'package:sukri/core/utils/app_colors.dart';
import 'package:sukri/view%20model/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:sukri/view/widgets/recipe_card.dart';

class RecipeSearchTab extends StatefulWidget {
  final MainTabsController controller;
  const RecipeSearchTab({super.key, required this.controller});

  @override
  _RecipeSearchTabState createState() => _RecipeSearchTabState();
}

class _RecipeSearchTabState extends State<RecipeSearchTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Input Field for Recipe Description
            buildInputField(
              "اكتب وصف للوصفة التي تريدها :",
              widget.controller.descriptionController,
            ),
            const SizedBox(height: 16),

            // Search Button
            ValueListenableBuilder<bool>(
              valueListenable: widget.controller.isLoading,
              builder: (context, isLoading, _) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => widget.controller
                            .searchRecipes(context, widget.controller),
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      backgroundColor: FitnessColors.buttonsColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      isLoading ? 'جاري البحث...' : 'ابدأ البحث',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Recipe Cards Grid
            ValueListenableBuilder<List<RecipeCard>>(
              valueListenable: widget.controller.recipeCards,
              builder: (context, recipeCards, _) {
                return recipeCards.isEmpty
                    ? const Center(
                        child: Text(
                          "لا توجد وصفات للعرض",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: recipeCards.length,
                        itemBuilder: (context, index) {
                          return recipeCards[index];
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build the Input Field Widget
  Widget buildInputField(String label, TextEditingController controller) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: FitnessColors.buttonsColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: FitnessColors.buttonsColor, width: 1.5),
            ),
            child: Center(
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 13, color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  hintText: "ابحث عن الوصفة هنا",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
