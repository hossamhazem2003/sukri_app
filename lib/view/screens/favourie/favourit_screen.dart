import 'package:flutter/material.dart';
import 'package:sukri/core/utils/app_colors.dart';
import 'package:sukri/model/models/recipe_model.dart';
import 'package:sukri/view%20model/favourite_controller.dart';
import 'package:sukri/view/widgets/favourit_card.dart';

class FavouritScreen extends StatefulWidget {
  const FavouritScreen({super.key});

  @override
  State<FavouritScreen> createState() => _FavouritScreenState();
}

class _FavouritScreenState extends State<FavouritScreen> {
  late final FavouriteController favouriteController;
  @override
  void initState() {
    favouriteController = FavouriteController(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: FitnessColors.baseAppColor,
        appBar: AppBar(
          backgroundColor: FitnessColors.baseAppColor,
          title: const Text('الوصفات المفضلة',style: TextStyle(fontSize: 25,color: Colors.black,fontWeight: FontWeight.bold),),
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
        ),
        body: ValueListenableBuilder<bool>(
          valueListenable: favouriteController.isLoadingFavorites,
          builder: (context, isLoadingFavorites, _) {
            if (isLoadingFavorites) {
              return const Center(child: CircularProgressIndicator());
            }
            return ValueListenableBuilder<List<Recipe>>(
              valueListenable: favouriteController.recipes,
              builder: (context, allRecipes, _) {
                return ValueListenableBuilder<List<String>>(
                  valueListenable: favouriteController.favoriteRecipes,
                  builder: (context, favoriteRecipeIds, _) {
                    // Filter the recipes to match favorites
                    List<Recipe> favoriteRecipes = allRecipes
                        .where(
                            (recipe) => favoriteRecipeIds.contains(recipe.id))
                        .toList();
                    //1 2 3 4 5 allRecipes
                    // 2 4 favourites

                    if (favoriteRecipes.isEmpty) {
                      return const Center(
                          child: Text('لا يوجد وصفات مفضلة بعد'));
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: favoriteRecipes.map((recipe) {
                          return Padding(
                            padding: const EdgeInsets.only(left:8.0, right:8.0),
                            child: buildFavoriteCard({
                              'name': recipe.name,
                              'calories': recipe.calories,
                              'time': recipe.time,
                              'id': recipe.id,
                            }, context),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
