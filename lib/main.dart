import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'models/product.dart';
import 'models/order.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Durum çubuğu ve gezinme çubuğu renklerini manuel olarak ayarlıyoruz
  // çünkü açık tema ile sistem UI renkleri otomatik uyuşmuyor.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MiniKatalogApp());
}

class MiniKatalogApp extends StatelessWidget {
  const MiniKatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Katalog',
      debugShowCheckedModeBanner: false,

      // Uygulamanın ana renk şeması: turuncu birincil renk, açık arka plan.
      // Tüm ekranlar bu temayı miras alır, her yerde ayrıca tanımlamaya gerek kalmaz.
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF27A1A),
          primary: const Color(0xFFF27A1A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF27A1A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),

      // Rota yönetimi merkezi olarak burada yapılıyor.
      // /detail rotası, ana sayfadan callback ile birlikte argüman alır;
      // böylece detay ekranı sepet state'ine doğrudan erişmek zorunda kalmaz.
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (_) => const SplashScreen());
          case '/home':
            return MaterialPageRoute(
                builder: (_) => const HomeScreen());
          case '/detail':
            final args = settings.arguments as Map<String, dynamic>;
            final product = args['product'] as Product;
            final onAddToCart = args['onAddToCart'] as Function(Product);
            final isFavorited = args['isFavorited'] as bool;
            final onFavoriteToggle = args['onFavoriteToggle'] as Function(Product);
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: product,
                onAddToCart: onAddToCart,
                isFavorited: isFavorited,
                onFavoriteToggle: onFavoriteToggle,
              ),
            );
          case '/cart':
            final args = settings.arguments as Map<String, dynamic>;
            final cart = args['cartItems'] as List<Product>;
            final onOrderCompleted = args['onOrderCompleted'] as Function(List<Product>);
            return MaterialPageRoute(
              builder: (_) => CartScreen(
                cartItems: cart,
                onOrderCompleted: onOrderCompleted,
              ),
            );
          case '/orders':
            final orders = settings.arguments as List<Order>;
            return MaterialPageRoute(
              builder: (_) => OrdersScreen(orders: orders),
            );
          default:
            return MaterialPageRoute(
                builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
