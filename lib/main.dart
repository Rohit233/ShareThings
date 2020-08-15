import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharethings/ThemeChanger.dart';
import 'package:sharethings/config.dart';
import 'Screens/HomePage.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkTheme;
gettheme()async{
  final _preference=await SharedPreferences.getInstance();
 isDarkTheme= _preference.getBool("Dark");
 setState(() {

 });
}
  @override
  void initState() {
  isDarkTheme=false;
    gettheme();
    themeChanger.addListener(() {
      setState(() {
         isDarkTheme=!isDarkTheme;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Things',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        accentColor: Colors.blueGrey,


        buttonTheme: ButtonThemeData(
          splashColor: Colors.teal,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          buttonColor: Colors.blueGrey,
        ),

      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.tealAccent,
          splashColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12))
    ),
        )
      ),
      themeMode: isDarkTheme?ThemeMode.dark:ThemeMode.light,
      home: HomePage(),
    );
  }
}

