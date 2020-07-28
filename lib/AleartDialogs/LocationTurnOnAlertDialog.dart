import 'package:sharethings/Screens/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocationTurnOnAlertDialog  {
  static const platform=MethodChannel("Native.code/deviceList");
  dialog(context){
    showDialog(context: context,builder: (context){
      return AlertDialog(
      title: Text("Turn On Location"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        actions: <Widget>[
          RaisedButton(
            child: Text("TurnOn"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))
            ),
            onPressed: ()async{
              Navigator.pop(context);
              await platform.invokeMethod("TurnOnLocation");

            },
          ),
          RaisedButton(
            child: Text("cancle"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))
            ),
            onPressed: (){
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                return HomePage();
              }), (route) => false);
            },
          ),
        ],
      );
    },barrierDismissible: false);
  }


}



