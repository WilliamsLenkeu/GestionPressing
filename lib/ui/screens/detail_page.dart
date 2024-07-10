import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order.dart' as model;
import 'package:gestwash/constants.dart';

class DetailPage extends StatelessWidget {
  final model.Order order;

  const DetailPage({Key? key, required this.order}) : super(key: key);

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

  Future<String?> _getOwnerId(String role) async {
    try {
      // Récupérer l'ID du propriétaire du pressing en fonction du rôle
      firestore.QuerySnapshot querySnapshot = await firestore.FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        print('Aucun utilisateur trouvé avec le rôle $role');
        return null;
      }
    } catch (e) {
      print('Error retrieving owner ID: $e');
      return null;
    }
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

  Future<void> _processPayment(BuildContext context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté. Veuillez vous connecter pour effectuer un paiement.')),
      );
      return;
    }

    // Récupérer l'ID du propriétaire du pressing
    String? ownerId = await _getOwnerId('Propriétaire de pressing');
    if (ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun propriétaire de pressing trouvé.')),
      );
      return;
    }

    double amountPaid = order.totalAmount; // Montant payé par le client

    try {
      // Mettre à jour le statut de la commande
      await firestore.FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .update({'status': 'En cours de traitement'});

      // Mettre à jour le solde du propriétaire de pressing
      await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .update({
        'solde': firestore.FieldValue.increment(amountPaid),
      });

      // Enregistrer la transaction dans la collection transactions
      await firestore.FirebaseFirestore.instance
          .collection('transactions')
          .add({
        'debiteur': currentUser.displayName ?? currentUser.email ?? 'Utilisateur inconnu',
        'receveur': 'Propriétaire de pressing',
        'montant': amountPaid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showStatusChangedDialog(context, 'En cours de traitement');
    } catch (e) {
      print('Error processing payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue lors du traitement du paiement.')),
      );
    }
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
                _buildDetailCard('Montant total:', '${order.totalAmount} XAF'),
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
                        () => _processPayment(context), // Utilisez une fonction synchrone pour onPressed
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
                    'Commande remplie',
                    Constants.primaryColor,
                        () async {
                      await firestore.FirebaseFirestore.instance
                          .collection('orders')
                          .doc(order.id)
                          .update({'status': 'Prêt à être livré'});
                      _showStatusChangedDialog(context, 'Prêt à être livré');
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
