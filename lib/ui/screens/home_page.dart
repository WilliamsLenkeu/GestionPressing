import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gestwash/constants.dart';
import 'package:gestwash/models/order.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final List<Order> _orderList = Order.orderList;
    final List<String> _orderTypes = [
      'Lavage et repassage',
      'Nettoyage à sec',
      'Lavage',
      'Repassage'
    ];

    // Créez une liste unique des commandes par type de service
    final List<Order> uniqueOrderList = [];
    final Set<String> seenServices = {};

    for (final Order order in _orderList) {
      if (!seenServices.contains(order.serviceType)) {
        uniqueOrderList.add(order);
        seenServices.add(order.serviceType);
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    width: size.width * .9,
                    decoration: BoxDecoration(
                      color: Constants.primaryColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        Expanded(
                          child: TextField(
                            showCursor: false,
                            decoration: InputDecoration(
                              hintText: 'Chercher une commande',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 50.0,
              width: size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _orderTypes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Text(
                        _orderTypes[index],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: selectedIndex == index
                              ? FontWeight.bold
                              : FontWeight.w300,
                          color: selectedIndex == index
                              ? Constants.primaryColor
                              : Constants.blackColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: size.height * .3,
              child: ListView.builder(
                itemCount: uniqueOrderList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Constants.primaryColor.withOpacity(.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          right: 20,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              onPressed: null,
                              icon: const Icon(Icons.add_circle_sharp),
                              color: Constants.primaryColor,
                              iconSize: 30,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 50,
                          right: 50,
                          top: 50,
                          bottom: 50,
                          child: Center(
                            child: SizedBox(
                              height: 120,
                              width: 120,
                              child: Image.asset(
                                uniqueOrderList[index].serviceImage,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                uniqueOrderList[index].serviceType,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                uniqueOrderList[index].itemDescription,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${uniqueOrderList[index].totalAmount} XAF',
                              style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 16, bottom: 20, top: 20),
              child: const Text(
                'Dernières commandes',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: size.height * .5,
              child: ListView.builder(
                itemCount: _orderList.length,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Constants.primaryColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 80.0,
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                color: Constants.primaryColor.withOpacity(.8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Positioned(
                              left: 5,
                              right: 5,
                              bottom: 5,
                              top: 5,
                              child: Center(
                                child: SizedBox(
                                  height: 80.0,
                                  child: Image.asset(
                                    _orderList[index].serviceImage,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              left: 80,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_orderList[index].serviceType),
                                  Text(
                                    _orderList[index].itemDescription,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Constants.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            '${_orderList[index].totalAmount} XAF',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Constants.blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
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
