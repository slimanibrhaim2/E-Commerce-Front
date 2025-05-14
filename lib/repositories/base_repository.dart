abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(int id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<bool> delete(int id);
} 