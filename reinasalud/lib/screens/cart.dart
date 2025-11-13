// cart_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    // Si no hay usuario logueado
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: Navigator.of(context).canPop(),
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
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
      appBar: AppBar(
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Carrito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
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

            // Calcular total
            double total = 0;
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final rawPrice = data['price'] ?? 0;
              final price = (rawPrice is num)
                  ? rawPrice.toDouble()
                  : double.tryParse(rawPrice.toString()) ?? 0;
              total += price;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen de tu compra',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Lista de productos o mensaje vacío
                Expanded(
                  child: docs.isEmpty
                      ? Center(
                          child: Text(
                            'Tu carrito está vacío por ahora',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final itemDoc = docs[index];
                            final data =
                                itemDoc.data() as Map<String, dynamic>;

                            final name = data['name'] ?? 'Sin nombre';
                            final description =
                                data['description'] ?? 'Sin descripción';
                            final rawPrice = data['price'] ?? 0;
                            final price = (rawPrice is num)
                                ? rawPrice.toDouble()
                                : double.tryParse(rawPrice.toString()) ?? 0;

                            return ListTile(
                              title: Text(name.toString()),
                              subtitle: Text(
                                description.toString().isEmpty
                                    ? 'Sin descripción'
                                    : description.toString(),
                              ),

                              // -------------------------
                              // 🔥 BOTÓN DE ELIMINAR
                              // -------------------------
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .collection('cart')
                                          .doc(itemDoc.id)
                                          .delete();

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Producto eliminado del carrito'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // Total si hay items
                if (docs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '\$${total.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Aquí iría la lógica para finalizar la compra'),
                        ),
                      );
                    },
                    child: const Text('Finalizar compra'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
