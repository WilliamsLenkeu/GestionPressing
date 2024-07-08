import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../models/notification.dart';


class notifPage extends StatelessWidget{
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: notifPage.navigatorKey,
      title: 'vos notifications',
      theme: ThemeData(
    colorScheme:const ColorScheme.light(),
    ),
      home: const MesNotifs()
    );

  }

}

class MesNotifs extends StatefulWidget{

  const MesNotifs({super.key});

  @override
  notifsPages createState()=>notifsPages();
}

class notifsPages extends State<MesNotifs>{
 static late List< Notifications> list=[];
  late String msg='';
  @override
   initState()  {
    // list=[
    //   Notifications( body: 'c est ok',title: '',channelId: '1'),Notifications(body: 'blader', title: 'title', channelId: 'channelId')
    // ];
     readNotif().then((value) => {
       setState(() {
          list=value;
       })
     });
     if(list==[]) {
       setState(() {
         msg='la liste est vide';
       });
     }
    super.initState();
  }

  removeAll(){
    removeAllNotif()
        .then((value) => {
      if(value) {
        setState(() {list=[];})
      }
    }
    );
  }
 
   remove(int id) async {
  bool ok= await removeNotif(id);
  if(ok){
      list.forEach((element) {
        if(element.id==id){
          list.remove(element);
        }
    });
  }
 }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text('vos notifications',style: TextStyle(color:  Colors.white),),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions:  [
          IconButton(onPressed: (){
            removeAll();
            }, icon: const Icon(Icons.delete_forever_rounded, size: 30, color: Colors.white,))
        ],),
      body:  Column(
        children: [Text(msg),
          for(var item in list )
            Padding(padding:const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                child:Dismissible(key: Key(item.id.toString(),),
                    onDismissed:(direction) async {
                     await remove(item.id);
                    } ,
                    child:Container(
                  decoration:  BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(width: 1,color: Colors.white60),
                      borderRadius: const BorderRadius.all(Radius.circular(10))
                  ),

                  padding:const EdgeInsets.all(5),
                  child:Row(
                      children: [
                       const  Icon(Icons.cabin,size: 30,color: Colors.white,),
                        Column(
                          children: [
                            Text(item.title,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: 20),),
                            Text(item.body,style:  const TextStyle(color: Colors.white,fontSize: 30,) ,),
                           Text('${item.date.day}/${item.date.month}/${item.date.year}' ,style: const TextStyle(fontSize: 15))
                          ,]
                        ),
                      ],
                    ),
                  )
                )
            )

        ],
      )
    );

  }
}