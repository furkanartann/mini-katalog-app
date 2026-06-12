import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../data/product_repository.dart';
import '../widgets/product_card.dart';
import 'favorites_screen.dart';

// Sıralama seçenekleri için enum; switch-case okunabilirliği için tercih edildi.
enum SortOption { defaultOrder, priceLow, priceHigh, ratingHigh }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository _repo = ProductRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = [];       // API'den gelen ham liste, hiç değişmez
  List<Product> _filteredProducts = [];  // Arama + kategori + sıralama sonucu
  List<Product> _cartItems = [];
  List<Order> _orders = [];
  Set<int> _favoriteIds = {};            // Favori ürün ID'leri; hızlı arama için Set
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'all';
  List<String> _categories = ['all'];
  SortOption _sortOption = SortOption.defaultOrder;

  // API'deki İngilizce kategori isimlerini Material ikonlarla eşleştirir.
  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'all': return Icons.apps_rounded;
      case 'electronics': return Icons.phone_android_rounded;
      case 'jewelery': return Icons.diamond_outlined;
      case "men's clothing": return Icons.man_rounded;
      case "women's clothing": return Icons.woman_rounded;
      default: return Icons.category_outlined;
    }
  }

  // Kullanıcıya gösterilecek Türkçe kategori etiketleri.
  String _categoryLabel(String cat) {
    switch (cat) {
      case 'all': return 'Tümü';
      case 'electronics': return 'Elektronik';
      case 'jewelery': return 'Mücevher';
      case "men's clothing": return 'Erkek';
      case "women's clothing": return 'Kadın';
      default: return cat[0].toUpperCase() + cat.substring(1);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    // Arama kutusuna her karakter girildiğinde filtreleme tetiklensin.
    _searchController.addListener(_filterAndSort);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final products = await _repo.fetchAllProducts();
      final categories = await _repo.fetchCategories();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _categories = ['all', ...categories];
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  // Arama metni, seçili kategori ve sıralama seçeneğine göre listeyi günceller.
  // Her koşul değiştiğinde bu metot çağrılır; sonuç _filteredProducts'a yazılır.
  void _filterAndSort() {
    final q = _searchController.text.toLowerCase();
    List<Product> result = _allProducts.where((p) {
      final matchSearch = p.title.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final matchCat = _selectedCategory == 'all' ||
          p.category == _selectedCategory;
      return matchSearch && matchCat;
    }).toList();

    switch (_sortOption) {
      case SortOption.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingHigh:
        result.sort((a, b) => b.ratingRate.compareTo(a.ratingRate));
        break;
      case SortOption.defaultOrder:
        break;
    }

    setState(() => _filteredProducts = result);
  }

  // Ürünü sepete ekler ve kısa bir geri bildirim gösterir.
  void _addToCart(Product product) {
    setState(() => _cartItems.add(product));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Sepete eklendi',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Ürünü favorilere ekler ya da çıkarır.
  // State HomeScreen'de tutulduğu için FavoritesScreen ile senkronize çalışır.
  void _toggleFavorite(Product product) {
    setState(() {
      if (_favoriteIds.contains(product.id)) {
        _favoriteIds.remove(product.id);
      } else {
        _favoriteIds.add(product.id);
      }
    });
  }

  // Favori ID seti üzerinden tam ürün nesnelerini döndürür.
  List<Product> get _favoriteProducts =>
      _allProducts.where((p) => _favoriteIds.contains(p.id)).toList();

  // Sepet badge metni: 9'dan fazla ürün varsa "9+" göster, icon taşmasın.
  String get _cartBadge =>
      _cartItems.length > 9 ? '9+' : '${_cartItems.length}';

  // Alt çekmecede sıralama seçeneklerini gösterir.
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final options = [
          (SortOption.defaultOrder, 'Varsayılan Sıralama', Icons.sort_rounded),
          (SortOption.priceLow, 'Fiyat: Düşükten Yükseğe', Icons.arrow_upward_rounded),
          (SortOption.priceHigh, 'Fiyat: Yüksekten Düşüğe', Icons.arrow_downward_rounded),
          (SortOption.ratingHigh, 'En Yüksek Puan', Icons.star_rounded),
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Çekmeceyi aşağı kaydırmak için kullanılan tutaç çizgisi
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sıralama',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A))),
                ),
              ),
              const SizedBox(height: 8),
              ...options.map((opt) {
                final isSelected = _sortOption == opt.$1;
                return ListTile(
                  leading: Icon(opt.$3,
                      color: isSelected
                          ? const Color(0xFFF27A1A)
                          : const Color(0xFF666666),
                      size: 22),
                  title: Text(opt.$2,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFFF27A1A)
                              : const Color(0xFF1A1A1A))),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Color(0xFFF27A1A), size: 20)
                      : null,
                  onTap: () {
                    setState(() => _sortOption = opt.$1);
                    _filterAndSort();
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF27A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Mini Katalog',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            actions: [
              // 1. Favoriler (Solda)
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FavoritesScreen(
                        favorites: _favoriteProducts,
                        favoriteIds: _favoriteIds,
                        onFavoriteToggle: _toggleFavorite,
                        onAddToCart: _addToCart,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.favorite_border_rounded,
                        color: Color(0xFF1A1A1A), size: 24),
                    if (_favoriteIds.isNotEmpty)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          constraints: const BoxConstraints(
                              minWidth: 14, minHeight: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF27A1A),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _favoriteIds.length > 9
                                  ? '9+'
                                  : '${_favoriteIds.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // 2. Siparişlerim (Ortada)
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/orders',
                    arguments: _orders,
                  );
                },
                icon: const Icon(Icons.inventory_2_outlined,
                    color: Color(0xFF1A1A1A), size: 24),
              ),
              // 3. Sepetim (Sağda)
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context, '/cart',
                    arguments: {
                      'cartItems': _cartItems,
                      'onOrderCompleted': (items) {
                        setState(() {
                          _orders.add(Order(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            date: DateTime.now(),
                            items: List.from(items),
                          ));
                        });
                      },
                    },
                  ).then((_) => setState(() {}));
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        color: Color(0xFF1A1A1A), size: 24),
                    if (_cartItems.isNotEmpty)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          constraints: const BoxConstraints(
                              minWidth: 14, minHeight: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF27A1A),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _cartBadge,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF1A1A1A)),
                  decoration: InputDecoration(
                    hintText: 'Ürün veya marka ara',
                    hintStyle: const TextStyle(
                        color: Color(0xFFAAAAAA), fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF999999), size: 20),
                    // Bir şey yazılmışsa temizleme butonu göster
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Color(0xFF999999), size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _filterAndSort();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Color(0xFFF27A1A), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _loadProducts,
          color: const Color(0xFFF27A1A),
          child: CustomScrollView(
            slivers: [
              // Yatay kaydırılabilir kategori listesi
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                  child: SizedBox(
                    height: 72,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = cat);
                            _filterAndSort();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 64,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFF3E8)
                                        : const Color(0xFFF5F5F5),
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: const Color(0xFFF27A1A),
                                            width: 1.5)
                                        : null,
                                  ),
                                  child: Icon(_categoryIcon(cat),
                                    size: 20,
                                    color: isSelected
                                        ? const Color(0xFFF27A1A)
                                        : const Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _categoryLabel(cat),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? const Color(0xFFF27A1A)
                                        : const Color(0xFF666666),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Ürün sayısı ve sıralama butonu yan yana
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isLoading)
                        Text(
                          '${_filteredProducts.length} ürün',
                          style: const TextStyle(
                              color: Color(0xFF999999), fontSize: 13),
                        )
                      else
                        const SizedBox(),
                      // Aktif sıralama varsa buton turuncu kenarlık alır
                      GestureDetector(
                        onTap: _showSortSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _sortOption != SortOption.defaultOrder
                                  ? const Color(0xFFF27A1A)
                                  : const Color(0xFFEEEEEE),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swap_vert_rounded,
                                size: 16,
                                color: _sortOption != SortOption.defaultOrder
                                    ? const Color(0xFFF27A1A)
                                    : const Color(0xFF666666)),
                              const SizedBox(width: 4),
                              Text(
                                _sortOption == SortOption.defaultOrder
                                    ? 'Sırala'
                                    : _sortOption == SortOption.priceLow
                                        ? 'Fiyat ↑'
                                        : _sortOption == SortOption.priceHigh
                                            ? 'Fiyat ↓'
                                            : 'Puan ↓',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _sortOption != SortOption.defaultOrder
                                      ? const Color(0xFFF27A1A)
                                      : const Color(0xFF666666),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Yükleme, hata, boş sonuç ve ürün grid'i durumları
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                            color: Color(0xFFF27A1A), strokeWidth: 2.5),
                        SizedBox(height: 14),
                        Text('Ürünler yükleniyor...',
                            style: TextStyle(
                                color: Color(0xFF999999), fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.signal_wifi_off_outlined,
                              size: 56, color: Color(0xFFCCCCCC)),
                          const SizedBox(height: 16),
                          const Text('Bağlantı Hatası',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 8),
                          const Text('İnternet bağlantını kontrol et',
                              style:
                                  TextStyle(color: Color(0xFF999999))),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadProducts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF27A1A),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_filteredProducts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 56, color: Color(0xFFCCCCCC)),
                        const SizedBox(height: 16),
                        const Text('Sonuç bulunamadı',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 6),
                        Text(
                          '"${_searchController.text}" için ürün yok',
                          style: const TextStyle(color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final product = _filteredProducts[i];
                        return ProductCard(
                          product: product,
                          isFavorited: _favoriteIds.contains(product.id),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/detail',
                            arguments: {
                              'product': product,
                              'onAddToCart': _addToCart,
                              'isFavorited': _favoriteIds.contains(product.id),
                              'onFavoriteToggle': _toggleFavorite,
                            },
                          ).then((_) => setState(() {})),
                          onAddToCart: () => _addToCart(product),
                          onFavoriteToggle: () => _toggleFavorite(product),
                        );
                      },
                      childCount: _filteredProducts.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
