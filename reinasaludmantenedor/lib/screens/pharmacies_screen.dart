import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'medications_screen.dart';

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  String _selectedChain = 'cruz_verde';

  final _chains = const [
    {'value': 'cruz_verde', 'label': 'Cruz Verde'},
    {'value': 'ahumada', 'label': 'Ahumada'},
    {'value': 'salcobrand', 'label': 'Salcobrand'},
  ];

  Future<void> _savePharmacy() async {
    final name = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final logoUrl = _logoUrlCtrl.text.trim();
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());

    if (name.isEmpty ||
        address.isEmpty ||
        logoUrl.isEmpty ||
        lat == null ||
        lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos correctamente')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('pharmacies').add({
      'name': name,
      'address': address,
      'chain': _selectedChain,
      'logoUrl': logoUrl,
      'lat': lat,
      'lng': lng,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Farmacia guardada')),
    );
  }

  void _clearForm() {
    _nameCtrl.clear();
    _addressCtrl.clear();
    _logoUrlCtrl.clear();
    _latCtrl.clear();
    _lngCtrl.clear();
    setState(() {
      _selectedChain = 'cruz_verde';
    });
  }

  void _onNavTapped(int index) {
    if (index == 1) return; // ya estamos en farmacias

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MedicationsScreen(),
        ),
      );
    }
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _logoUrlCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenedor de farmacias'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Agregar farmacia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la farmacia',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedChain,
                      items: _chains
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['value'],
                              child: Text(c['label']!),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedChain = value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Cadena',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _logoUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Logo URL (Storage)',
                        helperText:
                            'URL del logo: Cruz Verde, Ahumada, Salcobrand',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _latCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitud',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _lngCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitud',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _clearForm();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _savePharmacy();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add_location_alt),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pharmacies')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar farmacias'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('Aún no has agregado farmacias'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = (data['name'] ?? '').toString();
              final address = (data['address'] ?? '').toString();
              final chain = (data['chain'] ?? '').toString();
              final logoUrl = (data['logoUrl'] ?? '').toString();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: logoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            logoUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.local_pharmacy),
                          ),
                        )
                      : const Icon(Icons.local_pharmacy),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$address\n${_chainLabel(chain)}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),

      // ---------- BOTTOM NAV ----------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // estamos en FARMACIAS
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy),
            label: 'Farmacias',
          ),
        ],
      ),
    );
  }
}
