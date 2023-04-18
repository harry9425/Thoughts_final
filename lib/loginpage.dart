import 'package:dummy_firebase/registerdetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Signuppage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  var auth=FirebaseAuth.instance;
  var key=GlobalKey<FormState>();
  var emailcontroller=TextEditingController();
  var passwordcontroller=TextEditingController();
  var done=false;
  var clicked=false;

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image(image: AssetImage('assets/images/loginpagelogo.png'),height: size*0.25,),
                  Positioned(
                    child:
                    done?SpinKitPouringHourGlass(
                      size: 80,
                      color:  Colors.black87,
                    ):SpinKitPianoWave(
                      size: 80,
                      color:  Colors.black87,
                    ),
                  ),
                ],
              ),
              Text("Welcome Back",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800,fontSize: 30),),
              SizedBox(height: 4,),
              Text(done?"Signing In......":"Share your mind, connect with kind.",style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 18),textAlign: TextAlign.start,),
              SizedBox(height: 5,),
              Form(
                  key : key,
                  child:Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: emailcontroller,
                          validator: (value){
                            if(value!.isEmpty || !RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value.trim())){
                              return "Enter Correct email";
                            }
                            else return null;
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.account_circle,color: Colors.grey,),
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
                          controller: passwordcontroller,
                          validator: (value){
                            value=value!.trim();
                            if(value!.isEmpty || value!.length<6){
                              return "Password length must be atleast 6.";
                            }
                            else return null;
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.fingerprint,color: Colors.grey,),
                              suffix: GestureDetector(onTap:(){setState(() {
                                clicked!=clicked;
                              });},child: Icon(Icons.remove_red_eye,color: Colors.grey,)),
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
                      ],
                    ),
                  )
              ),
              SizedBox(height: 2,),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
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
                                Text("Select one of the options below to reset your password!",style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 15),textAlign: TextAlign.start,),
                                SizedBox(height: 25,),
                                GestureDetector(
                                  onTap: (){},
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color.fromARGB(100, 200, 200, 200)
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.email_outlined,color: Colors.black,size: 60,),
                                        SizedBox(width: 20,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("E-mail",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18)),
                                            SizedBox(height: 5,),
                                            Text("Reset password via E-mail",style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 15)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30,),
                                GestureDetector(
                                  onTap: ()=>{},
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: const Color.fromARGB(100, 200, 200, 200)
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.phone_android_outlined,color: Colors.black,size: 60,),
                                        SizedBox(width: 20,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Phone",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18)),
                                            SizedBox(height: 5,),
                                            Text("Reset password via OTP",
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
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.grey),
                    child: Text("Forget Password ?",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)
                ),
              ),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){
                       if(!(key.currentState!.validate())) {
                        Fluttertoast.showToast(msg: "Fields can't be empty..",backgroundColor: Colors.red);
                       }
                       else{
                         signinuserwithemailandpass(emailcontroller.text, passwordcontroller.text);
                       }
                    },
                    child: Text("Login",style:TextStyle(color: Colors.white),),
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
                        MaterialPageRoute(builder: (_) => SignUpPage()),
                      )
                    },
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.grey),
                    child: Text("Don't have and Account? SignUp",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future signinuserwithemailandpass(String email,String pass) async{
    setState(() {
      done=true;
    });
    Fluttertoast.showToast(msg: "Signing in...",backgroundColor: Colors.black87);
    try{
      await auth.signInWithEmailAndPassword(email:email.trim(), password: pass.trim()).then((value) async {
        await Future.delayed(Duration(milliseconds: 1000));
        setState(() {
          done=false;
        });
        Fluttertoast.showToast(msg: "Welcome Back",backgroundColor: Colors.green);
        Navigator.pushNamedAndRemoveUntil(
            (context), 'home', (route) => false);
      });
    } on FirebaseAuthException catch(e){
      Fluttertoast.showToast(msg: "Sign In Failed..",backgroundColor: Colors.red);
      setState(() {
        done=false;
      });
    }
    catch(_){
      Fluttertoast.showToast(msg: "Error Occured..",backgroundColor: Colors.red);
      setState(() {
        done=false;
      });
    }
  }
}
