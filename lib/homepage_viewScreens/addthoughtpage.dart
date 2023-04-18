import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dart_sentiment/dart_sentiment.dart';
import 'package:dummy_firebase/model%20classes/userclass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/marqueewidget.dart';

class AddThoughtsPage extends StatefulWidget {
  const AddThoughtsPage({Key? key}) : super(key: key);

  @override
  State<AddThoughtsPage> createState() => _AddThoughtsPageState();
}

class _AddThoughtsPageState extends State<AddThoughtsPage> {

  var database=FirebaseDatabase.instance;
  var auth=FirebaseAuth.instance;
  var currentuser;
  var thougthcontroller=TextEditingController();
  LatLng currpos=LatLng(20.5937, 78.9629);
  String chatgptkey="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";
  BitmapDescriptor markericon = BitmapDescriptor.defaultMarker;
  String fetchaddress="fetching location";
  double radiusofrange = 2;
  Completer<GoogleMapController> controller = Completer();
  final List<Marker> _markers = [];
  List<String> airesult=[];
  bool generating=true;
  var colorlist=[Colors.pinkAccent,Colors.green,Colors.blueAccent,Colors.redAccent,Colors.deepOrangeAccent];
  int copied=-1;
  var publishing=false;
  double emojiRating = 0;
  late Sentiment sentiment;
  var lock=false;

  Future<String> generateResponse(String prompt) async {
    var apiKey = chatgptkey;
    var url = Uri.https("api.openai.com", "/v1/completions");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $apiKey"
      },
      body: json.encode({
        "model": "text-davinci-003",
        "prompt": prompt,
        'temperature': 0,
        'max_tokens': 2000,
        'top_p': 1,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0,
      }),
    );
    Map<String, dynamic> newresponse = jsonDecode(response.body);
    return newresponse['choices'][0]['text'];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sentiment=Sentiment();
    database.ref().keepSynced(true);
    if(auth.currentUser!=null) {
      setState(() {
        currentuser = auth.currentUser?.uid;
      });
      print(currentuser);
      _getCurrentPosition();
    }
    else{
      Navigator.pushNamedAndRemoveUntil(context,"welcome",(route) => false);
    }
    generateResponse("give me exactly 5 suggestions (with bulletin : #) for long sentences that describes the following phrases : [Happiness,peace of mind,good mood].").then((value){
      setState(() {
        generating=false;
        airesult= splitString(value.toString());
      });
    });
    thougthcontroller.addListener(() {
      if(thougthcontroller.text.trim().isNotEmpty){
        dynamic analysisResult = sentiment.analysis(thougthcontroller.text.trim(), emoji: true, languageCode: LanguageCode.english);
        double score = double.parse(analysisResult['score'].toString());
        double mappedScore = ((score + 10) / 20) * 5;
        int mappedScoreInt = mappedScore.round();
          setState(() {
            emojiRating=min(max(1,mappedScoreInt*1.0),5.0);
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 90,),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: EdgeInsets.only(left: 20,right: 20,bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.bubble_chart,color: Colors.black,size: 40,),
                        SizedBox(width: 5,),
                        Row(
                          children: [
                            Text("Write a Thought.",style:TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: TextField(
                            cursorColor: Colors.black,
                            scrollPhysics: BouncingScrollPhysics(),
                            textAlignVertical: TextAlignVertical.top,
                            textAlign: TextAlign.start,
                            enableSuggestions: true,
                            decoration: InputDecoration(
                              hintText: "Write your thought here.",
                              hintStyle: TextStyle(fontSize: 18,color: Colors.grey,),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(20.0), // set border radius
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(20.0), // set border radius
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            controller: thougthcontroller,
                            style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.normal), // set font size
                            maxLines: null, // set ma
                            expands: true,// xLines to null to allow the text field to expand vertically
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.generating_tokens_sharp, color: Colors.white),
                                label: MarqueeWidget(direction:Axis.horizontal,child: Text("Sentiment Analysis", style: TextStyle(color: Colors.white))),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Row(
                              children: [
                                Icon(
                                  Icons.sentiment_very_dissatisfied,
                                  color: emojiRating == 1 ? Colors.red : Colors.grey,
                                ),
                                SizedBox(width: 10,),
                                Icon(
                                  Icons.sentiment_dissatisfied,
                                  color: emojiRating == 2 ? Colors.redAccent : Colors.grey,
                                ),
                                SizedBox(width: 10,),
                                Icon(
                                  Icons.sentiment_neutral,
                                  color: emojiRating == 3 ? Colors.amber : Colors.grey,
                                ),
                                SizedBox(width: 10,),
                                Icon(
                                  Icons.sentiment_satisfied,
                                  color: emojiRating == 4 ? Colors.lightGreen : Colors.grey,
                                ),
                                SizedBox(width: 10,),
                                Icon(
                                  Icons.sentiment_very_satisfied,
                                  color: emojiRating == 5 ? Colors.green : Colors.grey,
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                        child: OutlinedButton(
                          onPressed: (){
                            if(thougthcontroller.text.toString().trim().isNotEmpty){
                              setState(() {
                                publishing=true;
                              });
                              String? key=database.ref().push().key;
                              DateTime today = DateTime.now();
                              Map<String, dynamic> map = {
                                'key': key,
                                'userid':currentuser,
                                'thought' : thougthcontroller.text.trim(),
                                'time' : today.toString(),
                                'sentiment': emojiRating.toString(),
                                'coor' : {
                                  'latitude':currpos.latitude,
                                  'longitude':currpos.longitude,
                                },
                                'lock':lock.toString(),
                                'agree':0,
                              };
                              database.ref().child("Thoughts").child(key!).set(map).whenComplete((){
                                database.ref().child("Users").child(currentuser).child("Thoughts").child(key!).set(map).whenComplete((){
                                  setState(() {
                                    thougthcontroller.clear();
                                    publishing=false;
                                  });
                                });
                              }).onError((error, stackTrace){
                                setState(() {
                                  publishing=false;
                                });
                              });
                            }
                          },
                          //icon: Icon(Icons.upload,size: 20,),
                          child: Text(thougthcontroller.text.isEmpty?"Write one thought":(publishing?"Posting..":(lock)?"Publish Anonymously":"Publish Publicly"),style:TextStyle(color: Colors.black),),
                          style: OutlinedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape : RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              shadowColor: Colors.black54,
                              side: BorderSide(color: Colors.black),
                              padding: EdgeInsets.symmetric(vertical: 14)
                          ),
                        ),
                      ),
                        publishing?Container():Row(
                          children: [
                            SizedBox(width: 10,),
                            GestureDetector(
                              onTap: (){setState(() {
                                lock=!lock;
                              });
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black87,
                                ),
                                child: Icon(lock?Icons.lock:Icons.lock_open,color: Colors.white,),
                              ),
                            ),
                          ],
                        ),
                        (thougthcontroller.text.isEmpty||publishing)?
                        Container():
                        Row(
                          children: [
                            SizedBox(width: 10,),
                            GestureDetector(
                              onTap: (){
                                thougthcontroller.clear();
                                setState(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black87,
                                ),
                                child: Icon(Icons.close_rounded,color: Colors.white,),
                              ),
                            ),
                          ],
                        ),

                        publishing?Row(
                          children: [
                            SizedBox(width: 10,),
                            SpinKitFadingCircle(
                              color: Colors.white54,
                              size: 20,
                            )
                          ],
                        ):Container()
                     ]
                    ),
                    SizedBox(height: 10,),
                    Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (){
                                if(thougthcontroller.text.toString().trim().isNotEmpty){
                                  setState(() {
                                    generating=true;
                                  });
                                  generateResponse("give me exactly 5 suggestions (with bulletin : #) for long sentences that describes the following phrases : ["+thougthcontroller.text.trim()+"].").then((value){
                                    setState(() {
                                      generating=false;
                                      airesult= splitString(value.toString());
                                    });
                                  });
                                }
                              },
                              //icon: Icon(Icons.upload,size: 20,),
                              child: Text(generating?"Fetching results..":"Generate AI Responses",style:TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.black87,
                                  shape : RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  shadowColor: Colors.black54,
                                  side: BorderSide(color: Colors.black),
                                  padding: EdgeInsets.symmetric(vertical: 14)
                              ),
                            ),
                          ),
                          generating?Row(
                            children: [
                              SizedBox(width: 10,),
                              SpinKitThreeInOut(
                                color: Colors.black87,
                                size: 20,
                              )
                            ],
                          ):Container()
                        ]
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 300,
                      child: Center(
                        child: generating?CircularProgressIndicator(color: Colors.black,):ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: airesult.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 200,
                              padding: EdgeInsets.all(15),
                              margin: EdgeInsets.only(right: 20,top: 20,bottom: 10),
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
                                          backgroundColor: colorlist[index%5],
                                          child: Icon(
                                            Icons.bubble_chart_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Response ${index+1}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        child: Icon(((copied==index)?Icons.done_all:Icons.copy),color: colorlist[index%5],size: 20,),
                                        onTap:(){
                                          setState(() {
                                            copied=index;
                                          });
                                          thougthcontroller.text=airesult[index].trim();
                                          Future.delayed(Duration(milliseconds: 1500)).whenComplete((){
                                            setState(() {
                                              copied=-1;
                                            });
                                          });
                                        },
                                      ),
                                      SizedBox(width: 10,),
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
                                  Expanded(
                                    child: MarqueeWidget(
                                      child: Text(
                                        airesult[index],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      direction: Axis.vertical,
                                      animationDuration: Duration(milliseconds: 1000),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                            _getCurrentPosition();
                          },
                          child: Container(
                            width: 80,
                            height: 100,
                            padding: EdgeInsets.only(top: 8,bottom: 8,left: 8,right: 8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow:[
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2),
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Icon(Icons.my_location_rounded,color: Colors.black87,size: 30,),
                                ),
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
                                markers: Set<Marker>.of(_markers),
                                mapType: MapType.hybrid,
                                compassEnabled: true,
                                onMapCreated: (GoogleMapController c) {
                                  controller.complete(c);
                                },
                                zoomControlsEnabled: false,
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            target: LatLng(position.latitude, position.longitude), zoom: 12.5),
      ));
      currpos=LatLng(position.latitude, position.longitude);
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

  List<String> splitString(String text) {
    RegExp regex = RegExp(r'#[1-5]');
    List<String> result = text.split(regex);
    result.removeWhere((s) => s.trim().isEmpty);
    return result;
  }


}
