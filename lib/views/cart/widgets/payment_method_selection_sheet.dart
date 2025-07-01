import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/payment_view_model.dart';
import '../../../models/payment_method.dart';

class PaymentMethodSelectionSheet extends StatelessWidget {
  const PaymentMethodSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentViewModel = context.watch<PaymentViewModel>();
    final paymentMethods = paymentViewModel.paymentMethods;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('اختر طريقة الدفع', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            if (paymentViewModel.isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              )
            else if (paymentViewModel.error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('خطأ: ${paymentViewModel.error}', style: const TextStyle(fontFamily: 'Cairo', color: Colors.red)),
              )
            else if (paymentMethods.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('لا توجد طرق دفع متاحة', style: TextStyle(fontFamily: 'Cairo')),
              )
            else
              ...paymentMethods.where((method) => method.isActive == true).map((method) => ListTile(
                title: Text(method.name ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                subtitle: Text(method.description ?? '', style: const TextStyle(fontFamily: 'Cairo')),
                onTap: () => Navigator.pop(context, method),
              )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 