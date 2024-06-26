class Order {
  final int orderId;
  final double totalAmount;
  final String serviceType;
  final String itemDescription;
  final String status;
  final String customerName;
  final String customerAddress;
  final String pickupTime;
  bool isCompleted;
  final String serviceImage;

  Order({
    required this.orderId,
    required this.totalAmount,
    required this.serviceType,
    required this.itemDescription,
    required this.status,
    required this.customerName,
    required this.customerAddress,
    required this.pickupTime,
    required this.isCompleted,
    required this.serviceImage,
  });

  static List<Order> orderList = [
    Order(
      orderId: 0,
      totalAmount: 22.0,
      serviceType: 'Lavage et repassage',
      itemDescription: 'Chemise et pantalon',
      status: 'En attente de ramassage',
      customerName: 'Jean Dupont',
      customerAddress: '123 Rue des Fleurs, 75000 Paris',
      pickupTime: '2024-06-27 10:00',
      isCompleted: false,
      serviceImage: 'assets/images/lavage_repassage.png',
    ),
    Order(
      orderId: 1,
      totalAmount: 15.5,
      serviceType: 'Nettoyage à sec',
      itemDescription: 'Robe',
      status: 'En cours de traitement',
      customerName: 'Marie Durand',
      customerAddress: '456 Avenue des Champs, 69000 Lyon',
      pickupTime: '2024-06-28 14:30',
      isCompleted: false,
      serviceImage: 'assets/images/nettoyage_sec.png',
    ),
    Order(
      orderId: 2,
      totalAmount: 30.0,
      serviceType: 'Lavage',
      itemDescription: 'Couette',
      status: 'Prêt à être livré',
      customerName: 'Pauline Martin',
      customerAddress: '789 Boulevard des Etoiles, 33000 Bordeaux',
      pickupTime: '2024-06-26 17:00',
      isCompleted: true,
      serviceImage: 'assets/images/lavage.png',
    ),
    Order(
      orderId: 3,
      totalAmount: 18.0,
      serviceType: 'Repassage',
      itemDescription: 'Chemisier et jupe',
      status: 'En cours de traitement',
      customerName: 'Claire Lefevre',
      customerAddress: '567 Avenue des Roses, 59000 Lille',
      pickupTime: '2024-06-29 11:00',
      isCompleted: false,
      serviceImage: 'assets/images/repassage.png',
    ),
    Order(
      orderId: 4,
      totalAmount: 25.0,
      serviceType: 'Nettoyage à sec',
      itemDescription: 'Costume',
      status: 'En attente de ramassage',
      customerName: 'Pierre Leclerc',
      customerAddress: '890 Rue des Violettes, 69000 Lyon',
      pickupTime: '2024-06-27 09:30',
      isCompleted: false,
      serviceImage: 'assets/images/nettoyage_sec.png',
    ),
    Order(
      orderId: 5,
      totalAmount: 28.0,
      serviceType: 'Repassage',
      itemDescription: 'Chemise et pantalon',
      status: 'Prêt à être livré',
      customerName: 'Sophie Rousseau',
      customerAddress: '234 Avenue du Soleil, 44000 Nantes',
      pickupTime: '2024-06-25 15:00',
      isCompleted: true,
      serviceImage: 'assets/images/repassage.png',
    ),
    Order(
      orderId: 6,
      totalAmount: 33.5,
      serviceType: 'Lavage',
      itemDescription: 'Draps et taies d\'oreiller',
      status: 'En cours de traitement',
      customerName: 'Antoine Dubois',
      customerAddress: '345 Rue des Cerisiers, 13000 Marseille',
      pickupTime: '2024-06-30 12:00',
      isCompleted: false,
      serviceImage: 'assets/images/lavage.png',
    ),
    Order(
      orderId: 7,
      totalAmount: 20.0,
      serviceType: 'Lavage et repassage',
      itemDescription: 'Chemise',
      status: 'En attente de ramassage',
      customerName: 'Julie Blanc',
      customerAddress: '456 Avenue des Roses, 59000 Lille',
      pickupTime: '2024-06-26 11:30',
      isCompleted: false,
      serviceImage: 'assets/images/lavage_repassage.png',
    ),
    Order(
      orderId: 8,
      totalAmount: 17.5,
      serviceType: 'Nettoyage à sec',
      itemDescription: 'Veste',
      status: 'Prêt à être livré',
      customerName: 'Lucas Martin',
      customerAddress: '567 Boulevard des Lilas, 75000 Paris',
      pickupTime: '2024-06-29 16:30',
      isCompleted: true,
      serviceImage: 'assets/images/nettoyage_sec.png',
    ),
    Order(
      orderId: 9,
      totalAmount: 21.0,
      serviceType: 'Repassage',
      itemDescription: 'Chemisier et pantalon',
      status: 'En cours de traitement',
      customerName: 'Emma Lemoine',
      customerAddress: '678 Rue des Marguerites, 69000 Lyon',
      pickupTime: '2024-06-28 09:00',
      isCompleted: false,
      serviceImage: 'assets/images/repassage.png',
    ),
  ];

  static List<Order> getOrdersPendingPickup() {
    return orderList.where((order) => order.status == 'En attente de ramassage').toList();
  }

  static List<Order> getOrdersInProcessing() {
    return orderList.where((order) => order.status == 'En cours de traitement').toList();
  }

  static List<Order> getOrdersReadyForDelivery() {
    return orderList.where((order) => order.status == 'Prêt à être livré').toList();
  }
}
