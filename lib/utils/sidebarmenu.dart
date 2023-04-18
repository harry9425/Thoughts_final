import 'package:dummy_firebase/model%20classes/userclass.dart';
import 'package:dummy_firebase/utils/marqueewidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';
import '../homepage_viewScreens/friendspage.dart';

class Sidebarmenu extends StatefulWidget {
  Sidebarmenu({Key? key,required this.userModel}) : super(key: key);
  final UserModel userModel;
  @override
  State<Sidebarmenu> createState() => _SidebarmenuState();
}

class _SidebarmenuState extends State<Sidebarmenu> {
  SMIBool? hometrigger;
  SMIBool? favtrigger;
  LatLng currpos=LatLng(20.5937, 78.9629);
  SMIBool? searchrigger;
  SMIBool? chattrigger;
  SMIBool? persontrigger;
  var gpsdone=true;
  var list=[0,0,0,0,0,0,0,0,0,0,0,0,0,0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: 260,
        padding: EdgeInsets.only(left: 5,top: 8,bottom: 5,right: 5),
        height: double.infinity,
        color: Colors.black,
        child: SafeArea(

          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context,'account_edit');
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(widget.userModel.userdp),
                    ),
                    title: MarqueeWidget(child: Text(widget.userModel.name,style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
                    subtitle: Text("@"+widget.userModel.name,style: TextStyle(color: Colors.grey),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24,top: 12,bottom: 16),
                  child: Text("SYNC",style: TextStyle(color: Colors.white70,fontSize: 18),),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:24 ),
                      child: Divider(color: Colors.white24,height: 1,),
                    ),
                    Stack(
                      children: [
                        AnimatedPositioned(
                            duration: Duration(milliseconds: 300),
                            height: 56,
                            width: list[9]==1?250:0,
                            child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                        ListTile(
                          onTap: (){
                            setState(() {
                              list[9]=1;
                            });
                            showSyncLocationDialog(context);
                        Future.delayed(Duration(milliseconds: 1000),(){
                          setState(() {
                            list[9]=0;
                          });
                        });
                      },
                      leading: SizedBox(
                      height: 34,
                      width: 34,
                      child: Icon(Icons.location_on_rounded,color: Colors.white,size: 25,)
                    ),
                      title: Text("Sync your location",style: TextStyle(color: Colors.white),),
                    )])
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24,top: 12,bottom: 16),
                  child: Text("BROWSE",style: TextStyle(color: Colors.white70,fontSize: 18),),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:24 ),
                      child: Divider(color: Colors.white24,height: 1,),
                    ),
                    Stack(
                        children: [
                          AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              height: 56,
                              width: list[0]==1?250:0,
                              child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                          ListTile(
                            onTap: (){
                              setState(() {
                                list[0]=1;
                              });
                              searchrigger!.change(true);
                              Future.delayed(Duration(milliseconds: 1000),(){
                                setState(() {
                                  list[0]=0;
                                });
                                searchrigger!.change(false);
                                Navigator.pushNamed(context, 'allusers');
                              });
                            },
                            leading: SizedBox(
                              height: 34,
                              width: 34,
                              child: RiveAnimation.asset(
                                "assets/rive/bottombaricons.riv",
                                artboard: "SEARCH",
                                stateMachines: ["SEARCH_Interactivity"],
                                onInit: (artboard){
                                  final controller=StateMachineController.fromArtboard(artboard,"SEARCH_Interactivity");
                                  artboard.addController(controller!);
                                  searchrigger=controller.findInput<bool>("active") as SMIBool;
                                },
                              ),
                            ),
                            title: Text("Search Users",style: TextStyle(color: Colors.white),),
                          )])
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:24 ),
                      child: Divider(color: Colors.white24,height: 1,),
                    ),
                    Stack(
                      children: [
                        AnimatedPositioned(
                            duration: Duration(milliseconds: 300),
                            height: 56,
                            width: list[1]==1?250:0,
                            child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                        ListTile(
                          onTap: (){
                            setState(() {
                              list[1]=1;
                            });
                            Future.delayed(Duration(milliseconds: 1000),(){
                              setState(() {
                                list[1]=0;
                              });
                              Navigator.pushNamed(context, 'allthoughts');
                            });
                      },
                      leading: SizedBox(
                      height: 34,
                      width: 34,
                      child: Icon(Icons.bubble_chart,color: Colors.white,size:30,)
                    ),
                      title: Text("Thoughts",style: TextStyle(color: Colors.white),),
                    )])
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:24 ),
                      child: Divider(color: Colors.white24,height: 1,),
                    ),
                    Stack(
                        children: [
                          AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              height: 56,
                              width: list[4]==1?250:0,
                              child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                          ListTile(
                            onTap: (){
                              setState(() {
                                list[4]=1;
                              });
                              Future.delayed(Duration(milliseconds: 1000),(){
                                setState(() {
                                  list[4]=0;
                                });
                                Navigator.pushNamed(context, 'addthought');
                              });
                            },
                            leading: SizedBox(
                                height: 34,
                                width: 34,
                                child: Icon(Icons.add_circle_outline_sharp,color: Colors.white,size:30,)
                            ),
                            title: Text("Post Thoughts",style: TextStyle(color: Colors.white),),
                          )])
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:24 ),
                      child: Divider(color: Colors.white24,height: 1,),
                    ),
                    Stack(
                        children: [
                          AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              height: 56,
                              width: list[3]==1?250:0,
                              child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                          ListTile(
                            onTap: (){
                              setState(() {
                                list[3]=1;
                              });
                              chattrigger!.change(true);
                              Future.delayed(Duration(seconds: 1),(){
                                setState(() {
                                  list[3]=0;
                                });
                                chattrigger!.change(false);
                                Navigator.pushNamed(context,'allchat');
                              });
                            },
                            leading: SizedBox(
                              height: 34,
                              width: 34,
                              child:  RiveAnimation.asset(
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
                            title: Text("Chat",style: TextStyle(color: Colors.white),),
                          )])
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:24 ),
                      child: Divider(color: Colors.white24,height: 1,),
                    ),
                    Stack(
                        children: [
                          AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              height: 56,
                              width: list[2]==1?250:0,
                              child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                          ListTile(
                            onTap: (){
                              setState(() {
                                list[2]=1;
                              });
                              persontrigger!.change(true);
                              Future.delayed(Duration(seconds: 1),(){
                                setState(() {
                                  list[2]=0;
                                });
                                persontrigger!.change(false);
                                Navigator.pushNamed(context,'friends');
                              });
                            },
                            leading: SizedBox(
                              height: 34,
                              width: 34,
                              child:  RiveAnimation.asset(
                                "assets/rive/bottombaricons.riv",
                                artboard: "USER",
                                stateMachines: ["USER_Interactivity"],
                                onInit: (artboard){
                                  final controller=StateMachineController.fromArtboard(artboard,"USER_Interactivity");
                                  artboard.addController(controller!);
                                  persontrigger=controller.findInput<bool>("active") as SMIBool;
                                },
                              ),
                            ),
                            title: Text("Friends",style: TextStyle(color: Colors.white),),
                          )])
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:24 ),
                      child: Divider(color: Colors.white24,height: 1,),
                    ),
                    Stack(
                        children: [
                          AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              height: 56,
                              width: list[5]==1?250:0,
                              child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                          ListTile(
                            onTap: (){
                              setState(() {
                                list[5]=1;
                              });
                              Future.delayed(Duration(milliseconds: 1000),(){
                                setState(() {
                                  list[5]=0;
                                });
                                Navigator.pushNamed(context, 'requestpage');
                              });
                            },
                            leading: SizedBox(
                                height: 34,
                                width: 34,
                                child: Icon(Icons.pending,color: Colors.white,size:30,)
                            ),
                            title: Text("See Requests",style: TextStyle(color: Colors.white),),
                          )])
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left:24 ),
                  child: Divider(color: Colors.white24,height: 1,),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24,top: 16,bottom: 16),
                  child: Text("Support",style: TextStyle(color: Colors.white70,fontSize: 18),),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:24 ),
                      child: Divider(color: Colors.white24,height: 1,),
                    ),
                    Stack(
                        children: [
                          AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              height: 56,
                              width: list[6]==1?250:0,
                              child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                          ListTile(
                            onTap: (){
                              setState(() {
                                list[6]=1;
                              });
                              Future.delayed(Duration(milliseconds: 1000),(){
                                _composeEmail();
                                setState(() {
                                  list[6]=0;
                                });
                              });
                              },
                            leading: SizedBox(
                                height: 34,
                                width: 34,
                                child: Icon(Icons.bug_report_outlined,color: Colors.white,size:30,)
                            ),
                            title: Text("Report Bugs",style: TextStyle(color: Colors.white),),
                          )])
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:24 ),
                      child: Divider(color: Colors.white24,height: 1,),
                    ),
                    Stack(
                        children: [
                          AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              height: 56,
                              width: list[7]==1?250:0,
                              child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                          ListTile(
                            onTap: (){
                              setState(() {
                                list[7]=1;
                              });
                              Future.delayed(Duration(milliseconds: 1000),(){
                                _composeEmailforsupport();
                                setState(() {
                                  list[7]=0;
                                });
                              });
                            },
                            leading: SizedBox(
                                height: 34,
                                width: 34,
                                child: Icon(Icons.mail,color: Colors.white,size:30,)
                            ),
                            title: Text("Send us E-mail",style: TextStyle(color: Colors.white),),
                          )])
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left:24 ),
                  child: Divider(color: Colors.white24,height: 1,),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24,top: 16,bottom: 16),
                  child: Text("Others",style: TextStyle(color: Colors.white70,fontSize: 18),),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:24 ),
                      child: Divider(color: Colors.white24,height: 1,),
                    ),
                    Stack(
                        children: [
                          AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              height: 56,
                              width: list[8]==1?250:0,
                              child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                          ListTile(
                            onTap: (){
                              setState(() {
                                list[8]=1;
                              });
                              Future.delayed(Duration(milliseconds: 1000),(){
                                setState(() {
                                  list[8]=0;
                                });
                              });
                            },
                            leading: SizedBox(
                                height: 34,
                                width: 34,
                                child: Icon(Icons.password,color: Colors.white,size:30,)
                            ),
                            title: Text("Change PassCode",style: TextStyle(color: Colors.white),),
                          )])
                  ],
                ),
                GestureDetector(
                  onLongPress: (){
                    _signOut();
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:24 ),
                        child: Divider(color: Colors.white24,height: 1,),
                      ),
                      Stack(
                          children: [
                            AnimatedPositioned(
                                duration: Duration(milliseconds: 300),
                                height: 56,
                                width: list[9]==1?250:0,
                                child: Container(decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),)),
                            ListTile(
                              onTap: (){
                                setState(() {
                                  list[9]=1;
                                });
                                Future.delayed(Duration(milliseconds: 1000),(){
                                  setState(() {
                                    list[9]=0;
                                  });
                                });
                              },
                              leading: SizedBox(
                                  height: 34,
                                  width: 34,
                                  child: Icon(Icons.exit_to_app,color: Colors.white,size:30,)
                              ),
                              title: Text("SignOut",style: TextStyle(color: Colors.white),),
                            )])
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _composeEmail() async {
    final Email email = Email(
      body: 'BUG REPORT',
      subject: "",
      recipients: ['hitanshagrawal@gmail.com'],
      /*cc: ['cc@example.com'],
      bcc: ['bcc@example.com'],
      attachmentPaths: ['/path/to/attachment.zip'],
       */
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }
  void _composeEmailforsupport() async {
    // Define the email parameters
    final Email email = Email(
      body: "",
      subject: '',
      recipients: ['hitanshagrawal@gmail.com'],
      /*cc: ['cc@example.com'],
      bcc: ['bcc@example.com'],
      attachmentPaths: ['/path/to/attachment.zip'],
       */
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }
  void showSyncLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: 350,
            child: Column(
              children: [
                SizedBox(height: 20),
                Image.asset(
                  "assets/images/location.png",
                  height: 200,
                  width: 200,
                ),
                SizedBox(height: 20),
                Text(
                  'Sync your location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    side: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      gpsdone=false;
                    });
                    Fluttertoast.showToast(msg: "Fetching Location...");
                    _getCurrentPosition();
                  },
                  child: Text(
                    'Sync Now',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _signOut() {
    FirebaseAuth.instance.signOut().whenComplete((){
      Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route) => false);
    }).onError((error, stackTrace){
      print(error.toString());
    });
  }
  Future<bool> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return false;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      currpos = LatLng(position.latitude, position.longitude);
      Fluttertoast.showToast(msg: "Syncing...");
      Map<String,String> mp={
        "latitude":currpos.latitude.toString(),
        "longitude":currpos.longitude.toString()
      };
      await FirebaseDatabase.instance.ref().child("Users").child(widget.userModel.id).child("coor").set(mp).whenComplete((){
        setState(() {
          gpsdone=true;
        });
        Fluttertoast.showToast(msg: "Synced Successfully..");
      });
      return true;
    }).catchError((e) {
      debugPrint(e);
      print(e);
      setState(() {
        gpsdone=true;
      });
      return false;
    });
    setState(() {
      gpsdone=true;
    });
    return true;
  }
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        gpsdone=true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        gpsdone=true;
      });
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        gpsdone=true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
}
