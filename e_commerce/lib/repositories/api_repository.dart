import 'base_repository.dart';
import '../models/product.dart';

class ApiRepository implements BaseRepository<Product> {
  final String baseUrl;
  
  ApiRepository({required this.baseUrl});

  @override
  Future<List<Product>> getAll() async {
    // TODO: Implement actual API call
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<Product?> getById(int id) async {
    // TODO: Implement actual API call
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<Product> create(Product item) async {
    // TODO: Implement actual API call
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<Product> update(Product item) async {
    // TODO: Implement actual API call
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<bool> delete(int id) async {
    // TODO: Implement actual API call
    throw UnimplementedError('API implementation pending');
  }
} 