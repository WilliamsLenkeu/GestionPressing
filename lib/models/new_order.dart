import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'order.dart' as local_order;

class AddOrderModal extends StatefulWidget {
  const AddOrderModal({super.key});

  @override
  _AddOrderModalState createState() => _AddOrderModalState();
}

class _AddOrderModalState extends State<AddOrderModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _pickupTimeController = TextEditingController();

  String _serviceType = 'Lavage';
  String? _customerName;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _setInitialTotalAmount();
  }

  void _fetchUserData() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _customerName = currentUser.displayName;
    }
  }

  void _setInitialTotalAmount() {
    // Définir le montant initial prédéfini pour chaque type de service
    switch (_serviceType) {
      case 'Lavage':
        _totalAmountController.text = Constants.lavageAmount.toString();
        break;
      case 'Lavage a sec':
        _totalAmountController.text = Constants.lavageSecAmount.toString();
        break;
      case 'Repassage':
        _totalAmountController.text = Constants.repassageAmount.toString();
        break;
      default:
        _totalAmountController.text = '';
    }
  }

  void _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        local_order.Order newOrder = local_order.Order(
          totalAmount: double.parse(_totalAmountController.text),
          serviceType: _serviceType,
          itemDescription: _itemDescriptionController.text,
          status: 'En attente de ramassage',
          customerName: _customerName!,
          customerAddress: _customerAddressController.text,
          pickupTime: _pickupTimeController.text,
          isCompleted: false,
          id: '',
          userEmail: currentUser.email!,
        );

        FirebaseFirestore.instance.collection('orders').add(newOrder.toMap());

        Navigator.pop(context);
      } else {
        // Handle case where the user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter pour ajouter une commande')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _serviceType,
              decoration: InputDecoration(
                labelText: 'Type de service',
                labelStyle: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              items: ['Lavage', 'Lavage a sec', 'Repassage']
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _serviceType = value!;
                  _setInitialTotalAmount(); // Mettre à jour le montant lorsque le type de service change
                });
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _totalAmountController,
              readOnly: true, // Champ non modifiable
              decoration: InputDecoration(
                labelText: 'Montant total (XAF)',
                labelStyle: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _itemDescriptionController,
              decoration: InputDecoration(
                labelText: 'Description de l\'article',
                labelStyle: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer la description de l\'article';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _customerName ?? '',
              readOnly: true, // Récupéré à partir des informations de l'utilisateur
              decoration: InputDecoration(
                labelText: 'Nom du client',
                labelStyle: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _customerAddressController,
              decoration: InputDecoration(
                labelText: 'Adresse du client',
                labelStyle: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'adresse du client';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _pickupTimeController,
              decoration: InputDecoration(
                labelText: 'Heure de ramassage',
                labelStyle: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'heure de ramassage';
                }
                return null;
              },
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (date != null) {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _pickupTimeController.text =
                      '${date.year}-${date.month}-${date.day} ${time.hour}:${time.minute}';
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Ajouter la commande'),
            ),
          ],
        ),
      ),
    );
  }
}
