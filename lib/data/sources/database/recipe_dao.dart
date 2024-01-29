import 'package:repopattern/data/sources/database/base_dao.dart';
import '../../../domain/entities/recipe.dart';

class RecipeDao extends BaseDao{
  Future<List<Recipe>> selectAll() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(BaseDao.recipeTableName);
    return List.generate(maps.length, (i) => Recipe.fromRow(maps[i]));
  }

  Future<void> insertAll(List<Recipe> recipes) async {
    final db = await getDatabase();
    final batch = db.batch();
    batch.delete(BaseDao.recipeTableName);
    for (final recipe in recipes){

      batch.insert(BaseDao.recipeTableName, recipe.toRow());
    }
    await batch.commit();

  }
}