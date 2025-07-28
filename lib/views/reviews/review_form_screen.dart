import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/review_config.dart';
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
  
  // Dynamic form values
  final Map<String, dynamic> _formValues = {
    'experienceDescription': '',
    'overallSatisfaction': 0,
    'itemQuality': 0,
    'communication': 0,
    'timeliness': 0,
    'valueForMoney': '',
    'netPromoterScore': 0,
    'willUseAgain': false,
  };

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
  }

  Widget _buildQuestionWidget(ReviewQuestion question) {
    switch (question.type) {
      case 'text':
        return _buildTextQuestion(question);
      case 'star':
        return _buildStarRating(question);
      case 'radio':
        return _buildRadioQuestion(question);
      case 'nps':
        return _buildNPSRating(question);
      case 'boolean':
        return _buildBooleanQuestion(question);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextQuestion(ReviewQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          question.subtitle,
          style: const TextStyle(
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
            hintText: ReviewConfig.textFieldHint,
            hintStyle: const TextStyle(fontFamily: 'Cairo'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontFamily: 'Cairo'),
          onChanged: (value) => _formValues[question.fieldKey] = value,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStarRating(ReviewQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          question.subtitle,
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
            final value = _formValues[question.fieldKey] as int;
            return GestureDetector(
              onTap: () => setState(() => _formValues[question.fieldKey] = index + 1),
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

  Widget _buildRadioQuestion(ReviewQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          question.subtitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...question.options!.map((option) => RadioListTile<String>(
          title: Text(
            option,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          value: option,
          groupValue: _formValues[question.fieldKey] as String,
          onChanged: (value) => setState(() => _formValues[question.fieldKey] = value!),
        )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNPSRating(ReviewQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          question.subtitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          ReviewConfig.npsRangeText,
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
            final value = _formValues[question.fieldKey] as int;
            return GestureDetector(
              onTap: () => setState(() => _formValues[question.fieldKey] = index),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: value == index ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: value == index ? Colors.white : Colors.black,
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

  Widget _buildBooleanQuestion(ReviewQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          question.subtitle,
          style: const TextStyle(
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
                  ReviewConfig.yesText,
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                value: true,
                groupValue: _formValues[question.fieldKey] as bool,
                onChanged: (value) => setState(() => _formValues[question.fieldKey] = value!),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text(
                  ReviewConfig.noText,
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                value: false,
                groupValue: _formValues[question.fieldKey] as bool,
                onChanged: (value) => setState(() => _formValues[question.fieldKey] = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  bool _validateForm() {
    // Check required star ratings
    final starQuestions = ReviewConfig.getQuestionsByType('star');
    for (final question in starQuestions) {
      if ((_formValues[question.fieldKey] as int) == 0) {
        return false;
      }
    }
    
    // Check value for money
    if ((_formValues['valueForMoney'] as String).isEmpty) {
      return false;
    }
    
    return true;
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
                    // Build all questions dynamically
                    ...ReviewConfig.questions.map((question) => 
                      _buildQuestionWidget(question)),

                    const SizedBox(height: 16),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (!_validateForm()) {
                              ModernSnackbar.show(
                                context: context,
                                message: ReviewConfig.validationMessage,
                                type: SnackBarType.error,
                              );
                              return;
                            }

                            final review = Review(
                              experienceDescription: _experienceController.text.trim(),
                              overallSatisfaction: _formValues['overallSatisfaction'] as int,
                              itemQuality: _formValues['itemQuality'] as int,
                              communication: _formValues['communication'] as int,
                              timeliness: _formValues['timeliness'] as int,
                              valueForMoney: _formValues['valueForMoney'] as String,
                              netPromoterScore: _formValues['netPromoterScore'] as int,
                              willUseAgain: _formValues['willUseAgain'] as bool,
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
                                message: ReviewConfig.successMessage,
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
                          ReviewConfig.submitButtonText,
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