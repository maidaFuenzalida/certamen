// cart.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const Color _turquoise = Color(0xFF45B7B7);
  static const Color _greyIcon = Color(0xFFB0B0B0);
  static const Color _bgGrey = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Carrito'),
        ),
        body: const Center(
          child: Text('Debes iniciar sesión para ver tu carrito'),
        ),
      );
    }

    final cartStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .orderBy('createdAt', descending: false)
        .snapshots();

    return Scaffold(
      backgroundColor: _bgGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgGrey,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Carrito',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.shopping_cart_outlined, color: _turquoise),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: cartStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error al cargar el carrito'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            double subtotal = 0;
            for (final doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final rawPrice = data['price'] ?? 0;
              final price = (rawPrice is num)
                  ? rawPrice.toDouble()
                  : double.tryParse(rawPrice.toString()) ?? 0;
              final quantity = (data['quantity'] ?? 1) as int;
              subtotal += price * quantity;
            }

            const double shipping = 1000; // fijo como en la maqueta
            final double total = docs.isEmpty ? 0 : subtotal + shipping;

            return Column(
              children: [
                // ---------------- LISTA DE ITEMS ----------------
                Expanded(
                  child: docs.isEmpty
                      ? const Center(
                          child: Text(
                            'Tu carrito está vacío por ahora',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.white,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final itemDoc = docs[index];
                              final data =
                                  itemDoc.data() as Map<String, dynamic>;

                              final name =
                                  (data['name'] ?? 'Sin nombre').toString();
                              final rawPrice = data['price'] ?? 0;
                              final price = (rawPrice is num)
                                  ? rawPrice.toDouble()
                                  : double.tryParse(rawPrice.toString()) ?? 0;
                              final quantity =
                                  (data['quantity'] ?? 1) as int;
                              final lineTotal = price * quantity;
                              final imageUrl =
                                  (data['imageUrl'] ?? '').toString().trim();

                              return _CartItemTile(
                                name: name,
                                price: price,
                                quantity: quantity,
                                lineTotal: lineTotal,
                                imageUrl: imageUrl,
                                onIncrement: () async {
                                  await itemDoc.reference.update({
                                    'quantity': quantity + 1,
                                  });
                                },
                                onDecrement: () async {
                                  if (quantity <= 1) {
                                    await itemDoc.reference.delete();
                                  } else {
                                    await itemDoc.reference.update({
                                      'quantity': quantity - 1,
                                    });
                                  }
                                },
                                onDelete: () async {
                                  await itemDoc.reference.delete();
                                },
                              );
                            },
                          ),
                        ),
                ),

                const SizedBox(height: 8),

                // ---------------- RESUMEN DE COMPRA ----------------
                if (docs.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumen de tu compra',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text('\$${subtotal.toStringAsFixed(0)}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Envío'),
                            Text(docs.isEmpty
                                ? '\$0'
                                : '\$${shipping.toStringAsFixed(0)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _turquoise,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              if (docs.isEmpty) return;
                              _showOrderCompletedDialog(context);
                            },
                            child: const Text('Finalizar Compra'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Entrega: Despacho a domicilio\n'
                          'Dirección: Av. Los Leones 1234',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // ---------------- SEGUIR COMPRANDO ----------------
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back_ios_new,
                            size: 18, color: Colors.black54),
                        SizedBox(width: 4),
                        Text(
                          'Seguir Comprando',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------- DIALOGO COMPRA REALIZADA ----------------
  static Future<void> _showOrderCompletedDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Compra realizada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _turquoise,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Recibirás tu medicamento pronto.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Aquí podrías abrir una pantalla de detalle de pedido
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Ver pedido',
                        style: TextStyle(color: _turquoise, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Aceptar/Volver',
                        style: TextStyle(color: _turquoise, fontSize: 13),
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
  }
}

// ===================================================
// ITEM DEL CARRITO – con imagen, cantidad y basura gris
// ===================================================

class _CartItemTile extends StatelessWidget {
  final String name;
  final double price;
  final int quantity;
  final double lineTotal;
  final String imageUrl;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const _CartItemTile({
    required this.name,
    required this.price,
    required this.quantity,
    required this.lineTotal,
    required this.imageUrl,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  static const Color _turquoise = Color(0xFF45B7B7);
  static const Color _greyIcon = Color(0xFFB0B0B0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Imagen del medicamento
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 70,
              height: 40,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.medication,
                            color: _greyIcon, size: 28),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.medication,
                          color: _greyIcon, size: 28),
                    ),
            ),
          ),
          const SizedBox(width: 8),

          // Nombre + precio x cantidad
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${price.toStringAsFixed(0)} x $quantity = \$${lineTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // Contador + eliminar
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      color: _turquoise,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 30, minHeight: 30),
                      onPressed: onDecrement,
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      color: _turquoise,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 30, minHeight: 30),
                      onPressed: onIncrement,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: _greyIcon, // basurero gris
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
