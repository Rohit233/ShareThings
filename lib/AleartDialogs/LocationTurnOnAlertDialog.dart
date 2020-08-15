import 'dart:io';

import 'package:sharethings/Screens/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocationTurnOnAlertDialog  {
  static const platform=MethodChannel("Native.code/deviceList");
  BuildContext  context;
  dialog(context){
    this.context=context;
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
          if(this.context.widget.toString()!="HomePage") {
            Navigator.pushAndRemoveUntil(
             context, MaterialPageRoute(builder: (context) {
             return HomePage();
          }), (route) => false);

          }
          else{
            Navigator.pop(context);
          }
            },
          ),
        ],
      );
    },barrierDismissible: false);
  }
  dialogLocaionPermission(context){
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text("Location Permission"),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        actions: <Widget>[
          RaisedButton(
            child: Text("Allow"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))
            ),
            onPressed: ()async{
                Navigator.pop(context);
                await platform.invokeMethod("locationPermission");


            },
          ),
          RaisedButton(
            child: Text("Deny"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))
            ),
            onPressed: (){
              exit(0);
            },
          ),
        ],
      );
    },barrierDismissible: false);
  }




}



