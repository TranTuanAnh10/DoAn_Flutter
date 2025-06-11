import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app-drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  static const routeName = '/orders-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Order")),
      body: FutureBuilder(
        future:
            Provider.of<Orders>(context, listen: false).fectchAndSetOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return const Center(
              child: Text('An error occurred!'),
            );
          } else {
            return Consumer<Orders>(
                builder: (ctx, orderData, _) => ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (ctx, i) =>
                          OrderItem(order: orderData.orders[i]),
                    ));
          }
        },
      ),
      drawer: const AppDrawer(),
    );
  }
}
