import 'dart:io';
import 'dart:ui';

import 'package:dummy_firebase/Signuppage.dart';
import 'package:dummy_firebase/loginpage.dart';
import 'package:dummy_firebase/utils/marqueewidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  @override
  Widget build(BuildContext context) {
    var height=MediaQuery.of(context).size.height;
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SpinKitSquareCircle(
                size: 25,
                color: Colors.white,
              ),
            SizedBox(height: 4,),
            Image.asset('assets/images/welcomescreenlogo.png',height: height*0.6,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Connect And Share",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800,fontSize: 28),),
                    SizedBox(width: 10,),
                    SpinKitPumpingHeart(
                      size: 50,
                      color: const Color.fromARGB(255, 57, 57, 57),
                    ),
                  ],
                ),
                SizedBox(height: 12,),
                MarqueeWidget(
                    direction: Axis.vertical,
                    child: Text("Welcome to our app! Here, you can share your thoughts, feelings, and experiences with others anonymously or publicly. Connect with like-minded individuals and find support in a safe and non-judgmental space. Join our community and start sharing your mind today!",style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 10),textAlign: TextAlign.center)
                )
              ],
            ),
            Row(
              children: [
                Expanded(child: OutlinedButton(
                    onPressed: ()=>{
                    Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    )
                    },
                    child: Text("Login"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(),
                   foregroundColor: Colors.black,
                   side: BorderSide(color: Colors.black),
                    padding: EdgeInsets.symmetric(vertical: 14)
                  ),
                )),
                SizedBox(width: 10,),
                Expanded(child: ElevatedButton(
                    onPressed: ()=>{
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SignUpPage()),
                      )
                    },
                    child: Text("Sign Up",style:TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(),
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.black
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14)
                  ),
                )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
