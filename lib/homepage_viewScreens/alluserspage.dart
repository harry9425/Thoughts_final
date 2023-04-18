import 'dart:async';
import 'dart:math';
import 'package:dummy_firebase/utils/marqueewidget.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dummy_firebase/main.dart';
import 'package:dummy_firebase/utils/alluserswidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dummy_firebase/homepage_viewScreens/alluserspage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../model classes/userclass.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({Key? key}) : super(key: key);

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {

  var auth = FirebaseAuth.instance;
  static String userid = "";
  double radiusofrange = 0.25;
  DatabaseReference database = FirebaseDatabase.instance.reference();
  List<UserModel> list = [],
      toplist = [],
      og = [];
  BitmapDescriptor markericon = BitmapDescriptor.defaultMarker;
  String fetchaddress = "fetching location";
  LatLng currpos = LatLng(20.5937, 78.9629);
  UserModel mainuser = UserModel.empty();
  var searchcontroller = TextEditingController();
  var focus = FocusNode();
  var closebtn = false;
  var laoded = true;

  @override
  void initState() {
    super.initState();
    focus.unfocus();
    database.keepSynced(true);
    if (auth.currentUser == null) {
      Navigator.pushNamedAndRemoveUntil(context, 'welcome', (route) => false);
    }
    userid = auth.currentUser!.uid;
    var uref = FirebaseDatabase.instance.ref().child("Users").child(userid);
    uref.keepSynced(true);
    uref.get().then((v) {
      mainuser.uderdp = v
          .child("userdp")
          .value
          .toString();
    }).whenComplete(() {
      list.clear();
      database
          .child('Users')
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          og.clear();
          Map<dynamic, dynamic> value = event.snapshot.value as dynamic;
          value.forEach((key, data) async {
            UserModel userModel = UserModel.empty();
            userModel.name = data['name'].toString() ?? '';
            userModel.id = data['id'].toString() ?? '';
            userModel.email = "0";
            userModel.uderdp = data['userdp'].toString() ?? '';
            userModel.password = data['coor']['latitude'].toString()+"&&"+data['coor']['longitude'].toString() ?? '';
            var uref = FirebaseDatabase.instance.ref()
                .child("friends_data")
                .child(userModel.id);
            uref.keepSynced(true);
            await uref.get().then((v) {
              userModel.email = v.children.length.toString();
            });
            if (data['id'] != userid) og.add(userModel);
          });
          list = og;
          toplist = og;
          setState(() {
            laoded = false;
          });
        } else {
          print('No data available');
        }
      });
    });
    searchcontroller.addListener(() {
      if (searchcontroller.text
          .trim()
          .isNotEmpty) {
        setState(() {
          closebtn = true;
        });
        List<UserModel> tempList = [];
        for (int i = 0; i < og.length; i++) {
          if (og[i].name.toLowerCase().startsWith(
              searchcontroller.text.toLowerCase().trim())) {
            tempList.add(og[i]);
          }
        }
        setState(() {
          list = tempList;
        });
      }
      else {
        focus.unfocus();
        setState(() {
          list = og;
          closebtn = false;
        });
      }
    });
    _getCurrentPosition();
  }

  Completer<GoogleMapController> controller = Completer();
  final List<Marker> _markers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: laoded ? Center(
            child: CircularProgressIndicator(color: Colors.black,)) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 20,),
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
                Text("Users", style: TextStyle(color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                SizedBox(width: 20,),
                Container(
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
                          color: Colors.black,
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 40,
                          backgroundImage: NetworkImage(
                              mainuser.userdp),
                        ),
                      ),
                      SizedBox(height: 8,),
                      Expanded(
                          child: MarqueeWidget(
                            animationDuration: Duration(seconds: 10),
                            direction: Axis.horizontal,
                            child: Text(
                              fetchaddress,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold
                              ),
                              softWrap: true,
                            ),
                          )
                      )
                    ],
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
                        markers: Set<Marker>.of(_markers),
                        mapType: MapType.hybrid,
                        compassEnabled: true,
                        onMapCreated: (GoogleMapController c) {
                          controller.complete(c);
                        },
                        zoomControlsEnabled: false,
                        circles: {
                          Circle(
                              circleId: CircleId(userid),
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
                SizedBox(width: 20,),
              ],
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                SizedBox(width: 20,),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.my_location_rounded, color: Colors.black),
                  label: Text("Range", style: TextStyle(color: Colors.black)),
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
                            child: OutlinedButton(
                              onPressed: () async {
                                GoogleMapController googleMapController = await controller
                                    .future;
                                googleMapController.animateCamera(
                                    CameraUpdate.newLatLngZoom(currpos, 15.7));
                                radiusofrange = 0.25;
                                filterlist();
                                setState(() {});
                              },
                              child: Text("Under 250M", style: TextStyle(
                                  color: Colors.black, fontSize: 12),),
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
                            child: OutlinedButton(
                              onPressed: () async {
                                GoogleMapController googleMapController = await controller
                                    .future;
                                googleMapController.animateCamera(
                                    CameraUpdate.newLatLngZoom(currpos, 14.7));
                                radiusofrange = 0.5;
                                filterlist();
                                setState(() {});
                              },
                              child: Text("Under 500M", style: TextStyle(
                                  color: Colors.black, fontSize: 12),),
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
                            child: OutlinedButton(
                              onPressed: () async {
                                GoogleMapController googleMapController = await controller
                                    .future;
                                googleMapController.animateCamera(
                                    CameraUpdate.newLatLngZoom(currpos, 13.4));
                                radiusofrange = 1;
                                filterlist();
                                setState(() {});
                              },
                              child: Text("Under 1KM", style: TextStyle(
                                  color: Colors.black, fontSize: 12),),
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
                            child: OutlinedButton(
                              onPressed: () async {
                                GoogleMapController googleMapController = await controller
                                    .future;
                                googleMapController.animateCamera(
                                    CameraUpdate.newLatLngZoom(currpos, 11.3));
                                radiusofrange = 5;
                                filterlist();
                                setState(() {});
                              },
                              child: Text("Under 5KM", style: TextStyle(
                                  color: Colors.black, fontSize: 12),),
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
                            child: OutlinedButton(
                              onPressed: () async {
                                radiusofrange = 10;
                                filterlist();
                                GoogleMapController googleMapController = await controller
                                    .future;
                                googleMapController.animateCamera(
                                    CameraUpdate.newLatLngZoom(currpos, 10.2));
                                setState(() {});
                              },
                              child: Text("Under 10KM", style: TextStyle(
                                  color: Colors.black, fontSize: 12),),
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
            SizedBox(height: 2,),
            Divider(color: Colors.grey,),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 20),
                color: Colors.white,
                child: Row(
                  children: [
                    SizedBox(width: 20,),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: 80,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Column(
                        children: [
                          MarqueeWidget(child: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.offline_bolt, color: Colors.black87,
                                  size: 15,),
                                SizedBox(width: 2,),
                                Text("Gurus", style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),),
                              ],
                              mainAxisAlignment: MainAxisAlignment.start,
                            ),
                          )),
                          SizedBox(height: 10,),
                          Expanded(
                            child: ScrollablePositionedList.builder(
                              itemCount: min(toplist.length, 10),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                toplist.sort((a, b) =>
                                    int.parse(b.email).compareTo(
                                        int.parse(a.email)));
                                UserModel user = toplist[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, 'userprofilepage',
                                        arguments: user.id);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height: 60,
                                        child: Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                15),
                                            color: Colors.black,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                15),
                                            child: Image.network(
                                              user.userdp,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      MarqueeWidget(
                                          animationDuration: Duration(
                                              milliseconds: 2500),
                                          child: Text("@" + user.name,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),)
                                      ),
                                      SizedBox(height: 10,),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            padding: EdgeInsets.only(
                                left: 15, right: 15, top: 5, bottom: 5),
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
                                ]
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.search, color: Colors.black),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 0),
                                    height: 35,
                                    child: TextField(
                                      controller: searchcontroller,
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
                                      focusNode: focus,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                closebtn
                                    ? GestureDetector(
                                    onTap: () {
                                      searchcontroller.clear();
                                    },
                                    child: Icon(
                                        Icons.cancel, color: Colors.black87))
                                    : Container(),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                  left: 5, right: 5, top: 5, bottom: 5),
                              itemCount: list.length,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                UserModel user = list[index];
                                return GestureDetector(
                                  onTap: () {
                                    focus.unfocus();
                                    Navigator.pushNamed(
                                        context, 'userprofilepage',
                                        arguments: user.id);
                                  },
                                  child: Container(
                                    height: 100,
                                    padding: EdgeInsets.only(left: 10,
                                        top: 10,
                                        bottom: 10,
                                        right: 10),
                                    margin: EdgeInsets.only(bottom: 15),
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
                                    child: Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                              child: Image.network(
                                                user.userdp,
                                                fit: BoxFit.cover,
                                                width: 60,
                                                height: 80,
                                              ),
                                            ),
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius
                                                    .circular(10)
                                            ),
                                          ),
                                          SizedBox(width: 15,),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                MarqueeWidget(child: Text(
                                                  "@" + user.name,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      fontSize: 16),)),
                                                SizedBox(height: 3,),
                                                MarqueeWidget(child: Text(
                                                  user.name, style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight
                                                        .normal,
                                                    fontSize: 14),))
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                            ),
                                            child: Icon(
                                              Icons.bubble_chart_outlined,
                                              color: Colors.white,),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20,),
                  ],
                ),
              ),
            )
          ],
        )
    );
  }

  void filterlist(){
    List<UserModel> templist=[];
    for(UserModel userModel in og){
      var latLngList = userModel.password.split('&&');
      var latitude = double.parse(latLngList[0]);
      var longitude = double.parse(latLngList[1]);
      var km = calculateDistance(currpos.latitude,currpos.longitude,latitude,longitude);
      if(km<=radiusofrange/2){
        templist.add(userModel);
      }
    }
    list=templist;
    toplist=templist;
    setState(() {});
  }
  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> getAddressFromCoordinates(double latitude,
      double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude, longitude);
      Placemark placemark = placemarks[0];
      setState(() {
        fetchaddress =
            "address : " + placemark.subLocality!.toLowerCase()! + " " +
                placemark.locality!.toLowerCase()! + "\n" +
                placemark.postalCode!.toLowerCase()! + " " +
                placemark.administrativeArea!.toLowerCase()! + ".";
      });
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<bool> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return false;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      getAddressFromCoordinates(position.latitude, position.longitude);
      GoogleMapController googleMapController = await controller.future;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 12.5),
      ));
      currpos = LatLng(position.latitude, position.longitude);
      _markers.add(
          Marker(
            markerId: MarkerId(userid),
            position: LatLng(position.latitude, position.longitude,),
            infoWindow: InfoWindow(
              title: "Your Location",
            ),
            icon: markericon,
          )
      );
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
}