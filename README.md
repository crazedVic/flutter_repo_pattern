# Prototyping Without a Backend

The fact of the matter is, building apps is time consuming and expensive.  Imagine you’re building something new and different; oftentimes as the product comes together, many tweaks are made along the way to get it “just right”.  These tweaks will originate from feedback offered by future customers, and even you testing your own assumptions.  More often than not, the app you eventually end up with is not anywhere near what you envisioned it to be, and this is almost always a good thing.  And expensive.  And time consuming.

With rich client frameworks like Flutter, however, you can focus on just the product that people use, and worry about building all the behind the scenes technology after your product feels “done”.  A few years ago I built a prototype for a client where they were convinced the product was ready to ship.  The fact was that behind that mobile app there was actually nothing, no database, no services, nothing.  And yet, the product felt good, felt complete.  But it was a long road getting there, with tons of small and big tweaks.  If I had been required to iterate on not just the app but all the supporting backend services, it would have taken 6 months, not 6 weeks.  And at least four times the cost.

So now that I’ve explained the why, let’s look at the how.  For this demonstration I’ll be using Flutter, Provider for state management, and the Repository pattern.  What is the repository pattern?  It basically creates a bridge between the app you see and the data that drives the app.  And that bridge can be rotated to different sources, one where the data lives on the device or one where the data lives on the cloud.  The app itself, the part you see, doesn’t know nor care about that.  It asks for data, and it gets it, no questions asked.  That’s the beauty of the repository pattern.  Let’s see how it breaks down.

For sake of cleanliness, I’ll be using a folder structure inspired by clean architecture, which splits the app into 3 parts - the data, the domain and the presentation.  The domain will contain the contract, the presentation will contain the parts you see when you launch the app, and the data will handle, well, the data.

First I’ll create a constant variable in a shared/data file that will tell the repository where the data will live, for prototyping this will be local, and later, when we are ready to build out the backend services, we can switch it to api.
```
const DataSource dataAccessMode = DataSource.localdb;
enum DataSource {
  localdb,
  api
}
```

Then we create the repository contract, this lives in domain/repositories
```
abstract class IRepository<T> {
  Future<List<T>> getAll();
}
```

Now we implement this interface in data/repositories.  You can see here I’ll have the bridge pointable to a REST Api and a Sqlite local database using package sqfilte.  For now we will use DataSource.localdb.
```
lass RecipeRepository implements IRepository<Recipe>{
  final RecipeApi recipeApi;
  final RecipeDao recipeDao;

  RecipeRepository({required this.recipeApi, required this.recipeDao});

  @override
  Future<List<Recipe>> getAll() async {
    switch(dataAccessMode) {
      case DataSource.localdb:
        return await recipeDao.selectAll();
      case DataSource.api:
        return await recipeApi.getRecipes();
    }
  }
}
```

Now we implement the sqlite datasource (one could choose to use SharedPreferences instead here) in data/sources:
```
abstract class BaseDao {
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

class RecipeDao extends BaseDao{

  Future<List<Recipe>> selectAll() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(BaseDao.recipeTableName);
    return List.generate(maps.length, (i) => Recipe.fromRow(maps[i]));
  }
}
```

Ok now that we have our sqlite datasource, we’ve set up our repository to pull the data from here, and we’ve established the interface, we can create the Recipe entity in domain/entities.
```
class Recipe{
  final String title;
  final String ingredients;
  final String servings;
  final String instructions;

Recipe({required this.title, required this.ingredients, required this.servings, required this.instructions}); }

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
And to manage state in the presentation layer, we now create the class to manage state in presentation/providers.
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

As you can see, the only class that is aware of where the data actually lives is the Repository class, the rest of the application exists in ignorant bliss.  Finally we create the main screen in presentation/screens using Provider to manage the state.
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
                    recipeApi: RecipeApi(),
                    recipeDao: RecipeDao()
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

