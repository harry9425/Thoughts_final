import 'package:dummy_firebase/Signuppage.dart';
import 'package:dummy_firebase/Welcomescreen.dart';
import 'package:dummy_firebase/accounts_editpage.dart';
import 'package:dummy_firebase/allthoughtspage.dart';
import 'package:dummy_firebase/homepage_viewScreens/AllChatsPage.dart';
import 'package:dummy_firebase/homepage_viewScreens/addthoughtpage.dart';
import 'package:dummy_firebase/homepage_viewScreens/alluserspage.dart';
import 'package:dummy_firebase/homepage.dart';
import 'package:dummy_firebase/homepage_viewScreens/friendspage.dart';
import 'package:dummy_firebase/requestPage.dart';
import 'package:dummy_firebase/userchatpage.dart';
import 'package:dummy_firebase/loginpage.dart';
import 'package:dummy_firebase/splashscreen.dart';
import 'package:dummy_firebase/splashscreen.dart';
import 'package:dummy_firebase/userprofilepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //darkTheme: ThemeData(brightness: Brightness.dark),
     // themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: 'splash',
      routes: {
        'userprofilepage':(context) =>UserProfilePage(),
        'splash': (context) =>SplashScreen(),
        'account_edit':(context) =>AccountsEditPage(),
        'userchat': (context) =>UserChatPage(),
        'friends': (context) =>FriendsPage(),
        'allchat': (context) =>AllChatPage(),
        'allusers': (context) =>AllUsersPage(),
        'home':(context) =>HomePage(),
        'addthought':(context)=>AddThoughtsPage(),
        'login':(context) =>LoginPage(),
        'requestpage':(context) =>RequestPage(),
        'signup':(context)=>SignUpPage(),
        'welcome':(context)=>WelcomePage(),
        'allthoughts':(context)=>allThoughtsPage(),
      },
    );
  }
}
