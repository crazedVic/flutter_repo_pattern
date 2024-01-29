import 'package:flutter/cupertino.dart';

import '../../data/repositories/recipe_repository.dart';
import '../../domain/entities/recipe.dart';


class RecipeProvider with ChangeNotifier {
  bool _isLoading = false;
  String _searchTerm = "noodles";
  final RecipeRepository _repository;
  List<Recipe> _recipes = [];

  RecipeProvider(this._repository){
    _searchTerm = "noodles";
    fetchRecipes(_searchTerm);
  }

  bool get isLoading => _isLoading;
  List<Recipe> get recipes => _recipes;

  Future<void> fetchRecipes(String search) async {
    _searchTerm = search;
    _isLoading = true;
    notifyListeners();

    _recipes = await _repository.getAll(search: search);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sync() async {
    _recipes = await _repository.sync(search: _searchTerm);
    notifyListeners();
  }
}
