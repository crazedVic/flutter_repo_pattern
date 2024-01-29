import 'dart:convert';

import '../../../domain/entities/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeCache {
  static const String _recipesKey = 'recipes';

  Future<List<Recipe>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the string stored in shared preferences
    final String? recipesJson = prefs.getString(_recipesKey);

    if (recipesJson == null) {
      // Handle the case where there are no recipes stored
      return [];
    }

    // Decode the JSON string into a List of Maps
    final List<dynamic> recipesList = json.decode(recipesJson);

    // Filter the recipes based on the search term and convert them to Recipe objects
    return recipesList
        .map((recipeMap) => Recipe.fromJson(recipeMap))
      //  .where((recipe) => recipe.title.contains(search)) // Assuming Recipe has a 'name' field
        .toList();
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert the list of recipes to a JSON string
    final String recipesJson = json.encode(recipes.map((recipe) =>
        Recipe.recipeToJson(recipe)).toList());

    // Save the JSON string in shared preferences
    await prefs.setString(_recipesKey, recipesJson);
  }
}