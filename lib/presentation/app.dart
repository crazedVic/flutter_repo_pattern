import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import '../data/database/recipe_dao.dart';
import '../data/entity/recipe.dart';
import '../data/repository/recipe_repository.dart';
import '../data/api/recipe_api.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Provider<RecipeRepository>(create: (_) => RecipeRepository(
          recipeApi: RecipeApi(baseUrl: baseUrl, apiKey: apiKey),
          recipeDao: RecipeDao()
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
        actions: serverless ? [
          TextButton(
            onPressed: () {
              Provider.of<RecipeRepository>(context, listen:false).sync();
            },
            child: const Text(
              'Sync',
              style: TextStyle(
                color: Colors.black, // Text color (use a contrasting color for better visibility)
              ),
            ),
          ),
        ] : [],
        title: const Text("Recipes ${serverless? "[Offline]" : "[Online]"}")),
      body: FutureBuilder<List<Recipe>>(
        future: Provider.of<RecipeRepository>(context).getRecipes(search: "noodles"),
        builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
          if (snapshot.hasData){
              //actual data returned, now to display it in a list view
            return ListView.separated(
                itemBuilder: (context, index) {
                  final recipe = snapshot.data![index];
                  return ListTile(
                    leading:  SizedBox(
                      width:48,
                      height:48.0,
                      child: ClipOval(
                        child: Image.network("https://picsum.photos/250?image=55"),
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

