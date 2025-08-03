import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/categories_view_model.dart';
import '../../view_models/products_view_model.dart';
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
  
  // Feature selection state
  Map<String, List<String>> _selectedFeatureValues = {};
  List<String> _expandedFeatures = [];

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
      _selectedFeatureValues.clear();
      _expandedFeatures.clear();
    });
    
    // Clear features in view model
    final productsViewModel = context.read<ProductsViewModel>();
    productsViewModel.setSelectedFeatureName(null);
  }

  void _onCategoryChanged(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedFeatureValues.clear();
      _expandedFeatures.clear();
    });

    if (categoryId != null && categoryId.isNotEmpty) {
      // Load feature names for the selected category
      context.read<ProductsViewModel>().loadFeatureNames(categoryId);
    }
  }

  void _loadFeatureValues(String featureName) {
    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      context.read<ProductsViewModel>().loadFeatureValues(featureName, _selectedCategoryId!);
    }
  }

  void _toggleFeatureExpansion(String featureName) {
    setState(() {
      if (_expandedFeatures.contains(featureName)) {
        _expandedFeatures.remove(featureName);
      } else {
        _expandedFeatures.add(featureName);
        _loadFeatureValues(featureName);
      }
    });
  }

  void _toggleFeatureValue(String featureName, String value) {
    setState(() {
      if (!_selectedFeatureValues.containsKey(featureName)) {
        _selectedFeatureValues[featureName] = [];
      }
      
      if (_selectedFeatureValues[featureName]!.contains(value)) {
        _selectedFeatureValues[featureName]!.remove(value);
        if (_selectedFeatureValues[featureName]!.isEmpty) {
          _selectedFeatureValues.remove(featureName);
        }
      } else {
        _selectedFeatureValues[featureName]!.add(value);
      }
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

      // Prepare feature names and values for API
      List<String> featureNames = [];
      List<String> featureValues = [];
      
      _selectedFeatureValues.forEach((featureName, values) {
        for (String value in values) {
          featureNames.add(featureName);
          featureValues.add(value);
        }
      });

      // Navigate to filter results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilterResultsScreen(
            categoryId: categoryId,
            minPrice: minPrice,
            maxPrice: maxPrice,
            featureNames: featureNames.isNotEmpty ? featureNames : null,
            featureValues: featureValues.isNotEmpty ? featureValues : null,
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
            'تصفية المنتجات المتقدمة',
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
                        onChanged: _onCategoryChanged,
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
                
                const SizedBox(height: 24),
                
                // Features Filter (only show if category is selected)
                if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) ...[
                  const Text(
                    'الخصائص',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Consumer<ProductsViewModel>(
                    builder: (context, productsViewModel, child) {
                      if (productsViewModel.isLoadingFeatureNames) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (productsViewModel.featureNames.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            'لا توجد خصائص متاحة لهذا التصنيف',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                                             return Column(
                         children: productsViewModel.featureNames.map((featureName) {
                           final isExpanded = _expandedFeatures.contains(featureName.name);
                           final selectedValues = _selectedFeatureValues[featureName.name] ?? [];

                           return Container(
                             margin: const EdgeInsets.only(bottom: 12),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(16),
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.grey.withOpacity(0.1),
                                   spreadRadius: 1,
                                   blurRadius: 8,
                                   offset: const Offset(0, 2),
                                 ),
                               ],
                               border: selectedValues.isNotEmpty
                                   ? Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3), width: 2)
                                   : Border.all(color: Colors.grey.shade200),
                             ),
                             child: Column(
                               children: [
                                 Material(
                                   color: Colors.transparent,
                                   child: InkWell(
                                     borderRadius: const BorderRadius.vertical(
                                       top: Radius.circular(16),
                                       bottom: Radius.circular(16),
                                     ),
                                     onTap: () => _toggleFeatureExpansion(featureName.name),
                                     child: Container(
                                       padding: const EdgeInsets.all(16),
                                       child: Row(
                                         children: [
                                           Container(
                                             padding: const EdgeInsets.all(8),
                                             decoration: BoxDecoration(
                                               color: selectedValues.isNotEmpty 
                                                   ? const Color(0xFF7C3AED).withOpacity(0.1)
                                                   : Colors.grey.withOpacity(0.1),
                                               borderRadius: BorderRadius.circular(8),
                                             ),
                                             child: Icon(
                                               Icons.tune,
                                               size: 20,
                                               color: selectedValues.isNotEmpty 
                                                   ? const Color(0xFF7C3AED)
                                                   : Colors.grey.shade600,
                                             ),
                                           ),
                                           const SizedBox(width: 12),
                                           Expanded(
                                             child: Text(
                                               featureName.name,
                                               style: TextStyle(
                                                 fontFamily: 'Cairo',
                                                 fontWeight: FontWeight.bold,
                                                 fontSize: 16,
                                                 color: selectedValues.isNotEmpty 
                                                     ? const Color(0xFF7C3AED)
                                                     : Colors.black87,
                                               ),
                                             ),
                                           ),
                                           if (selectedValues.isNotEmpty)
                                             Container(
                                               margin: const EdgeInsets.only(left: 8),
                                               padding: const EdgeInsets.symmetric(
                                                 horizontal: 10,
                                                 vertical: 6,
                                               ),
                                               decoration: BoxDecoration(
                                                 gradient: const LinearGradient(
                                                   colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                                                   begin: Alignment.topLeft,
                                                   end: Alignment.bottomRight,
                                                 ),
                                                 borderRadius: BorderRadius.circular(20),
                                                 boxShadow: [
                                                   BoxShadow(
                                                     color: const Color(0xFF7C3AED).withOpacity(0.3),
                                                     spreadRadius: 1,
                                                     blurRadius: 4,
                                                     offset: const Offset(0, 2),
                                                   ),
                                                 ],
                                               ),
                                               child: Text(
                                                 '${selectedValues.length}',
                                                 style: const TextStyle(
                                                   color: Colors.white,
                                                   fontSize: 12,
                                                   fontWeight: FontWeight.bold,
                                                   fontFamily: 'Cairo',
                                                 ),
                                               ),
                                             ),
                                           const SizedBox(width: 8),
                                           AnimatedRotation(
                                             turns: isExpanded ? 0.5 : 0,
                                             duration: const Duration(milliseconds: 200),
                                             child: Icon(
                                               Icons.keyboard_arrow_down,
                                               color: selectedValues.isNotEmpty 
                                                   ? const Color(0xFF7C3AED)
                                                   : Colors.grey.shade600,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                   ),
                                 ),
                                 AnimatedCrossFade(
                                   firstChild: const SizedBox.shrink(),
                                   secondChild: Container(
                                     width: double.infinity,
                                     decoration: BoxDecoration(
                                       color: Colors.grey.shade50,
                                       borderRadius: const BorderRadius.vertical(
                                         bottom: Radius.circular(16),
                                       ),
                                     ),
                                     child: Column(
                                       children: [
                                         Container(
                                           height: 1,
                                           color: Colors.grey.shade200,
                                         ),
                                         if (productsViewModel.isLoadingFeatureValues)
                                           Container(
                                             padding: const EdgeInsets.all(24),
                                             child: Column(
                                               children: [
                                                 const CircularProgressIndicator(
                                                   color: Color(0xFF7C3AED),
                                                   strokeWidth: 3,
                                                 ),
                                                 const SizedBox(height: 12),
                                                 Text(
                                                   'جارٍ تحميل القيم...',
                                                   style: TextStyle(
                                                     fontFamily: 'Cairo',
                                                     color: Colors.grey.shade600,
                                                     fontSize: 14,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           )
                                         else if (productsViewModel.featureValues[featureName.name]?.isEmpty ?? true)
                                           Container(
                                             padding: const EdgeInsets.all(24),
                                             child: Column(
                                               children: [
                                                 Icon(
                                                   Icons.inbox_outlined,
                                                   size: 32,
                                                   color: Colors.grey.shade400,
                                                 ),
                                                 const SizedBox(height: 8),
                                                 Text(
                                                   'لا توجد قيم متاحة',
                                                   style: TextStyle(
                                                     fontFamily: 'Cairo',
                                                     color: Colors.grey.shade600,
                                                     fontSize: 14,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           )
                                         else
                                           Container(
                                             width: double.infinity,
                                             padding: const EdgeInsets.all(16),
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 Text(
                                                   'اختر من القيم التالية:',
                                                   style: TextStyle(
                                                     fontFamily: 'Cairo',
                                                     fontSize: 13,
                                                     color: Colors.grey.shade600,
                                                     fontWeight: FontWeight.w500,
                                                   ),
                                                 ),
                                                 const SizedBox(height: 12),
                                                 Wrap(
                                                   spacing: 8,
                                                   runSpacing: 8,
                                                   children: productsViewModel.featureValues[featureName.name]!
                                                       .map((featureValue) {
                                                     final isSelected = selectedValues.contains(featureValue.value);
                                                     return Container(
                                                       decoration: BoxDecoration(
                                                         borderRadius: BorderRadius.circular(25),
                                                         boxShadow: isSelected ? [
                                                           BoxShadow(
                                                             color: const Color(0xFF7C3AED).withOpacity(0.3),
                                                             spreadRadius: 1,
                                                             blurRadius: 4,
                                                             offset: const Offset(0, 2),
                                                           ),
                                                         ] : null,
                                                       ),
                                                       child: Material(
                                                         color: Colors.transparent,
                                                         child: InkWell(
                                                           borderRadius: BorderRadius.circular(25),
                                                           onTap: () => _toggleFeatureValue(featureName.name, featureValue.value),
                                                           child: AnimatedContainer(
                                                             duration: const Duration(milliseconds: 200),
                                                             padding: const EdgeInsets.symmetric(
                                                               horizontal: 16,
                                                               vertical: 10,
                                                             ),
                                                             decoration: BoxDecoration(
                                                               gradient: isSelected 
                                                                   ? const LinearGradient(
                                                                       colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                                                                       begin: Alignment.topLeft,
                                                                       end: Alignment.bottomRight,
                                                                     )
                                                                   : null,
                                                               color: isSelected ? null : Colors.white,
                                                               borderRadius: BorderRadius.circular(25),
                                                               border: Border.all(
                                                                 color: isSelected 
                                                                     ? Colors.transparent 
                                                                     : Colors.grey.shade300,
                                                                 width: 1.5,
                                                               ),
                                                             ),
                                                             child: Row(
                                                               mainAxisSize: MainAxisSize.min,
                                                               children: [
                                                                 if (isSelected) ...[
                                                                   const Icon(
                                                                     Icons.check_circle,
                                                                     color: Colors.white,
                                                                     size: 16,
                                                                   ),
                                                                   const SizedBox(width: 6),
                                                                 ],
                                                                 Text(
                                                                   featureValue.value,
                                                                   style: TextStyle(
                                                                     fontFamily: 'Cairo',
                                                                     color: isSelected ? Colors.white : Colors.black87,
                                                                     fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                                     fontSize: 14,
                                                                   ),
                                                                 ),
                                                               ],
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                     );
                                                   }).toList(),
                                                 ),
                                               ],
                                             ),
                                           ),
                                       ],
                                     ),
                                   ),
                                   crossFadeState: isExpanded 
                                       ? CrossFadeState.showSecond 
                                       : CrossFadeState.showFirst,
                                   duration: const Duration(milliseconds: 300),
                                 ),
                               ],
                             ),
                           );
                         }).toList(),
                       );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                ],
                
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
                      'تطبيق الفلتر المتقدم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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