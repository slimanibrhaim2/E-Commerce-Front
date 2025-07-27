import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/categories_view_model.dart';
import 'filter_results_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Load categories when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesViewModel>().loadCategories();
    });
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _applyFilters() {
    if (_formKey.currentState!.validate()) {
      // Get filter values
      final categoryId = _selectedCategoryId;
      final minPrice = _minPriceController.text.isNotEmpty 
          ? double.tryParse(_minPriceController.text) 
          : null;
      final maxPrice = _maxPriceController.text.isNotEmpty 
          ? double.tryParse(_maxPriceController.text) 
          : null;

      // Validate price range
      if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الحد الأدنى للسعر يجب أن يكون أقل من الحد الأقصى'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navigate to filter results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilterResultsScreen(
            categoryId: categoryId,
            minPrice: minPrice,
            maxPrice: maxPrice,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تصفية المنتجات',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _clearFilters,
              child: const Text(
                'مسح الكل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Filter
                const Text(
                  'التصنيف',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<CategoriesViewModel>(
                  builder: (context, categoriesViewModel, child) {
                    if (categoriesViewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'اختر التصنيف (اختياري)',
                          hintStyle: TextStyle(fontFamily: 'Cairo'),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'جميع التصنيفات',
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                          ),
                          ...categoriesViewModel.categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(
                                category.name,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Price Range Filter
                const Text(
                  'نطاق السعر',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    // Min Price
                    Expanded(
                      child: TextFormField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'من',
                          labelStyle: TextStyle(fontFamily: 'Cairo'),
                          hintText: '0',
                          border: OutlineInputBorder(),
                          suffixText: 'ل.س',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final price = double.tryParse(value);
                            if (price == null || price < 0) {
                              return 'سعر غير صالح';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'إلى',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Max Price
                    Expanded(
                      child: TextFormField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'إلى',
                          labelStyle: TextStyle(fontFamily: 'Cairo'),
                          hintText: '∞',
                          border: OutlineInputBorder(),
                          suffixText: 'ل.س',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final price = double.tryParse(value);
                            if (price == null || price < 0) {
                              return 'سعر غير صالح';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Apply Filter Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF7C3AED).withOpacity(0.3),
                    ),
                    child: const Text(
                      'تطبيق الفلتر',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'يمكنك ترك أي حقل فارغاً لعدم تطبيق الفلتر عليه',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 