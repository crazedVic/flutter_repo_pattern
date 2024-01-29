import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/sources/cache/recipe_cache.dart';
import '../../shared/data.dart';
import '../../data/sources/database/recipe_dao.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/sources/api/recipe_api.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_tile.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return
      // ChangeNotifierProvider<RecipeRepository>(create: (_) => RecipeRepository(
      ChangeNotifierProvider(
        create: (context) =>
            RecipeProvider(
                RecipeRepository(
                    recipeApi: RecipeApi(baseUrl: baseUrl, apiKey: apiKey),
                    recipeDao: RecipeDao(),
                    recipeCache: RecipeCache(),
                )),
      child: const MaterialApp(
        home: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});



  @override
  Widget build(BuildContext context) {
    String searchQuery = 'noodles';
    return Scaffold(
      appBar: AppBar(
        actions: dataAccessMode != DataSource.api ? [
          TextButton(
            onPressed: () {
              Provider.of<RecipeProvider>(context, listen:false).sync();
            },
            child: const Text(
              'Sync',
              style: TextStyle(
                color: Colors.black, // Text color (use a contrasting color for better visibility)
              ),
            ),
          ),
        ] : [],
        title: Text("Recipes "
            "[${dataAccessMode.toString().split('.').last}]")),
      body: Column(
        children: [
          dataAccessMode == DataSource.api ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Update searchQuery here
                  },
                ),
              ),
              onSubmitted: (value) {
                searchQuery = value;
                // Trigger a rebuild to update the FutureBuilder
                Provider.of<RecipeProvider>(context, listen:false).fetchRecipes(searchQuery);
              },
            ),
          ): const SizedBox(),
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (BuildContext context, recipeProvider, child) {
                if (recipeProvider.isLoading) {
                    return const Center(
                    child: CircularProgressIndicator(),
                    );
                }
                else{
                    //actual data returned, now to display it in a list view
                    return ListView.separated(
                        itemBuilder: (context, index) {
                          final recipe = recipeProvider.recipes[index];
                          return ListTile(
                            leading:  const RecipeTile(),
                            title: Text(recipe.title)
                          );
                        },
                        separatorBuilder:(context, index) => const Divider(),
                        itemCount: recipeProvider.recipes.length,);
                }
              },
            
            ),
          ),
        ],
      )
    );
  }
}



