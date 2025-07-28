class ReviewQuestion {
  final String title;
  final String subtitle;
  final String type; // 'star', 'radio', 'nps', 'text'
  final List<String>? options; // For radio buttons
  final String fieldKey; // For identifying the field

  const ReviewQuestion({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.fieldKey,
    this.options,
  });
}

class ReviewConfig {
  static const List<ReviewQuestion> questions = [
    // Text Area Question
    ReviewQuestion(
      title: 'صف تجربتك مع المزود',
      subtitle: 'يرجى وصف ما أعجبك أكثر، وأي مشكلات واجهتها، وكيف يمكننا التحسين.',
      type: 'text',
      fieldKey: 'experienceDescription',
    ),

    // Star Rating Questions
    ReviewQuestion(
      title: 'درجة الرضا العام',
      subtitle: 'على مقياس من 1 إلى 5، ما مدى رضاك عن هذا المزود؟',
      type: 'star',
      fieldKey: 'overallSatisfaction',
    ),

    ReviewQuestion(
      title: 'جودة المنتج/الخدمة',
      subtitle: 'كيف تقيم جودة المنتج أو الخدمة التي تلقيتها؟',
      type: 'star',
      fieldKey: 'itemQuality',
    ),

    ReviewQuestion(
      title: 'التواصل والاستجابة',
      subtitle: 'كيف تقيم وضوح وسرعة ولباقة تواصل المزود؟',
      type: 'star',
      fieldKey: 'communication',
    ),

    ReviewQuestion(
      title: 'الالتزام بالموعد أو التسليم',
      subtitle: 'ما مدى رضاك عن سرعة التسليم أو الالتزام بموعد الخدمة؟',
      type: 'star',
      fieldKey: 'timeliness',
    ),

    // Radio Button Question
    ReviewQuestion(
      title: 'القيمة مقابل السعر',
      subtitle: 'هل ترى أن السعر الذي دفعته عادل مقابل الجودة التي حصلت عليها؟',
      type: 'radio',
      fieldKey: 'valueForMoney',
      options: [
        'A. قيمة ممتازة',
        'B. قيمة جيدة',
        'C. قيمة مقبولة',
        'D. قيمة ضعيفة',
        'E. قيمة سيئة جداً',
      ],
    ),

    // NPS Question
    ReviewQuestion(
      title: 'مدى التوصية (NPS)',
      subtitle: 'ما مدى احتمالية أن توصي بهذا المزود لصديق أو زميل؟',
      type: 'nps',
      fieldKey: 'netPromoterScore',
    ),

    // Boolean Question
    ReviewQuestion(
      title: 'هل ستستخدمه مرة أخرى؟',
      subtitle: 'هل ستختار هذا المزود مرة أخرى لشراء مشابه في المستقبل؟',
      type: 'boolean',
      fieldKey: 'willUseAgain',
    ),
  ];

  // Helper methods
  static List<ReviewQuestion> getQuestionsByType(String type) {
    return questions.where((q) => q.type == type).toList();
  }

  static ReviewQuestion? getQuestionByKey(String fieldKey) {
    try {
      return questions.firstWhere((q) => q.fieldKey == fieldKey);
    } catch (e) {
      return null;
    }
  }

  // NPS specific text
  static const String npsRangeText = '0 = غير محتمل إطلاقاً … 10 = محتمل جداً';
  
  // Button texts
  static const String submitButtonText = 'إرسال التقييم';
  static const String yesText = 'نعم';
  static const String noText = 'لا';
  
  // Validation messages
  static const String validationMessage = 'يرجى إكمال جميع التقييمات المطلوبة';
  static const String successMessage = 'تم إرسال التقييم بنجاح';
  
  // Placeholders
  static const String textFieldHint = 'اكتب تجربتك هنا...';
} 