import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/review.dart';
import '../../view_models/review_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';

class ReviewFormScreen extends StatefulWidget {
  final String orderId;

  const ReviewFormScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  
  int _overallSatisfaction = 0;
  int _itemQuality = 0;
  int _communication = 0;
  int _timeliness = 0;
  String _valueForMoney = '';
  int _netPromoterScore = 0;
  bool _willUseAgain = false;

  final List<String> _valueForMoneyOptions = [
    'A. قيمة ممتازة',
    'B. قيمة جيدة',
    'C. قيمة مقبولة',
    'D. قيمة ضعيفة',
    'E. قيمة سيئة جداً',
  ];

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
  }

  Widget _buildStarRating({
    required String title,
    required String subtitle,
    required int value,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => onChanged(index + 1),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < value ? Icons.star : Icons.star_border,
                  color: index < value ? Colors.amber : Colors.grey,
                  size: 32,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNPSRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مدى التوصية (NPS)',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'ما مدى احتمالية أن توصي بهذا المزود لصديق أو زميل؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '0 = غير محتمل إطلاقاً … 10 = محتمل جداً',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(11, (index) {
            return GestureDetector(
              onTap: () => setState(() => _netPromoterScore = index),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _netPromoterScore == index ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: _netPromoterScore == index ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تقييم التجربة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<ReviewViewModel>(
          builder: (context, reviewViewModel, child) {
            if (reviewViewModel.isLoading) {
              return const Center(child: ModernLoader());
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Experience Description
                    const Text(
                      'صف تجربتك مع المزود',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'يرجى وصف ما أعجبك أكثر، وأي مشكلات واجهتها، وكيف يمكننا التحسين.',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _experienceController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'اكتب تجربتك هنا...',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 24),

                    // Overall Satisfaction
                    _buildStarRating(
                      title: 'درجة الرضا العام',
                      subtitle: 'على مقياس من 1 إلى 5، ما مدى رضاك عن هذا المزود؟',
                      value: _overallSatisfaction,
                      onChanged: (value) => setState(() => _overallSatisfaction = value),
                    ),

                    // Item Quality
                    _buildStarRating(
                      title: 'جودة المنتج/الخدمة',
                      subtitle: 'كيف تقيم جودة المنتج أو الخدمة التي تلقيتها؟',
                      value: _itemQuality,
                      onChanged: (value) => setState(() => _itemQuality = value),
                    ),

                    // Communication
                    _buildStarRating(
                      title: 'التواصل والاستجابة',
                      subtitle: 'كيف تقيم وضوح وسرعة ولباقة تواصل المزود؟',
                      value: _communication,
                      onChanged: (value) => setState(() => _communication = value),
                    ),

                    // Timeliness
                    _buildStarRating(
                      title: 'الالتزام بالموعد أو التسليم',
                      subtitle: 'ما مدى رضاك عن سرعة التسليم أو الالتزام بموعد الخدمة؟',
                      value: _timeliness,
                      onChanged: (value) => setState(() => _timeliness = value),
                    ),

                    // Value for Money
                    const Text(
                      'القيمة مقابل السعر',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'هل ترى أن السعر الذي دفعته عادل مقابل الجودة التي حصلت عليها؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._valueForMoneyOptions.map((option) => RadioListTile<String>(
                      title: Text(
                        option,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      value: option,
                      groupValue: _valueForMoney,
                      onChanged: (value) => setState(() => _valueForMoney = value!),
                    )),
                    const SizedBox(height: 16),

                    // NPS Rating
                    _buildNPSRating(),

                    // Will Use Again
                    const Text(
                      'هل ستستخدمه مرة أخرى؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'هل ستختار هذا المزود مرة أخرى لشراء مشابه في المستقبل؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text(
                              'نعم',
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                            value: true,
                            groupValue: _willUseAgain,
                            onChanged: (value) => setState(() => _willUseAgain = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text(
                              'لا',
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                            value: false,
                            groupValue: _willUseAgain,
                            onChanged: (value) => setState(() => _willUseAgain = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_overallSatisfaction == 0 || 
                                _itemQuality == 0 || 
                                _communication == 0 || 
                                _timeliness == 0 || 
                                _valueForMoney.isEmpty) {
                              ModernSnackbar.show(
                                context: context,
                                message: 'يرجى إكمال جميع التقييمات المطلوبة',
                                type: SnackBarType.error,
                              );
                              return;
                            }

                            final review = Review(
                              experienceDescription: _experienceController.text.trim(),
                              overallSatisfaction: _overallSatisfaction,
                              itemQuality: _itemQuality,
                              communication: _communication,
                              timeliness: _timeliness,
                              valueForMoney: _valueForMoney,
                              netPromoterScore: _netPromoterScore,
                              willUseAgain: _willUseAgain,
                              orderId: widget.orderId,
                            );

                            final message = await reviewViewModel.submitReview(review);
                            
                            if (reviewViewModel.error != null && context.mounted) {
                              ModernSnackbar.show(
                                context: context,
                                message: reviewViewModel.error!,
                                type: SnackBarType.error,
                              );
                            } else if (message != null && context.mounted) {
                              ModernSnackbar.show(
                                context: context,
                                message: 'تم إرسال التقييم بنجاح',
                                type: SnackBarType.success,
                              );
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'إرسال التقييم',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 