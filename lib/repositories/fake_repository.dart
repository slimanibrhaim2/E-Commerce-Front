import 'base_repository.dart';
import '../models/product.dart';

class FakeRepository implements BaseRepository<Product> {
  final List<Product> _products = [
    Product(
      id: 1,
      name: 'هاتف ذكي',
      description: 'هاتف ذكي حديث مع كاميرا عالية الدقة',
      price: 1999.99,
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9',
    ),
    Product(
      id: 2,
      name: 'لابتوب',
      description: 'لابتوب قوي للألعاب والعمل',
      price: 4999.99,
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8',
    ),
    Product(
      id: 3,
      name: 'سماعات لاسلكية',
      description: 'سماعات بلوتوث مع خاصية إلغاء الضوضاء',
      price: 299.99,
      imageUrl: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
    ),
    Product(
      id: 4,
      name: 'ساعة ذكية',
      description: 'ساعة ذكية مع تتبع اللياقة البدنية',
      price: 799.99,
      imageUrl: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
    ),
    Product(
      id: 5,
      name: 'كاميرا رقمية',
      description: 'كاميرا رقمية عالية الدقة للمحترفين',
      price: 2499.99,
      imageUrl: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
    ),
    Product(
      id: 6,
      name: 'جهاز لوحي',
      description: 'جهاز لوحي خفيف الوزن وسريع الأداء',
      price: 1599.99,
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    ),
    Product(
      id: 7,
      name: 'سماعة رأس للألعاب',
      description: 'سماعة رأس مريحة مع صوت محيطي',
      price: 399.99,
      imageUrl: 'https://images.unsplash.com/photo-1519985176271-adb1088fa94c',
    ),
    Product(
      id: 8,
      name: 'لوحة مفاتيح ميكانيكية',
      description: 'لوحة مفاتيح بإضاءة خلفية للألعاب',
      price: 299.99,
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8',
    ),
  ];


  @override
  Future<List<Product>> getAll() async {
    // Simulating network delay
    await Future.delayed(const Duration(seconds: 1));
    return _products;
  }

  @override
  Future<Product?> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Product> create(Product item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.add(item);
    return item;
  }

  @override
  Future<Product> update(Product item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _products.indexWhere((product) => product.id == item.id);
    if (index != -1) {
      _products[index] = item;
    }
    return item;
  }

  @override
  Future<bool> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final initialLength = _products.length;
    _products.removeWhere((product) => product.id == id);
    return _products.length < initialLength;
  }
} 