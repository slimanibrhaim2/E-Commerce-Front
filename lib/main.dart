import 'package:e_commerce/views/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/cart_view_model.dart';
import 'view_models/products_view_model.dart';
import 'view_models/categories_view_model.dart';
import 'repositories/product_repository.dart';
import 'repositories/category_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductRepository>(
          create: (_) => ProductRepository(),
        ),
        Provider<CategoryRepository>(
          create: (_) => CategoryRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) => CartViewModel(
            context.read<ProductRepository>(),
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
