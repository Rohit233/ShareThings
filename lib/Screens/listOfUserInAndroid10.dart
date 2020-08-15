import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config.dart';
class listOfUserAndroid10{
static const platform=MethodChannel("Native.code/deviceList");


 Widget view(String connectedWifiSSID){
    return  Container(
      child:  Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              ListTile(
                title: connectedWifiSSID==""? Text("Not Connected with wifi network"):Text(connectedWifiSSID.substring(1,connectedWifiSSID.length-1),style:TextStyle(
                    fontSize: 25
                ),
                ),
                trailing: connectedWifiSSID==""?null:Icon(Icons.check_circle),
              ),
              Divider(),
            ],
          ),
          RaisedButton(
            child: Text("Connect To Wifi Networks",
              style: TextStyle(
                color: themeChanger.themeMode()==ThemeMode.dark?Colors.black:Colors.white
              ),
            ),
            onPressed: (){
             platform.invokeMethod("ConnectToDevice");
            },

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))
            ),
          )
        ],
      ),

    );
  }

}