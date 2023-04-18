import 'package:dummy_firebase/homepage_viewScreens/alluserspage.dart';
import 'package:dummy_firebase/utils/marqueewidget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UserCardWidget extends StatefulWidget {
  final String name;
  final String userid;
  final String curruser;
  final String username;
  final String dpUrl;
  final int friendCount;
  final int depPower;

  const UserCardWidget({
    required this.userid,
    required this.name,
    required this.curruser,
    required this.username,
    required this.dpUrl,
    required this.friendCount,
    required this.depPower,
  });
  
  @override
  _UserCardWidgetState createState() => _UserCardWidgetState();
}

class _UserCardWidgetState extends State<UserCardWidget> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("friends_data").child(widget.curruser);
    dbRef.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      if (dataSnapshot != null) {
        if (dataSnapshot.hasChild(widget.userid)) {
          if (dataSnapshot.child(widget.userid).value.toString() == "s") {
            setState(() {
              text = "pending";
              _following = 1;
            });
            print(1);
          } else if (dataSnapshot.child(widget.userid).value.toString() == "r") {
            setState(() {
              text = "Accept";
              _following = 2;
            });
            print(2);
          } else if(dataSnapshot.child(widget.userid).value.toString() == "f"){
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
      }
    });
     */
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15,right: 15,top: 10),
      height: 210,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            // changes position of shadow
          ),
        ],
      ),
      child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),

              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 50,
                      backgroundImage: NetworkImage("https://cdn.pixabay.com/photo/2023/01/28/20/23/ai-generated-7751688_960_720.jpg"),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SpinKitDoubleBounce(
                                      size:15,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 10,),
                                    MarqueeWidget(
                                      animationDuration: Duration(milliseconds: 1000),
                                      direction: Axis.horizontal,
                                      child: Text(
                                        widget.username,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4,),
                                MarqueeWidget(
                                  animationDuration: Duration(milliseconds: 1000),
                                  direction: Axis.horizontal,
                                  child: Text(
                                    widget.name,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                        SizedBox(height: 4,),
                        MarqueeWidget(
                          animationDuration: Duration(milliseconds: 1000),
                          direction: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.people),
                                      SizedBox(width: 10),
                                      Text(
                                        '25 Followers',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.article),
                                      SizedBox(width: 10),
                                      Text(
                                        '50 Thoughts',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Expanded(
                      child: OutlinedButton(
                        onPressed: (){
                          Navigator.pushNamed(context, 'userprofilepage',arguments:widget.userid);
                        },
                        child: Text("View User",style: TextStyle(color: Colors.white),),
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))),
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white),
                            padding: EdgeInsets.symmetric(vertical: 14)
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ]
      ),
    );
  }
}
