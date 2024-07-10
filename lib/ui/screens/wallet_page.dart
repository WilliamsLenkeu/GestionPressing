import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String? _userId = FirebaseAuth.instance.currentUser?.uid;
  double _balance = 0.0;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    if (_userId != null) {
      fetchBalance();
      fetchTransactions();
    }
  }

  Future<void> fetchBalance() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await FirebaseFirestore.instance.collection('users').doc(_userId).get();

      if (userDoc.exists) {
        setState(() {
          _balance = userDoc.data()?['solde'] ?? 0.0;
        });
      } else {
        print('User does not exist or document not found');
      }
    } catch (e) {
      print('Error fetching balance: $e');
    }
  }

  Future<void> fetchTransactions() async {
    try {
      QuerySnapshot<Map<String, dynamic>> transactionDocs = await FirebaseFirestore.instance
          .collection('transactions')
          .get();

      if (transactionDocs.docs.isNotEmpty) {
        setState(() {
          _transactions = transactionDocs.docs
              .map((doc) => Transaction.fromFirestore(doc.data()))
              .toList();
        });
      } else {
        print('No transactions found');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your balance: $_balance',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Debiteur: ${_transactions[index].debiteur}'),
                  subtitle: Text('Montant: ${_transactions[index].montant.toString()}'),
                  trailing: Text('Receveur: ${_transactions[index].receveur}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Transaction {
  final String debiteur;
  final double montant;
  final String receveur;

  Transaction({
    required this.debiteur,
    required this.montant,
    required this.receveur,
  });

  factory Transaction.fromFirestore(Map<String, dynamic> json) {
    return Transaction(
      debiteur: json['debiteur'] ?? '',
      montant: (json['montant'] ?? 0.0).toDouble(), // Convertir en double si nécessaire
      receveur: json['receveur'] ?? '',
    );
  }
}
