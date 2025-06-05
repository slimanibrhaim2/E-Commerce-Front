import 'package:e_commerce/views/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/api/api_endpoints.dart';
import 'view_models/cart_view_model.dart';
import 'view_models/products_view_model.dart';
import 'view_models/categories_view_model.dart';
import 'view_models/favorites_view_model.dart';
import 'repositories/product_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/favorites_repository.dart';
import 'repositories/cart_repository.dart';
import 'repositories/user_repository.dart';
import 'view_models/user_view_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize API client
    final apiClient = ApiClient(baseUrl: ApiEndpoints.baseUrl);

    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => apiClient,
        ),
        Provider<ProductRepository>(
          create: (context) => ProductRepository(context.read<ApiClient>()),
        ),
        Provider<CategoryRepository>(
          create: (context) => CategoryRepository(context.read<ApiClient>()),
        ),
        Provider<FavoritesRepository>(
          create: (context) => FavoritesRepository(context.read<ApiClient>()),
        ),
        Provider<CartRepository>(
          create: (context) => CartRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CartViewModel(
            context.read<CartRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductsViewModel(
            context.read<ProductRepository>(),
          )..loadProducts(),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoriesViewModel(
            context.read<CategoryRepository>(),
          )..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoritesViewModel(
            context.read<FavoritesRepository>(),
          ),
        ),
        Provider<UserRepository>(
          create: (context) => UserRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserViewModel(
            context.read<UserRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'E-Commerce',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          fontFamily: 'Cairo',
        ),
        home: MainNavigationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
