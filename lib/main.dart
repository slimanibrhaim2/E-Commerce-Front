import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/products_view_model.dart';
import 'view_models/cart_view_model.dart';
import 'repositories/api_repository.dart';
import 'views/products/products_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProductsViewModel(
            ApiRepository(),
          )..loadProducts(),
        ),
        ChangeNotifierProvider(
          create: (context) => CartViewModel(
            context.read<ProductsViewModel>().repository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'متجر الإلكترونيات',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          fontFamily: 'Cairo',
        ),
        home: const ProductsView(),
      ),
    );
  }
}
