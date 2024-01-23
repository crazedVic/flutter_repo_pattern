import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import '../data/entity/recipe.dart';
import '../data/repository/recipe_repository.dart';
import '../data/network/api_client.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Provider<RecipeRepository>(create: (_) => RecipeRepository(
          apiClient: ApiClient(baseUrl: baseUrl, apiKey: apiKey)
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipes")),
      body: FutureBuilder<List<Recipe>>(
        future: Provider.of<RecipeRepository>(context).getRecipes(search: "noodles"),
        builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
          if (snapshot.hasData){
              //actual data returned, now to display it in a list view
            return ListView.separated(
                itemBuilder: (context, index) {
                  final recipe = snapshot.data![index];
                  return ListTile(
                    leading: const SizedBox(
                      width:48,
                      height:48.0,
                      child: ClipOval(
                        child: Placeholder(),// Image.network('https://www.clker.com/cliparts/k/v/A/g/l/E/recipe-icon.svg'),
                      ),
                    ),
                    title: Text(recipe.title)
                  );
                },
                separatorBuilder:(context, index) => const Divider(),
                itemCount: snapshot.data!.length);
          }
          else if (snapshot.hasError){
            return Center(
              child: Text("error occurred ${snapshot.error.toString()}"),
            );
          }
          else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },

      )
    );
  }
}

