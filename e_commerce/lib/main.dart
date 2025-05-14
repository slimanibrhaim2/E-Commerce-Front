import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/fake_repository.dart';
import 'view_models/products_view_model.dart';
import 'views/products_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductsViewModel(FakeRepository())..loadProducts(),
      child: MaterialApp(
        title: 'متجر إلكتروني',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Cairo',
        ),
        home: const ProductsView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
