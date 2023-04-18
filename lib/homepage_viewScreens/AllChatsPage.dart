import 'package:dummy_firebase/main.dart';
import 'package:dummy_firebase/model%20classes/ThoughtsModel.dart';
import 'package:dummy_firebase/utils/alluserswidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../model classes/MessageModel.dart';
import '../model classes/userclass.dart';
import '../utils/marqueewidget.dart';

class AllChatPage extends StatefulWidget {
  const AllChatPage({Key? key}) : super(key: key);

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {

  var auth=FirebaseAuth.instance;
  static String userid="";
  var modaldone=false;
  DatabaseReference database=FirebaseDatabase.instance.reference();
  List<MessageModel> list=[];
  List<ThoughtModel> thlist=[];
  var loaded=false;
  var searchcontroller=TextEditingController();
  final _focusNode = FocusNode();
  var droplist=true;
  var done=false;
  ItemScrollController itemScrollController=ItemScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    database.keepSynced(true);
    if(auth.currentUser==null){
      Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route)=>false);
    }
    List<MessageModel> backlist=[];
    userid=auth.currentUser!.uid;
    database.child("Chats").child(userid).onValue.listen((event) async {
      if (event.snapshot.value != null) {
        List<MessageModel> tempList = [];
        for(DataSnapshot data in event.snapshot.children) {
          MessageModel messageModel = MessageModel.empty();
          messageModel.message = data.child("info").child("message").value
              .toString() ?? '';
          messageModel.messageby = data.child("info").child("userid").value
              .toString() ?? '';
          messageModel.time = data.child("info").child("time").value
              .toString() ?? '';
          messageModel.type = data.child("info").child("type").value
              .toString() ?? '';
          messageModel.imageurl="-1";
          var idlist=data.key.toString().split('&') ?? [];
          messageModel.userid=idlist[0]==userid?idlist[1]:idlist[0];
          messageModel.username = "Username";
          messageModel.dpurl = "n";
          var uref = FirebaseDatabase.instance.ref().child("Users").child(
              messageModel.userid);
          uref.keepSynced(true);
          await uref.child("name").get().then((value) {
            messageModel.username = value.value.toString();
          });
          await uref.child("userdp").get().then((value) {
            messageModel.dpurl = value.value.toString();
          });
          if(done==false) {
            await uref.child("Thoughts").get().then((value) {
              for (DataSnapshot snapshot in value.children) {
                if (snapshot
                    .child("lock")
                    .value
                    .toString() == "false") {
                  ThoughtModel thoughtModel = ThoughtModel.empty();
                  thoughtModel.time = snapshot
                      .child("time")
                      .value
                      .toString();
                  thoughtModel.thought = snapshot
                      .child("thought")
                      .value
                      .toString();
                  thoughtModel.userid = snapshot
                      .child("userid")
                      .value
                      .toString();
                  thoughtModel.agree = snapshot.child("agree").value.toString() ?? '';
                  thoughtModel.key = snapshot.key.toString();
                  thoughtModel.username = messageModel.username;
                  thoughtModel.userdp = messageModel.dpurl;
                  messageModel.imageurl=thlist.length.toString();
                  thlist.add(thoughtModel);
                  break;
                }
              }
            });
          }
          tempList.add(messageModel);
        }
        tempList.sort((a, b) => b.time.compareTo(a.time));
        setState(() {
          done=true;
          list = tempList;
          backlist = tempList;
          loaded = true;
        });
      } else {
        print('No data available');
      }
    });
    searchcontroller.addListener(() {
      if(searchcontroller.text.trim().isNotEmpty) {
        List<MessageModel> tempList = [];
        for (int i = 0; i < list.length; i++) {
          if (list[i].username.contains(searchcontroller.text.trim())) {
            tempList.add(list[i]);
          }
        }
        setState(() {
          list = tempList;
        });
      }
      else{
        setState(() {
          list = backlist;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        minimum: EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50,),
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    boxShadow:[
                      BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        color: Colors.grey.withOpacity(0.3)
                      )
                    ]
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 15,),
                      Row(
                        children: [
                          SizedBox(width: 15,),
                          Container(
                            //padding: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black87,
                            ),
                            child: Icon(
                              Icons.message, color: Colors.white,
                              size: 20,),
                          ),
                          SizedBox(width: 10,),
                          Text("Messages", style: TextStyle(color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),),
                          SizedBox(width: 15,)
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 15,right: 15,top: 5,bottom: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.search, color: Colors.black),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                      height: 35,// specify smaller padding
                                      child: TextField(
                                        focusNode: _focusNode,
                                        controller: searchcontroller,
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          hintText: 'Search username',
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
                                  searchcontroller.text.isNotEmpty?
                                  GestureDetector(
                                    child: Icon(Icons.cancel, color: Colors.grey),
                                    onTap:(){
                                      searchcontroller.clear();
                                    },
                                  ):Container(),
                                ],
                              ),
                            ),
                          ),
                          Text(droplist?"Hide Thoughts":"View Thoughts",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize:10),),
                          SizedBox(width: 5,),
                          GestureDetector(
                              onTap: (){
                                setState(() {
                                  droplist=!droplist;
                                });
                              },
                              child: Icon(droplist?Icons.arrow_drop_up_outlined:Icons.arrow_drop_down_circle,color: Colors.black,size: 30,)),
                          SizedBox(width: 10,)
                        ],
                      ),
                      SizedBox(height: 10,)
                    ],
                  ),
                ),
                droplist?Container(
                  height: 150,
                  margin: EdgeInsets.only(right: 10,),
                  child: Expanded(
                    child: ScrollablePositionedList.builder(
                      itemScrollController: itemScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                      itemCount: thlist.length,
                      //physics:  BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        ThoughtModel thoughtModel = thlist[index];
                        return  Container(
                          width: 200,
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.only(right: 10,bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow:[
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black
                                    ),
                                    margin: EdgeInsets.only(right: 10),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black,
                                      backgroundImage: NetworkImage(thoughtModel.userdp)
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap:(){
                                      showModalBottomSheet(context: context,
                                          backgroundColor: Colors.black54,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                                          ),
                                          builder: (context){
                                            return Container(
                                              padding: EdgeInsets.all(30),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text("Make Selection!",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 30),),
                                                  SizedBox(height: 4,),
                                                  Text(
                                                    "Select one of the options below to Re-Post the thought",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight
                                                            .normal,
                                                        fontSize: 15),
                                                    textAlign: TextAlign.start,),
                                                  SizedBox(height: 25,),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (modaldone == false) {
                                                        setState(() {
                                                          modaldone == true;
                                                        });
                                                        Fluttertoast.showToast(
                                                          msg: 'Posting...',
                                                          toastLength: Toast.LENGTH_SHORT,
                                                          gravity: ToastGravity.BOTTOM,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor: Colors.red,
                                                          textColor: Colors.white,
                                                          fontSize: 16.0,
                                                        );
                                                        String? key = FirebaseDatabase.instance.ref()
                                                            .push()
                                                            .key;
                                                        DateTime today = DateTime
                                                            .now();
                                                        Map<String, dynamic> map = {
                                                          'key': key,
                                                          'userid': userid,
                                                          'thought': thoughtModel
                                                              .thought,
                                                          'time': today.toString(),
                                                          'sentiment': thoughtModel
                                                              .sentiment,
                                                          'coor': {
                                                            'latitude':24.87,
                                                            'longitude': 23.00,
                                                          },
                                                          'lock': thoughtModel.lock,
                                                          'agree': 0,
                                                        };
                                                        FirebaseDatabase.instance.ref().child(
                                                            "Thoughts")
                                                            .child(key!)
                                                            .set(map)
                                                            .whenComplete(() {
                                                          Fluttertoast.showToast(
                                                            msg: 'In-Progress....',
                                                            toastLength: Toast.LENGTH_LONG,
                                                            gravity: ToastGravity.BOTTOM,
                                                            timeInSecForIosWeb: 1,
                                                            backgroundColor: Colors.red,
                                                            textColor: Colors.white,
                                                            fontSize: 16.0,
                                                          );
                                                          FirebaseDatabase.instance.ref().child(
                                                              "Users").child(
                                                              userid).child(
                                                              "Thoughts").child(
                                                              key!)
                                                              .set(map)
                                                              .whenComplete(() {
                                                            Fluttertoast.showToast(
                                                              msg: 'Posted successfully',
                                                              toastLength: Toast.LENGTH_LONG,
                                                              gravity: ToastGravity.BOTTOM,
                                                              timeInSecForIosWeb: 1,
                                                              backgroundColor: Colors.red,
                                                              textColor: Colors.white,
                                                              fontSize: 16.0,
                                                            );
                                                            print("posted boi");
                                                            Navigator.pop(context);
                                                          });
                                                        }).onError((error,
                                                            stackTrace) {
                                                          Fluttertoast.showToast(
                                                            msg: 'BMS Error Occured',
                                                            toastLength: Toast.LENGTH_SHORT,
                                                            gravity: ToastGravity.BOTTOM,
                                                            timeInSecForIosWeb: 1,
                                                            backgroundColor: Colors.red,
                                                            textColor: Colors.white,
                                                            fontSize: 16.0,
                                                          );
                                                          Navigator.pop(context);
                                                        });
                                                      }
                                                      else print("outer error");
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(15),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius
                                                              .circular(20),
                                                          color: Colors.white
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .start,
                                                        children: [
                                                          Icon(Icons.repeat,color: Colors.black,size: 60,),
                                                          SizedBox(width: 20,),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text(
                                                                  "Re-Post instantly",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .bold,
                                                                      fontSize: 18)),
                                                              SizedBox(height: 5,),
                                                              Text(
                                                                  "Share without any changes",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .normal,
                                                                      fontSize: 15)),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 30,),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Clipboard.setData(ClipboardData(text: thoughtModel.thought));
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(15),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius
                                                              .circular(20),
                                                          color: Colors.white
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .start,
                                                        children: [
                                                          Icon(Icons.copy_rounded,
                                                            color: Colors.black,
                                                            size: 60,),
                                                          SizedBox(width: 20,),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text("Copy and Edit",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .bold,
                                                                      fontSize: 18)),
                                                              SizedBox(height: 5,),
                                                              Text(
                                                                  "Copy the thought to clipboard",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .normal,
                                                                      fontSize: 15)),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          }
                                      ).whenComplete((){
                                        setState(() {
                                          modaldone=false;
                                        });
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: Offset(0, 3),
                                              color: Colors.grey.withOpacity(0.3)
                                          )
                                        ],
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.repeat,
                                            color: Colors.black87,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  GestureDetector(
                                    onTap: () {
                                      var uref = FirebaseDatabase.instance.ref().child("Thoughts").child(
                                          thoughtModel.key);
                                      uref.keepSynced(true);
                                      uref.child("agree").get().then((value) {
                                        uref.child("agree").set(int.parse(value.value.toString())+1);
                                        FirebaseDatabase.instance.ref().child("Users").child(thoughtModel.userid).child("Thoughts").child(thoughtModel.key).child("agree").set(int.parse(value.value.toString())+1);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            thoughtModel.agree=="-1"||thoughtModel.agree=="0"?"Like":thoughtModel.agree,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Thoughts",style:TextStyle(color:Colors.black,fontWeight: FontWeight.bold,fontSize:12),),
                                  Text(DateFormat('h:mm a').format(DateTime.parse(thoughtModel.time)),style:TextStyle(color:Colors.grey,fontWeight: FontWeight.bold,fontSize:8),),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Expanded(
                                child: MarqueeWidget(
                                  child: Text(
                                    thoughtModel.thought,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  direction: Axis.vertical,
                               ),
                               ),
                         ]
                        )
                        );
                      },
                    )
                  ),
                ):Container(),
                SizedBox(height: 5,),
                (loaded||list.isNotEmpty)?
                Expanded(child: ScrollablePositionedList.builder(
                  padding: EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                  itemCount: list.length,
                  physics:  BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    MessageModel messageModel = list[index];
                    return GestureDetector(
                      onLongPress: (){
                        if(droplist==false){
                          setState(() {
                            droplist=true;
                          });
                          if (messageModel.imageurl != "-1") {
                            itemScrollController.scrollTo(index: int.parse(
                                messageModel.imageurl.toString()),
                                duration: Duration(milliseconds: 500));
                          }
                          else {
                            Fluttertoast.showToast(msg: messageModel.username +
                                " has no public thoughts to show.");
                          }
                          return;
                        }
                        if(droplist==true) {
                          if (messageModel.imageurl != "-1") {
                            Fluttertoast.showToast(msg: "Finding..");
                            itemScrollController.scrollTo(index: int.parse(
                                messageModel.imageurl.toString()),
                                duration: Duration(milliseconds: 500));
                          }
                          else {
                            Fluttertoast.showToast(msg: messageModel.username +
                                " has no public thoughts to show.");
                          }
                        }
                        },
                      onTap: (){
                        UserModel userModel=UserModel.empty();
                        userModel.name=messageModel.username;
                        userModel.uderdp=messageModel.dpurl;
                        userModel.id=messageModel.userid;
                        print(userModel.id);
                        Navigator.pushNamed(context, 'userchat',arguments:userModel);
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.only(left: 5,right: 5,top: 10),
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
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                    margin: EdgeInsets.only(right: 10),
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black
                                    ),
                                    child:CircleAvatar(
                                      backgroundColor: Colors.black,
                                      radius: 20,
                                      backgroundImage: NetworkImage(messageModel.dpurl,),
                                    )
                                ),
                                SizedBox(width: 5,),
                                Expanded(
                                  child: MarqueeWidget(
                                    direction: Axis.horizontal,
                                    child: Text(
                                     messageModel.username,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(DateFormat('h:mm a').format(DateTime.parse(messageModel.time)),style:TextStyle(color:Colors.black,fontWeight: FontWeight.normal,fontSize:12),),
                                SizedBox(width: 5,)
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: 55,),
                                Text(messageModel.messageby==userid?"you:":"from:",style:TextStyle(color:Colors.grey,fontWeight: FontWeight.normal,fontSize:14),),
                                SizedBox(width: 5,),
                                Expanded(
                                  child: MarqueeWidget(
                                    child: Text(
                                      messageModel.message,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    direction: Axis.horizontal,
                                  ),
                                ),
                                SizedBox(width: 5,),
                                messageModel.imageurl!="-1"?Icon(Icons.bubble_chart_outlined,color: Colors.black,):Icon(Icons.linear_scale_sharp)
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ))
                :Expanded(child: Container(child: Center(child: CircularProgressIndicator(color: Colors.white,)))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route) => false);
  }
}
