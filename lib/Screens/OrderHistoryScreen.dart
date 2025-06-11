import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../models/order_data.dart';
import '../providers/constants.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<OrderData> _orders = [];
  bool _isLoading = true;

  Future<void> fetchOrders() async {
    final url = Uri.parse("${Constant.baseUrl}/api/order/");
    try {
      final response = await http.get(url, headers: {
        'accept': 'application/json',
        'authorization': 'Bearer ${Provider.of<Auth>(context, listen: false).token}',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<OrderData> fetchedOrders = (data['items'] as List)
            .map((item) => OrderData.fromJson(item))
            .toList();
        setState(() {
          _orders = fetchedOrders;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showOrderDetails(BuildContext context, OrderData order) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order #${order.id}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Status: ${order.status}'),
              Text('Created: ${order.created.toLocal()}'),
              Text('Delivery Charge: ${order.deliveryCharge.toStringAsFixed(2)}'),
              Text('Total Amount: ${order.totalAmount.toStringAsFixed(2)}'),
              const Divider(),
              Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => ListTile(
                leading: Image.network(item.photoUrl, width: 40, height: 40),
                title: Text(item.name),
                subtitle: Text('Qty: ${item.count}'),
                trailing: Text('${item.price.toStringAsFixed(2)}'),
              )),
            ],
          ),
        );
      },
    );
  }




  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.length <= 0 ? Center(child: Text("You don't have order.")) : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final item = order.items.first;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 1,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Item(s) Ordered:",
                    style: TextStyle(color: Colors.black)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.network(item.photoUrl,
                        width: 60, height: 60, fit: BoxFit.cover),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          Text("Price: ₹${item.price.toStringAsFixed(2)}",
                              style:
                              const TextStyle(color: Colors.black)),
                          Text("Unit(s): ${item.count}",
                              style:
                              const TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total: \$${order.totalAmount}",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            "Status: ${order.status}",
                            style:
                            const TextStyle(color: Colors.green),
                          ),
                          Text(
                            "Date: ${order.created.toLocal().toString().split('.')[0]}",
                            style:
                            const TextStyle(color: Colors.black),
                          ),
                        ]),
                    ElevatedButton(
                      onPressed: () {
                        _showOrderDetails(context, order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text("View", style: const TextStyle(color: Colors.white),),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
