import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order.dart' as model;
import 'package:gestwash/constants.dart';

class DetailPage extends StatelessWidget {
  final model.Order order;

  const DetailPage({super.key, required this.order});

  Future<String?> _getUserRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      firestore.DocumentSnapshot userDoc = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return userDoc['role'];
    }
    return null;
  }

  void _showChangeStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedStatus;
        return AlertDialog(
          title: const Text('Changer le statut de la commande'),
          content: DropdownButton<String>(
            isExpanded: true,
            value: selectedStatus,
            hint: const Text('Sélectionner un statut'),
            items: <String>[
              'En attente de ramassage',
              'En cours de traitement',
              'Prêt à être livré'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              selectedStatus = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedStatus != null) {
                  await firestore.FirebaseFirestore.instance
                      .collection('orders')
                      .doc(order.id)
                      .update({'status': selectedStatus});
                  Navigator.of(context).pop();
                  _showStatusChangedDialog(context, selectedStatus!);
                }
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  void _showStatusChangedDialog(BuildContext context, String newStatus) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Statut modifié'),
          content: Text('Le statut de la commande a été modifié à "$newStatus".'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer l\'annulation'),
          content: const Text('Êtes-vous sûr de vouloir annuler cette commande? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () async {
                await firestore.FirebaseFirestore.instance
                    .collection('orders')
                    .doc(order.id)
                    .delete();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Retour à la page précédente
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        String? userRole = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Détails de la commande'),
            backgroundColor: Constants.primaryColor,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailCard('Description de l\'article:', order.itemDescription),
                const SizedBox(height: 10),
                _buildDetailCard('Nom du client:', order.customerName),
                const SizedBox(height: 10),
                _buildDetailCard('Adresse du client:', order.customerAddress),
                const SizedBox(height: 10),
                _buildDetailCard('Montant total:', '${order.totalAmount} €'),
                const SizedBox(height: 10),
                _buildDetailCard('Statut:', order.status),
                const SizedBox(height: 10),
                _buildDetailCard('Heure de ramassage:', order.pickupTime),
                const SizedBox(height: 20),
                if (userRole == 'Client' && order.status == 'En attente de ramassage') ...[
                  _buildActionButton(
                    context,
                    'Confirmer la commande',
                    Constants.primaryColor,
                        () async {
                      await firestore.FirebaseFirestore.instance
                          .collection('orders')
                          .doc(order.id)
                          .update({'status': 'En cours de traitement'});
                      _showStatusChangedDialog(context, 'En cours de traitement');
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                if (userRole == 'Client') ...[
                  _buildActionButton(
                    context,
                    'Annuler la commande',
                    Colors.redAccent,
                        () {
                      _showDeleteConfirmationDialog(context);
                    },
                  ),
                ],
                if (userRole == 'Propriétaire de pressing') ...[
                  _buildActionButton(
                    context,
                    'Changer le statut de la commande',
                    Constants.primaryColor,
                        () {
                      _showChangeStatusDialog(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(String title, String detail) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RichText(
          text: TextSpan(
            text: '$title ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: detail,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
