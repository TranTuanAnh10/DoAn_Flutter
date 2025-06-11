import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';

class CartItem {
  final int id;
  final int storeId;
  final int productId;
  final int storeItemId;
  final String name;
  final int amount;
  final String photoUrl;
  final int maxPerOrder;
  final String storeName;
  final int available;

  CartItem({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.storeItemId,
    required this.name,
    required this.amount,
    required this.photoUrl,
    required this.maxPerOrder,
    required this.storeName,
    required this.available,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      storeId: json['storeId'],
      productId: json['productId'],
      storeItemId: json['storeItemId'],
      name: json['name'],
      amount: json['amount'],
      photoUrl: json['photoUrl'],
      maxPerOrder: json['maxPerOrder'],
      storeName: json['storeName'],
      available: json['available'],
    );
  }
}

class CartStore {
  final int storeId;
  final String storeName;
  final List<CartItem> cartItems;

  CartStore({
    required this.storeId,
    required this.storeName,
    required this.cartItems,
  });

  factory CartStore.fromJson(Map<String, dynamic> json) {
    return CartStore(
      storeId: json['storeId'],
      storeName: json['storeName'],
      cartItems: (json['cartItems'] as List)
          .map((e) => CartItem.fromJson(e))
          .toList(),
    );
  }
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get items {
    return {..._items};
  }
  Map<String, CartStore> _cartStores = {};
  Map<String, CartStore> get cartStores {
    return {..._cartStores};
  }

  int get itemCount {
    return _items.length;
  }
  int get totalItems =>
      _cartStores.values.fold(0, (sum, store) => sum + store.cartItems.length);
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      //total += cartItem.price * cartItem.quantity;
    });
    return total;
  }
  bool hasProduct(Map<String, CartItem> items, String productId) {
    return items.values.any((item) => item.productId == productId);
  }
  Future<void> fetchCartFromApi(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}/api/Cart'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);
        final List<Map<String, dynamic>> data = rawData.cast<Map<String, dynamic>>();

        _cartStores = Map<String, CartStore>.fromIterable(
          data,
          key: (e) => (e['storeId'] as int).toString(),
          value: (e) => CartStore.fromJson(e),
        );
        print(data);
        notifyListeners();
      } else {
        throw Exception('Failed to fetch cart: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<void> addToCart(BuildContext context, int storeItemId, int productId, String token) async {
    final url = Uri.parse('${Constant.baseUrl}/api/cart/$storeItemId/$productId');

    try {
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json, text/plain, */*',
          'content-type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({}), // empty body
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🛒 Item added to cart successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        fetchCartFromApi(token);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to add item to cart (code: ${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ An error occurred: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  void addItem(
    String token,
    String productId,
    double price,
    String title,
  ) {
    // if (_items.containsKey(productId)) {
    //   _items.update(
    //       productId,
    //       (existItem) => CartItem(
    //           id: existItem.id,
    //           title: existItem.title,
    //           quantity: existItem.quantity + 1,
    //           price: existItem.price, imageUrl: null));
    // } else {
    //   _items.putIfAbsent(
    //       productId,
    //       () => CartItem(
    //           id: DateTime.now().toString(),
    //           title: title,
    //           quantity: 1,
    //           price: price, imageUrl: null));
    // }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
  Future<void> deleteCartItem(BuildContext context, String token , List<int> itemIds) async {
    final url = Uri.parse('${Constant.baseUrl}/api/cart/');

    final headers = {
      'accept': 'application/json, text/plain, */*',
      'authorization': 'Bearer ${token}',
    };

    final body = json.encode(itemIds);

    try {
      final response = await http.delete(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Cart item(s) deleted successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cart item(s) deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        fetchCartFromApi(token);
      } else {
        print('Failed to delete cart item(s). Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to delete cart item(s). Status code: ${response.statusCode} ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    // if (_items[productId]!.quantity > 1) {
    //   _items.update(
    //       productId,
    //       (existProd) => CartItem(
    //           id: existProd.id,
    //           title: existProd.title,
    //           quantity: existProd.quantity - 1,
    //           price: existProd.price, imageUrl: null));
    // } else {
    //   _items.remove(productId);
    // }
    notifyListeners();
  }
  void increaseItem(String productId) {
    // if (_items.containsKey(productId)) {
    //   _items.update(
    //     productId,
    //         (existingItem) => CartItem(
    //       id: existingItem.id,
    //       title: existingItem.title,
    //       price: existingItem.price,
    //       quantity: existingItem.quantity + 1,
    //       imageUrl: existingItem.imageUrl, // Giữ nguyên ảnh sản phẩm
    //     ),
    //   );
    // }
    notifyListeners();
  }

  void decreaseItem(String productId) {
    // if (_items.containsKey(productId)) {
    //   if (_items[productId]!.quantity > 1) {
    //     _items.update(
    //       productId,
    //           (existingItem) => CartItem(
    //         id: existingItem.id,
    //         title: existingItem.title,
    //         price: existingItem.price,
    //         quantity: existingItem.quantity - 1,
    //         imageUrl: existingItem.imageUrl,
    //       ),
    //     );
    //   } else {
    //     _items.remove(productId);
    //   }
    // }
    notifyListeners();
  }

}
