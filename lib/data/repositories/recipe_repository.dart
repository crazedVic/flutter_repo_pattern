import 'package:flutter/material.dart';
import 'package:repopattern/domain/repositories/i_repository.dart';
import 'package:repopattern/shared/data.dart';
import '../sources/database/recipe_dao.dart';
import '../../domain/entities/recipe.dart';
import '../sources/api/recipe_api.dart';

class RecipeRepository extends ChangeNotifier implements IRepository<Recipe>{
  final RecipeApi recipeApi;
  final RecipeDao recipeDao;

  RecipeRepository({required this.recipeApi, required this.recipeDao});

  @override
  Future<List<Recipe>> getAll({String search = "noodles"}) async {

    if (dataAccessMode == DataSource.localdb) {
      return await recipeDao.selectAll();
    }
    else {
      return await recipeApi.getRecipes(search);
    }
  }

  @override
  Future<List<Recipe>> sync() async {
    final recipes = await recipeApi.getRecipes("tomato");
    recipeDao.insertAll(recipes);
    notifyListeners();
    return await recipeDao.selectAll();
  }
}