import 'dart:async';

import 'package:dummy_firebase/loginpage.dart';
import 'package:dummy_firebase/model%20classes/userclass.dart';
import 'package:dummy_firebase/utils/marqueewidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class SignUpPage extends StatefulWidget {

  static String verify="";

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var auth=FirebaseAuth.instance;
  late DatabaseReference database;
  var key=GlobalKey<FormState>();
  var namecontroller=TextEditingController();
  var phonecontroller=TextEditingController();
  var emailcontroller=TextEditingController();
  var passwordcontroller=TextEditingController();
  var done=false;
  var locationdone=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    database=FirebaseDatabase.instance.ref();
    database.keepSynced(true);
  }
  double radiusofrange = 0.25;
  LatLng currpos=LatLng(20.5937, 78.9629);
  Completer<GoogleMapController> controller = Completer();
  final List<Marker> _markers = [];

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(image: AssetImage('assets/images/signuplogo.png'),height: size*0.2,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                Text("Get On Board!",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800,fontSize: 30),),
                  SizedBox(width: 10,),
                   done?SpinKitDualRing(size: 20,
                     color: Colors.black,):SpinKitThreeInOut(
                size: 30,
                color: Colors.black,
              ),
                  ]),
              SizedBox(height: 4,),
              Text("Fill the below form to start your journey!",style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 15),textAlign: TextAlign.start,),
              Form(
                key: key,
                  child:Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.account_circle,color: Colors.grey,),
                              labelText: "Name",
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: "Name",
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                              )
                          ),
                          validator: (value){
                            value=value!.trim();
                            if(value!.isEmpty || value!.length>20){
                              return "Enter Correct Name";
                            }
                            else return null;
                          },
                          controller: namecontroller,
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: emailcontroller,
                          validator: (value){
                            if(value!.isEmpty || !RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value.trim())){
                              return "Enter Correct email";
                            }
                            else return null;
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.alternate_email_outlined,color: Colors.grey,),
                              labelText: "E-mail",
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: "E-mail",
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                              )
                          ),
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: phonecontroller,
                            validator: (value){
                            if(value!.isEmpty || !RegExp(r'([0-9]{10}$)').hasMatch(value.trim())){
                            return "Enter correct phone number format";
                            }
                            else return null;
                            },
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone_android,color: Colors.grey,),
                              labelText: "Phone",
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: "Phone",
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                              )
                          ),
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          obscureText: true,
                          controller: passwordcontroller,
                          validator: (value){
                            value=value!.trim();
                            if(value!.isEmpty || value!.length<6){
                              return "Password length must be atleast 6.";
                            }
                            else return null;
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.fingerprint,color: Colors.grey,),
                              suffixIcon: Icon(Icons.remove_red_eye,color: Colors.grey,),
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: "Password",
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                              )
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            SizedBox(width: 5,),
                            GestureDetector(
                              onTap: (){
                                Fluttertoast.showToast(msg: "Syncing...");
                                _getCurrentPosition();
                              },
                              child: Container(
                                width: 80,
                                height: 100,
                                padding: EdgeInsets.only(
                                    top: 8, bottom: 8, left: 8, right: 8),
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Icon(Icons.my_location,color: Colors.black87,size: 35,)
                                    ),
                                    SizedBox(height: 8,),
                                    Expanded(
                                        child: MarqueeWidget(
                                          animationDuration: Duration(seconds: 10),
                                          direction: Axis.horizontal,
                                          child: Text(
                                            locationdone?"Synced":"Sync your\nLocation",
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 11,
                                                fontWeight: FontWeight. normal
                                            ),
                                            softWrap: true,
                                          ),
                                        )
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 15,),
                            Expanded(
                              child: Container(
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      zoom: 18,
                                      target: LatLng(20.5937, 78.9629),
                                    ),
                                    zoomControlsEnabled: false,
                                    zoomGesturesEnabled: false,
                                    markers: Set<Marker>.of(_markers),
                                    mapType: MapType.hybrid,
                                    compassEnabled: true,
                                    onMapCreated: (GoogleMapController c) {
                                      controller.complete(c);
                                    },
                                    circles: {
                                      Circle(
                                          circleId: CircleId("hello"),
                                          center: _markers.isEmpty
                                              ? LatLng(0, 0)
                                              : _markers[0].position,
                                          radius: (radiusofrange / 2) * 1000,
                                          strokeWidth: 3,
                                          strokeColor: Colors.black,
                                          fillColor: Colors.black.withOpacity(0.3)
                                      )
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5,),
                          ],
                        ),
                        SizedBox(height: 20,),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (){
                              if(!(key.currentState!.validate())){
                                Fluttertoast.showToast(msg: "Formatting Error");
                              }
                              else {
                                Fluttertoast.showToast(msg: "Processing...");
                                createuserwithemailandpass(emailcontroller.text, passwordcontroller.text);
                              }
                              },
                              child: Text(done?"Processing...":"Sign-Up",style:TextStyle(color: Colors.white),),
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
                        ),
                        SizedBox(height: 15,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Or",style:TextStyle(color: Colors.black),),
                            SizedBox(height: 10,),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: (){},
                                label: Text("Sign-in with Google"),
                                style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(),
                                    foregroundColor: Colors.black,
                                    side: BorderSide(color: Colors.black),
                                    padding: EdgeInsets.symmetric(vertical: 14)
                                ), icon: Image(image: AssetImage('assets/images/googlelogo.png'),width: 20,),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                              onPressed: ()=>{
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => LoginPage()),
                                )
                              },
                              style: ElevatedButton.styleFrom(foregroundColor: Colors.grey),
                              child: Text("Already have an Account? Login",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)
                          ),
                        ),
                      ],
                    ),
                  )
              ),
              SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }

  Future createuserwithemailandpass(String email,String pass) async{
    if(!locationdone){
      Fluttertoast.showToast(msg: "Sync Your Location First to create your accoubnt");
      return;
    }
    setState(() {
      done=true;
    });
    try{
      await auth.createUserWithEmailAndPassword(email:email.trim(), password: pass.trim()).then((value) async {
        DateTime today = DateTime.now();
        String formattedDate = DateFormat('d MMM yy').format(today);
        formattedDate = formattedDate.replaceAllMapped(RegExp(r'(\d+)(st|nd|rd|th)'), (Match m) {
          var suffix = '';
          if (m.group(2) == '1' && m.group(1) != '11') {
            suffix = 'st';
          } else if (m.group(2) == '2' && m.group(1) != '12') {
            suffix = 'nd';
          } else if (m.group(2) == '3' && m.group(1) != '13') {
            suffix = 'rd';
          } else {
            suffix = 'th';
          }
          return '${m.group(1)}$suffix';
        });
        Map<String, dynamic> map = {
          'id': value.user!.uid.toString(),
          'phone':phonecontroller.text.trim(),
          'userdp' : "https://firebasestorage.googleapis.com/v0/b/groupies-29fbd.appspot.com/o/userdp%2F508-5087236_tab-profile-f-user-icon-white-fill-hd.png?alt=media&token=ff05d49f-011b-456a-b002-880c0f7d2159",
          'email' : emailcontroller.text.trim(),
          'password':passwordcontroller.text.trim(),
          'name':namecontroller.text.trim(),
          'time':formattedDate,
          'coor':{'latitude':currpos.latitude,'longitude':currpos.longitude}
        };
        var database=FirebaseDatabase.instance.ref();
        database.child("Users").child(value.user!.uid.toString()).set(map).then((v){
          setState(() {
            done=false;
          });
          if(value.user!.uid==null) {
            Navigator.pushNamedAndRemoveUntil(
                (context), 'login', (route) => false);
          }
          else Navigator.pushNamedAndRemoveUntil(
              (context), 'home', (route) => false);
        }).onError((error, stackTrace){
          Fluttertoast.showToast(msg: error.toString());
          setState(() {
            done=false;
          });
        });
      });
    } on FirebaseAuthException catch(e){
      setState(() {
        done=true;
      });
      Fluttertoast.showToast(msg: e.message.toString());
    }
    catch(_){
      setState(() {
        done=true;
      });
      Fluttertoast.showToast(msg: "Error occured");
    }
  }


  Future<bool> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return false;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      GoogleMapController googleMapController = await controller.future;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 16.5),
      ));
      currpos=LatLng(position.latitude, position.longitude);
      _markers.add(
          Marker(
            markerId: MarkerId("hello55"),
            position: LatLng(position.latitude, position.longitude,),
            infoWindow: InfoWindow(
              title: "Your Location",
            ),
          )
      );
      Fluttertoast.showToast(msg: "Synced Successfully");
      setState(() {
        locationdone=true;
      });
      return true;
    }).catchError((e) {
      debugPrint(e);
      print(e);
      return false;
    });
    return true;
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Location services are disabled. Please enable the services");
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permissions are disabled");
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg:
      'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }
    return true;
  }

}
