import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final double rating;
  final int? numOfReviews;
  final double starSize;
  final double fontSize;
  final bool showReviews;
  final MainAxisAlignment alignment;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.numOfReviews,
    this.starSize = 16,
    this.fontSize = 12,
    this.showReviews = true,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        // Star rating
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isFilled = starValue <= rating;
            final isHalfFilled = starValue - 0.5 <= rating && starValue > rating;
            
            return Icon(
              isFilled 
                ? Icons.star 
                : isHalfFilled 
                  ? Icons.star_half 
                  : Icons.star_border,
              size: starSize,
              color: Colors.amber,
            );
          }),
        ),
        const SizedBox(width: 8),
        // Rating text
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.amber,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Reviews count
        if (showReviews && numOfReviews != null && numOfReviews! > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($numOfReviews تقييم)',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: fontSize - 2,
            ),
          ),
        ],
      ],
    );
  }
} 