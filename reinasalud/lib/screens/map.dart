import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'home.dart';
import 'profile.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // índice bottom bar → 0 perfil, 1 home, 2 mapa
  int _currentIndex = 2;

  // color celeste principal
  static const Color _turquoise = Color(0xFF45B7B7);

  // Centro aproximado de La Reina
  static const LatLng _laReinaCenter = LatLng(-33.4418, -70.5393);

  // Cadena seleccionada: 'cruz_verde', 'ahumada', 'salcobrand' o null = todas
  String? _selectedChain;

  // URLs de los logos (Firebase Storage)
  static const String cruzVerdeLogoUrl =
      'https://firebasestorage.googleapis.com/v0/b/reinasalud1.firebasestorage.app/o/logos%2FLogocruzverde.png?alt=media&token=4ccb4e8e-2c79-44f8-896d-dbabbb8f8494';
  static const String ahumadaLogoUrl =
      'https://firebasestorage.googleapis.com/v0/b/reinasalud1.firebasestorage.app/o/logos%2FLogo%20ahumada.png?alt=media&token=719cf382-5420-48fc-8494-3dc1df581fd1';
  static const String salcobrandLogoUrl =
      'https://firebasestorage.googleapis.com/v0/b/reinasalud1.firebasestorage.app/o/logos%2FLogosalcobrand.png?alt=media&token=633aa417-bbc5-4040-88d8-856d9c6a432c';

  // -----------------------------
  // Navegación bottom bar
  // -----------------------------
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

  // -----------------------------
  // Animar cámara al centro
  // -----------------------------
  void _animateToLaReina() {
    if (_mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: _laReinaCenter,
          zoom: 14.5,
          tilt: 10,
        ),
      ),
    );
  }

  // Cuando el usuario toca una card de cadena
  void _onChainSelected(String chain) {
    setState(() {
      // Si toca la misma card de nuevo → deseleccionar (mostrar todas)
      if (_selectedChain == chain) {
        _selectedChain = null;
      } else {
        _selectedChain = chain;
      }
    });

    _animateToLaReina();
  }

  // -----------------------------
  // Card de cada cadena
  // -----------------------------
  Widget _buildChainCard({
    required String chain,
    required String label,
    required String logoUrl,
  }) {
    final isSelected = _selectedChain == chain;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onChainSelected(chain),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          child: Card(
            elevation: isSelected ? 6 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? _turquoise : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (logoUrl.startsWith('http'))
                    SizedBox(
                      height: 32,
                      child: Image.network(
                        logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.local_pharmacy),
                      ),
                    )
                  else
                    const Icon(Icons.local_pharmacy),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? _turquoise : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------
  // Markers desde Firestore
  // -----------------------------
  Set<Marker> _buildMarkers(List<QueryDocumentSnapshot> docs) {
    final markers = <Marker>{};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      final name = (data['name'] ?? '').toString();
      final address = (data['address'] ?? '').toString();
      final chain = (data['chain'] ?? '').toString();

      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: name,
            snippet: '$address (${_chainLabel(chain)})',
          ),
        ),
      );
    }

    return markers;
  }

  String _chainLabel(String chain) {
    switch (chain) {
      case 'cruz_verde':
        return 'Cruz Verde';
      case 'ahumada':
        return 'Ahumada';
      case 'salcobrand':
        return 'Salcobrand';
      default:
        return chain;
    }
  }

  // -----------------------------
  // BUILD
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de farmacias'),
        centerTitle: true,
        backgroundColor: cs.background,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 3 CARDS ARRIBA
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                _buildChainCard(
                  chain: 'cruz_verde',
                  label: 'Cruz Verde',
                  logoUrl: cruzVerdeLogoUrl,
                ),
                const SizedBox(width: 6),
                _buildChainCard(
                  chain: 'ahumada',
                  label: 'Ahumada',
                  logoUrl: ahumadaLogoUrl,
                ),
                const SizedBox(width: 6),
                _buildChainCard(
                  chain: 'salcobrand',
                  label: 'Salcobrand',
                  logoUrl: salcobrandLogoUrl,
                ),
              ],
            ),
          ),

          // MAPA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pharmacies')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error al cargar farmacias'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                // Filtrar por cadena seleccionada
                if (_selectedChain != null) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['chain'] == _selectedChain;
                  }).toList();
                }

                final markers = _buildMarkers(docs);

                if (markers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay farmacias registradas para esta cadena.\n'
                      'Agrégalas desde el mantenedor.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _animateToLaReina();
                  },
                  initialCameraPosition: const CameraPosition(
                    target: _laReinaCenter,
                    zoom: 13,
                  ),
                  markers: markers,
                  myLocationEnabled: false,
                  zoomControlsEnabled: true,
                );
              },
            ),
          ),
        ],
      ),

      // BOTTOM NAV BAR
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
