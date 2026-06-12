import 'package:flutter/material.dart';
import '../models/product.dart';

// Ürün detay ekranı; ürün bilgisini ve sepete ekleme callback'ini dışarıdan alır.
// Callback tasarımı sayesinde ekran, HomeScreen'deki sepet state'ini doğrudan değiştirebilir.
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final bool isFavorited;
  final Function(Product) onFavoriteToggle;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.isFavorited,
    required this.onFavoriteToggle,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  late bool _isWishlisted;
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.isFavorited;
  }

  // Tam, yarım ve boş yıldız ikonlarıyla puan gösterimi.
  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded,
              size: 14, color: Color(0xFFF27A1A));
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded,
              size: 14, color: Color(0xFFF27A1A));
        }
        return const Icon(Icons.star_border_rounded,
            size: 14, color: Color(0xFFDDDDDD));
      }),
    );
  }

  // Seçili adet kadar ürünü callback aracılığıyla sepete ekler.
  void _handleAddToCart() {
    for (int i = 0; i < _quantity; i++) {
      widget.onAddToCart(widget.product);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              _quantity > 1
                  ? '$_quantity ürün sepete eklendi'
                  : 'Sepete eklendi',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A1A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        // AppBar başlığı olarak kategori adı gösteriliyor
        title: Text(
          p.category[0].toUpperCase() + p.category.substring(1),
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isWishlisted = !_isWishlisted);
              widget.onFavoriteToggle(widget.product);
            },
            icon: Icon(
              _isWishlisted
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isWishlisted
                  ? const Color(0xFFF27A1A)
                  : const Color(0xFF666666),
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined,
                color: Color(0xFF666666), size: 22),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ürün görseli beyaz/gri arka plan üzerinde gösterilir
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: const Color(0xFFFAFAFA),
                    padding: const EdgeInsets.all(32),
                    child: Image.network(
                      p.image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Color(0xFFCCCCCC), size: 64),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFF27A1A), strokeWidth: 2),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fiyat en üstte ve belirgin şekilde gösteriliyor
                        Text(
                          '\$${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFF27A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStars(p.ratingRate),
                            const SizedBox(width: 6),
                            Text(
                              p.ratingRate.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xFFF27A1A),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${p.ratingCount} değerlendirme)',
                              style: const TextStyle(
                                  color: Color(0xFF999999), fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),

                        // Kargo, güvence ve iade bilgileri
                        _buildInfoRow(Icons.local_shipping_outlined,
                            'Ücretsiz Kargo', 'Yarın teslim'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.verified_user_outlined,
                            'Güvenli Alışveriş',
                            '100% orijinal ürün garantisi'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.replay_outlined,
                            'Kolay İade', '30 gün içinde ücretsiz iade'),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),

                        const Text('Ürün Açıklaması',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 8),
                        // Varsayılan olarak 3 satır göster; "Devamını gör" ile tam açılır
                        Text(
                          p.description,
                          maxLines: _descExpanded ? null : 3,
                          overflow: _descExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 13.5,
                              height: 1.65),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => setState(
                              () => _descExpanded = !_descExpanded),
                          child: Text(
                            _descExpanded
                                ? 'Daha az göster'
                                : 'Devamını gör',
                            style: const TextStyle(
                                color: Color(0xFFF27A1A),
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),

                        const Text('Ürün Detayları',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 12),
                        _buildDetailRow('Kategori',
                            p.category[0].toUpperCase() +
                                p.category.substring(1)),
                        _buildDetailRow('Puan', '${p.ratingRate} / 5.0'),
                        _buildDetailRow('Değerlendirme', '${p.ratingCount}'),
                        _buildDetailRow('Ürün No', '#${p.id}'),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sayfanın altında sabit duran adet seçici ve sepet butonu
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                // Adet seçici: minimum 1, üst sınır yok
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36, height: 44,
                        child: IconButton(
                          onPressed: () {
                            if (_quantity > 1)
                              setState(() => _quantity--);
                          },
                          icon: const Icon(Icons.remove,
                              size: 16, color: Color(0xFF666666)),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$_quantity',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A1A1A)),
                        ),
                      ),
                      SizedBox(
                        width: 36, height: 44,
                        child: IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add,
                              size: 16, color: Color(0xFF666666)),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _handleAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF27A1A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sepete Ekle',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
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

  // İkon, başlık ve alt başlık içeren bilgi satırı (kargo, güvence, iade).
  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFF27A1A)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11.5, color: Color(0xFF999999))),
          ],
        ),
      ],
    );
  }

  // Sabit genişlikli etiket sütunu ve yanındaki değer sütunundan oluşan satır.
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF999999))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
