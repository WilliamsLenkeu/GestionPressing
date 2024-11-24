import 'package:flutter/material.dart';
import '../../models/pressing.dart';

class PressingSearch extends StatefulWidget{
  const PressingSearch({super.key});

  @override
  createState()=>PressingSearchState();
}

class PressingSearchState extends State<PressingSearch>{
  List<Pressing> list=[];

  @override
  void initState()  {
    super.initState();

     Pressing.getPressings().then((value){
      setState(() {
        list=value;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
   return  Scaffold(
     body: Column(
       children: [
        for(var item in list)
       Container(
   decoration:  BoxDecoration(
   color: Colors.blue,
       border: Border.all(width: 1,color: Colors.white60),
       borderRadius: const BorderRadius.all(Radius.circular(10))
   ),
    padding: const EdgeInsets.all(3),
    margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
    child: Column(
    children: [
    const Icon(Icons.cabin_sharp),
    Text(item.nom),
    Text(item.ville),
    Text(item.quartier),
    Text('a ${item.distance}m')
    ],
    ),
    )
       ],
     ),
   );
  }

}