import 'package:flutter/material.dart';
import '../models/product.dart';

// Ürün grid'inde her kartı temsil eden yeniden kullanılabilir widget.
// Kendi içinde state tutmuyor; favori ve sepet durumu dışarıdan geliyor.
// Böylece HomeScreen ve FavoritesScreen aynı kartı paylaşabiliyor.
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorited;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorited,
    required this.onTap,
    required this.onAddToCart,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst bölüm: ürün görseli ve sağ üstteki favori butonu
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10)),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFFAFAFA),
                      padding: const EdgeInsets.all(14),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                              color: Color(0xFFCCCCCC), size: 36),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Color(0xFFF27A1A), strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Favori ikonu: sağ üst köşede daire içinde
                  Positioned(
                    top: 6, right: 6,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorited
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFavorited
                              ? const Color(0xFFF27A1A)
                              : const Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Alt bölüm: ürün adı, puan ve fiyat + sepete ekle
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF1A1A1A),
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Puan satırı
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: Color(0xFFF27A1A)),
                            const SizedBox(width: 2),
                            Text(
                              product.ratingRate.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF666666),
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              ' (${product.ratingCount})',
                              style: const TextStyle(
                                  fontSize: 10, color: Color(0xFF999999)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Fiyat solda, sepete ekle butonu sağda
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF27A1A),
                              ),
                            ),
                            GestureDetector(
                              onTap: onAddToCart,
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF27A1A),
                                  borderRadius: BorderRadius.circular(7),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF27A1A)
                                          .withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
