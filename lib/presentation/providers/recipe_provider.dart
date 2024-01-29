import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../domain/entities/recipe.dart';


class RecipeProvider with ChangeNotifier {
  bool _isLoading = false;
  String _searchTerm = "noodles";
  final RecipeRepository _repository;
  List<Recipe> _recipes = [];

  RecipeProvider(this._repository){
    initialLoad();
  }

  bool get isLoading => _isLoading;
  List<Recipe> get recipes => _recipes;

  Future<void> initialLoad() async {
    final prefs = await SharedPreferences.getInstance();
    _searchTerm = prefs.getString("searchTerm") ?? "noodles";
    fetchRecipes(_searchTerm);
  }

  Future<void> fetchRecipes(String search) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("searchTerm", search);
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
