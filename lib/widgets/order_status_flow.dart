import 'package:flutter/material.dart';

class OrderStatusFlow extends StatelessWidget {
  final String currentStatus;
  final bool isCancelled;

  const OrderStatusFlow({
    super.key,
    required this.currentStatus,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'حالة الطلب',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildStatusFlow(),
        ],
      ),
    );
  }

  Widget _buildStatusFlow() {
    // Define the status flow
    final statuses = [
      {'name': 'قيد الانتظار', 'icon': Icons.schedule, 'color': Colors.blue},
      {'name': 'تم الدفع', 'icon': Icons.payment, 'color': Colors.blue},
      {'name': 'تم التوصيل', 'icon': Icons.local_shipping, 'color': Colors.blue},
    ];

    // If cancelled, show cancelled status
    if (isCancelled) {
      return _buildCancelledStatus();
    }

    // Find current status index
    int currentIndex = -1;
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i]['name'] == currentStatus) {
        currentIndex = i;
        break;
      }
    }

    return Column(
      children: [
        // Status items row
        Row(
          children: List.generate(statuses.length, (index) {
            final status = statuses[index];
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;
            final isPending = index > currentIndex;

            return Expanded(
              child: Column(
                children: [
                  // Status Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? status['color'] as Color
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: isCurrent 
                          ? Border.all(color: status['color'] as Color, width: 3)
                          : null,
                    ),
                    child: Icon(
                      status['icon'] as IconData,
                      color: isCompleted ? Colors.white : Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status Text (Centered)
                  Text(
                    status['name'] as String,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted 
                          ? status['color'] as Color
                          : isCurrent 
                              ? status['color'] as Color
                              : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                ],
              ),
            );
          }),
        ),
        // Connector lines row
        const SizedBox(height: 16),
        Row(
          children: List.generate(statuses.length - 1, (index) {
            return Expanded(
              child: Container(
                height: 2,
                color: index < currentIndex 
                    ? statuses[index + 1]['color'] as Color
                    : Colors.grey.shade300,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCancelledStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ملغي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'تم إلغاء الطلب',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 