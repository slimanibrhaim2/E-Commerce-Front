import 'package:flutter/material.dart';
import '../../favorites/favorites_screen.dart';
import '../../../view_models/favorites_view_model.dart';
import '../../../repositories/product_repository.dart';
import 'package:provider/provider.dart';

class SearchAndFavoriteBar extends StatelessWidget {
  final int favoriteCount;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onFavoriteTap;

  const SearchAndFavoriteBar({
    Key? key,
    this.favoriteCount = 0,
    this.onSearch,
    this.onFavoriteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث هنا',
                  hintStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.indigo),
                    onPressed: () {},
                  ),
                ),
                onSubmitted: onSearch,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Favorite icon with badge
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.grey,
                  size: 32,
                ),
                if (favoriteCount > 0)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Center(
                        child: Text(
                          '$favoriteCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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