import 'package:flutter/material.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'الخدمات',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'سيتم إضافة الخدمات قريباً',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Cairo',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 