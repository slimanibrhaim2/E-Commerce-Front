import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_colors.dart';
import '../../view_models/categories_view_model.dart';
import '../../widgets/modern_loader.dart';
import 'widgets/category_card.dart';
import '../services/widgets/services_tab.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          //backgroundColor: Colors.white,
          title: const Text(
            'التصنيفات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.navBarUnselected,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag),
                    SizedBox(width: 8),
                    Text('المنتجات'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.miscellaneous_services),
                    SizedBox(width: 8),
                    Text('الخدمات'),
                  ],
                ),
              ),
            ],
            labelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Products Tab
            Consumer<CategoriesViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: ModernLoader(),
                  );
                }

                if (viewModel.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => viewModel.loadCategories(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد تصنيفات متاحة',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => viewModel.loadCategories(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('تحديث'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.loadCategories(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.categories.length,
                    itemBuilder: (context, index) {
                      final category = viewModel.categories[index];
                      return CategoryCard(
                        category: category,
                        apiClient: viewModel.apiClient,
                      );
                    },
                  ),
                );
              },
            ),
            // Services Tab
            const ServicesTab(),
          ],
        ),
      ),
    );
  }
} 