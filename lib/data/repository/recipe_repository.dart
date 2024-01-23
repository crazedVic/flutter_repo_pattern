import '../entity/recipe.dart';
import '../network/api_client.dart';

class RecipeRepository{
  final ApiClient apiClient;

  RecipeRepository({required this.apiClient});

  Future<List<Recipe>> getRecipes({String search = "soup"}) async {
    final response = await apiClient.getRecipes(search);
    return response;
  }
}