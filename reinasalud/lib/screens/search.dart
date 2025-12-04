import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'product_detail.dart';
import 'cart.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchText = '';
  bool _searchFocused = false;

  // Colores de diseño
  static const Color turquoise = Color(0xFF45B7B7);
  static const Color lightGreyBg = Color(0xFFF8F9FB);
  static const Color greyText = Color(0xFF9E9E9E);
  static const Color orange = Color(0xFFF27D33);

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _searchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // =============================
  // Agregar al carrito
  // =============================
  Future<void> _addToCart(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes iniciar sesión")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .add({
      "name": data["productName"] ?? '',
      "description": data["description"] ?? '',
      "price": (data["price"] ?? 0).toDouble(),
      "imageUrl": (data["imageUrl"] ?? '').toString().trim(), // 👈 NUEVO
      "quantity": 1, // 👈 NUEVO
      "createdAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Agregado al carrito")),
    );
  }

  // Dialogo de confirmación "Añadido al carrito"
  Future<void> _confirmAddToCart(
      Map<String, dynamic> data, double price) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Añadido al Carrito',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: \$${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: greyText,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: greyText),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(color: turquoise),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await _addToCart(data);
    }
  }

  // =============================
  // Texto + color del estado
  // =============================
  (String, Color) _status(bool requiresPrescription, bool inStock) {
    if (!inStock) return ('Sin stock', greyText);
    if (requiresPrescription) return ('Requiere receta médica', orange);
    return ('Disponible', turquoise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: lightGreyBg,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Resultado búsqueda",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          )
        ],
      ),

      // =============================
      // BODY
      // =============================
      body: Column(
        children: [
          // -------------------------------------------
          // BARRA DE BÚSQUEDA
          // -------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: _searchFocused ? turquoise : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: TextField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                onChanged: (v) {
                  setState(() => _searchText = v.toLowerCase().trim());
                },
                cursorColor: turquoise,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: turquoise),
                  hintText: "Busca tus medicamentos",
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  filled: false,
                ),
              ),
            ),
          ),

          // -------------------------------------------
          // RESULTADOS
          // -------------------------------------------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("medications")
                  .orderBy("productName")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                      (data["productName"] ?? '').toString().toLowerCase();
                  if (_searchText.isEmpty) return false;
                  return name.contains(_searchText);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child:
                        Text("Sin resultados", style: TextStyle(color: greyText)),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;

                    final chain = (data["pharmacy"] ?? '').toString();
                    final chainLogo =
                        (data["pharmacyLogo"] ?? '').toString().trim();
                    final productName =
                        (data["productName"] ?? '').toString();
                    final description =
                        (data["description"] ?? '').toString();
                    final price = (data["price"] ?? 0).toDouble();
                    final requiresPrescription =
                        data["requiresPrescription"] == true;
                    final inStock = data["inStock"] != false;

                    final (statusText, statusColor) =
                        _status(requiresPrescription, inStock);

                    return _SearchResultCard(
                      chainName: chain.isEmpty ? 'Farmacia' : chain,
                      logoUrl: chainLogo,
                      medicationName: productName,
                      description: description,
                      price: price,
                      statusText: statusText,
                      statusColor: statusColor,
                      inStock: inStock,
                      onAdd: () => _confirmAddToCart(data, price),
                      onBuy: () async {
                        await _addToCart(data);
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CartScreen(),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              name: productName,
                              description: description,
                              price: price,
                              imageUrl: data["imageUrl"] ?? "",
                              requiresPrescription: requiresPrescription,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

//
// ======================================================
// CARD DE RESULTADO – ESTILO DISEÑO
// ======================================================
//

class _SearchResultCard extends StatelessWidget {
  final String chainName;
  final String logoUrl;
  final String medicationName;
  final String description;
  final double price;
  final String statusText;
  final Color statusColor;
  final bool inStock;
  final VoidCallback onAdd;
  final VoidCallback onBuy;
  final VoidCallback onTap;

  static const Color turquoise = Color(0xFF45B7B7);
  static const Color greyButton = Color(0xFFBDBDBD);

  const _SearchResultCard({
    required this.chainName,
    required this.logoUrl,
    required this.medicationName,
    required this.description,
    required this.price,
    required this.statusText,
    required this.statusColor,
    required this.inStock,
    required this.onAdd,
    required this.onBuy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOGO FARMACIA
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                ),
                child: logoUrl.isNotEmpty
                    ? Image.network(
                        logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.local_pharmacy, color: turquoise),
                      )
                    : const Icon(Icons.local_pharmacy, color: turquoise),
              ),

              const SizedBox(width: 14),

              // INFORMACIÓN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estado
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Nombre farmacia
                    Text(
                      chainName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // Medicamento
                    Text(
                      medicationName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Precio
                    Text(
                      "\$${price.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: turquoise,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botones
                    Row(
                      children: [
                        // BOTÓN AÑADIR
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.shopping_cart_outlined,
                                size: 18),
                            label: const Text("Añadir"),
                            onPressed: inStock ? onAdd : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  inStock ? turquoise : greyButton,
                              side: BorderSide(
                                color:
                                    inStock ? turquoise : greyButton,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // BOTÓN COMPRAR
                        Expanded(
                          child: ElevatedButton(
                            onPressed: inStock ? onBuy : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  inStock ? turquoise : greyButton,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                            child: const Text("Comprar"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
