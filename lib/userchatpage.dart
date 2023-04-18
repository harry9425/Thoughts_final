import 'package:dummy_firebase/model%20classes/MessageModel.dart';
import 'package:dummy_firebase/model%20classes/userclass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'utils/marqueewidget.dart';
import 'package:intl/intl.dart';

class UserChatPage extends StatefulWidget {
  const UserChatPage({Key? key}) : super(key: key);

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {

  var auth = FirebaseAuth.instance;
  ItemScrollController itemScrollController=ItemScrollController();
  String userid = "";
  String chatuserid="";
  DatabaseReference database = FirebaseDatabase.instance.reference();
  List<MessageModel> list = [];
  String chatroom="";
  var laoding=true;
  late UserModel curruser,mainuser;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    curruser= ModalRoute.of(context)!.settings.arguments as UserModel;
    chatuserid=curruser.id;
    final ref = FirebaseDatabase.instance.ref().child("Users");
    ref.keepSynced(true);
    final snapshot2 = await ref.child(userid).get();
    if (snapshot2.exists) {
      UserModel userModel = UserModel.empty();
      userModel.name = snapshot2.child('name').value.toString() ?? '';
      userModel.id = snapshot2.child('id').value.toString() ?? '';
      userModel.uderdp = snapshot2.child('userdp').value.toString() ?? '';
      mainuser=userModel;
      setState(() {
        laoding=false;
      });
    }
    String chatroomid="";
    if(userid.compareTo(chatuserid)==-1) chatroomid=userid+"&"+chatuserid;
    else chatroomid=chatuserid+"&"+userid;
    chatroom=chatroomid;
    database.child('Chats').child(userid)
        .child(chatroomid)
        .orderByChild('time')
        .startAt('')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        list.clear();
        Map<dynamic, dynamic> value = event.snapshot.value as dynamic;
        value.forEach((key, data) {
          if(key!="info") {
            MessageModel messageModel = MessageModel.empty();
            messageModel.message = data['message'].toString() ?? '';
            messageModel.id = data['id'].toString() ?? '';
            messageModel.time = data['time'].toString() ?? '';
            messageModel.type = data['type'].toString() ?? '';
            messageModel.userid = data['userid'].toString() ?? '';
            list.add(messageModel);
          }
        });
        list.sort((a, b) => a.time.compareTo(b.time));
        setState(() {});
      } else {
        print('No data available');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    database.keepSynced(true);
    if (auth.currentUser == null) {
      Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route) => false);
    }
    userid = auth.currentUser!.uid;
    list.clear();
    curruser=UserModel.empty();
    mainuser=UserModel.empty();
  }

  @override
  Widget build(BuildContext context) {

    var messageController=TextEditingController();

    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: laoding?Center(child: CircularProgressIndicator(color: Colors.white,),):Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             GestureDetector(
               onTap: (){
                 Navigator.pushNamed(context,'userprofilepage',arguments:chatuserid);
               },
               child: Container(
                 width: MediaQuery.of(context).size.width*0.85,
                 margin: EdgeInsets.only(left: 20,right: 20),
                 padding: EdgeInsets.only(bottom: 10,top: 10,left: 20,right: 20),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   boxShadow: [
                     BoxShadow(
                       color: Colors.grey.withOpacity(0.3),
                       spreadRadius: 2,
                       blurRadius: 5,
                       offset: Offset(0, 3),
                     ),
                   ],
                   borderRadius: BorderRadius.circular(30)
                 ),
                 child: Row(
                   children: [
                     Container(
                       padding: EdgeInsets.all(2),
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: Colors.black,
                       ),
                       child: CircleAvatar(
                         backgroundColor: Colors.black,
                         radius: 40,
                         backgroundImage: NetworkImage(
                             curruser.userdp),
                       ),
                     ),
                     SizedBox(width: 20,),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Row(
                             children: [
                               Expanded(child: MarqueeWidget(child: Text("@"+curruser.name,style:TextStyle(color:Colors.black,fontWeight:FontWeight.bold,fontSize:18)))),
                               SizedBox(width: 15,),
                             ],
                           ),
                           SizedBox(height: 5,),
                           Row(
                             children: [
                               Expanded(child: MarqueeWidget(child: Text("chat with "+curruser.name,style:TextStyle(color:Colors.black,fontWeight:FontWeight.normal,fontSize:13)))),
                             ],
                           ),
                         ],
                       ),
                     )
                   ],
                 ),
               ),
             ),
           ],
         ),
         SizedBox(height: 20,),
         Expanded(
           child:
           ScrollablePositionedList.builder(
             itemScrollController: itemScrollController,
              itemCount: list.length,
               physics:  BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                MessageModel chatModel = list[index];
                //itemScrollController.scrollTo(index: list.length-1, duration: Duration(milliseconds: 500));
                return Container(
                  margin: EdgeInsets.only(left: 30,right: 30,bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 20,
                          backgroundImage: NetworkImage(
                              chatModel.userid==userid?mainuser.userdp:curruser.userdp),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(list[index].message),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(DateFormat('h:mm a').format(DateTime.parse(list[index].time)),style:TextStyle(color:Colors.black,fontWeight: FontWeight.bold,fontSize:12),)
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
         ),
         SizedBox(height: 20,),
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Expanded(
               child: Container(
                  margin: EdgeInsets.only(left: 20,right: 12),
                  padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ]
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 35,// specify smaller padding
                          child: TextField(
                            controller: messageController,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              hintText: 'Send Message',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
             ),
             SizedBox(width: 10,),
             GestureDetector(
               onTap: (){
                 if(messageController.text.isNotEmpty){
                   DatabaseReference db=FirebaseDatabase.instance.ref().child("Chats");
                   String message=messageController.text.trim();
                   DateTime today = DateTime.now();
                   String id=db.push().key.toString();
                   Map<String, dynamic> map = {
                     'id': id,
                     'userid':userid,
                     'message' : message,
                     'time' : today.toString(),
                     'type':"t",
                   };
                   db.child(userid).child(chatroom).child(id).set(map).then((value){
                     db.child(userid).child(chatroom).child("info").set(map).then((value){});
                     db.child(curruser.id).child(chatroom).child(id).set(map).then((value){
                       db.child(curruser.id).child(chatroom).child("info").set(map).then((value){messageController.clear();});});
                   });
                 }
               },
               child: Container(
                 child: Icon(Icons.send_rounded, color: Colors.white),
                 padding: EdgeInsets.all(11),
                 decoration:BoxDecoration(
                   shape: BoxShape.circle,
                   color: Color.fromRGBO(15, 15, 15, 1),
                 ),
               ),
             ),
             SizedBox(width: 20,),
           ],
         ),
         SizedBox(height: 20,),
        ],
      ),
    );
  }
}
