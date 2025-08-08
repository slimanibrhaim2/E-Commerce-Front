import 'package:flutter/material.dart';

class OrderStatusFlow extends StatefulWidget {
  final String currentStatus;
  final bool isCancelled;

  const OrderStatusFlow({
    super.key,
    required this.currentStatus,
    this.isCancelled = false,
  });

  @override
  State<OrderStatusFlow> createState() => _OrderStatusFlowState();
}

class _OrderStatusFlowState extends State<OrderStatusFlow>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF7C3AED),
                          const Color(0xFF9333EA),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.track_changes,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'حالة الطلب',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatusFlow(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusFlow() {
    // Define the status flow with better colors
    final statuses = [
      {'name': 'قيد الانتظار', 'icon': Icons.schedule, 'color': Colors.orange, 'gradient': [Colors.orange.shade400, Colors.orange.shade600]},
      {'name': 'تم الدفع', 'icon': Icons.payment, 'color': Colors.blue, 'gradient': [Colors.blue.shade400, Colors.blue.shade600]},
      {'name': 'تم التوصيل', 'icon': Icons.local_shipping, 'color': Colors.green, 'gradient': [Colors.green.shade400, Colors.green.shade600]},
    ];

    // If cancelled, show cancelled status
    if (widget.isCancelled) {
      return _buildCancelledStatus();
    }

    // Find current status index
    int currentIndex = -1;
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i]['name'] == widget.currentStatus) {
        currentIndex = i;
        break;
      }
    }

    return Column(
      children: [
        // Status items
        SizedBox(
          height: 120,
          child: Row(
            children: List.generate(statuses.length, (index) {
              final status = statuses[index];
              final isCompleted = index <= currentIndex;
              final isCurrent = index == currentIndex;

              return Expanded(
                child: Column(
                  children: [
                    // Status Icon with enhanced design
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500 + (index * 200)),
                      curve: Curves.bounceOut,
                      width: isCurrent ? 60 : 50,
                      height: isCurrent ? 60 : 50,
                      decoration: BoxDecoration(
                        gradient: isCompleted 
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: status['gradient'] as List<Color>,
                              )
                            : LinearGradient(
                                colors: [Colors.grey.shade300, Colors.grey.shade400],
                              ),
                        shape: BoxShape.circle,
                        border: isCurrent 
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: (status['color'] as Color).withOpacity(0.4),
                                  blurRadius: isCurrent ? 15 : 10,
                                  offset: const Offset(0, 5),
                                  spreadRadius: isCurrent ? 2 : 1,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isCurrent && isCompleted)
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: (status['color'] as Color).withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                          Icon(
                            status['icon'] as IconData,
                            color: isCompleted ? Colors.white : Colors.grey.shade600,
                            size: isCurrent ? 28 : 24,
                          ),
                          if (isCompleted && !isCurrent)
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Status Text with enhanced styling
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isCurrent ? 8 : 4, vertical: 4),
                      decoration: isCurrent
                          ? BoxDecoration(
                              color: (status['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (status['color'] as Color).withOpacity(0.3),
                              ),
                            )
                          : null,
                      child: Text(
                        status['name'] as String,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: isCurrent ? 13 : 11,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCompleted 
                              ? status['color'] as Color
                              : isCurrent 
                                  ? status['color'] as Color
                                  : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        
        // Animated progress line
        const SizedBox(height: 8),
        Container(
          height: 4,
          child: Row(
            children: List.generate(statuses.length - 1, (index) {
              final isCompleted = index < currentIndex;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: isCompleted
                        ? LinearGradient(
                            colors: [
                              statuses[index]['color'] as Color,
                              statuses[index + 1]['color'] as Color,
                            ],
                          )
                        : LinearGradient(
                            colors: [Colors.grey.shade300, Colors.grey.shade300],
                          ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledStatus() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade50,
            Colors.red.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade300,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.cancel_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ملغي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تم إلغاء الطلب بنجاح',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 