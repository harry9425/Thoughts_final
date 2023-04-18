import 'dart:async';
import 'package:dummy_firebase/Welcomescreen.dart';
import 'package:dummy_firebase/utils/marqueewidget.dart';
import 'package:dummy_firebase/utils/sidebarmenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'homepage.dart';
import 'loginpage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool animate=false;
  bool start=false;
  String desc="With this app, you have access to a safe and secure platform where you can freely share your thoughts, feelings, and experiences with others. Whether you want to share something positive or negative, you can find a non-judgmental space to express yourself and connect with like-minded individuals.\nYou have the option to share anonymously or publicly, so you can choose how you want to interact with the community. If you prefer to keep your identity hidden, anonymous sharing is a great way to share your thoughts without fear of scrutiny. On the other hand, if you're comfortable with sharing your name and profile, public sharing allows you to connect with other users and build meaningful relationships.\nOne of the best features of the app is the ability to interact with other users. You can like, comment, and share posts, allowing you to connect with other people who share your interests and experiences. Additionally, you can send private messages to other users, which provides a more intimate setting for deeper conversations and connections.\nThe app takes your privacy seriously, with robust privacy settings and encryption technology that ensures your personal information and data are always protected.\nOverall, this app is a powerful tool that you can use to connect with others and share your thoughts in a supportive environment. Whether you need emotional support, a place to vent, or just a community of like-minded individuals, this app has everything you need. Join the community today and start sharing your mind!";

  @override
  void initState() {
    startanimate();
    super.initState();
  }

  Future<void> _checkCurrentUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => WelcomePage()),
      );
    } else {
      print(currentUser!.uid.toString());
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: MarqueeWidget(
                animationDuration: Duration(seconds: 3),
                direction: Axis.vertical,
                child: Text(
                  desc+"\n"+desc+"\n"+desc+"\n"+desc+"\n",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.7,
                    child: Row(
                      children: [
                        SpinKitSquareCircle(color: Colors.transparent,size: 30,),
                        Expanded(
                          child: Image.asset(
                            "assets/images/applogo.png",
                          ),
                        ),
                        SpinKitSquareCircle(color: Colors.transparent,size: 30,),
                      ],
                    ),
                  ),
                  Opacity(
                    opacity: 0.9,
                    child: Column(
                      children: [
                        Container(
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
                                  Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: CircleAvatar(
                                          backgroundColor: Colors.black87,
                                          child: Icon(
                                            Icons.lock,
                                            color: Colors.white,
                                          )
                                  ),
                                  ),
                                  Expanded(
                                    child: MarqueeWidget(
                                      direction: Axis.horizontal,
                                      child: Text(
                                        "Thoughts",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Container(
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
                                          "Like",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                        boxShadow: [
                                        BoxShadow(
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: Offset(0, 3),
                                        color: Colors.grey.withOpacity(0.3)
                                    )],
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.repeat,
                                          color: Colors.black,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Post',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  SpinKitCircle(color: Colors.black,size: 30,),
                                  SizedBox(width: 5,),
                                  Text(
                                    'Loading',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  AnimatedContainer(duration: Duration(seconds: 3),
                                    height: 10,
                                    width: start?MediaQuery.of(context).size.width*0.5:0,
                                    decoration: BoxDecoration(
                                      color: start?Colors.black87:Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Welcome to our app - a place where your voice is heard and your thoughts matter. Whether you're looking to connect with like-minded individuals or seeking support and guidance, our community is here for you. Share your journey and experiences, engage in meaningful conversations, and discover a world of diverse perspectives. Join us today and find a safe space to be yourself.",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("app by: ",style:TextStyle(color: Colors.black87,fontWeight: FontWeight.normal,fontSize:12),),
                                  Text("Hitansh Agrawal",style:TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize:12),),
                                  SizedBox(width: 13,)
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future startanimate() async{
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      start=true;
    });
    await Future.delayed(Duration(milliseconds: 3200));
     _checkCurrentUser();
  }
}