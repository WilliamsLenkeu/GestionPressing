import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'order.dart' as local_order;

class AddOrderModal extends StatefulWidget {
  @override
  _AddOrderModalState createState() => _AddOrderModalState();
}

class _AddOrderModalState extends State<AddOrderModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _pickupTimeController = TextEditingController();

  String _serviceType = 'Lavage';

  void _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        local_order.Order newOrder = local_order.Order(
          totalAmount: double.parse(_totalAmountController.text),
          serviceType: _serviceType,
          itemDescription: _itemDescriptionController.text,
          status: 'En attente de ramassage',
          customerName: _customerNameController.text,
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
          SnackBar(content: Text('Veuillez vous connecter pour ajouter une commande')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: ListView(
    children: [
    DropdownButtonFormField<String>(
    value: _serviceType,
    decoration: const InputDecoration(labelText: 'Type de service'),
    items: ['Lavage', 'Lavage a sec', 'Repassage']
        .map((type) => DropdownMenuItem(
    value: type,
    child: Text(type),
    ))
        .toList(),
    onChanged: (value) {
    setState(() {
    _serviceType = value!;
    });
    },
    ),
    TextFormField(
    controller: _totalAmountController,
    decoration: InputDecoration(labelText: 'Montant total (€)'),
    keyboardType: TextInputType.number,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Veuillez entrer le montant total';
    }
    return null;
    },
    ),
    TextFormField(
    controller: _itemDescriptionController,
    decoration: InputDecoration(labelText: 'Description de l\'article'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Veuillez entrer la description de l\'article';
    }
    return null;
    },
    ),
    TextFormField(
    controller: _customerNameController,
    decoration: InputDecoration(labelText: 'Nom du client'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Veuillez entrer le nom du client';
    }
    return null;
    },
    ),
    TextFormField(
    controller: _customerAddressController,
    decoration: InputDecoration(labelText: 'Adresse du client'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Veuillez entrer l\'adresse du client';
    }
    return null;
    },
    ),
    TextFormField(
    controller: _pickupTimeController,
    decoration: InputDecoration(labelText: 'Heure de ramassage'),
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
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: _submitOrder,
        child: Text('Ajouter la commande'),
      ),
    ],
    ),
    ),
    );
  }
}

