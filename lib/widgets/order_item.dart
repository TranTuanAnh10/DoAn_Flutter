import 'dart:math';

import 'package:flutter/material.dart';
import '../providers/orders.dart' as ord;
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  const OrderItem({Key? key, required this.order}) : super(key: key);
  final ord.OrderItem order;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 155, 280) : 95,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$${widget.order.amount}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            if (_expanded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: _expanded
                    ? min(widget.order.products.length * 20.0 + 100, 100)
                    : 95,
                child: ListView.builder(
                    itemCount: widget.order.products.length,
                    itemBuilder: (context, indexProd) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Text(
                              //   widget.order.products[indexProd].title,
                              //   style: const TextStyle(
                              //       fontSize: 18, fontWeight: FontWeight.bold),
                              // ),
                              // Text(
                              //   "${widget.order.products[indexProd].quantity} x \$${widget.order.products[indexProd].price}",
                              //   style: const TextStyle(
                              //       fontSize: 18, color: Colors.grey),
                              // ),
                            ],
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ],
                      );
                    }),
              )
          ],
        ),
      ),
    );
  }
}
