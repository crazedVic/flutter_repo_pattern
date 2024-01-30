# Prototyping Without a Backend

The fact of the matter is, building apps is time consuming and expensive.  Imagine you’re building 
something new and different; oftentimes as the product comes together, many tweaks are made 
along the way to get it “just right”.  These tweaks will originate from feedback offered by future 
customers, and even you testing your own assumptions.  More often than not, the app you eventually 
end up with is not anywhere near what you envisioned it to be, and this is almost always a 
good thing.  And expensive.  And time consuming.

With rich client frameworks like Flutter, however, you can focus on just the product that people 
use, and worry about building all the behind the scenes technology after your product feels 
“done”.  A few years ago, after many iterations, feedback and builds, I completed a prototype 
mobile app for a client.  It seemed so functionally complete, I had difficulty convincing them that 
it was not actually "ready to ship".  In fact, behind that app there was actually nothing; no 
database, no services, nothing.  And yet the product felt good, felt complete.  Had I set up all these 
backend services, it would have taken 3x the time and 4x the cost.  And the best part, I could now 
focus on just building out the backend in one shot, no longer having to worry about any further
feature creep or changes in functionality, saving time and money.

So now that I’ve explained the "why", let’s examine the "how".  For this demonstration I’ll be developing 
a mobile application using the [Flutter](https://flutter.dev/) framework, with 
the [Provider](https://pub.dev/packages/provider) package for state management, and the 
[Repository Pattern](https://deviq.com/design-patterns/repository-pattern).  What is the 
repository pattern?  It basically creates a bridge between the app you see and the data that drives 
the app.  And that bridge can be rotated to different sources, one where the data lives on the device or 
one where the data lives on the cloud.  The app itself, the part you see, doesn't know nor care 
about that.  It asks for data, and it gets it, no questions asked.  That’s the beauty of the 
Repository Pattern.  Let’s see how it breaks down.

For sake of cleanliness, I’ll be using a folder structure inspired by [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html), which 
splits the app into 3 parts - the **Data**, the **Domain** and the **Presentation**.  The Domain will contain 
the contracts and the business entities, the Presentation will contain the parts you see when 
you launch the app, and the Data will handle, well, the data.

First I’ll create a constant variable in a _shared/data.dart_ file that will tell the repository 
where the data will live. For prototyping we will use local data, and later, when we are ready 
to build out the backend services, we can switch it to API.
```
const DataSource dataAccessMode = DataSource.localdb;
enum DataSource {
  localdb,
  API
}
```

Then we create the repository contract using [generics](https://dart.dev/language/generics) <T> so 
that we can use it for all entities not just Recipe, this lives in _domain/repositories_.
```
abstract class IRepository<T> {
  Future<List<T>> getAll();
}
```

Now we implement this interface in _data/repositories_.  You can see here I’ll have the 
bridge pointing to a REST API and a Sqlite local database using package 
_[sqfilte](https://pub.dev/packages/sqflite)_.  For now we will use DataSource.localdb.
```
class RecipeRepository implements IRepository<Recipe>{
  final RecipeAPI recipeAPI;
  final RecipeDAO recipeDAO; //Data Access Object

  RecipeRepository({required this.recipeAPI, required this.recipeDAO});

  @override
  Future<List<Recipe>> getAll() async {
    switch(dataAccessMode) {
      case DataSource.localdb:
        return await recipeDAO.selectAll();
      case DataSource.API:
        return await recipeAPI.getRecipes();
    }
  }
}
```

Now we implement the sqlite datasource (one could choose to use 
SharedPreferences instead here) in _data/sources_:
```
abstract class BaseDAO {
  static const databaseName = "database.sqlite";
  static const recipeTableName = "recipes";

  @protected
  Future<Database> getDatabase() async {
    return openDatabase(join(await getDatabasesPath(), databaseName),
    onCreate: (db, version) async {
      final batch = db.batch(); // transaction begin
      _createRecipeTable(batch);
      await batch.commit(); // transaction commit
    },
    version: 1);
  }

  void _createRecipeTable(Batch batch){
    batch.execute(
        '''
          CREATE TABLE $recipeTableName(
          title TEXT NOT NULL,
          ingredients TEXT NOT NULL,
          servings TEXT NOT NULL,
          instructions TEXT NOT NULL);
        '''
    );
  }
}

class RecipeDAO extends BaseDAO{

  Future<List<Recipe>> selectAll() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(BaseDAO.recipeTableName);
    return List.generate(maps.length, (i) => Recipe.fromRow(maps[i]));
  }
}
```

Ok now that we have our sqlite datasource, we’ve set up our repository to pull the data 
from here, and we’ve established the interface, we can create the Recipe entity in _domain/entities_.
```
class Recipe{
  final String title;
  final String ingredients;
  final String servings;
  final String instructions;

Recipe({required this.title, 
    required this.ingredients, 
    required this.servings, 
    required this.instructions}); }

  Recipe.fromRow(Map<String, dynamic> map)
    : title = map['title'] as String,
    ingredients = map['ingredients'] as String,
    servings = map['servings'] as String,
    instructions = map['instructions'] as String;

  Map<String, dynamic> toRow() => {
    'title': title,
    'ingredients': ingredients,
    'servings': servings,
    'instructions': instructions,
  };
}
```
And to manage state in the presentation layer, we now create the class 
to manage state in _presentation/providers_.
```
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

  Future<void> fetchRecipes() async {
    _isLoading = true;
    notifyListeners();
    _recipes = await _repository.getAll();
    _isLoading = false;
    notifyListeners();
  }
}
```

As you can see, the only class that is aware of where the data actually lives
is the RecipeRepository class, the rest of the application exists in ignorant bliss.  Finally 
we create the main screen in _presentation/screens_ using Provider to manage the state.
```
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return
      ChangeNotifierProvider(
        create: (context) =>
            RecipeProvider(
                RecipeRepository(
                    recipeAPI: RecipeAPI(),
                    recipeDAO: RecipeDAO()
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipes "),
      ),
      body: Column(
        children: [
          const SizedBox(),
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (BuildContext context, recipeProvider, child) {
                if (recipeProvider.isLoading) {
                    return const Center(
                    child: CircularProgressIndicator(),
                    );
                }
                else{
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

class RecipeTile extends StatelessWidget {
  const RecipeTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:48,
      height:48.0,
      child: ClipOval(
        child: Image.network("https://picsum.photos/250?image=55"),
      ),
    );
  }
}
```
The only thing that remains is to replace the default code in _main.dart_ with this:
```
import 'package:flutter/material.dart';
import 'presentation/screens/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
```
The Repository Pattern, in tandem with Clean Architecture and Provider, keeps 
the code clean and easy to update/maintain when building a backend-less prototype. 
Backend-less prototyping means you can iterate faster, cheaper and every change 
you make will most likely be something the client can see and experience, and appreciate. 
