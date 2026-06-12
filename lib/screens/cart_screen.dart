import 'package:flutter/material.dart';
import '../models/product.dart';

class CartScreen extends StatefulWidget {
  final List<Product> cartItems;
  final Function(List<Product>)? onOrderCompleted;

  const CartScreen({
    super.key,
    required this.cartItems,
    this.onOrderCompleted,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Product> _items;

  @override
  void initState() {
    super.initState();
    // Widget'a gelen listeyi kopyalıyoruz; böylece local değişiklikler
    // HomeScreen'deki orijinal listeyi doğrudan bozmaz.
    _items = List.from(widget.cartItems);
  }

  double get _total => _items.fold(0.0, (s, i) => s + i.price);

  // Kargo ücreti şimdilik sıfır; ilerleyen sürümde değişebilir.
  double get _shipping => _items.isEmpty ? 0 : 0;

  // Hem local listeden hem orijinal listeden siler; HomeScreen badge'i güncellensin.
  void _remove(int index) {
    setState(() {
      _items.removeAt(index);
      widget.cartItems.removeAt(index);
    });
  }

  // Sipariş tamamlandığında onay dialogu gösterir, ardından sepeti temizler.
  void _checkout() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFFF27A1A), size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Siparişiniz Alındı!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              Text(
                '\$${_total.toStringAsFixed(2)} tutarındaki\n${_items.length} ürün sipariş edildi.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF666666), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onOrderCompleted != null) {
                      widget.onOrderCompleted!(_items);
                    }
                    Navigator.pop(context);
                    // Her iki listeyi de temizle; ana sayfadaki badge sıfırlansın
                    setState(() { _items.clear(); widget.cartItems.clear(); });
                    Navigator.pop(context);
                  },
                  child: const Text('Tamam',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            const Text('Sepetim',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            if (_items.isNotEmpty)
              Text('${_items.length} ürün',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF999999))),
          ],
        ),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() { _items.clear(); widget.cartItems.clear(); });
              },
              child: const Text('Sepeti Temizle',
                  style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12)),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: _items.isEmpty ? _buildEmpty() : _buildContent(),
    );
  }

  // Sepet boşsa gösterilen ekran
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 44, color: Color(0xFFF27A1A)),
          ),
          const SizedBox(height: 20),
          const Text('Sepetiniz Boş',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          const Text('Ürün eklemek için alışverişe başlayın',
              style: TextStyle(color: Color(0xFF999999), fontSize: 13)),
          const SizedBox(height: 28),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Alışverişe Başla',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // Ürün listesi + fiyat özeti + ödeme butonu
  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final p = _items[i];
              return Dismissible(
                key: Key('${p.id}-$i'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _remove(i),
                // Sola kaydırıldığında görünen kırmızı silme arka planı
                background: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red, size: 24),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Ürün görseli
                        Container(
                          width: 76, height: 76,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Image.network(p.image,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFFCCCCCC))),
                        ),
                        const SizedBox(width: 12),
                        // Ad, kategori ve fiyat
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1A1A1A),
                                      height: 1.3,
                                      fontWeight: FontWeight.w400)),
                              const SizedBox(height: 4),
                              Text(
                                p.category[0].toUpperCase() +
                                    p.category.substring(1),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF999999)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${p.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF27A1A)),
                              ),
                            ],
                          ),
                        ),
                        // X butonu ile ürünü çıkar
                        IconButton(
                          onPressed: () => _remove(i),
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFFCCCCCC), size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Alt ödeme paneli: fiyat özeti + sipariş butonu
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Ürünler toplamı',
                        '\$${_total.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Kargo', 'Ücretsiz',
                        valueColor: Colors.green.shade600),
                    const Divider(height: 20, color: Color(0xFFEEEEEE)),
                    _buildSummaryRow('Toplam',
                        '\$${(_total + _shipping).toStringAsFixed(2)}',
                        isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _checkout,
                  child: Text(
                    'Siparişi Tamamla  •  \$${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Özet satırı: isBold ile toplam satırı, valueColor ile özel renk desteği.
  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: isBold
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF666666),
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 15 : 13,
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ??
                    (isBold
                        ? const Color(0xFFF27A1A)
                        : const Color(0xFF1A1A1A)))),
      ],
    );
  }
}
