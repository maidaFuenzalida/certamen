import 'package:flutter/material.dart';

import 'home.dart';
import 'map.dart';
import 'cart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // índice del bottom bar (0 = perfil)
  int _currentIndex = 0;

  // color celeste principal
  static const Color _turquoise = Color(0xFF45B7B7);

  // estados de “presionado”
  bool _menuPressed = false;
  bool _cartPressed = false;
  bool _recetasPressed = false;
  bool _favPressed = false;
  bool _editPressed = false;
  bool _ordersPressed = false;

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // =====================
      // APP BAR PERSONALIZADO
      // =====================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: cs.background,
        title: Row(
          children: [
            // BOTÓN MENÚ (gris → celeste)
            GestureDetector(
              onTapDown: (_) => setState(() => _menuPressed = true),
              onTapCancel: () => setState(() => _menuPressed = false),
              onTapUp: (_) {
                setState(() => _menuPressed = false);
                // aquí podrías abrir el drawer más adelante
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.menu,
                  color: _menuPressed ? _turquoise : Colors.grey,
                ),
              ),
            ),

            // LOGO CENTRADO (texto por ahora)
            Expanded(
              child: Center(
                child: Text(
                  'La Reina +',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
            ),

            // BOTÓN CARRITO (gris → celeste)
            GestureDetector(
              onTapDown: (_) => setState(() => _cartPressed = true),
              onTapCancel: () => setState(() => _cartPressed = false),
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

      // =====================
      // CUERPO DEL PERFIL
      // =====================
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // FOTO PERFIL
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade300,
                // si después tienes una foto real puedes usar foregroundImage
                child: const Icon(
                  Icons.person,
                  size: 52,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // NOMBRE Y TELÉFONO
              const Text(
                'Perfil usuario',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+569 8320 0171',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              // BOTONES CIRCULARES: RECETAS + FAVORITOS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mis recetas médicas
                  GestureDetector(
                    onTapDown: (_) => setState(() => _recetasPressed = true),
                    onTapCancel: () => setState(() => _recetasPressed = false),
                    onTapUp: (_) {
                      setState(() => _recetasPressed = false);
                      // aquí podrías abrir pantalla de recetas
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: _recetasPressed
                                  ? _turquoise
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              if (_recetasPressed)
                                BoxShadow(
                                  color: _turquoise.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: _recetasPressed
                                ? _turquoise
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mis Recetas\nMédicas',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),

                  // Favoritos
                  GestureDetector(
                    onTapDown: (_) => setState(() => _favPressed = true),
                    onTapCancel: () => setState(() => _favPressed = false),
                    onTapUp: (_) {
                      setState(() => _favPressed = false);
                      // aquí podrías abrir favoritos
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: _favPressed
                                  ? _turquoise
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              if (_favPressed)
                                BoxShadow(
                                  color: _turquoise.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: _favPressed
                                ? _turquoise
                                : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Favoritos',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // LÍNEA SEPARADORA
              Divider(color: Colors.grey.shade300, height: 32),

              // ====== ITEM: EDITAR PERFIL ======
              GestureDetector(
                onTapDown: (_) => setState(() => _editPressed = true),
                onTapCancel: () => setState(() => _editPressed = false),
                onTapUp: (_) {
                  setState(() => _editPressed = false);
                  // abrir pantalla de edición
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: _editPressed
                            ? _turquoise
                            : Colors.deepPurple.shade200,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Editar Perfil',
                          style: TextStyle(
                            fontSize: 16,
                            color: _editPressed
                                ? _turquoise
                                : Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: _editPressed ? _turquoise : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              Divider(color: Colors.grey.shade300, height: 32),

              // ====== ITEM: COMPRAS RECIENTES ======
              GestureDetector(
                onTapDown: (_) => setState(() => _ordersPressed = true),
                onTapCancel: () => setState(() => _ordersPressed = false),
                onTapUp: (_) {
                  setState(() => _ordersPressed = false);
                  // abrir compras recientes
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: _ordersPressed
                            ? _turquoise
                            : Colors.deepPurple.shade200,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Compras recientes',
                          style: TextStyle(
                            fontSize: 16,
                            color: _ordersPressed
                                ? _turquoise
                                : Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: _ordersPressed ? _turquoise : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // =====================
      // BOTTOM NAV BAR
      // =====================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _turquoise,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        ],
      ),
    );
  }
}
