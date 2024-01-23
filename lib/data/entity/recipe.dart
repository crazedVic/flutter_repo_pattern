class Recipe{
  // if the json name is different, use JsonKey to map it to the class property
  final String title;
  final String ingredients;
  final String servings;
  final String instructions;
  factory Recipe.fromJson(Map<String, dynamic> json) =>
      recipeFromJson(json);
  static Recipe recipeFromJson(Map<String, dynamic> json) => Recipe(
    title: json['title'] as String,
    ingredients: json['ingredients'] as String,
    servings: json['servings'] as String,
    instructions: json['instructions'] as String,
  );

  static Map<String, dynamic> recipeToJson(Recipe instance) => <String, dynamic>{
    'title': instance.title,
    'ingredients': instance.ingredients,
    'servings': instance.servings,
    'instructions': instance.instructions,
  };
  Recipe({required this.title, required this.ingredients, required this.servings, required this.instructions}); // this method lives in the generated class file ***.g.dart
}