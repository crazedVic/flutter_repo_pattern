import 'package:repopattern/shared/data.dart';

import '../sources/database/recipe_dao.dart';
import '../../domain/entities/recipe.dart';
import '../sources/api/recipe_api.dart';

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

  Future<List<Recipe>> sync() async {
    final recipes = await recipeApi.getRecipes("soup");
    recipeDao.insertAll(recipes);
    return await recipeDao.selectAll();
  }
}