import 'package:dummy_firebase/model%20classes/userclass.dart';
import 'package:dummy_firebase/utils/marqueewidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rive/rive.dart';
import 'package:intl/intl.dart';
import 'model classes/ThoughtsModel.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}
class _UserProfilePageState extends State<UserProfilePage> {
  late String userid,mainid;
  UserModel curruser=UserModel.empty();
  var loading=true;
  var colourlist=[Colors.red,Colors.deepOrange,Colors.orangeAccent,Colors.lightGreenAccent,Colors.green];
  String text="fetching..";
  String reths="No recents thoughts for featuring...";
  late int _following;
  var choosen=0;
  var thcnt="0",fcnt="0";
  List<UserModel> list=[];
  late FirebaseDatabase database;
  var publishing=false;
  var modaldone=false;

  String displayRange(int range) {
    range=(range/10).toInt();
    int start = range * 100;
    int end = start + 100;
    return 'ranges from $start-$end';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    database=FirebaseDatabase.instance;
    database.ref().keepSynced(true);
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    mainid=FirebaseAuth.instance.currentUser!.uid;
    userid = ModalRoute.of(context)!.settings.arguments as String;
    final ref = FirebaseDatabase.instance.ref().child("Users");
    ref.keepSynced(true);
    final snapshot = await ref.child(userid).get();
    if (snapshot.exists) {
      UserModel userModel = UserModel.empty();
      userModel.name = snapshot.child('name').value.toString() ?? '';
      userModel.id = snapshot.child('id').value.toString() ?? '';
      userModel.email = snapshot.child('email').value.toString() ?? '';
      userModel.password = snapshot.child('time').value.toString() ?? '';
      userModel.uderdp = snapshot.child('userdp').value.toString() ?? '';
      curruser=userModel;
      if(snapshot.hasChild("Thoughts")){
        thcnt=snapshot.child("Thoughts").children.length.toString();
        reths =snapshot.child("Thoughts").children.last.child("thought").value.toString();
      }
      DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("friends_data").child(mainid);
      dbRef.onValue.listen((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        if (dataSnapshot != null) {
          if (dataSnapshot.hasChild(userid)) {
            if (dataSnapshot.child(userid).value.toString() == "s") {
              setState(() {
                text = "pending";
                _following = 1;
              });
              print(1);
            } else if (dataSnapshot.child(userid).value.toString() == "r") {
              setState(() {
                text = "Accept";
                _following = 2;
              });
              print(2);
            } else if(dataSnapshot.child(userid).value.toString() == "f"){
              setState(() {
                _following = 3;
                text = "Remove";
              });
              print(3);
            }
          } else {
            setState(() {
              _following = 0;
              text = "Add";
            });
          }
          setState(() {
            loading=false;
          });
        }
      });
    }
    DatabaseReference database = FirebaseDatabase.instance.reference();
    database.keepSynced(true);
    list.clear();
    database.child("friends_data").child(userid).once().then((v){
      if (v.snapshot.value != null) {
        List<UserModel> tempList = [];
        Map<dynamic, dynamic> value = v.snapshot.value as dynamic;
        value.forEach((key, data) async {
          if(data=='f'){
            final ref = FirebaseDatabase.instance.ref().child("Users");
            ref.keepSynced(true);
            final snapshot = await ref.child(key).get();
            if (snapshot.exists) {
              UserModel userModel = UserModel.empty();
              userModel.name = snapshot.child('name').value.toString() ?? '';
              userModel.id = snapshot.child('id').value.toString() ?? '';
              userModel.uderdp = snapshot.child('userdp').value.toString() ?? '';
              tempList.add(userModel);
            }
          }
        });
        setState(() {
          list = tempList;
          fcnt=list.length.toString();
        });
      } else {
        print('No data available');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: loading?Center(child: CircularProgressIndicator(color: Colors.black,)):Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 25,right: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black
                      ),
                      padding: EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 40,
                        backgroundImage: NetworkImage(
                            curruser.userdp),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 8, bottom: 8),
                        height: 60,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
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
                              Icons.bubble_chart_outlined,
                              color: Colors.black,
                              size: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child:MarqueeWidget(
                                animationDuration: Duration(seconds: 20),
                                direction: Axis.vertical,
                                child: Text(
                                 reths,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Text("@"+curruser.name,style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.bold),),
                    SizedBox(width: 10,),
                  ],
                ),
                SizedBox(height: 10,),
                Text(curruser.name,style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.normal),),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: (){
                          if(_following==1||_following==3){

                            FirebaseDatabase.instance.ref().child("friends_data").child(mainid).child(userid).remove();
                            FirebaseDatabase.instance.ref().child("friends_data").child(userid).child(mainid).remove();
                          }
                          else if(_following==2){
                            FirebaseDatabase.instance.ref().child("friends_data").child(mainid).child(userid).set("f");
                            FirebaseDatabase.instance.ref().child("friends_data").child(userid).child(mainid).set("f");
                          }
                          else{
                            FirebaseDatabase.instance.ref().child("friends_data").child(mainid).child(userid).set("s");
                            FirebaseDatabase.instance.ref().child("friends_data").child(userid).child(mainid).set("r");
                          }
                        },
                        child: Text(text,style: TextStyle(color: Colors.black),),
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.black),
                            padding: EdgeInsets.symmetric(vertical: 14)
                        ),
                      ),
                    ),
                    SizedBox(width: 13,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (){
                          if(_following==3){
                            Navigator.pushNamed(context, 'userchat',arguments:curruser);
                          }
                          else{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: Color.fromRGBO(15, 15, 15,1),
                                  child: Container(
                                    width: 220,
                                    height: 230,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Image.asset(
                                            "assets/images/Messages-pana.png",
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(width: 20,),
                                            Text(
                                              'Become Friends to start\nmessaging with each other.',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                              ),
                                            ),
                                            SizedBox(width: 20,),
                                          ],
                                        ),
                                        SizedBox(height: 10,),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: Text("Message",style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black87,
                            side: BorderSide(color: Colors.black),
                            padding: EdgeInsets.symmetric(vertical: 14)
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Divider(color: Colors.black87,thickness: 1,),
                Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.description,color:choosen==0?Colors.black87:Colors.grey,size: 30,),
                        onPressed: () {
                          setState(() {
                            choosen=0;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.bubble_chart_outlined,color:choosen==1?Colors.black87:Colors.grey,size: 30,),
                        onPressed: () {
                          setState(() {
                            choosen=1;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.people,color:choosen==2?Colors.black87:Colors.grey,size: 30,),
                        onPressed: () {
                          setState(() {
                            choosen=2;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15,),
              ],
            ),
          ),
          if(choosen==0) Expanded(child:
          Container(
               decoration: BoxDecoration(
                 boxShadow: [
                   BoxShadow(
                       spreadRadius: 5,
                       blurRadius: 5,
                       offset: Offset(0, 3),
                       color: Colors.grey.withOpacity(0.3)
                   )
                 ],
                 color: Colors.white,
                 borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))
               ),
               child: Padding(
                 padding: EdgeInsets.all(30),
                 child: SingleChildScrollView(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Icon(Icons.account_circle,color: Colors.black,size: 35,),
                           SizedBox(width: 20,),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text("about "+curruser.name,style: TextStyle(color: Colors.grey,fontSize: 14,fontWeight: FontWeight.bold),),
                               SizedBox(height: 10,),
                               SizedBox(
                                 width: MediaQuery.of(context).size.width*0.7,
                                 height: 30,
                                 child: Scrollbar(
                                   isAlwaysShown: true,
                                   child: SingleChildScrollView(
                                     child: Text(
                                       "Success in a career in data science requires not only technical skills but also a strong understanding of business, communication, and problem-solving. It's not just about mastering the tools and techniques but also being able to use data to drive decision-making and bring value to organizations.",
                                       style: TextStyle(
                                         color: Colors.black,
                                         fontSize: 14,
                                         fontWeight: FontWeight.bold,
                                       ),
                                       softWrap: true,
                                     ),
                                   //  padding: EdgeInsets.only(right: 10),
                                     scrollDirection: Axis.horizontal,
                                     physics: BouncingScrollPhysics(),
                                   ),
                                 )
                               ),
                             ],
                           )
                         ],
                       ),
                       SizedBox(height: 20,),
                       Row(
                         children: [
                           Icon(Icons.calendar_today_outlined,color: Colors.black,size: 35,),
                           SizedBox(width: 20,),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text("member since",style: TextStyle(color: Colors.grey,fontSize: 14,fontWeight: FontWeight.bold),),
                               SizedBox(height: 10,),
                               Text(curruser.password,style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                             ],
                           )
                         ],
                       ),
                       SizedBox(height: 20,),
                       Row(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Icon(Icons.stars_sharp,color: Colors.black,size: 35,),
                           SizedBox(width: 20,),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(curruser.name+" ranking",style: TextStyle(color: Colors.grey,fontSize: 14,fontWeight: FontWeight.bold),),
                               SizedBox(height: 10,),
                               Text(displayRange(int.parse(thcnt)),style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                               SizedBox(height: 20,),
                               Row(
                                 children: [
                                   Container(
                                     decoration:BoxDecoration(
                                         color: Colors.white,
                                         borderRadius: BorderRadius.circular(20),
                                       boxShadow: [
                                         BoxShadow(
                                             spreadRadius: 2,
                                             blurRadius: 5,
                                             offset: Offset(0, 3),
                                             color: Colors.grey.withOpacity(0.3)
                                         )
                                       ]
                                     ),
                                     padding: EdgeInsets.all(20),
                                     child: Expanded(
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           Icon(Icons.bubble_chart,color: Colors.black,size: 25,),
                                           SizedBox(height: 5,),
                                           Text("thoughts\ncount",style: TextStyle(color: Colors.grey,fontSize: 15),),
                                           SizedBox(height: 8,),
                                           Text(thcnt=='0'?"zero":thcnt+"+",style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.bold),),
                                         ],
                                       ),
                                     ),
                                     height: 150,
                                     width: 120,
                                   ),
                                   SizedBox(width: 20,),
                                   Container(
                                     decoration:BoxDecoration(
                                         color: Colors.black87,
                                         borderRadius: BorderRadius.circular(20)
                                     ),
                                     padding: EdgeInsets.all(20),
                                     child: Expanded(
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           Icon(Icons.people_alt,color: Colors.white,size: 25,),
                                           SizedBox(height: 5,),
                                           Text("friends\ncount",style: TextStyle(color: Colors.white,fontSize: 15),),
                                           SizedBox(height: 8,),
                                           Text(list.length.toString(),style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),
                                         ],
                                       ),
                                     ),
                                     height: 150,
                                     width: 120,
                                   ),
                                 ],
                               )
                             ],
                           )
                         ],
                       ),
                       SizedBox(height: 20,),
                     ],
                   ),
                 ),
               ),
            )
          )
          else if(choosen==1) Expanded(child: FirebaseAnimatedList(
            physics: BouncingScrollPhysics(),
            query: database.ref().child("Users").child(userid).child("Thoughts"),
            itemBuilder: (context,snapshot,animation,index){
              ThoughtModel thoughtModel=ThoughtModel.empty();
              if (snapshot.value != null) {
                Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
                thoughtModel.thought = data['thought'] ?? '';
                thoughtModel.userid = data['userid'] ?? '';
                thoughtModel.time = data['time'] ?? '';
                thoughtModel.agree = data['agree'].toString() ?? '';
                thoughtModel.lock = data['lock'].toString() ?? '';
                thoughtModel.sentiment = data['sentiment'].toString() ?? '';
                thoughtModel.key = data['key'] ?? '';
                thoughtModel.coor = (data['latitude'] ?? '0.00')+"&&"+(data['longitude']??'0.00');
              }
              return thoughtModel.lock=="false"?Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.all(10),
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
                        SizedBox(width: 10,),
                        GestureDetector(
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
                                  thoughtModel.agree=="-1"||thoughtModel.agree=="0"?"Like":thoughtModel.agree.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            var uref = FirebaseDatabase.instance.ref().child("Thoughts").child(
                                thoughtModel.key);
                            uref.keepSynced(true);
                            uref.child("agree").get().then((value) {
                              uref.child("agree").set(int.parse(value.value.toString())+1);
                              FirebaseDatabase.instance.ref().child("Users").child(thoughtModel.userid).child("Thoughts").child(thoughtModel.key).child("agree").set(int.parse(value.value.toString())+1);
                            });
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Container(
                          decoration:BoxDecoration(
                              color: colourlist[double.parse(thoughtModel.sentiment).toInt()-1],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black,width: 2)
                          ),
                          width: 10,
                          height: 10,
                        ),
                        SizedBox(width: 5,),
                        Text(
                          'Thought',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      thoughtModel.thought,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ):Container();
            },
            padding: EdgeInsets.all(5),
          ))
          else Expanded(
              child:GridView.builder(
                  padding: EdgeInsets.only(left: 10,right: 10),
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemCount: list.length,
                  itemBuilder: (context,index){
                    return GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context,'userprofilepage',arguments: list[index].id);
                      },
                      child: Container(
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
                            MarqueeWidget(
                                direction: Axis.horizontal,
                                child: Text("@"+list[index].name,style:TextStyle(color: Colors.black,fontSize:11,fontWeight: FontWeight.bold),)),
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ),
        ],
      ),
    );
  }
}
