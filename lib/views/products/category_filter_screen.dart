import 'package:flutter/material.dart';
import 'filter_results_screen.dart';

class CategoryFilterScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryFilterScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
}

class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _applyFilters() {
    if (_formKey.currentState!.validate()) {
      // Get filter values
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

      // Navigate to filter results screen with the pre-selected category
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilterResultsScreen(
            categoryId: widget.categoryId,
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
          title: Text(
            'تصفية منتجات ${widget.categoryName}',
            style: const TextStyle(fontFamily: 'Cairo'),
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
                // Category Info (Read-only)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.category, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'التصنيف المحدد',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.categoryName,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.grey.withOpacity(0.3),
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
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تصفية حسب السعر فقط',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.orange.shade700,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ستظهر منتجات من تصنيف "${widget.categoryName}" فقط ضمن نطاق الأسعار المحدد',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.orange.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
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