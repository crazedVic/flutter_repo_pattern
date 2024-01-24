import 'package:repopattern/data/database/base_dao.dart';

import '../entity/recipe.dart';

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
    for (final recipe in recipes){
      batch.delete(BaseDao.recipeTableName);
      batch.insert(BaseDao.recipeTableName, recipe.toRow());
    }
    await batch.commit();
  }
}