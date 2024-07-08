
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Notifications{
   late String title;
   late String body;
   late String channelId;
   late int id;
   late DateTime date;

   String getBody(){
     return body;
   }

   Notifications({required String? body,required String? title, required String? channelId,required this.date}){
     this.body=body!;
     this.title=title!;
     this.channelId=channelId!;
   }

   Notifications.create({required int? id,required String? body,required String? title, required String? channelId,required this.date}){
     this.body=body!;
     this.title=title!;
     this.channelId=channelId!;
     this.id=id!;
   }

   String notificationToJson() {
     Map<String,dynamic> val= {
       'body':body,
       'title':title,
       'channelId':channelId,
       'id':id,
       'date':date.toString()
     };
      return jsonEncode(val);
   }

  Notifications.jsonToNotification( String jsonNotif){
     Map<String,dynamic> notif=jsonDecode(jsonNotif);
     title=notif['title'];
     channelId=notif['channelId'];
     body=notif['body'];
     id=notif['id'];
     date=DateTime.parse(notif['date']);
  }
}


Future<void> setNotification(String channelKey,String title,String body) async {
  bool isPermission= await AwesomeNotifications().isNotificationAllowed();
  if(!isPermission){
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  Notifications notification=Notifications( body: body, title:title, channelId: channelKey,date: DateTime.now());
  await addNotif(notification).then((value) => {
    if(value){
      AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10,
            channelKey: channelKey,
            actionType: ActionType.Default,
            title: title,
            body: body,
          )
      )
    }
  });

}

const String listname='notifsList';

Future<bool> addNotif(Notifications notif) async{
   List<Notifications> notifs=[];
  await readNotif().then((value) => notifs=value)
  .catchError((error)=>{ Future.error(error) });
  notif.id=notifs.length;
  notifs.add(notif);
  return await setNotifs(notifs);

}

Future<bool> setNotifs(List<Notifications> notifs)async {
  var pref= await SharedPreferences.getInstance();
  List<String> stringNotifs=[];
  notifs.forEach((element) {
    stringNotifs.add(element.notificationToJson());
  });

  return  await pref.setStringList(listname,stringNotifs);
}

Future<List<Notifications>> readNotif() async{
  var pref= await SharedPreferences.getInstance();
  List<String>? val= await pref.getStringList(listname);
  if(val==null) {
    return [];
  }
  else{
    List<Notifications> notifs=[];
    val.forEach((element) {
      notifs.add(Notifications.jsonToNotification(element));
    });
    return notifs;
  }
}

Future<bool> removeAllNotif()async {
  var pref= await SharedPreferences.getInstance();
  return await pref.remove(listname);
}

Future<bool> removeNotif(int id)  async {
  List<Notifications> notifs=[];
  await readNotif().then((value) => notifs=value)
      .catchError((error)=>{ Future.error(error) });
  if(id>=0 && id<notifs.length) {
    for(var i=0;i<notifs.length;i++){
      if(notifs[i].id==id){
        notifs.removeAt(i);
         await setNotifs(notifs);
         return true;
      }
    }
  }
  return Future.error('l id $id n existe pas ${notifs.length}');
}