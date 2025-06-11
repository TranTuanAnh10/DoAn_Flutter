import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';

class CartScreen extends StatelessWidget {
  static const routeName = "/cart-screen";

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart>(context);
    final cartStoresList = cartProvider.cartStores.values.toList();
    final isCartEmpty = cartStoresList.isEmpty;

    double getTotalAmount() {
      return cartStoresList
          .expand((store) => store.cartItems)
          .fold(0.0, (sum, item) => sum + item.amount);
    }

    void clearCart() {
      final itemIds = <int>[];
      for (var store in cartStoresList) {
        for (var item in store.cartItems) {
          itemIds.add(item.storeItemId);
        }
      }
      final token = Provider.of<Auth>(context, listen: false).token;
      cartProvider.deleteCartItem(context, token, itemIds);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Cart"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
            onPressed: isCartEmpty
                ? null
                : () {
              clearCart();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isCartEmpty
                ? const Center(
              child: Text(
                "Your cart is empty.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
                : ListView.builder(
              itemCount: cartStoresList.length,
              itemBuilder: (ctx, i) {
                final store = cartStoresList[i];
                return ExpansionTile(
                  title: Text(
                    store.storeName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: store.cartItems.map((item) {
                    return ListTile(
                      leading: Image.network(
                        item.photoUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item.name),
                      subtitle: Text("Amount: \$${item.amount.toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => {
                          cartProvider.deleteCartItem(context, Provider.of<Auth>(context, listen: false).token, [item.storeItemId])
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (!isCartEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total (${cartProvider.totalItems} items):",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "\$${getTotalAmount().toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      // Checkout logic placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Proceeding to checkout...")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Proceed to Checkout", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
