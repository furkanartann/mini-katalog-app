import 'dart:io';
import 'dart:convert';
import '../models/product.dart';

// Ağ isteklerini tek bir yerde toplamak için repository pattern kullandık.
// Ekstra paket kullanmak yerine dart:io içindeki HttpClient tercih edildi.
class ProductRepository {
  static const String _baseUrl = 'fakestoreapi.com';

  // Tüm ürünleri API'den çeker ve Product listesine dönüştürür.
  Future<List<Product>> fetchAllProducts() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.https(_baseUrl, '/products'),
      );
      request.headers.set('Accept', 'application/json');

      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }

      final body = await response.transform(utf8.decoder).join();
      final List<dynamic> jsonList = json.decode(body) as List<dynamic>;

      return jsonList
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Ürünler yüklenirken hata: $e');
    } finally {
      // İstek başarılı ya da hatalı olsun, client her durumda kapatılır.
      client.close();
    }
  }

  // Belirli bir kategoriye ait ürünleri döner.
  // Şu an uygulama içi filtreleme kullanılıyor, bu metot ilerisi için hazır.
  Future<List<Product>> fetchProductsByCategory(String category) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.https(_baseUrl, '/products/category/$category'),
      );
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final List<dynamic> jsonList = json.decode(body) as List<dynamic>;

      return jsonList
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Kategori ürünleri yüklenirken hata: $e');
    } finally {
      client.close();
    }
  }

  // Mevcut kategori listesini API'den çeker.
  // Ana sayfadaki kategori filtresi bu veriyle oluşturuluyor.
  Future<List<String>> fetchCategories() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.https(_baseUrl, '/products/categories'),
      );
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final List<dynamic> jsonList = json.decode(body) as List<dynamic>;

      return jsonList.map((item) => item.toString()).toList();
    } catch (e) {
      throw Exception('Kategoriler yüklenirken hata: $e');
    } finally {
      client.close();
    }
  }
}
