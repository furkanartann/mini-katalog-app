// FakeStore API'den gelen ürün verisini temsil eden model.
// API'nin döndürdüğü JSON yapısı birebir bu alanlara karşılık geliyor.
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double ratingRate;
  final int ratingCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.ratingRate,
    required this.ratingCount,
  });

  // API'den dönen ham JSON'u Product nesnesine dönüştürür.
  // rating alanı iç içe bir Map olduğu için ayrıca parse ediliyor.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      ratingRate: ((json['rating'] as Map<String, dynamic>)['rate'] as num).toDouble(),
      ratingCount: ((json['rating'] as Map<String, dynamic>)['count'] as num).toInt(),
    );
  }

  // Gerektiğinde nesneyi tekrar JSON'a çevirir.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': {
        'rate': ratingRate,
        'count': ratingCount,
      },
    };
  }

  @override
  String toString() => 'Product(id: $id, title: $title, price: $price)';
}
