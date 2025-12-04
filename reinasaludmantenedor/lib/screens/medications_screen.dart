import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'pharmacies_screen.dart'; // 👈 importante para cambiar de pestaña

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _pharmacyLogoCtrl = TextEditingController(); // 👈 URL logo farmacia

  bool _requiresPrescription = false;
  String? _selectedPharmacy; // Cruz Verde / Ahumada / Salcobrand

  Future<void> _saveMedication() async {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim());
    final imageUrl = _imageUrlCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    final pharmacy = _selectedPharmacy;
    final pharmacyLogo = _pharmacyLogoCtrl.text.trim();

    // Validación
    if (name.isEmpty ||
        price == null ||
        imageUrl.isEmpty ||
        pharmacy == null ||
        pharmacyLogo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa nombre, precio, URL imagen producto, farmacia y URL logo',
          ),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('medications').add({
      'productName': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'requiresPrescription': _requiresPrescription,
      'pharmacy': pharmacy,
      'pharmacyLogo': pharmacyLogo, // 👈 se guarda el link del logo
      'createdAt': FieldValue.serverTimestamp(),
    });

    _nameCtrl.clear();
    _priceCtrl.clear();
    _imageUrlCtrl.clear();
    _descriptionCtrl.clear();
    _pharmacyLogoCtrl.clear();

    setState(() {
      _requiresPrescription = false;
      _selectedPharmacy = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medicamento guardado')),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _imageUrlCtrl.dispose();
    _descriptionCtrl.dispose();
    _pharmacyLogoCtrl.dispose();
    super.dispose();
  }

  // ---------- BOTTOM NAV TAP ----------
  void _onNavTapped(int index) {
    if (index == 0) return; // ya estamos en medicamentos

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PharmaciesScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenedor de medicamentos'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --------- FORMULARIO ARRIBA (SCROLLEABLE, SIN OVERFLOW) ---------
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del medicamento',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _imageUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL imagen del medicamento (Storage)',
                        helperText:
                            'Pega aquí el link de Amoxicilina.png, Paracetamol.png, etc.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ------------ DROPDOWN FARMACIA ------------
                    DropdownButtonFormField<String>(
                      value: _selectedPharmacy,
                      decoration: const InputDecoration(
                        labelText: 'Farmacia',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Cruz Verde',
                          child: Text('Cruz Verde'),
                        ),
                        DropdownMenuItem(
                          value: 'Ahumada',
                          child: Text('Ahumada'),
                        ),
                        DropdownMenuItem(
                          value: 'Salcobrand',
                          child: Text('Salcobrand'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPharmacy = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // ------------ URL DEL LOGO DE LA FARMACIA ------------
                    TextField(
                      controller: _pharmacyLogoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL logo farmacia (Storage)',
                        helperText:
                            'Pega aquí el link del logo de Cruz Verde / Ahumada / Salcobrand',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      title: const Text('¿Requiere receta médica?'),
                      value: _requiresPrescription,
                      onChanged: (v) {
                        setState(() {
                          _requiresPrescription = v;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveMedication,
                        child: const Text('Guardar medicamento'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // --------- LISTA DE MEDICAMENTOS ABAJO ---------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('medications')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar medicamentos'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Aún no has agregado medicamentos'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final name = (data['productName'] ?? '').toString();
                      final price = (data['price'] ?? 0).toDouble();
                      final requires =
                          data['requiresPrescription'] == true;
                      final imageUrl =
                          (data['imageUrl'] ?? '').toString().trim();
                      final pharmacy =
                          (data['pharmacy'] ?? '').toString();
                      final description =
                          (data['description'] ?? '').toString();
                      final pharmacyLogo =
                          (data['pharmacyLogo'] ?? '').toString().trim();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          isThreeLine: true,
                          leading: imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(
                                      Icons.medication,
                                      size: 32,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.medication,
                                  size: 32,
                                ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('\$${price.toStringAsFixed(0)} · $pharmacy'),
                              if (description.isNotEmpty)
                                Text(
                                  description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (pharmacyLogo.isNotEmpty)
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Image.network(
                                    pharmacyLogo,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.local_pharmacy),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                requires ? 'Con receta' : 'Sin receta',
                                style: TextStyle(
                                  color: requires
                                      ? Colors.orange
                                      : colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ---------- BOTTOM NAV ----------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // estamos en MEDICAMENTOS
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
