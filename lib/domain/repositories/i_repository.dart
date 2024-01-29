abstract class IRepository<T> {
  Future<List<T>> getAll({String search = ""});
  Future<List<T>> sync({String search = ""});
}
