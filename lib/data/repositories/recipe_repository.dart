import '../../domain/repositories/i_repository.dart';
import '../../shared/data.dart';
import '../sources/cache/recipe_cache.dart';
import '../sources/database/recipe_dao.dart';
import '../../domain/entities/recipe.dart';
import '../sources/api/recipe_api.dart';

class RecipeRepository implements IRepository<Recipe>{
  final RecipeApi recipeApi;
  final RecipeDao recipeDao;
  final RecipeCache recipeCache;

  RecipeRepository({required this.recipeApi, required this.recipeDao, required this.recipeCache});

  @override
  Future<List<Recipe>> getAll() async {

    switch(dataAccessMode) {
      case DataSource.localdb:
        return await recipeDao.selectAll();
      case DataSource.api:
        return await recipeApi.getRecipes();
      case DataSource.cache:
        return await recipeCache.getRecipes();
    }
  }

}