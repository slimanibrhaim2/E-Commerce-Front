import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/address_view_model.dart';
import '../../models/address.dart';
import '../../widgets/modern_snackbar.dart';
import 'address_selection_screen.dart';
import 'view_address_on_map_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  bool _didFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final addressViewModel = context.watch<AddressViewModel>();
    if (!_didFetch && !addressViewModel.isLoading) {
      _didFetch = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final message = await addressViewModel.loadAddresses();
        if (addressViewModel.error != null && mounted) {
          ModernSnackbar.show(
            context: context,
            message: addressViewModel.error!,
            type: SnackBarType.error,
          );
        }
      });
    }
  }

  void _addNewAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressSelectionScreen(),
      ),
    );

    if (result != null) {
      final addressViewModel = context.read<AddressViewModel>();
      final address = Address(
        name: result['name'],
        address: result['address'],
        latitude: result['latitude'],
        longitude: result['longitude'],
      );

      final message = await addressViewModel.createAddress(address);
      if (addressViewModel.error != null && mounted) {
        ModernSnackbar.show(
          context: context,
          message: addressViewModel.error!,
          type: SnackBarType.error,
        );
      } else if (message != null && mounted) {
        ModernSnackbar.show(
          context: context,
          message: message,
          type: SnackBarType.success,
        );
        await addressViewModel.loadAddresses();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressViewModel = context.watch<AddressViewModel>();
    final addresses = addressViewModel.addresses;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'عناويني',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          centerTitle: true,
        ),
        body: addressViewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: addresses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد عناوين محفوظة',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final address = addresses[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    if (address.latitude != null && address.longitude != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewAddressOnMapScreen(
                                            latitude: address.latitude!,
                                            longitude: address.longitude!,
                                            name: address.name,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          final controller = TextEditingController(text: address.name ?? '');
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Directionality(
                                                textDirection: TextDirection.rtl,
                                                child: AlertDialog(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                  title: const Text(
                                                    'تعديل اسم الموقع',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontFamily: 'Cairo',
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF7C3AED),
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  content: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                    child: TextField(
                                                      controller: controller,
                                                      decoration: InputDecoration(
                                                        hintText: 'اسم الموقع',
                                                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                      ),
                                                      textAlign: TextAlign.right,
                                                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        if (controller.text.trim().isNotEmpty) {
                                                          Navigator.pop(context);
                                                          final updatedAddress = address.copyWith(name: controller.text.trim());
                                                          final message = await addressViewModel.updateAddress(address.id!, updatedAddress);
                                                          if (addressViewModel.error != null && mounted) {
                                                            ModernSnackbar.show(
                                                              context: context,
                                                              message: addressViewModel.error!,
                                                              type: SnackBarType.error,
                                                            );
                                                          } else if (message != null && mounted) {
                                                            ModernSnackbar.show(
                                                              context: context,
                                                              message: message,
                                                              type: SnackBarType.success,
                                                            );
                                                            await addressViewModel.loadAddresses();
                                                          }
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color(0xFF7C3AED),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                                      ),
                                                      child: const Text(
                                                        'حفظ',
                                                        style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return Directionality(
                                                textDirection: TextDirection.rtl,
                                                child: AlertDialog(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                  title: const Text(
                                                    'تأكيد الحذف',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontFamily: 'Cairo',
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.red,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  content: const Text(
                                                    'هل أنت متأكد أنك تريد حذف هذا العنوان؟',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(fontFamily: 'Cairo'),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                                      ),
                                                      child: const Text(
                                                        'حذف',
                                                        style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                          if (confirm == true) {
                                            try {
                                              final message = await addressViewModel.deleteAddress(address.id!);
                                              if (mounted) {
                                                ModernSnackbar.show(
                                                  context: context,
                                                  message: message ?? 'تم حذف العنوان بنجاح',
                                                  type: addressViewModel.error != null ? SnackBarType.error : SnackBarType.success,
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ModernSnackbar.show(
                                                  context: context,
                                                  message: e.toString().replaceAll('Exception: ', ''),
                                                  type: SnackBarType.error,
                                                );
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    (address.name != null && address.name!.isNotEmpty)
                                        ? address.name!
                                        : 'بدون اسم',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    address.address ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addressViewModel.isLoading ? null : _addNewAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Colors.pinkAccent.withOpacity(0.2),
                        ),
                        child: addressViewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'إضافة عنوان جديد',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Cairo',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
} 