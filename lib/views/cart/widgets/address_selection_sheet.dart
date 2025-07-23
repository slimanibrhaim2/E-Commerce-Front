import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/address_view_model.dart';
import '../../../models/address.dart';
import '../../../widgets/modern_snackbar.dart';
import '../../address/address_selection_screen.dart';

class AddressSelectionSheet extends StatefulWidget {
  @override
  State<AddressSelectionSheet> createState() => _AddressSelectionSheetState();
}

class _AddressSelectionSheetState extends State<AddressSelectionSheet> {
  final ScrollController _scrollController = ScrollController();
  bool _showLoadMore = false;

  @override
  void initState() {
    super.initState();
    
    // Add scroll listener
    _scrollController.addListener(_onScroll);
    
    // Load addresses when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressViewModel>().loadAddresses();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Show load more button when user is 200 pixels from bottom
      if (!_showLoadMore) {
        setState(() {
          _showLoadMore = true;
        });
      }
    } else {
      // Hide load more button when user scrolls up
      if (_showLoadMore) {
        setState(() {
          _showLoadMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Consumer<AddressViewModel>(
          builder: (context, addressViewModel, child) {
            final addresses = addressViewModel.addresses;
            
            return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
                const Text(
                  'اختر عنوان التوصيل', 
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18)
                ),
            const SizedBox(height: 16),
                
                // Addresses list with pagination
                if (addressViewModel.isLoading && addresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (addresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'لا يوجد عناوين محفوظة', 
                      style: TextStyle(fontFamily: 'Cairo'),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final address = addresses[index];
                              return ListTile(
                                title: Text(
                                  address.name ?? 'بدون اسم', 
                                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)
                                ),
                                subtitle: Text(
                                  address.address ?? '', 
                                  style: const TextStyle(fontFamily: 'Cairo')
                                ),
                  onTap: () => Navigator.pop(context, address),
                              );
                            },
                          ),
                        ),
                        // Show "Load More" button only when user reaches bottom and has more data
                        if (_showLoadMore && addressViewModel.hasMoreData)
                          Container(
                            margin: const EdgeInsets.all(16),
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: addressViewModel.isLoadingMore ? null : () async {
                                await addressViewModel.loadMoreAddresses();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: addressViewModel.isLoadingMore
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'تحميل المزيد',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                
                // Add new address button
            ListTile(
              leading: const Icon(Icons.add_location_alt, color: Colors.blue),
                  title: const Text(
                    'إضافة عنوان جديد', 
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)
                  ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressSelectionScreen()),
                );
                if (result != null) {
                  final address = Address(
                    name: result['name'],
                    address: result['address'],
                    latitude: result['latitude'],
                    longitude: result['longitude'],
                  );
                  final message = await addressViewModel.createAddress(address);
                  if (addressViewModel.error != null && context.mounted) {
                    ModernSnackbar.show(
                      context: context,
                      message: addressViewModel.error!,
                      type: SnackBarType.error,
                    );
                  } else if (message != null && context.mounted) {
                    ModernSnackbar.show(
                      context: context,
                      message: message,
                      type: SnackBarType.success,
                    );
                    await addressViewModel.loadAddresses();
                    
                    // Find the newly created address and return it
                    final newAddresses = addressViewModel.addresses;
                    if (newAddresses.isNotEmpty) {
                      // Find the newly created address by matching the data
                      final newAddress = newAddresses.firstWhere(
                        (addr) => addr.name == result['name'] && 
                                  addr.address == result['address'] &&
                                  addr.latitude == result['latitude'] &&
                                  addr.longitude == result['longitude'],
                        orElse: () => newAddresses.last, // Fallback to last address if not found
                      );
                      
                      // Return the address with ID to the cart screen
                      Navigator.pop(context, newAddress);
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
            );
          },
        ),
      ),
    );
  }
} 