import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order.dart' as local_order;
import 'detail_page.dart';

class CartPage extends StatefulWidget {
  final String? serviceType;

  const CartPage({super.key, this.serviceType});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<local_order.Order> orders = [];
  String? _userRole;
  String? _userEmail;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchOrders();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getUserDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      setState(() {
        _userRole = userDoc['role'];
        _userEmail = currentUser.email;
        _isLoading = false;
      });

      fetchOrders(); // Fetch orders after getting user details
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void fetchOrders() async {
    List<local_order.Order> fetchedOrders = await local_order.Order.fetchOrders();
    setState(() {
      orders = fetchedOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    List<local_order.Order> filteredOrders;

    if (_userRole == 'Propriétaire de pressing') {
      filteredOrders = orders;
    } else if (_userRole == 'Client' && _userEmail != null) {
      filteredOrders = orders
          .where((order) => order.userEmail == _userEmail)
          .toList();
    } else {
      filteredOrders = [];
    }

    if (widget.serviceType != null) {
      filteredOrders = filteredOrders
          .where((order) => order.serviceType == widget.serviceType)
          .toList();
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return ListTile(
            leading: Image(image: order.getServiceImage()),
            title: Text(order.itemDescription),
            subtitle: Text(
                'Client: ${order.customerName}\nAdresse: ${order.customerAddress}\nStatut: ${order.status}'),
            trailing: Text('${order.totalAmount} €'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(order: order),
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
