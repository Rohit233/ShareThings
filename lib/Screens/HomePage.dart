import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharethings/AleartDialogs/ErrorDialog.dart';
import 'package:sharethings/AleartDialogs/LocationTurnOnAlertDialog.dart';
import 'package:sharethings/Screens/SendScreen.dart';
import 'package:sharethings/Screens/listOfUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharethings/config.dart';
//import 'package:wifi/wifi.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
String IP;
class _HomePageState extends State<HomePage> {
  static const platform=const MethodChannel("Native.code/wifi");
  static const platformForLocation=const MethodChannel("Native.code/deviceList");
  String sdk;
  bool isWifiOn;
  Map hotspotDetails=Map();
  Future<void> NativeCodeWifiTurnOn()async{
    try{
     if(await platform.invokeMethod("wifiOn")){
       Navigator.push(context, MaterialPageRoute(builder: (context){
         return ListOfUser();
       }));
     }

    }on PlatformException catch(e){
      print("failed");
    }
  }
  Future NativeCodeToCheckWifiIsOn()async{
    try{

        isWifiOn =await platform.invokeMethod("checkWifi");
        if(isWifiOn){
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return ListOfUser();
          }));
        }
        else{
          Dialogs dialogs=Dialogs();
          dialogs.showDialogWifi(context);
        }


    }
    catch(e){

    }
  }
  Future getIpAddress()async{
    for(var interface in await NetworkInterface.list()){
      if(interface.name.contains("wlan")){
        IP= interface.addresses[0].address;
        break;
      }
    }
    print(IP);
  }
  NativeCodeHotspot()async{
     if(int.parse(await platformForLocation.invokeMethod("GetAndroidVersion"))<=25){
       try {
         if (!(await platformForLocation.invokeMethod("checkLocationPermission"))){
           if(await platformForLocation.invokeMethod("checkLocationOn")){
             await platform.invokeMethod("Hotspot").then((value){
               if (value != null){
                 var wifiip;
                 getIpAddress().whenComplete((){
                   wifiip=IP;
                   Navigator.push(
                       context, MaterialPageRoute(builder: (context) {
                     return SendScreen();
                   }));

                 });

//
               }
             });

           }
           else{
             LocationTurnOnAlertDialog locationTurnOnAlertDialog=LocationTurnOnAlertDialog();
             locationTurnOnAlertDialog.dialog(context);
           }
         }
         else{
           await platformForLocation.invokeMethod("locationPermission");
         }

       }on PlatformException catch(e){
         print("failed");
       }
     }
     else {
//    try {
//      if (!(await platformForLocation.invokeMethod("checkLocationPermission"))){
//        if(await platformForLocation.invokeMethod("checkLocationOn")){
//     await platform.invokeMethod("Hotspot").then((value){
//       if (value != null){
       if (await platformForLocation.invokeMethod("checkLocationOn")) {
         Navigator.push(context, MaterialPageRoute(builder: (context) {
           return SendScreen();
         }));
       }
       else {
         LocationTurnOnAlertDialog locationTurnOnAlertDialog = LocationTurnOnAlertDialog();
         locationTurnOnAlertDialog.dialog(context);
       }
//       }
//      });

//      }
//        else{
//         LocationTurnOnAlertDialog locationTurnOnAlertDialog=LocationTurnOnAlertDialog();
//         locationTurnOnAlertDialog.dialog(context);
//        }
//    }
//      else{
//       await platformForLocation.invokeMethod("locationPermission");
//      }
//
//    }on PlatformException catch(e){
//      print("failed");
//    }
     }
  }
  locationMissingCode()async{
    if(await platformForLocation.invokeMethod("checkLocationPermission")) {
      LocationTurnOnAlertDialog locationTurnOnAlertDialog = LocationTurnOnAlertDialog();
      locationTurnOnAlertDialog.dialogLocaionPermission(context);
    }
  }

  @override
  void initState() {

    locationMissingCode();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share Things"),
        actions: <Widget>[
          IconButton(
            splashColor: Colors.blueAccent,
            icon:themeChanger.themeMode()==ThemeMode.light?Icon(Icons.brightness_3):Icon(Icons.wb_sunny) ,
            onPressed:(){
              themeChanger.switchTheme();
            },
          )

        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: (){
                  platform.invokeMethod("motorVibrate");
                  NativeCodeHotspot();
                },
                child: Text("Send",
                style: TextStyle(
                  color: themeChanger.themeMode()==ThemeMode.dark?Colors.black:Colors.white
                ),
                ),
              ),
              RaisedButton(
                onPressed: (){
                  platform.invokeMethod("motorVibrate");
                  NativeCodeWifiTurnOn();

                },

                child: Text("Receive",
                style: TextStyle(
                  color: themeChanger.themeMode()==ThemeMode.dark?Colors.black:Colors.white
                ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
