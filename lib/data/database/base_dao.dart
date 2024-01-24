import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
          title TEXT PRIMARY KEY NOT NULL,
          ingredients TEXT NOT NULL,
          servings TEXT NOT NULL,
          instructions TEXT NOT NULL);
        '''
    );
  }

}