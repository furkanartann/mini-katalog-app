import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

// StatefulWidget yapıldı çünkü favori kaldırıldığında ekranın
// anında güncellenmesi gerekiyor. StatelessWidget bunu yapamaz;
// state değişikliği ancak sayfadan çıkıp girince fark edilirdi.
class FavoritesScreen extends StatefulWidget {
  final List<Product> favorites;
  final Set<int> favoriteIds;
  final Function(Product) onFavoriteToggle;
  final Function(Product) onAddToCart;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.favoriteIds,
    required this.onFavoriteToggle,
    required this.onAddToCart,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<Product> _favorites;

  @override
  void initState() {
    super.initState();
    // Dışarıdan gelen listeyi kopyalıyoruz;
    // bu ekranda yapılan değişiklikler local olarak da yansıtılacak.
    _favorites = List.from(widget.favorites);
  }

  // Hem HomeScreen'deki state'i hem de bu ekranın local listesini günceller.
  void _handleToggle(Product product) {
    widget.onFavoriteToggle(product);
    setState(() {
      final isFav = _favorites.any((p) => p.id == product.id);
      if (isFav) {
        _favorites.removeWhere((p) => p.id == product.id);
      } else {
        _favorites.add(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A1A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Favorilerim',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            if (_favorites.isNotEmpty)
              Text('${_favorites.length} ürün',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF999999))),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border_rounded,
                        size: 44, color: Color(0xFFF27A1A)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Henüz Favori Yok',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 8),
                  const Text('Beğendiğin ürünleri kaydet',
                      style: TextStyle(
                          color: Color(0xFF999999), fontSize: 13)),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF27A1A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Ürünleri Keşfet',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _favorites.length,
              itemBuilder: (_, i) => ProductCard(
                product: _favorites[i],
                isFavorited: widget.favoriteIds.contains(_favorites[i].id),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: {
                      'product': _favorites[i],
                      'onAddToCart': widget.onAddToCart,
                      'isFavorited': widget.favoriteIds.contains(_favorites[i].id),
                      'onFavoriteToggle': _handleToggle,
                    },
                  ).then((_) {
                    setState(() {
                      _favorites.removeWhere((p) => !widget.favoriteIds.contains(p.id));
                    });
                  });
                },
                onAddToCart: () => widget.onAddToCart(_favorites[i]),
                onFavoriteToggle: () => _handleToggle(_favorites[i]),
              ),
            ),
    );
  }
}
