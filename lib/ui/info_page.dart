import 'package:flutter/material.dart';
import 'package:gestwash/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestwash/ui/root_page.dart';
import 'login_screen.dart';

class InfoPage extends StatefulWidget {
  final User currentUser;

  const InfoPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedRole;

  String? _userEmail;

  List<String> roles = [
    'Propriétaire de pressing',
    'Client',
  ];

  // Instance de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _userEmail = widget.currentUser.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Information utilisateur',
          style: TextStyle(color: Constants.blackColor),
        ),
        backgroundColor: Constants.primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue, ${widget.currentUser.displayName ?? ''}',
              style: TextStyle(
                color: Constants.primaryColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Email: $_userEmail',
              style: TextStyle(
                color: Constants.secondaryColor,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Nom complet',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Constants.primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Constants.primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Constants.primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: roles.map((role) {
                return RadioListTile<String>(
                  title: Text(role),
                  value: role,
                  groupValue: _selectedRole,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                // Logique de validation ici
                if (_fullNameController.text.isNotEmpty &&
                    _phoneNumberController.text.isNotEmpty &&
                    _addressController.text.isNotEmpty &&
                    _selectedRole != null) {
                  // Créer un document dans Firestore pour l'utilisateur
                  try {
                    await _firestore.collection('users').doc(widget.currentUser.uid).set({
                      'fullName': _fullNameController.text,
                      'phoneNumber': _phoneNumberController.text,
                      'address': _addressController.text,
                      'role': _selectedRole,
                      'email': _userEmail,
                      'solde': 0,
                    });

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RootPage()),
                    );
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Erreur lors de la sauvegarde'),
                        content: const Text('Une erreur est survenue lors de la sauvegarde des données.'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  // Afficher une erreur si les champs ne sont pas remplis
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Erreur de validation'),
                      content: const Text('Veuillez remplir tous les champs et sélectionner un rôle.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Valider',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
