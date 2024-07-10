import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late Stream<List<Map<String, dynamic>>> transactionsStream;
  double? solde;

  @override
  void initState() {
    super.initState();
    transactionsStream = Stream.empty(); // Initialisation avec une valeur par défaut
    _fetchData();
  }

  Future<void> _fetchData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      firestore.QuerySnapshot transactionsSnapshot = await firestore.FirebaseFirestore.instance
          .collection('transactions')
          .where('debiteur', isEqualTo: currentUser.displayName ?? currentUser.email ?? 'Utilisateur inconnu')
          .get();

      setState(() {
        transactionsStream = Stream.value(transactionsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
      });

      firestore.DocumentSnapshot userDoc = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      setState(() {
        solde = userDoc['solde'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Page de dépenses',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (solde != null) ...[
              Text(
                'Solde total : $solde €',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              'Transactions :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: transactionsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune transaction trouvée.'));
                  }
                  List<Map<String, dynamic>> transactions = snapshot.data!;
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> transaction = transactions[index];
                      return ListTile(
                        title: Text('Montant : ${transaction['montant']} €'),
                        subtitle: Text('De : ${transaction['debiteur']} | Vers : ${transaction['receveur']}'),
                        trailing: Text(transaction['timestamp'] != null ? 'Date : ${transaction['timestamp']}' : ''),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
