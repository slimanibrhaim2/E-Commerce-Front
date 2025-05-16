import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/categories_view_model.dart';
import '../../models/category.dart';
import '../products/product_list/product_list_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التصنيفات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CategoriesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadCategories(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.categories.isEmpty) {
            return const Center(
              child: Text('لا توجد تصنيفات متاحة'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.categories.length,
            itemBuilder: (context, index) {
              final category = viewModel.categories[index];
              return CategoryCard(category: category);
            },
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductsView(category: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
                size: 20,
              ),
              Expanded(
                child: Text(
                  category.name,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildCategoryImage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage() {
    if (category.image.isEmpty || !category.image.startsWith('http')) {
      return const Icon(Icons.category, size: 50);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        category.image,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.category, size: 50);
        },
      ),
    );
  }
} 