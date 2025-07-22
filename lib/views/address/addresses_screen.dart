import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/address_view_model.dart';
import '../../models/address.dart';
import '../../widgets/modern_snackbar.dart';
import 'address_selection_screen.dart';
import 'view_address_on_map_screen.dart';
import '../../widgets/modern_loader.dart';
import '../../view_models/user_view_model.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  bool _didFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final addressViewModel = context.watch<AddressViewModel>();
    final userViewModel = context.watch<UserViewModel>();
    
    if (!_didFetch && !addressViewModel.isLoading && userViewModel.isLoggedIn) {
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
    final userViewModel = context.watch<UserViewModel>();
    final isLoggedIn = userViewModel.isLoggedIn;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'عناويني',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          centerTitle: true,
          actions: [
            // Show pagination info
            if (addresses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    'الصفحة ${addressViewModel.currentPage} - ${addresses.length}/${addressViewModel.totalAddresses} عنوان',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Consumer<AddressViewModel>(
          builder: (context, viewModel, child) {
            if (!isLoggedIn) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'الرجاء تسجيل الدخول لعرض عناوينك',
                      style: TextStyle(fontSize: 18, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/login'),
                      child: const Text('تسجيل الدخول'),
                    ),
                  ],
                ),
              );
            }
            if (viewModel.isLoading && viewModel.addresses.isEmpty) {
              return const Center(child: ModernLoader());
            }

            if (viewModel.error != null && viewModel.addresses.isEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: Center(
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
                        onPressed: viewModel.isLoading ? null : _addNewAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Colors.pinkAccent.withOpacity(0.2),
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: ModernLoader(),
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
              );
            }

            return Column(
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
                      : RefreshIndicator(
                          onRefresh: () async {
                            await viewModel.refreshAddresses();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: addresses.length + (viewModel.hasMoreData ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Debug info
                              if (index == 0) {
                                print('🔍 UI Debug:');
                                print('   - addresses.length: ${addresses.length}');
                                print('   - viewModel.hasMoreData: ${viewModel.hasMoreData}');
                                print('   - viewModel.totalAddresses: ${viewModel.totalAddresses}');
                                print('   - viewModel.currentPage: ${viewModel.currentPage}');
                                print('   - itemCount: ${addresses.length + (viewModel.hasMoreData ? 1 : 0)}');
                              }
                              
                              // Show "Load More" button at the end
                              if (index == addresses.length) {
                                print('🔍 Showing Load More button');
                                return Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  child: Center(
                                    child: ElevatedButton(
                                      onPressed: viewModel.isLoadingMore ? null : () async {
                                        print('🔍 Load More button pressed');
                                        await viewModel.loadMoreAddresses();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: viewModel.isLoadingMore
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'تحميل المزيد',
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }

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
                                                          final message = await viewModel.updateAddress(address.id!, updatedAddress);
                                                          if (viewModel.error != null && mounted) {
                                                            ModernSnackbar.show(
                                                              context: context,
                                                              message: viewModel.error!,
                                                              type: SnackBarType.error,
                                                            );
                                                          } else if (message != null && mounted) {
                                                            ModernSnackbar.show(
                                                              context: context,
                                                              message: message,
                                                              type: SnackBarType.success,
                                                            );
                                                            await viewModel.refreshAddresses();
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
                                              final message = await viewModel.deleteAddress(address.id!);
                                              if (mounted) {
                                                ModernSnackbar.show(
                                                  context: context,
                                                  message: message ?? 'تم حذف العنوان بنجاح',
                                                  type: viewModel.error != null ? SnackBarType.error : SnackBarType.success,
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
                      onPressed: viewModel.isLoading ? null : _addNewAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.pinkAccent.withOpacity(0.2),
                      ),
                      child: viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: ModernLoader(),
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
            );
          },
        ),
      ),
    );
  }
} 