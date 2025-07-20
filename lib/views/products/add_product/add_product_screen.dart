import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../models/product.dart';
import '../../../view_models/products_view_model.dart';
import '../../../widgets/modern_snackbar.dart';
import '../../../view_models/categories_view_model.dart';
import '../../../views/main_navigation_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class AddProductScreen extends StatefulWidget {
  final Product? productToEdit;
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _serialNumberController = TextEditingController();
  String? _selectedCategory;
  final List<File> _selectedImages = [];
  final List<Map<String, String>> _features = [];
  final _featureNameController = TextEditingController();
  final _featureValueController = TextEditingController();
  bool get isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final p = widget.productToEdit!;
      _nameController.text = p.name;
      _descriptionController.text = p.description;
      _priceController.text = p.price.toString();
      _quantityController.text = p.stockQuantity.toString();
      _serialNumberController.text = p.serialNumber ?? '';
      _selectedCategory = p.categoryId;
      _features.addAll(p.features.map((f) => {'name': f.name, 'value': f.value}));
      // Note: Images are not prefilled for edit (backend should handle existing images)
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _serialNumberController.dispose();
    _featureNameController.dispose();
    _featureValueController.dispose();
    super.dispose();
  }

  Future<bool> checkImagePermission() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
        if (!status.isGranted) {
          ModernSnackbar.show(
            context: context,
            message: 'يجب السماح للتطبيق بالوصول إلى الصور لإكمال العملية',
            type: SnackBarType.error,
          );
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _pickImages() async {
    if (!await checkImagePermission()) return;
    
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  void _addFeatureInline() {
    if (_featureNameController.text.isNotEmpty && _featureValueController.text.isNotEmpty) {
      setState(() {
        _features.add({
          'name': _featureNameController.text,
          'value': _featureValueController.text,
        });
        _featureNameController.clear();
        _featureValueController.clear();
      });
    }
  }

  void _editFeature(int index) {
    _featureNameController.text = _features[index]['name']!;
    _featureValueController.text = _features[index]['value']!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل الميزة', style: TextStyle(fontFamily: 'Cairo')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _featureNameController,
                decoration: const InputDecoration(labelText: 'اسم الميزة'),
              ),
              TextField(
                controller: _featureValueController,
                decoration: const InputDecoration(labelText: 'قيمة الميزة'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _features[index] = {
                    'name': _featureNameController.text,
                    'value': _featureValueController.text,
                  };
                });
                _featureNameController.clear();
                _featureValueController.clear();
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFeature(int index) {
    setState(() {
      _features.removeAt(index);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _viewImage(File image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Image.file(image, fit: BoxFit.contain),
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final product = Product(
          id: isEditMode ? widget.productToEdit!.id : null,
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          sku: isEditMode ? widget.productToEdit!.sku : DateTime.now().millisecondsSinceEpoch.toString(),
          serialNumber: _serialNumberController.text.isNotEmpty ? _serialNumberController.text : null,
          stockQuantity: int.parse(_quantityController.text),
          isAvailable: true,
          categoryId: _selectedCategory ?? '1',
          media: [],
          features: _features.map((f) => Feature(
            name: f['name']!,
            value: f['value']!,
          )).toList(),
        );

        final viewModel = context.read<ProductsViewModel>();
        final response = isEditMode
          ? await viewModel.editProduct(product, images: _selectedImages.isNotEmpty ? _selectedImages : null)
          : await viewModel.addProduct(product, images: _selectedImages.isNotEmpty ? _selectedImages : null);
        
        if (context.mounted) {
          ModernSnackbar.show(
            context: context,
            message: response.message ?? 'An unknown error occurred.',
            type: response.success ? SnackBarType.success : SnackBarType.error,
          );
          
          if (response.success) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MainNavigationScreen(initialIndex: 4)),
              (Route<dynamic> route) => false,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ModernSnackbar.show(
            context: context,
            message: isEditMode ? 'حدث خطأ أثناء تعديل المنتج' : 'حدث خطأ أثناء إضافة المنتج',
            type: SnackBarType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditMode ? 'تعديل المنتج' : 'إضافة منتج جديد',
            style: const TextStyle(fontFamily: 'Cairo'),
            textAlign: TextAlign.right,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج',
                    labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المنتج';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'وصف المنتج',
                    labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال وصف المنتج';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'السعر',
                    labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    suffixText: 'ل.س ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال سعر المنتج';
                    }
                    if (double.tryParse(value) == null) {
                      return 'الرجاء إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _serialNumberController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'الرقم التسلسلي',
                    labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    hintText: 'اختياري - أدخل الرقم التسلسلي للمنتج',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'الكمية المتوفرة',
                    labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الكمية المتوفرة';
                    }
                    if (int.tryParse(value) == null) {
                      return 'الرجاء إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Category Dropdown
                Consumer<CategoriesViewModel>(
                  builder: (context, categoriesViewModel, child) {
                    return DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'التصنيف',
                        labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(),
                      ),
                      items: categoriesViewModel.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(
                            category.name,
                            style: const TextStyle(fontFamily: 'Cairo'),
                            textAlign: TextAlign.right,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء اختيار التصنيف';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text('اختر صور'),
                ),
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _viewImage(_selectedImages[index]),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(_selectedImages[index], height: 100, width: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white),
                                    onPressed: () => _removeImage(index),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _featureNameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم الميزة',
                          labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _featureValueController,
                        decoration: const InputDecoration(
                          labelText: 'قيمة الميزة',
                          labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addFeatureInline,
                    ),
                  ],
                ),
                if (_features.isNotEmpty)
                  Column(
                    children: _features.asMap().entries.map((entry) {
                      final index = entry.key;
                      final feature = entry.value;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${feature['name']}: ${feature['value']}',
                                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editFeature(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteFeature(index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEditMode ? 'تعديل المنتج' : 'إضافة المنتج',
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Cairo',
                      color: Colors.white
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