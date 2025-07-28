import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/config/review_config.dart';
import '../../view_models/provider_reviews_view_model.dart';
import '../../widgets/modern_loader.dart';

class ProviderReviewsScreen extends StatefulWidget {
  final String providerId;
  final String providerName;

  const ProviderReviewsScreen({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  late ProviderReviewsViewModel _viewModel;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _viewModel = ProviderReviewsViewModel(
      apiClient: context.read<ApiClient>(), 
      providerId: widget.providerId,
    );
    _scrollController = ScrollController();
    _setupScrollListener();
    _loadReviews();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (_viewModel.showLoadMore) {
          _viewModel.loadMoreReviews();
        }
      }
    });
  }

  Future<void> _loadReviews() async {
    await _viewModel.loadProviderReviews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'اليوم';
    } else if (difference == 1) {
      return 'أمس';
    } else if (difference < 30) {
      return '$difference يوم';
    } else if (difference < 365) {
      final months = (difference / 30).round();
      return '$months شهر';
    } else {
      final years = (difference / 365).round();
      return '$years سنة';
    }
  }

  Widget _buildStarRating(int? rating) {
    if (rating == null) return const SizedBox.shrink();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildRatingItem(String label, int? value) {
    if (value == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          _buildStarRating(value),
        ],
      ),
    );
  }

  String _getQuestionTitle(String fieldKey) {
    final question = ReviewConfig.getQuestionByKey(fieldKey);
    return question?.title ?? fieldKey;
  }

  String _formatValueForMoney(String? value) {
    if (value == null || value.isEmpty) return '';
    // If it's already formatted (contains Arabic), return as is
    if (value.contains('قيمة')) return value;
    // Otherwise, find the full text from config
    final question = ReviewConfig.getQuestionByKey('valueForMoney');
    if (question?.options != null) {
      final option = question!.options!.firstWhere(
        (opt) => opt.startsWith('$value.'),
        orElse: () => value,
      );
      return option;
    }
    return value;
  }

  Widget _buildReviewCard(review) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'مراجعة زبون',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  _formatDate(review.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Experience description
            if (review.experienceDescription != null && review.experienceDescription!.isNotEmpty) ...[
              Text(
                _getQuestionTitle('experienceDescription'),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  review.experienceDescription!,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Ratings
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildRatingItem(_getQuestionTitle('overallSatisfaction'), review.overallSatisfaction),
                  _buildRatingItem(_getQuestionTitle('itemQuality'), review.itemQuality),
                  _buildRatingItem(_getQuestionTitle('communication'), review.communication),
                  _buildRatingItem(_getQuestionTitle('timeliness'), review.timeliness),
                  _buildRatingItem(_getQuestionTitle('netPromoterScore'), review.netPromoterScore),
                ],
              ),
            ),
            
            // Additional info
            if (review.valueForMoney != null || review.willUseAgain != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (review.valueForMoney != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_getQuestionTitle('valueForMoney')}: ${_formatValueForMoney(review.valueForMoney)}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (review.willUseAgain != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: review.willUseAgain! ? Colors.blue[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_getQuestionTitle('willUseAgain')}: ${review.willUseAgain! ? ReviewConfig.yesText : ReviewConfig.noText}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: review.willUseAgain! ? Colors.blue : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'مراجعات الزبائن - ${widget.providerName}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: ChangeNotifierProvider.value(
          value: _viewModel,
          child: Consumer<ProviderReviewsViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading && viewModel.reviews.isEmpty) {
                return const Center(child: ModernLoader());
              }

              if (viewModel.error != null && viewModel.reviews.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.error!,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.refreshReviews(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (viewModel.reviews.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد مراجعات لهذا البائع بعد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ستظهر مراجعات الزبائن هنا بعد إضافتها',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => viewModel.refreshReviews(),
                child: Column(
                  children: [
                    // Reviews count header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        'إجمالي المراجعات: ${viewModel.totalCount}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: viewModel.reviews.length,
                        itemBuilder: (context, index) {
                          final review = viewModel.reviews[index];
                          return _buildReviewCard(review);
                        },
                      ),
                    ),
                    
                    // Load More Button
                    if (viewModel.showLoadMore)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: viewModel.isLoadingMore ? null : () async {
                            await viewModel.loadMoreReviews();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor: Colors.green.withOpacity(0.2),
                          ),
                          child: viewModel.isLoadingMore
                              ? const SizedBox(height: 20, width: 20, child: ModernLoader())
                              : const Text(
                                  'تحميل المزيد',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Cairo',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 