import 'package:repopattern/data.dart';

import '../database/recipe_dao.dart';
import '../entity/recipe.dart';
import '../api/recipe_api.dart';

class RecipeRepository{
  final RecipeApi recipeApi;
  final RecipeDao recipeDao;

  RecipeRepository({required this.recipeApi, required this.recipeDao});

  Future<List<Recipe>> getRecipes({String search = "soup"}) async {

    if (serverless) {
      return await recipeDao.selectAll();
    }
    else {
      return await recipeApi.getRecipes(search);
    }

  }
}