import 'product.dart';

// Sipariş verilerini tutan model sınıfı
class Order {
  final String id;
  final DateTime date;
  final List<Product> items;
  final double totalPrice;

  Order({
    required this.id,
    required this.date,
    required this.items,
  }) : totalPrice = items.fold(0.0, (sum, item) => sum + item.price);
}
