import 'package:flutter/cupertino.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../domain/entities/recipe.dart';

class RecipeProvider with ChangeNotifier {
  bool _isLoading = false;
  final RecipeRepository _repository;
  List<Recipe> _recipes = [];

  RecipeProvider(this._repository){
    initialLoad();
  }
  bool get isLoading => _isLoading;
  List<Recipe> get recipes => _recipes;

  Future<void> initialLoad() async {
    fetchRecipes();
  }

  Future<void> fetchRecipes({String search = ""}) async {
    _isLoading = true;
    notifyListeners();

    _recipes = await _repository.getAll(search: search);

    _isLoading = false;
    notifyListeners();
  }
}
