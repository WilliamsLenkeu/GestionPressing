import 'package:cloud_firestore/cloud_firestore.dart';

class Pressing{
  late String nom;
  late String ville;
  late String quartier;
  late double lat;
  late double long;
  late double distance;

  Pressing.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot){
    final data=snapshot.data();
      nom =data?['nom'];
      ville=data?['ville'];
      quartier=data?['quartier'];
      lat=data?['lat'];
      long=data?['long'];
  }
  Map<String, dynamic> toFireStore(){
        return{
          'nom':nom,
          'ville':ville,
          'quartier':quartier,
          'lat':lat,
          'long':long
        };
  }

  static var db= FirebaseFirestore.instance;
  Pressing({required this.nom,required this.ville,required this.quartier, required this.long,required this.lat,required this.distance});
  Pressing.create({required this.nom,required this.ville,required this.quartier, required this.long,required this.lat});
  static const pressingCollection='pressings';
  static Future<List<Pressing>> getPressings() async {
      List<Pressing> list=[];
    await  db.collection(pressingCollection).get().then((query){
        for(var item in query.docs){
          list.add(Pressing.fromFireStore(item));
        }
      },onError: (error){ Future.error(error);});
      return list;
  }
}