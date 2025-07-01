import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/address_view_model.dart';
import '../../../models/address.dart';
import '../../../widgets/modern_snackbar.dart';
import '../../address/address_selection_screen.dart';

class AddressSelectionSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final addressViewModel = context.watch<AddressViewModel>();
    final addresses = addressViewModel.addresses;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('اختر عنوان التوصيل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            if (addresses.isEmpty)
              const Text('لا يوجد عناوين محفوظة', style: TextStyle(fontFamily: 'Cairo')),
            ...addresses.map((address) => ListTile(
                  title: Text(address.name ?? 'بدون اسم', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  subtitle: Text(address.address ?? '', style: const TextStyle(fontFamily: 'Cairo')),
                  onTap: () => Navigator.pop(context, address),
                )),
            ListTile(
              leading: const Icon(Icons.add_location_alt, color: Colors.blue),
              title: const Text('إضافة عنوان جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressSelectionScreen()),
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
        ),
      ),
    );
  }
} 