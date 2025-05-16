import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_repository.dart';
import '../models/category.dart';

class CategoryRepository implements BaseRepository<Category> {
  final String baseUrl = 'https://api.escuelajs.co/api/v1';
  
  CategoryRepository();

  @override
  Future<List<Category>> getAll() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      
      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = json.decode(response.body);
        
        return categoriesJson.map((json) => Category(
          id: json['id'],
          name: json['name'],
          image: json['image'],
        )).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  @override
  Future<Category?> getById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Category(
          id: json['id'],
          name: json['name'],
          image: json['image'],
        );
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }

  // These methods are required by the interface but we're not implementing them yet
  @override
  Future<Category> create(Category item) {
    throw UnimplementedError('Create not implemented yet');
  }

  @override
  Future<Category> update(Category item) {
    throw UnimplementedError('Update not implemented yet');
  }

  @override
  Future<bool> delete(int id) {
    throw UnimplementedError('Delete not implemented yet');
  }
} 