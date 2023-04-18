import 'dart:async';
import 'dart:math' show asin, cos, pi, pow, sin, sqrt;
import 'package:dummy_firebase/homepage.dart';
import 'package:dummy_firebase/model%20classes/ThoughtsModel.dart';
import 'package:dummy_firebase/utils/marqueewidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class allThoughtsPage extends StatefulWidget {
  const allThoughtsPage({Key? key}) : super(key: key);

  @override
  State<allThoughtsPage> createState() => _allThoughtsPageState();
}

class _allThoughtsPageState extends State<allThoughtsPage> {

  var database=FirebaseDatabase.instance;
  var currentuser;
  double radiusofrange = 0.25;
  BitmapDescriptor markericon = BitmapDescriptor.defaultMarker;
  LatLng currpos=LatLng(20.5937, 78.9629);
  Completer<GoogleMapController> controller = Completer();
  final List<Marker> _markers = [];
  var auth=FirebaseAuth.instance;
  var colourlist=[Colors.red,Colors.deepOrange,Colors.orangeAccent,Colors.lightGreenAccent,Colors.green];
  List<ThoughtModel> thlist = [];
  List<ThoughtModel> oglist = [];
  var loading=true;
  ItemScrollController _scrollController = ItemScrollController();
  var publishing=false;
  var modaldone=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(auth.currentUser!=null){currentuser=auth.currentUser!.uid;}
    else Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route) => false);
    database.ref().keepSynced(true);
    var db=FirebaseDatabase.instance.ref().child("Thoughts");
    db.keepSynced(true);
    _getCurrentPosition();
    db.onValue.listen((event) async {
      oglist.clear();
      for(DataSnapshot snapshot in event.snapshot.children) {
        ThoughtModel thoughtModel = ThoughtModel.empty();
        if (snapshot.value != null) {
          Map<String, dynamic> data = Map<String, dynamic>.from(
          snapshot.value as Map);
          thoughtModel.thought = data['thought'] ?? '';
          thoughtModel.userid = data['userid'] ?? '';
          thoughtModel.time = data['time'] ?? '';
          thoughtModel.sentiment = data['sentiment'] ?? '3';
          thoughtModel.key = data['key'] ?? '';
          thoughtModel.agree = data['agree'].toString() ?? '-1';
          thoughtModel.lock = data['lock'].toString() ?? 'true';
          thoughtModel.coor = (snapshot.child("coor").child('latitude').value.toString() ?? '0.00') + "&&" +
              (snapshot.child("coor").child('longitude').value.toString() ?? '0.00');
          thoughtModel.username = "Username";
          thoughtModel.userdp="n";
          var uref = FirebaseDatabase.instance.ref().child("Users").child(
              thoughtModel.userid);
          uref.keepSynced(true);
          await uref.child("name").get().then((value) {
            thoughtModel.username = value.value.toString();
          });
          await uref.child("userdp").get().then((value) {
            thoughtModel.userdp=value.value.toString();
          });
          oglist.add(thoughtModel);
        }
      }
      oglist.sort((a, b) => int.parse(b.agree).compareTo(int.parse(a.agree)));
      setState(() {
        thlist=oglist;
        loading=false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        minimum: EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Center(
          child: loading?CircularProgressIndicator(color: Colors.black,):Column(
            children:[
              SizedBox(height: 50,),
              Row(
                children: [
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
                                circleId: CircleId(currentuser),
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
                  SizedBox(width: 15,),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  SizedBox(width: 20,),
                  ElevatedButton.icon(
                    onPressed: () async {
                      GoogleMapController googleMapController = await controller.future;
                      googleMapController.animateCamera(CameraUpdate.newLatLng(currpos));
                      setState(() {
                      });
                      setState(() {});
                    },
                    icon: Icon(Icons.my_location_rounded, color: Colors.black),
                    label: Text("Recenter", style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                              child:OutlinedButton(
                                onPressed: () async {
                                  GoogleMapController googleMapController = await controller.future;
                                  googleMapController.animateCamera(CameraUpdate.newLatLngZoom(currpos, 15.7));
                                  radiusofrange=0.25;
                                  filterlist();
                                  setState(() {
                                  });
                                },
                                child: Text("Under 250M",style: TextStyle(color: Colors.black,fontSize: 12),),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.black),
                                  //  padding: EdgeInsets.symmetric(vertical: 14)
                                ),
                              )
                          ),
                          SizedBox(width: 10,),
                          SizedBox(
                              child:OutlinedButton(
                                onPressed: () async {
                                  GoogleMapController googleMapController = await controller.future;
                                  googleMapController.animateCamera(CameraUpdate.newLatLngZoom(currpos, 14.7));
                                  radiusofrange=0.5;
                                  filterlist();
                                  setState(() {
                                  });
                                },
                                child: Text("Under 500M",style: TextStyle(color: Colors.black,fontSize: 12),),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.black),
                                  //  padding: EdgeInsets.symmetric(vertical: 14)
                                ),
                              )
                          ),
                          SizedBox(width: 10,),
                          SizedBox(
                              child:OutlinedButton(
                                onPressed: () async {
                                  GoogleMapController googleMapController = await controller.future;
                                  googleMapController.animateCamera(CameraUpdate.newLatLngZoom(currpos, 13.4));
                                  radiusofrange=1;
                                  filterlist();
                                  setState(() {
                                  });
                                },
                                child: Text("Under 1KM",style: TextStyle(color: Colors.black,fontSize: 12),),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.black),
                                  //  padding: EdgeInsets.symmetric(vertical: 14)
                                ),
                              )
                          ),
                          SizedBox(width: 10,),
                          SizedBox(
                              child:OutlinedButton(
                                onPressed: () async {
                                  GoogleMapController googleMapController = await controller.future;
                                  googleMapController.animateCamera(CameraUpdate.newLatLngZoom(currpos, 11.3));
                                  radiusofrange=5;
                                  filterlist();
                                  setState(() {
                                  });
                                },
                                child: Text("Under 5KM",style: TextStyle(color: Colors.black,fontSize: 12),),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.black),
                                  //  padding: EdgeInsets.symmetric(vertical: 14)
                                ),
                              )
                          ),
                          SizedBox(width: 10,),
                          SizedBox(
                              child:OutlinedButton(
                                onPressed: () async {
                                  radiusofrange=10;
                                  filterlist();
                                  GoogleMapController googleMapController = await controller.future;
                                  googleMapController.animateCamera(CameraUpdate.newLatLngZoom(currpos, 10.2));
                                  setState(() {
                                  });
                                },
                                child: Text("Under 10KM",style: TextStyle(color: Colors.black,fontSize: 12),),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.black),
                                  //  padding: EdgeInsets.symmetric(vertical: 14)
                                ),
                              )
                          ),
                          SizedBox(width: 20,),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
              SizedBox(height: 5,),
              Expanded(
              child:  ScrollablePositionedList.builder(
                itemScrollController: _scrollController,
                padding: EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                itemCount: thlist.length,
                physics:  BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  ThoughtModel thoughtModel = thlist[index];
                  return Container(
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
                              child: (thoughtModel.userdp=="n" || thoughtModel.lock=="true")?CircleAvatar(
                                backgroundColor: Colors.black87,
                                child: thoughtModel.lock=="true"?Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ):Icon(
                                  Icons.person,
                                  color: Colors.white,
                                )
                              ):CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 20,
                                backgroundImage: NetworkImage(thoughtModel.userdp,),
                              )
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.pushNamed(context,'userprofilepage',arguments:thoughtModel.userid);
                                },
                                child: MarqueeWidget(
                                  direction: Axis.horizontal,
                                  child: Text(
                                    thoughtModel.lock=="true"?"Anonymous":thoughtModel.username,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            GestureDetector(
                              onTap:(){
                                _scrollController.scrollTo(index: index, duration: Duration(milliseconds: 300)).whenComplete((){
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
                                                    String? key = database
                                                        .ref()
                                                        .push()
                                                        .key;
                                                    DateTime today = DateTime
                                                        .now();
                                                    Map<String, dynamic> map = {
                                                      'key': key,
                                                      'userid': currentuser,
                                                      'thought': thoughtModel
                                                          .thought,
                                                      'time': today.toString(),
                                                      'sentiment': thoughtModel
                                                          .sentiment,
                                                      'coor': {
                                                        'latitude': currpos
                                                            .latitude,
                                                        'longitude': currpos
                                                            .longitude,
                                                      },
                                                      'lock': thoughtModel.lock,
                                                      'agree': 0,
                                                    };
                                                    database.ref().child(
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
                                                      database.ref().child(
                                                          "Users").child(
                                                          currentuser).child(
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
                                });
                              },
                              child: Container(
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
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
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
                  );
                },
              ),
            ),
             ]
          )
        ),
      ),
    );
  }
  void filterlist(){
    List<ThoughtModel> templist=[];
    for(ThoughtModel thoughtModel in oglist){
         var latLngList = thoughtModel.coor.split('&&');
         var latitude = double.parse(latLngList[0]);
         var longitude = double.parse(latLngList[1]);
         var km = calculateDistance(currpos.latitude,currpos.longitude,latitude,longitude);
         if(km<=radiusofrange/2){
           templist.add(thoughtModel);
         }
    }
    thlist=templist;
    setState(() {});
  }
  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
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
            target: LatLng(position.latitude, position.longitude), zoom: 15.7),
      ));
      _markers.add(
          Marker(
            markerId: MarkerId(currentuser),
            position: LatLng(position.latitude, position.longitude,),
            infoWindow: InfoWindow(
              title: "Your Location",
            ),
            icon: markericon,
          )
      );
      currpos=LatLng(position.latitude, position.longitude);
      filterlist();
      setState(() {});
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
