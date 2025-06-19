import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'لمحة عن تطبيقنا',
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
              // App Logo/Icon Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تطبيق التجارة الإلكترونية',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الإصدار 1.0.0',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // About Section
              const Text(
                'عن التطبيق',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'تطبيقنا هو منصة تجارة إلكترونية متطورة تتيح للمستخدمين شراء وبيع المنتجات بسهولة وأمان. بدأنا كمنصة C2C (من مستهلك إلى مستهلك) حيث يمكن للأفراد عرض منتجاتهم وبيعها مباشرة للمشترين.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              
              // Features Section
              const Text(
                'المميزات الرئيسية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.store,
                title: 'منصة C2C متطورة',
                description: 'تتيح للأفراد بيع منتجاتهم بسهولة وأمان',
              ),
              _FeatureItem(
                icon: Icons.search,
                title: 'بحث متقدم',
                description: 'البحث السريع والدقيق عن المنتجات',
              ),
              _FeatureItem(
                icon: Icons.favorite,
                title: 'قائمة المفضلة',
                description: 'حفظ المنتجات المفضلة للوصول السريع',
              ),
              _FeatureItem(
                icon: Icons.shopping_cart,
                title: 'سلة التسوق',
                description: 'إدارة مشترياتك بسهولة',
              ),
              _FeatureItem(
                icon: Icons.location_on,
                title: 'إدارة العناوين',
                description: 'حفظ وإدارة عناوين التوصيل',
              ),
              _FeatureItem(
                icon: Icons.security,
                title: 'أمان عالي',
                description: 'حماية بياناتك ومعلوماتك الشخصية',
              ),
              const SizedBox(height: 24),
              
              // Development Section
              const Text(
                'التطوير المستمر',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'نحن نعمل باستمرار على تطوير وتحسين التطبيق لتقديم أفضل تجربة للمستخدمين. نخطط لإضافة المزيد من المميزات والوظائف في الإصدارات القادمة.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              
              // Contact Section
              const Text(
                'تواصل معنا',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'للاستفسارات والاقتراحات، لا تتردد في التواصل معنا من خلال صفحة "اتصل بنا" في التطبيق.',
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

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Cairo',
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