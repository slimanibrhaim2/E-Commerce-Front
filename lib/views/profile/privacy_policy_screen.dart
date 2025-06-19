import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'سياسة الخصوصية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.privacy_tip,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'سياسة الخصوصية',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'آخر تحديث: يناير 2024',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Introduction
              const Text(
                'مقدمة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'نحن في تطبيق التجارة الإلكترونية نلتزم بحماية خصوصيتك وبياناتك الشخصية. تشرح هذه السياسة كيفية جمع واستخدام وحماية معلوماتك عند استخدام تطبيقنا.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              
              // Information We Collect
              const Text(
                'المعلومات التي نجمعها',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              _PolicySection(
                title: 'المعلومات الشخصية',
                content: '• الاسم الكامل\n• رقم الهاتف\n• عنوان البريد الإلكتروني\n• العنوان الجغرافي\n• الصورة الشخصية',
              ),
              _PolicySection(
                title: 'معلومات التطبيق',
                content: '• سجل التصفح والبحث\n• المنتجات المفضلة\n• سلة التسوق\n• سجل الطلبات',
              ),
              _PolicySection(
                title: 'معلومات الجهاز',
                content: '• نوع الجهاز ونظام التشغيل\n• معرف الجهاز الفريد\n• معلومات الشبكة',
              ),
              const SizedBox(height: 24),
              
              // How We Use Information
              const Text(
                'كيفية استخدام المعلومات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'نستخدم معلوماتك لتقديم وتحسين خدماتنا، بما في ذلك:\n\n• معالجة الطلبات والمدفوعات\n• التواصل معك بخصوص طلباتك\n• تحسين تجربة المستخدم\n• إرسال إشعارات مهمة\n• تحليل استخدام التطبيق',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              
              // Information Sharing
              const Text(
                'مشاركة المعلومات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'لا نبيع أو نؤجر أو نشارك معلوماتك الشخصية مع أطراف ثالثة إلا في الحالات التالية:\n\n• عند الحصول على موافقتك الصريحة\n• لتقديم الخدمات المطلوبة (مثل التوصيل)\n• عند الالتزام بالقوانين والأنظمة\n• لحماية حقوقنا وسلامة المستخدمين',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              
              // Data Security
              const Text(
                'أمان البيانات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'نحن نستخدم تقنيات تشفير متقدمة لحماية بياناتك:\n\n• تشفير SSL/TLS لجميع الاتصالات\n• تشفير كلمات المرور\n• حماية من الهجمات السيبرانية\n• مراقبة مستمرة للأمان\n• نسخ احتياطية منتظمة',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              
              // User Rights
              const Text(
                'حقوق المستخدم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'لديك الحق في:\n\n• الوصول إلى معلوماتك الشخصية\n• تصحيح أو تحديث بياناتك\n• حذف حسابك وبياناتك\n• سحب الموافقة على جمع البيانات\n• تصدير بياناتك\n• تقديم شكوى إلى الجهات المختصة',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              
              // Cookies
              const Text(
                'ملفات تعريف الارتباط (Cookies)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'نستخدم ملفات تعريف الارتباط لتحسين تجربة التصفح:\n\n• حفظ تفضيلاتك\n• تحليل استخدام التطبيق\n• تحسين الأداء\n• تخصيص المحتوى',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              
              // Children's Privacy
              const Text(
                'خصوصية الأطفال',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'لا نجمع عمداً معلومات من الأطفال دون سن 13 عاماً. إذا اكتشفنا أننا جمعنا معلومات من طفل دون السن القانوني، سنقوم بحذفها فوراً.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              
              // Changes to Policy
              const Text(
                'تغييرات السياسة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'قد نقوم بتحديث هذه السياسة من وقت لآخر. سنقوم بإشعارك بأي تغييرات جوهرية عبر التطبيق أو البريد الإلكتروني.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              
              // Contact Information
              const Text(
                'معلومات التواصل',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'إذا كان لديك أي أسئلة حول سياسة الخصوصية، يمكنك التواصل معنا:\n\n• عبر صفحة "اتصل بنا" في التطبيق\n• عبر البريد الإلكتروني: privacy@ecommerce.com\n• عبر الهاتف: +1234567890',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 32),
              
              // Footer
              Center(
                child: Text(
                  '© 2024 تطبيق التجارة الإلكترونية. جميع الحقوق محفوظة.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
} 