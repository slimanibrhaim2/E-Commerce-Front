import 'package:e_commerce/views/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/api/api_endpoints.dart';
import 'view_models/cart_view_model.dart';
import 'view_models/products_view_model.dart';
import 'view_models/categories_view_model.dart';
import 'view_models/favorites_view_model.dart';
import 'view_models/address_view_model.dart';
import 'repositories/product_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/favorites_repository.dart';
import 'repositories/cart_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/address_repository.dart';
import 'view_models/user_view_model.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/profile/profile_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token');
  final apiClient = ApiClient(baseUrl: ApiEndpoints.baseUrl);
  if (token != null && token.isNotEmpty) {
    apiClient.setToken(token);
  }
  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;

  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        // Repositories
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
        Provider<UserRepository>(
          create: (context) => UserRepository(context.read<ApiClient>()),
        ),
        Provider<AddressRepository>(
          create: (context) => AddressRepository(context.read<ApiClient>()),
        ),
        // ViewModels
        ChangeNotifierProvider<ProductsViewModel>(
          create: (context) =>
              ProductsViewModel(context.read<ProductRepository>())..loadProducts(),
        ),
        ChangeNotifierProvider<CategoriesViewModel>(
          create: (context) => CategoriesViewModel(
            context.read<CategoryRepository>(),
            context.read<ApiClient>(),
          )..loadCategories(),
        ),
        ChangeNotifierProvider<FavoritesViewModel>(
          create: (context) =>
              FavoritesViewModel(context.read<FavoritesRepository>()),
        ),
        ChangeNotifierProvider<CartViewModel>(
          create: (context) => CartViewModel(context.read<CartRepository>()),
        ),
        ChangeNotifierProvider<AddressViewModel>(
          create: (context) => AddressViewModel(
            context.read<AddressRepository>(),
            context.read<ApiClient>(),
          ),
        ),
        ChangeNotifierProvider<UserViewModel>(
          create: (context) => UserViewModel(
            context.read<UserRepository>(),
            context.read<ApiClient>(),
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
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          // Add your home/profile screen route here, e.g.:
          // '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
