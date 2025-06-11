import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;
  final String imageUrl;

  const CartItem({
    Key? key,
    required this.id,
    required this.price,
    required this.quantity,
    required this.title,
    required this.productId,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          Checkbox(
            value: true,
            onChanged: (bool? value) {},
          ),

          // Hình ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),

          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text("Armchair High", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                Text("\$$price", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Nút số lượng
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.black54),
                onPressed: () {
                  cart.decreaseItem(productId);
                },
              ),
              Text("$quantity", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black54),
                onPressed: () {
                  cart.increaseItem(productId);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
