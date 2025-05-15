import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/cart_view_model.dart';
import 'view_models/products_view_model.dart';
import 'repositories/api_repository.dart';
import 'views/main_navigation_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartViewModel(ApiRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsViewModel(ApiRepository())..loadProducts(),
        ),
      ],
      child: MaterialApp(
        title: 'E-Commerce',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          fontFamily: 'Cairo',
        ),
        home: MainNavigationPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
