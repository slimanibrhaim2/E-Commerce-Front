import 'package:flutter/material.dart';
import '../../../models/category.dart';
import '../../../core/api/api_client.dart';
import '../../products/product_list/product_list_screen.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final ApiClient apiClient;

  const CategoryCard({
    super.key,
    required this.category,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductListScreen(category: category),
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
    if (category.imageUrl.isEmpty) {
      return const Icon(Icons.category, size: 50);
    }

    // Use the API client to construct the category image URL
    final mediaUrl = apiClient.getCategoryImageUrl(category.imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        mediaUrl,
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