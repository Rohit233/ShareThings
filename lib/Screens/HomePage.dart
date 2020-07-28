import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharethings/AleartDialogs/ErrorDialog.dart';
import 'package:sharethings/Screens/SendScreen.dart';
import 'package:sharethings/Screens/listOfUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:wifi/wifi.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
String IP;
class _HomePageState extends State<HomePage> {
  static const platform=const MethodChannel("Native.code/wifi");
  bool isWifiOn,isHotspotOn;
  Future<void> NativeCodeWifiTurnOn()async{
    try{
      print(await platform.invokeMethod("wifiOn"));

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
  NativeCodeHotspot()async{
    try{
      isHotspotOn= await platform.invokeMethod("Hotspot");
      if(isHotspotOn){
        Navigator.push(context, MaterialPageRoute(builder:(context){
          return SendScreen();
        }));
      }
      else{
        Dialogs dialogs=Dialogs();
        dialogs.showHotspotWarning(context);
      }
    }on PlatformException catch(e){
      print("failed");
    }
  }
  @override
  void initState() {
    NativeCodeWifiTurnOn();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: (){
                  NativeCodeHotspot();
                },
                child: Text("Send"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))
                ),
              ),
              RaisedButton(
                onPressed: (){
                  NativeCodeToCheckWifiIsOn();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))
                ),
                child: Text("Receive"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
