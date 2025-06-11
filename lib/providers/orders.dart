import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  final String authToken;
  List<OrderItem> _orders = [];
  final String userId;
  Orders(this.authToken, this.userId, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fectchAndSetOrders() async {
    final url = Uri.parse(
        'https://shop-app-flutter-152a-default-rtdb.asia-southeast1.firebasedatabase.app/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadOrders = [];
    final Map<String, dynamic>? extractedData;
    if (json.decode(response.body) != null) {
      extractedData = json.decode(response.body) as Map<String, dynamic>;
    } else {
      extractedData = null;
    }

    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      // loadOrders.add(OrderItem(
      //     id: orderId,
      //     amount: orderData['amount'],
      //     products: (orderData['products'] as List<dynamic>)
      //         .map((item) => CartItem(
      //             id: item['id'],
      //             title: item['title'],
      //             quantity: item['quantity'],
      //             price: item['price'], imageUrl: null))
      //         .toList(),
      //     dateTime: DateTime.parse(orderData['dateTime'])));
    });
    _orders = loadOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shop-app-flutter-152a-default-rtdb.asia-southeast1.firebasedatabase.app/$userId.json?auth=$authToken');
    final timeStamp = DateTime.now();
    // final response = await http.post(url,
    //     body: json.encode({
    //       'amount': total,
    //       'dateTime': timeStamp.toIso8601String(),
    //       'products': cartProducts
    //           .map((item) => {
    //                 'id': item.id,
    //                 'title': item.title,
    //                 'quantity': item.quantity,
    //                 'price': item.price,
    //               })
    //           .toList(),
    //     }));
    // _orders.insert(
    //     0,
    //     OrderItem(
    //         id: json.decode(response.body)['name'],
    //         amount: total,
    //         products: cartProducts,
    //         dateTime: DateTime.now()));
    // notifyListeners();
  }
}
