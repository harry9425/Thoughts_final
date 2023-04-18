import 'package:dummy_firebase/main.dart';
import 'package:dummy_firebase/utils/alluserswidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../model classes/userclass.dart';
import '../utils/marqueewidget.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {

  var auth=FirebaseAuth.instance;
  static String userid="";
  DatabaseReference database=FirebaseDatabase.instance.reference();
  List<UserModel> list=[],og=[];
  var loaded=false;
  var friendcontroller=TextEditingController();
  final _focusNode = FocusNode();
  var reloadlist=false;

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
    userid=auth.currentUser!.uid;
    reload();
    friendcontroller.addListener(() {
      if(friendcontroller.text.trim().isNotEmpty) {
        List<UserModel> tempList = [];
        for (int i = 0; i < og.length; i++) {
          if (og[i].name.toLowerCase().contains(friendcontroller.text.toLowerCase().trim())) {
            tempList.add(og[i]);
          }
        }
        setState(() {
          list = tempList;
        });
      }
      else{
        setState(() {
          list = og;
        });
      }
    });
  }

  void reload(){
    setState(() {
      reloadlist=true;
    });
    friendcontroller.clear();
    database.child("friends_data").child(userid).onValue.listen((event) async {
      print(event.snapshot.value.toString());
      og.clear();
      for(DataSnapshot snapshot in event.snapshot.children) {
        if (snapshot.value.toString() == "f") {
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
            og.add(userModel);
          });
        }
      }
      setState(() {
        list=og;
      });
    });
    Future.delayed(Duration(milliseconds: 500)).whenComplete((){
    setState(() {
      reloadlist=false;
    });
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
                    children: [
                      SizedBox(height: 15,),
                      Row(
                        children: [
                          SizedBox(width: 15,),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black87,
                            ),
                            child: Icon(
                              Icons.supervisor_account_rounded, color: Colors.white,
                              size: 20,),
                          ),
                          SizedBox(width: 10,),
                          Text("Friends", style: TextStyle(color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),),
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
                                    child: Icon(Icons.cancel, color: Colors.black87),
                                    onTap:(){
                                      friendcontroller.clear();
                                    },
                                  ):Container(),
                                ],
                              ),
                            ),
                          ),
                          Text(reloadlist?"Sycing...":"Reload Page",style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize:10),),
                          SizedBox(width: 5,),
                          reloadlist?SpinKitFadingCircle(color: Colors.black,size: 15,):GestureDetector(onTap:(){reload();},child: Icon(Icons.refresh,color: Colors.black,size: 15,)),
                          SizedBox(width: 5,),
                          SizedBox(width: 10,)
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                (loaded||list.isNotEmpty)?Expanded(
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                        itemCount: list.length,
                        itemBuilder: (context,index){
                          return GestureDetector(
                            onTap: (){
                              _focusNode.unfocus();
                              Navigator.pushNamed(context,'userprofilepage',arguments: list[index].id);
                            },
                            child: Container(
                              //height: 100,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                              ),
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black
                                  ),
                                  child : CircleAvatar(
                                    radius: MediaQuery.of(context).size.width*0.10,
                                    backgroundColor: Colors.black,
                                    backgroundImage: NetworkImage(list[index].userdp),
                                  ),
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      SizedBox(width: 8,),
                                      Image.asset("assets/images/friends.png",height: 15,width: 15,color: Colors.black87,),
                                      SizedBox(width: 5,),
                                      Expanded(
                                        child: MarqueeWidget(
                                            direction: Axis.horizontal,
                                            child: Text("@"+list[index].name,style:TextStyle(color: Colors.black,fontSize:14,fontWeight: FontWeight.bold),)),
                                      ),
                                      SizedBox(width: 5,),
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

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route) => false);
  }
}
