import 'dart:convert';
import 'dart:io';
import '../../../domain/entities/recipe.dart';
import 'package:http/http.dart' as http;
class RecipeApi {
  final String baseUrl;
  final String apiKey;

  RecipeApi({required this.baseUrl, required this.apiKey});

  Future<List<Recipe>> getRecipes({String search = ""}) async {
    try {
      // unfortunately this api requires a search string
      final queryParameters = {
        'query': search == "" ? "noodles":search,
        'offset': '0',
      };
      final uri =
      Uri.https(baseUrl, '/v1/recipe', queryParameters);
      final response = await http.get(uri,
          headers: {
            'X-Api-Key': apiKey,
          });
        if(response.statusCode < 300) {
          Iterable list = json.decode(response.body);
          List<Recipe> recipes;
          recipes = list.map((model) => Recipe.fromJson(model)).toList();
          return recipes;
        } else {
          throw Exception("could not parse response");
        }
    }
    on HttpException catch (e) {
        throw HttpException(e.message);
    }
  }
}