import 'package:flutter/material.dart';

import 'profile.dart';
import 'map.dart';
import 'cart.dart';
import 'search.dart';
import 'navegation.dart'; // 👈 IMPORTA TU DRAWER

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // 0 perfil, 1 home, 2 mapa

  // Estados de “presionado”
  bool _menuPressed = false;
  bool _cartPressed = false;
  bool _searchActive = false;
  bool _offersArrowPressed = false;

  // Carrusel banners
  final PageController _bannerController = PageController();
  int _bannerPage = 0;

  // URLs de promociones (ya las tenías)
  final List<String> _bannerImages = const [
    'https://firebasestorage.googleapis.com/v0/b/reinasalud1.firebasestorage.app/o/promociones%2FPromocion1.png?alt=media&token=0b9e7f28-bb1e-4df8-800e-e23b3f5308f2',
    'https://firebasestorage.googleapis.com/v0/b/reinasalud1.firebasestorage.app/o/promociones%2FPromocion3.jpg?alt=media&token=fc46f5b3-42ec-411c-af45-61d17f0ae579',
    'https://firebasestorage.googleapis.com/v0/b/reinasalud1.firebasestorage.app/o/promociones%2Fpromocion4.jpg?alt=media&token=e585aaa2-ded7-45db-98cd-1cbada3d551f',
  ];

  final List<String> _offerImages = const [
    'https://firebasestorage.googleapis.com/v0/b/reinasalud1.firebasestorage.app/o/promociones%2FPromocion2.png?alt=media&token=44503c80-6c67-4053-9679-404848305ffa',
    'https://firebasestorage.googleapis.com/v0/b/reinasalud1.firebasestorage.app/o/promociones%2Fpromocion5.png?alt=media&token=cc8b157f-21c7-4123-bdca-7cc2d9746328',
    'https://firebasestorage.googleapis.com/v0/b/reinasalud1.firebasestorage.app/o/promociones%2Fpromocion7.png?alt=media&token=a2d27822-a4ed-449a-b232-a191519ffe61',
  ];

  // Color celeste principal
  static const Color _turquoise = Color(0xFF45B7B7);

  // Navegación bottom bar
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
      default:
        screen = const MapScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // Cambiar página del carrusel principal
  void _goBanner(int delta) {
    final total = _bannerImages.length;
    final newPage = _bannerPage + delta;
    if (newPage < 0 || newPage >= total) return;

    _bannerController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const ReinaNavigationDrawer(), // 👈 Drawer lateral

      // AppBar: menú izquierda + carrito derecha
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: cs.background,
        title: Row(
          children: [
            // ====== BOTÓN MENÚ (3 rayitas) ======
            Builder(
              builder: (ctx) => GestureDetector(
                onTapDown: (_) {
                  setState(() => _menuPressed = true);
                },
                onTapCancel: () {
                  setState(() => _menuPressed = false);
                },
                onTapUp: (_) {
                  setState(() => _menuPressed = false);
                  Scaffold.of(ctx).openDrawer(); // 👈 abre el drawer
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.menu,
                    color: _menuPressed ? _turquoise : Colors.grey,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ====== BOTÓN CARRITO ======
            GestureDetector(
              onTapDown: (_) {
                setState(() => _cartPressed = true);
              },
              onTapCancel: () {
                setState(() => _cartPressed = false);
              },
              onTapUp: (_) {
                setState(() => _cartPressed = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: _cartPressed ? _turquoise : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // =========================
          // BARRA DE BÚSQUEDA
          // =========================
          GestureDetector(
            onTapDown: (_) {
              setState(() => _searchActive = true);
            },
            onTapCancel: () {
              setState(() => _searchActive = false);
            },
            onTapUp: (_) {
              setState(() => _searchActive = false);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  width: 2,
                  color: _searchActive
                      ? _turquoise // contorno celeste al presionar
                      : const Color(0xFFB0BEC5), // gris al inicio
                ),
                boxShadow: [
                  if (_searchActive)
                    BoxShadow(
                      color: _turquoise.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.search,
                    color: Color(0xFF90A4AE), // icono gris
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Buscar remedio',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF78909C), // texto gris
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // =========================
          // CARRUSEL BANNER PRINCIPAL
          // =========================
          if (_bannerImages.isNotEmpty)
            SizedBox(
              height: 170,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (i) => setState(() => _bannerPage = i),
                    itemCount: _bannerImages.length,
                    itemBuilder: (context, index) {
                      final url = _bannerImages[index];
                      return _PromoBanner(imageUrl: url);
                    },
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
                  if (_bannerPage < _bannerImages.length - 1)
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
          // TÍTULO "Ofertas de hoy"
          // =========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ofertas de hoy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Flecha “ver más” gris → celeste
              GestureDetector(
                onTapDown: (_) {
                  setState(() => _offersArrowPressed = true);
                },
                onTapCancel: () {
                  setState(() => _offersArrowPressed = false);
                },
                onTapUp: (_) {
                  setState(() => _offersArrowPressed = false);
                  // aquí si quieres navegar a otra pantalla de ofertas
                },
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: _offersArrowPressed ? _turquoise : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // =========================
          // LISTA HORIZONTAL DE OFERTAS
          // =========================
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _offerImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final url = _offerImages[index];
                return _OfferCard(imageUrl: url);
              },
            ),
          ),
        ],
      ),

      // BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _turquoise, // pestaña activa celeste
        unselectedItemColor: Colors.grey, // pestañas inactivas gris
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        ],
      ),
    );
  }
}

// =========================
// WIDGETS DE APOYO
// =========================

class _PromoBanner extends StatelessWidget {
  final String imageUrl;

  const _PromoBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String imageUrl;

  const _OfferCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
