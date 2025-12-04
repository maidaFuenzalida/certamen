import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool requiresPrescription;

  const ProductDetailScreen({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.requiresPrescription,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;
  bool _loadingFavorite = true;

  bool _usingCounter = false;
  int _quantity = 0;
  String? _cartItemId;

  final ImagePicker _picker = ImagePicker();
  File? _prescriptionFile;
  String? _prescriptionUrl;
  bool _isUploading = false;

  static const Color _turquoise = Color(0xFF45B7B7);
  static const Color _orange = Color(0xFFF27D33);
  static const Color _greyText = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  // ---------------- FAVORITOS ----------------

  Future<void> _loadFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isFavorite = false;
        _loadingFavorite = false;
      });
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.name);

    final snap = await docRef.get();
    setState(() {
      _isFavorite = snap.exists;
      _loadingFavorite = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.name);

    if (_isFavorite) {
      await docRef.delete();
      setState(() => _isFavorite = false);
    } else {
      await docRef.set({
        'name': widget.name,
        'description': widget.description,
        'price': widget.price,
        'imageUrl': widget.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() => _isFavorite = true);
    }
  }

  // ---------------- CARRITO ----------------

  Future<void> _createOrUpdateCartItem(int quantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para agregar al carrito'),
        ),
      );
      return;
    }

    final cartsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    if (quantity <= 0) {
      if (_cartItemId != null) {
        await cartsRef.doc(_cartItemId).delete();
      }
      setState(() {
        _cartItemId = null;
        _usingCounter = false;
        _quantity = 0;
      });
      return;
    }

    if (_cartItemId == null) {
      final docRef = await cartsRef.add({
        'name': widget.name,
        'description': widget.description,
        'price': widget.price,
        'imageUrl': widget.imageUrl, // 👈 AGREGADO
        'quantity': quantity,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _cartItemId = docRef.id;
    } else {
      await cartsRef.doc(_cartItemId).update({
        'quantity': quantity,
      });
    }

    setState(() {
      _usingCounter = true;
      _quantity = quantity;
    });
  }

  Future<void> _handleBuy() async {
    final newQty = _usingCounter && _quantity > 0 ? _quantity : 1;
    await _createOrUpdateCartItem(newQty);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  // ---------------- RECETA MÉDICA ----------------

  void _showPrescriptionOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadPrescription(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir desde galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadPrescription(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadPrescription(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para subir una receta'),
        ),
      );
      return;
    }

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 60,
        maxWidth: 800,
      );
      if (picked == null) return;

      setState(() {
        _isUploading = true;
        _prescriptionFile = File(picked.path);
      });

      final ref = FirebaseStorage.instance
          .ref()
          .child('prescriptions')
          .child('${user.uid}_${DateTime.now().toIso8601String()}.jpg');

      final uploadTask = ref.putFile(_prescriptionFile!);
      final snap = await uploadTask.whenComplete(() {});
      final url = await snap.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('prescriptions')
          .add({
        'productName': widget.name,
        'productDescription': widget.description,
        'productPrice': widget.price,
        'prescriptionUrl': url,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _prescriptionUrl = url;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta subida correctamente')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la receta: $e')),
      );
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Info Producto',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: _turquoise),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CABECERA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_loadingFavorite)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                  ],
                ),
              ),

              // IMAGEN
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.medication,
                                size: 64, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Precio: \$${widget.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 14, color: _greyText),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // INFORMACIÓN
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: widget.requiresPrescription
                          ? _showPrescriptionOptions
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: _orange, size: 22),
                          const SizedBox(width: 8),
                          const Text('Necesita receta: '),
                          Text(
                            widget.requiresPrescription ? 'Sí' : 'No',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: widget.requiresPrescription
                                  ? _orange
                                  : Colors.green,
                            ),
                          ),
                          if (widget.requiresPrescription) const Spacer(),
                          if (widget.requiresPrescription)
                            const Icon(Icons.chevron_right, color: _greyText),
                        ],
                      ),
                    ),

                    if (_isUploading)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),

                    if (_prescriptionUrl != null && !_isUploading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _prescriptionUrl!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.edit_outlined,
                            color: Color(0xFF9C27B0), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Descripción:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 6),
                      child: Text(widget.description),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Advertencias:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 32.0, top: 6),
                      child: Text(
                        'No exceder la dosis recomendada.\nConsultar siempre con un profesional de salud.',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BOTONES
              Row(
                children: [
                  Expanded(
                    child: _usingCounter
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _turquoise),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  color: _turquoise,
                                  onPressed: () async {
                                    final newQty =
                                        (_quantity - 1).clamp(0, 999);
                                    await _createOrUpdateCartItem(newQty);
                                  },
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '$_quantity',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  color: _turquoise,
                                  onPressed: () async {
                                    final newQty = _quantity + 1;
                                    await _createOrUpdateCartItem(newQty);
                                  },
                                ),
                              ],
                            ),
                          )
                        : OutlinedButton.icon(
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: const Text('Añadir'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _turquoise,
                              side: const BorderSide(color: _turquoise),
                            ),
                            onPressed: () async {
                              await _createOrUpdateCartItem(1);
                            },
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _turquoise,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _handleBuy,
                      child: const Text('Comprar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
