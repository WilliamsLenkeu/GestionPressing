import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/order.dart';

class CartPage extends StatefulWidget {
  final String? serviceType;

  const CartPage({super.key, this.serviceType});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    List<Order> filteredOrders;

    if (widget.serviceType == null) {
      filteredOrders = Order.orderList;
    } else {
      filteredOrders = Order.orderList
          .where((order) => order.serviceType == widget.serviceType)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return ListTile(
            leading: Image.asset(order.serviceImage),
            title: Text(order.itemDescription),
            subtitle: Text('Client: ${order.customerName}\nAdresse: ${order.customerAddress}\nStatut: ${order.status}'),
            trailing: Text('${order.totalAmount} €'),
          );
        },
      ),
    );
  }
}
