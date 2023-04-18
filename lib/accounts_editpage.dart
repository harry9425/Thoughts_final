import 'dart:async';
import 'dart:io';
import 'package:dummy_firebase/model%20classes/userclass.dart';
import 'package:dummy_firebase/utils/marqueewidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'model classes/ThoughtsModel.dart';

class AccountsEditPage extends StatefulWidget {
  const AccountsEditPage({Key? key}) : super(key: key);

  @override
  State<AccountsEditPage> createState() => _AccountsEditPageState();
}

class _AccountsEditPageState extends State<AccountsEditPage> {

  late UserModel userModel;
  String uid="";
  bool isLoading = true;
  File? image;
  var publishing=false;
  var modaldone=false;
  List<UserModel> list=[],og=[],thlist=[],thog=[];
  var thcnt=0,fcnt=0;
  var focus=FocusNode();
  var friendcontroller=TextEditingController();
  var thcontroller=TextEditingController();
  var colourlist=[Colors.red,Colors.deepOrange,Colors.orangeAccent,Colors.lightGreenAccent,Colors.green];
  String lastth="No Recents Thoughts Found!!";

  Future PickImage(ImageSource imageSource) async{
    final data= await ImagePicker().pickImage(source: imageSource);
    if(data!=null){
      final datapath=File(data.path);
      image=datapath;
      setState(() {});
      final ref=FirebaseStorage.instance.ref().child("userdp").child(uid);
      UploadTask uploadTask=ref.putFile(image!);
      final snapshot= await uploadTask!.whenComplete((){});
      final urlDownload=await snapshot.ref.getDownloadURL();
      DatabaseReference databaseReference=FirebaseDatabase.instance.ref().child("Users").child(uid);
      databaseReference.keepSynced(true);
      databaseReference.child("userdp").set(urlDownload.toString());
    }
    else return;
  }

  @override
  void initState(){
    super.initState();
    var auth=FirebaseAuth.instance.currentUser;
    userModel=UserModel.empty();
    if(auth==null){Navigator.pushNamed(context,'welcome');}
    uid=auth!.uid;
    final ref = FirebaseDatabase.instance.ref().child("Users");
    ref.keepSynced(true);
    ref.child(uid).onValue.listen((event){
      if (event.snapshot.exists) {
        userModel.name = event.snapshot.child('name').value.toString() ?? " ";
        userModel.id = event.snapshot.child('id').value.toString() ?? " ";
        userModel.email = event.snapshot.child('email').value.toString() ?? " ";
        userModel.phone = event.snapshot.child('phone').value.toString() ?? " ";
        userModel.uderdp = event.snapshot.child('userdp').value.toString() ?? " ";
        thcnt=0;
        lastth="No recents thoughts found.";
        if(event.snapshot.hasChild("Thoughts")) {
          thcnt=event.snapshot.child("Thoughts").children.length;
          lastth = event.snapshot
              .child("Thoughts")
              .children
              .last
              .child("thought")
              .value
              .toString();
        }
        setState(() {
          isLoading = false;
        });
      }
    });
    reload();
    friendcontroller.addListener(() {
      if(friendcontroller.text.trim().isNotEmpty) {
        List<UserModel> tempList = [];
        for (int i = 0; i < og.length; i++) {
          if (og[i].name.toLowerCase().contains(friendcontroller.text.toLowerCase().trim())) {
            tempList.add(og[i]);
          }
        }
        setState(() {
          list = tempList;
        });
      }
      else{
        setState(() {
          list = og;
        });
      }
    });
  }

  void reload(){
    friendcontroller.clear();
    DatabaseReference database = FirebaseDatabase.instance.reference();
    database.keepSynced(true);
    database.child("friends_data").child(uid).onValue.listen((event) async {
      print(event.snapshot.value.toString());
      og.clear();
      for(DataSnapshot snapshot in event.snapshot.children) {
        if (snapshot.value.toString() == "f") {
          var uref = FirebaseDatabase.instance.ref().child("Users").child(
              snapshot.key.toString());
          uref.keepSynced(true);
          UserModel userModel = UserModel.empty();
          await uref.get().then((v) {
            userModel.name = v
                .child("name")
                .value
                .toString();
            userModel.uderdp = v
                .child("userdp")
                .value
                .toString();
            userModel.id = v
                .child("id")
                .value
                .toString();
            og.add(userModel);
          });
        }
      }
      setState(() {
        list=og;
      });
    });
  }

  Completer<GoogleMapController> controller = Completer();
  final List<Marker> _markers = [];
  LatLng currpos=LatLng(20.5937, 78.9629);
  bool editon=false;
  var pagelist=[1,0,0,0];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading ? Center(child: CircularProgressIndicator(color: Colors.black,)) :
      Center(
        child: Container(
          height: MediaQuery.of(context).size.height*0.90,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if(pagelist[0]==1) getaccountview(),
              if(pagelist[1]==1) getthoughtsview(),
              if(pagelist[2]==1) getfriendsview(),
              Container(
                padding: EdgeInsets.only(left: 5,right: 5),
                width: MediaQuery.of(context).size.width*0.27,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          pagelist=[1,0,0,0];
                        });
                      }, child: Text("Profile",style:TextStyle(color: pagelist[0]==1?Colors.black:Colors.grey,fontWeight:FontWeight.bold,fontSize: pagelist[0]==1?21:16)),),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          pagelist=[0,1,0,0];
                        });
                      }, child: Text("Thoughts",style:TextStyle(color: pagelist[1]==1?Colors.black:Colors.grey,fontWeight:FontWeight.bold,fontSize: pagelist[1]==1?21:16)),),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          pagelist=[0,0,1,0];
                        });
                      }, child: Text("Friends",style:TextStyle(color: pagelist[2]==1?Colors.black:Colors.grey,fontWeight:FontWeight.bold,fontSize: pagelist[2]==1?21:16)),),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                      }, child: Text("Home",style:TextStyle(color: pagelist[3]==1?Colors.black:Colors.grey,fontWeight:FontWeight.bold,fontSize: pagelist[3]==1?21:16),)),
                  ],
                ),
              )
            ],
          ),
        ),
      )
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
            markerId: MarkerId(uid),
            position: LatLng(position.latitude, position.longitude,),
            infoWindow: InfoWindow(
              title: "Your Location",
            ),
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

  Widget getaccountview(){
    focus.unfocus();
    return Expanded(
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topRight:Radius.circular(20),bottomRight:Radius.circular(20)),
            boxShadow:[
              BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                  color: Colors.grey.withOpacity(0.3)
              )
            ],
            color: Colors.white,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 60,),
                image==null?Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black
                  ),
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(userModel.userdp),
                  ),
                ): Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black
                  ),
                  child: CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.transparent,
                      backgroundImage: FileImage(image!)//:NetworkImage(userModel.userdp)),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "@"+userModel.name,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  userModel.name,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_rounded,color: Colors.black87,size: 20,),
                    SizedBox(width: 5,),
                    Text(
                      userModel.email,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            list.length.toString()+"",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Friends',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 40),
                      Column(
                        children: [
                          Text(
                            thcnt==0?"0":thcnt.toString()+"+",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Thoughts',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ]
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    SizedBox(width: 25,),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: (){
                          setState(() {
                            editon=true;
                          });
                        },
                        child: Text(editon?"Save Changes":"Edit Profile Info"),
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)
                            ),
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.black),
                            padding: EdgeInsets.symmetric(vertical: 14)
                        ),
                      ),
                    ),
                    editon?SizedBox(width: 10,):Container(),
                    editon?Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87,
                      ),
                      child: GestureDetector(
                          onTap: (){
                            setState(() {
                              editon=false;
                            });
                          },
                          child: Icon(Icons.close_rounded,color: Colors.white,size: 25,)
                      ),
                    ):Container(),
                    SizedBox(width: 25,),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    SizedBox(width: 25,),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (){

                          showModalBottomSheet(context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                              ),
                              builder: (context)=>Container(

                                padding: EdgeInsets.all(30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Make Selection!",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800,fontSize: 30),),
                                    SizedBox(height: 4,),
                                    Text("Select one of the options below to change your profile photo",style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 15),textAlign: TextAlign.start,),
                                    SizedBox(height: 25,),
                                    GestureDetector(
                                      onTap: (){
                                        PickImage(ImageSource.gallery);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: const Color.fromARGB(100, 200, 200, 200)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.photo,color: Colors.black,size: 60,),
                                            SizedBox(width: 20,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Gallery",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18)),
                                                SizedBox(height: 5,),
                                                Text("Pick photo from gallery",style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 15)),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30,),
                                    GestureDetector(
                                      onTap: (){
                                        PickImage(ImageSource.camera);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: const Color.fromARGB(100, 200, 200, 200)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.camera_alt_rounded,color: Colors.black,size: 60,),
                                            SizedBox(width: 20,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Camera",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18)),
                                                SizedBox(height: 5,),
                                                Text("Click photo using camera",
                                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 15)),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                          );
                        },
                        child: Text("Change Profile Photo",style:TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)
                            ),
                            backgroundColor: Colors.black87,
                            side: BorderSide(color: Colors.black54),
                            padding: EdgeInsets.symmetric(vertical: 14)
                        ),
                      ),
                    ),
                    SizedBox(width: 25,),
                  ],
                ),
                SizedBox(height: 10,),
                SizedBox(height: 10,),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 20,),
                              Icon(Icons.bubble_chart_outlined,color: Colors.black87,size: 20,),
                              SizedBox(width: 10,),
                              Text("Recent thought :",style:TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),)
                            ],
                          ),
                          SizedBox(height: 15,),
                          Container(
                            margin: EdgeInsets.only(left: 10,right: 10),
                            height: 100,
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                boxShadow:[
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                      color: Colors.grey.withOpacity(0.3)
                                  )
                                ]
                            ),
                            child: MarqueeWidget(
                              direction: Axis.vertical,
                              child: Text(
                                lastth,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                        ],
                      ),
                    ),
                  ),
                )
              ]
          )
      ),
    );
  }

  Widget getfriendsview(){
    focus.unfocus();
    return Expanded(
      child:  Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topRight:Radius.circular(20),bottomRight:Radius.circular(20)),
            boxShadow:[
              BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                  color: Colors.grey.withOpacity(0.3)
              )
            ],
            color: Colors.white,
          ),
          child: list.isEmpty ? Center(child: CircularProgressIndicator(color: Colors.black87,)) :
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 40,),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SizedBox(height: 15,),
                      Row(
                        children: [
                          SizedBox(width: 15,),
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
                          Text("Friends", style: TextStyle(color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 15,right: 15,top: 5,bottom: 5),
                              decoration: BoxDecoration(
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.search, color: Colors.black),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                      height: 35,// specify smaller padding
                                      child: TextField(
                                        focusNode: focus,
                                        controller: friendcontroller,
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
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  friendcontroller.text.isNotEmpty?
                                  GestureDetector(
                                    child: Icon(Icons.cancel, color: Colors.black87),
                                    onTap:(){
                                      friendcontroller.clear();
                                    },
                                  ):Container(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10,)
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:  GridView.builder(
                      padding: EdgeInsets.only(left: 10,right: 10),
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      itemCount: list.length,
                      itemBuilder: (context,index){
                        return GestureDetector(
                          onTap: (){
                            focus.unfocus();
                            Navigator.pushNamed(context,'userprofilepage',arguments: list[index].id);
                          },
                          child: Container(
                            //height: 100,
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
                                    child: Text("@"+list[index].name,style:TextStyle(color: Colors.black,fontSize:14,fontWeight: FontWeight.bold),)),
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ),
                SizedBox(height: 20,)
            ]
          )
      ),
    );
  }

  Widget getthoughtsview(){
    focus.unfocus();
    var database=FirebaseDatabase.instance;
    database.ref().keepSynced(true);
    return Expanded(
      child:  Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topRight:Radius.circular(20),bottomRight:Radius.circular(20)),
            boxShadow:[
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
            color: Colors.white,
          ),
          child: list.isEmpty ? Center(child: CircularProgressIndicator(color: Colors.black,)) :
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 40,),
                Row(
                    children: [
                      SizedBox(width: 20,),
                      Icon(Icons.bubble_chart,color: Colors.black,size: 40,),
                      SizedBox(width: 5,),
                      Text("Thoughts",style:TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),)
                    ],
                ),
                SizedBox(height: 20,),
                Expanded(
                  child: FirebaseAnimatedList(
                    physics: BouncingScrollPhysics(),
                    query: database.ref().child("Users").child(uid).child("Thoughts"),
                    itemBuilder: (context,snapshot,animation,index){
                      ThoughtModel thoughtModel=ThoughtModel.empty();
                      if (snapshot.value != null) {
                        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
                        thoughtModel.thought = data['thought'] ?? '';
                        thoughtModel.userid = data['userid'] ?? '';
                        thoughtModel.time = data['time'] ?? '';
                        thoughtModel.agree = data['agree'].toString() ?? '';
                        thoughtModel.sentiment = data['sentiment'].toString() ?? '';
                        thoughtModel.key = data['key'] ?? '';
                        thoughtModel.coor = (data['latitude'] ?? '0.00')+"&&"+(data['longitude']??'0.00');
                      }
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
                                GestureDetector(
                                  onTap:(){
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
                                                          'userid': uid,
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
                                                              uid).child(
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
                                )
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
                    padding: EdgeInsets.all(5),
                  ),
                ),
                SizedBox(height: 20,)
              ]
          )
      ),
    );
  }
}