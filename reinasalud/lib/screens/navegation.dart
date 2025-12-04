import 'package:flutter/material.dart';

class ReinaNavigationDrawer extends StatelessWidget {
  const ReinaNavigationDrawer({super.key});

  static const Color turquoise = Color(0xFF45B7B7);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            // --------------------------
            // FLECHA PARA CERRAR
            // --------------------------
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: Colors.black87,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // ==========================
            // CONTENIDO SCROLEABLE (EVITA OVERFLOW)
            // ==========================
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // --------------------------
                  // ICONO DE PERFIL SIMPLE
                  // --------------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 34,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Perfil usuario",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "+569 8320 0171",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.grey.shade300, thickness: 1),

                  // --------------------------
                  // OPCIONES PRINCIPALES
                  // --------------------------
                  _drawerItem(
                    icon: Icons.favorite,
                    label: "Favoritos",
                    iconColor: Colors.red,
                    onTap: () {},
                  ),
                  _drawerItem(
                    icon: Icons.description_outlined,
                    label: "Mis Recetas",
                    iconColor: turquoise,
                    onTap: () {},
                  ),
                  _drawerItem(
                    icon: Icons.info_outline,
                    label: "Información",
                    iconColor: turquoise,
                    onTap: () {},
                  ),

                  Divider(color: Colors.grey.shade300, thickness: 1),

                  // --------------------------
                  // OPCIONES SECUNDARIAS
                  // --------------------------
                  _drawerItem(
                    icon: Icons.settings,
                    label: "Ajustes",
                    iconColor: turquoise,
                    onTap: () {},
                  ),
                  _drawerItem(
                    icon: Icons.chat_bubble_outline,
                    label: "Ayuda",
                    iconColor: turquoise,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // --------------------------
            // LOGO / COPYRIGHT
            // --------------------------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "© Reina Salud",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // ITEM REUTILIZABLE
  // ================================
  Widget _drawerItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 26),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }
}
