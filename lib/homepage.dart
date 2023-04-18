import 'dart:math';

import 'package:dummy_firebase/homepage_viewScreens/AllChatsPage.dart';
import 'package:dummy_firebase/homepage_viewScreens/alluserspage.dart';
import 'package:dummy_firebase/homepage_viewScreens/addthoughtpage.dart';
import 'package:dummy_firebase/allthoughtspage.dart';
import 'package:dummy_firebase/homepage_viewScreens/friendspage.dart';
import 'package:dummy_firebase/model%20classes/userclass.dart';
import 'package:dummy_firebase/requestPage.dart';
import 'package:dummy_firebase/utils/sidebarmenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rive/rive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  var auth = FirebaseAuth.instance;
  UserModel userModel = UserModel.empty();
  FirebaseDatabase database = FirebaseDatabase.instance;
  SMIBool? startrigger;
  SMIBool? chattrigger;
  SMIBool? menutrigger;
  SMIBool? persontrigger;
  SMIBool? searchtrigger;
  SMIBool? notitrigger;
  List opofbottom=[0.5,0.5,1.0,0.5,0.5];
  List<Widget> pages=<Widget>[
    allThoughtsPage(),
    AddThoughtsPage(),
    FriendsPage(),
    AllChatPage(),
    RequestPage(),
  ];
  int index=0;
  var issidemenuopen=false;
  late AnimationController animationController;
  late Animation<double> animation;
  late Animation<double> scaleanimation;
  var gpsdone=false;

  @override
  void initState(){
    animationController=AnimationController(vsync: this,duration: Duration(milliseconds: 200))..addListener(() {
      setState(() {
      });
    });
    super.initState();
    database.reference().keepSynced(true);
    if (auth.currentUser == null) {
      Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route) => false);
    }
    userModel.id=auth.currentUser!.uid.toString();
    getUserFromFirebase(auth.currentUser!.uid);
    scaleanimation=Tween<double>(begin: 1,end: 0.8).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn));
    animation=Tween<double>(begin: 0,end: 1).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getUserFromFirebase(userModel.id);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: Colors.black,
      bottomNavigationBar: Transform.translate(
        offset: Offset(0,100*animation.value),
        child: SafeArea(
          bottom: false,
          minimum: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
               color: Color.fromRGBO(0, 0, 0, 0.90),
                borderRadius: BorderRadius.circular(24)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              Opacity(
                      opacity: opofbottom[1],
                      child: GestureDetector(
                        onTap: (){
                          index=1;
                          setState(() {
                            opofbottom.setAll(0, [0.5,1.0,0.5,0.5,0.5]);
                          });
                        },

                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:[
                              AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                height: 4,
                                width: opofbottom[1]==1.0?20:0,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: Icon(Icons.bubble_chart_outlined,color: Colors.white,size: 30,)
                              ),
                            ]
                        ),
                      )
                  ),
              Opacity(
                    opacity: opofbottom[3],
                    child: GestureDetector(
                        onTap: (){
                          notitrigger!.change(true);
                          setState(() {
                            index=4;
                            opofbottom.setAll(0, [0.5,0.5,0.5,1.0,0.5]);
                          });
                          Future.delayed(Duration(seconds: 1),(){
                            notitrigger!.change(false);
                          });
                        },
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:[
                              AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                height: 4,
                                width: opofbottom[3]==1.0?20:0,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              SizedBox(
                                height: 36,
                                width: 36,
                                child: RiveAnimation.asset(
                                  "assets/rive/bottombaricons.riv",
                                  artboard: "BELL",
                                  stateMachines: ["BELL_Interactivity"],
                                  onInit: (artboard){
                                    final controller=StateMachineController.fromArtboard(artboard,"BELL_Interactivity");
                                    artboard.addController(controller!);
                                    notitrigger=controller.findInput<bool>("active") as SMIBool;
                                  },
                                ),
                              ),])
                    ),),
              Opacity(
                opacity: opofbottom[2],
                child: GestureDetector(
                onTap: (){
                  startrigger!.change(true);
                  setState(() {
                    index=0;
                    opofbottom.setAll(0, [0.5,0.5,1.0,0.5,0.5]);
                  });
                  Future.delayed(Duration(seconds: 1),(){
                    startrigger!.change(false);
                  });
                },
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                  AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 4,
                  width: opofbottom[2]==1.0?20:0,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                SizedBox(
                  height: 36,
                  width: 36,
                  child: RiveAnimation.asset(
                    "assets/rive/bottombaricons.riv",
                    artboard: "LIKE/STAR",
                    stateMachines: ["STAR_Interactivity"],
                    onInit: (artboard){
                      final controller=StateMachineController.fromArtboard(artboard,"STAR_Interactivity");
                      artboard.addController(controller!);
                      startrigger=controller.findInput<bool>("active") as SMIBool;
                    },
                  ),
                ),])
              ),),
              Opacity(
                    opacity: opofbottom[0],
                    child: GestureDetector(
                      onTap: (){
                        chattrigger!.change(true);
                        setState(() {
                          index=3;
                          opofbottom.setAll(0, [1.0,0.5,0.5,0.5,0.5]);
                        });
                        Future.delayed(Duration(seconds: 1),(){
                          chattrigger!.change(false);
                        });
                      },
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:[
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: 4,
                              width: opofbottom[0]==1.0?20:0,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            SizedBox(
                              height: 36,
                              width: 36,
                              child: RiveAnimation.asset(
                                "assets/rive/bottombaricons.riv",
                                artboard: "CHAT",
                                stateMachines: ["CHAT_Interactivity"],
                                onInit: (artboard){
                                  final controller=StateMachineController.fromArtboard(artboard,"CHAT_Interactivity");
                                  artboard.addController(controller!);
                                  chattrigger=controller.findInput<bool>("active") as SMIBool;
                                },
                              ),
                            ),
                          ]
                      ),
                    ),
                  ),
              Opacity(
                opacity: opofbottom[4],
                child: GestureDetector(
                onTap: (){
                  persontrigger!.change(true);
                  setState(() {
                    index=2;
                    opofbottom.setAll(0, [0.5,0.5,0.5,0.5,1.0]);
                  });
                  Future.delayed(Duration(seconds: 1),(){
                    persontrigger!.change(false);
                  });
                },
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                  AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 4,
                  width: opofbottom[4]==1.0?20:0,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                SizedBox(
                  height: 36,
                  width: 36,
                  child: RiveAnimation.asset(
                    "assets/rive/bottombaricons.riv",
                    artboard: "USER",
                    stateMachines: ["USER_Interactivity"],
                    onInit: (artboard){
                      final controller=StateMachineController.fromArtboard(artboard,"USER_Interactivity");
                      artboard.addController(controller!);
                      persontrigger=controller.findInput<bool>("active") as SMIBool;
                    },
                  ),
                ),])
              ),),
            ]),
          ),
        ),
      ),
      body:  Stack(children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
          child: Sidebarmenu(userModel: userModel),width: 288,height: MediaQuery.of(context).size.height,left: issidemenuopen?0:-288,),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(animation.value-30*animation.value*pi/180),
          child: Transform.translate(offset: Offset(animation.value*240,0),
          child: Transform.scale(
              scale: scaleanimation.value,
              child: ClipRRect(
                  child: pages[index],
                borderRadius: BorderRadius.circular(24),
              ),
             )
          ),
        ),
        AnimatedPositioned(
          top: issidemenuopen?50:35,
          left: issidemenuopen?220: 15,
          duration: Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: (){
              setState(() {
                issidemenuopen=!issidemenuopen;
              });
              if(issidemenuopen){
                animationController.forward();
              }
              else animationController.reverse();
              menutrigger!.change(issidemenuopen);
              Future.delayed(Duration(milliseconds: 1000),(){
              });
            },
            child: Container(
              height: 40,
              width: 40,
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 8,offset: Offset(0,3),color: Colors.black12)],
              ),
              child: RiveAnimation.asset(
                "assets/rive/simple_menu.riv",
                artboard: "New Artboard",
                stateMachines: ["switch"],
                onInit: (artboard){
                  final controller=StateMachineController.fromArtboard(artboard,"switch");
                  artboard.addController(controller!);
                  menutrigger=controller.findInput<bool>("toggleX") as SMIBool;
                  menutrigger!.change(false);
                },
              ),
            ),
          ),
        ),
       ]
      )
    );
  }
  Future<void> getUserFromFirebase(String userId) async {
    final snapshot = await database.ref().child('Users').child(userId).get();
    if (snapshot.value != null) {
      Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
      userModel.name = data['name'] ?? '';
      userModel.id = data['id'] ?? '';
      userModel.email = data['email'] ?? '';
      userModel.uderdp = data['userdp'] ?? '';
      userModel.phone = data['phone'] ?? '';
      userModel.password = data['password'] ?? '';
      setState(() {});
    } else
      print("homepage pr error aagya");
  }
}
