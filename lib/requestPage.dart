import 'package:dummy_firebase/main.dart';
import 'package:dummy_firebase/utils/alluserswidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../model classes/userclass.dart';
import '../utils/marqueewidget.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({Key? key}) : super(key: key);

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {

  var auth=FirebaseAuth.instance;
  static String userid="";
  late DatabaseReference database;
  List<UserModel> backlist=[];
  List<UserModel> list=[];
  var loaded=false;
  var friendcontroller=TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if(auth.currentUser==null){
      Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route)=>false);
    }
    userid=auth.currentUser!.uid;
    database=FirebaseDatabase.instance.ref();
    database.keepSynced(true);
    reload();
    friendcontroller.addListener(() {
      if(friendcontroller.text.trim().isNotEmpty) {
        List<UserModel> tempList = [];
        for (int i = 0; i < backlist.length; i++) {
          if (backlist[i].name.toLowerCase().contains(friendcontroller.text.toLowerCase().trim())) {
            tempList.add(backlist[i]);
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

  void reload(){
    database.child("friends_data").child(userid).onValue.listen((event) async {
      backlist.clear();
      for(DataSnapshot snapshot in event.snapshot.children) {
        if (snapshot.value.toString() != "f") {
          var uref = FirebaseDatabase.instance.ref().child("Users").child(
              snapshot.key.toString());
          uref.keepSynced(true);
          UserModel userModel = UserModel.empty();
          await uref.get().then((v) {
            userModel.name = v
                .child("name")
                .value
                .toString();
            userModel.uderdp = v
                .child("userdp")
                .value
                .toString();
            userModel.id = v
                .child("id")
                .value
                .toString();
            userModel.email = snapshot.value.toString()=="s"?"1":"2";
            backlist.add(userModel);
          });
        }
      }
      list=backlist;
      loaded=true;
      setState(() {});
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
                    boxShadow:  [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ]
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 15,),
                      Row(
                        children: [
                          SizedBox(width: 15,),
                          Container(

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: Icon(
                              Icons.pending, color: Colors.white,
                              size: 30,),
                          ),
                          SizedBox(width: 10,),
                          Text("Requests", style: TextStyle(color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Row(
                        children: [
                          SizedBox(width: 5,),
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
                                        controller: friendcontroller,
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
                                  friendcontroller.text.isNotEmpty?
                                  GestureDetector(
                                    child: Icon(Icons.cancel, color: Colors.grey),
                                    onTap:(){
                                      friendcontroller.clear();
                                    },
                                  ):Container(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                        ],
                      ),
                      SizedBox(height: 5,)
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                (loaded||list.isNotEmpty)?Expanded(
                  child: GridView.builder(
                      padding: EdgeInsets.only(right: 10),
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      itemCount: list.length,
                      itemBuilder: (context,index){
                        return GestureDetector(
                          onTap: (){
                            _focusNode.unfocus();
                            Navigator.pushNamed(context,'userprofilepage',arguments: list[index].id);
                          },
                          child: Container(
                            height: 200,
                            padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 8),
                            margin: EdgeInsets.only(left: 15,bottom: 10),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black,
                                      ),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(list[index].userdp,fit: BoxFit.cover,)),
                                      height: 50,
                                      width: 50,
                                    ),
                                    SizedBox(width: 10,),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          MarqueeWidget(child: Text("@"+list[index].name,style:TextStyle(color:Colors.black,fontWeight: FontWeight.bold,fontSize:15),)),
                                          SizedBox(height: 5,),
                                          MarqueeWidget(child: Text(list[index].name,style:TextStyle(color:Colors.black,fontWeight: FontWeight.normal,fontSize:12),)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: (){
                                          if(list[index].email=="1"){
                                            FirebaseDatabase.instance.ref().child("friends_data").child(userid).child(list[index].id).remove();
                                            FirebaseDatabase.instance.ref().child("friends_data").child(list[index].id).child(userid).remove();
                                          }
                                          else{
                                            FirebaseDatabase.instance.ref().child("friends_data").child(userid).child(list[index].id).set("f");
                                            FirebaseDatabase.instance.ref().child("friends_data").child(list[index].id).child(userid).set("f");
                                          }
                                        },
                                        child: Text(list[index].email=="1"?"Pending":"Accept",style: TextStyle(color: Colors.black),),
                                        style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            foregroundColor: Colors.white,
                                            side: BorderSide(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: (){
                                          Navigator.pushNamed(context,'userprofilepage',arguments: list[index].id);
                                        },
                                        child: Text("View",style: TextStyle(color: Colors.white),),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          backgroundColor:Colors.black87.withOpacity(0.8),
                                          side: BorderSide(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    Icon(
                                    Icons.linear_scale_outlined, color: Colors.black,
                                    size: 30,),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ):Expanded(child: Container(child: Center(child: CircularProgressIndicator(color: Colors.white,)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
