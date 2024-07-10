import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Order {
  final String id; // Identifiant du document Firebase
  final double totalAmount;
  final String serviceType;
  final String itemDescription;
  final String status;
  final String customerName;
  final String customerAddress;
  final String pickupTime;
  final bool isCompleted;
  final String userEmail; // Ajouter l'email de l'utilisateur

  Order({
    required this.id,
    required this.totalAmount,
    required this.serviceType,
    required this.itemDescription,
    required this.status,
    required this.customerName,
    required this.customerAddress,
    required this.pickupTime,
    required this.isCompleted,
    required this.userEmail, // Initialiser l'email de l'utilisateur
  });

  // Convertir un objet Order en Map
  Map<String, dynamic> toMap() {
    return {
      'totalAmount': totalAmount,
      'serviceType': serviceType,
      'itemDescription': itemDescription,
      'status': status,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'pickupTime': pickupTime,
      'isCompleted': isCompleted,
      'userEmail': userEmail, // Ajouter l'email de l'utilisateur à la Map
    };
  }

  // Convertir un Map en objet Order
  static Order fromMap(String id, Map<String, dynamic> map) {
    return Order(
      id: id,
      totalAmount: map['totalAmount'],
      serviceType: map['serviceType'],
      itemDescription: map['itemDescription'],
      status: map['status'],
      customerName: map['customerName'],
      customerAddress: map['customerAddress'],
      pickupTime: map['pickupTime'],
      isCompleted: map['isCompleted'],
      userEmail: map['userEmail'], // Récupérer l'email de l'utilisateur depuis la Map
    );
  }

  // Récupérer la liste des commandes depuis Firebase Firestore
  static Future<List<Order>> fetchOrders() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('orders').get();
      List<Order> orders = querySnapshot.docs
          .map((doc) =>
          Order.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      return []; // Retourner une liste vide en cas d'erreur
    }
  }

  // Obtenir l'image correspondant au type de service
  AssetImage getServiceImage() {
    switch (serviceType) {
      case 'Lavage':
        return const AssetImage('assets/images/lavage.png');
      case 'Lavage a sec':
        return const AssetImage('assets/images/lavage_a_sec.png');
      case 'Repassage':
        return AssetImage('assets/images/repassage.png');
      default:
        return AssetImage('assets/images/default.png'); // Image par défaut si le type de service n'est pas reconnu
    }
  }

  // Liste des commandes pour démonstration
  static List<Order> orderList = fetchOrders() as List<Order>;

  static List<Order> getOrdersPendingPickup() {
    return orderList
        .where((order) => order.status == 'En attente de ramassage')
        .toList();
  }

  static List<Order> getOrdersInProcessing() {
    return orderList
        .where((order) => order.status == 'En cours de traitement')
        .toList();
  }

  static List<Order> getOrdersReadyForDelivery() {
    return orderList
        .where((order) => order.status == 'Prêt à être livré')
        .toList();
  }
}
