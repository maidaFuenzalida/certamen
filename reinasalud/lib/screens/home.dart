import 'package:flutter/material.dart';

import 'profile.dart';
import 'map.dart';
import 'cart.dart';
import 'search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // 0 perfil, 1 home, 2 mapa, 3 carrito

  // Carruseles
  final PageController _bannerController = PageController();
  final PageController _offersController = PageController(viewportFraction: 0.8);

  // índices actuales de cada carrusel
  int _bannerPage = 0;
  int _offersPage = 0;

  static const int _bannerTotal = 3;
  static const int _offersTotal = 3;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const ProfileScreen();
        break;
      case 1:
        screen = const HomeScreen();
        break;
      case 2:
        screen = const MapScreen();
        break;
      case 3:
      default:
        screen = const CartScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // Mover carrusel de banners
  void _goBanner(int delta) {
    final newPage = _bannerPage + delta;
    if (newPage < 0 || newPage >= _bannerTotal) return;
    _bannerController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Mover carrusel de ofertas
  void _goOffers(int delta) {
    final newPage = _offersPage + delta;
    if (newPage < 0 || newPage >= _offersTotal) return;
    _offersController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _offersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // AppBar similar al diseño: menú izquierda + carrito derecha
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: cs.background,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Barra de búsqueda (como en el diseño)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search),
                  SizedBox(width: 12),
                  Text('Buscar remedio'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // =========================
          // CARRUSEL 1 – BANNERS
          // =========================
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                PageView(
                  controller: _bannerController,
                  onPageChanged: (i) => setState(() => _bannerPage = i),
                  children: [
                    _BannerCard(
                      color: const Color(0xFF5B2ECC), // morado tipo promo
                      title: '35% OFF',
                      subtitle: 'En medicamentos inscritos\ncon tu RUT',
                      buttonText: 'Comprar',
                    ),
                    _BannerCard(
                      color: Colors.purple.shade700,
                      title: '50% OFF',
                      subtitle: 'En tu segunda unidad\nde vitaminas',
                      buttonText: 'Ver más',
                    ),
                    _BannerCard(
                      color: Colors.deepPurple,
                      title: 'Envío gratis',
                      subtitle: 'Compras sobre \$20.000',
                      buttonText: 'Aprovechar',
                    ),
                  ],
                ),

                // Flecha izquierda
                if (_bannerPage > 0)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                        onPressed: () => _goBanner(-1),
                      ),
                    ),
                  ),

                // Flecha derecha
                if (_bannerPage < _bannerTotal - 1)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: Colors.white,
                        onPressed: () => _goBanner(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // =========================
          // Título "Ofertas de hoy"
          // =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ofertas de hoy',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 8),

          // =========================
          // CARRUSEL 2 – OFERTAS
          // =========================
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView(
                  controller: _offersController,
                  onPageChanged: (i) => setState(() => _offersPage = i),
                  children: const [
                    _ProductCard(
                      title: 'Mascota',
                      subtitle: 'Alimento y cuidados',
                      discount: '50% OFF',
                    ),
                    _ProductCard(
                      title: 'Pañales y Alimentos…',
                      subtitle: 'Productos seleccionados',
                      discount: '40% OFF',
                    ),
                    _ProductCard(
                      title: 'Cuidado personal',
                      subtitle: 'Higiene y belleza',
                      discount: '30% OFF',
                    ),
                  ],
                ),

                // Flecha izquierda
                if (_offersPage > 0)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => _goOffers(-1),
                      ),
                    ),
                  ),

                // Flecha derecha
                if (_offersPage < _offersTotal - 1)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () => _goOffers(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Carrito'),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final String buttonText;

  const _BannerCard({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.onPrimary,
                foregroundColor: color,
              ),
              onPressed: () {},
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String discount;

  const _ProductCard({
    required this.title,
    required this.subtitle,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // “Imagen” morada simulada
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF5B2ECC),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            discount,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
