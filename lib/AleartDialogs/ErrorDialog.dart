
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class Dialogs{
  static const platformForConnectivity=MethodChannel("Native.code/wifi");
  showDialogWifi(BuildContext context){
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text("Turn on wifi"),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        actions: <Widget>[
          RaisedButton(
            onPressed: (){
              Navigator.pop(context);
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            child: Text("Ok"),
          )
        ],
      );
    });
  }

  showHotspotWarning(BuildContext context){
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text("Turn on Hotspot"),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        actions: <Widget>[
          RaisedButton(
            onPressed: (){
              Navigator.pop(context);
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            child: Text("Ok"),
          )
        ],
      );
    });
  }

   OnBackPressWarning(context){
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text("Are you sure to cancel file transferring"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        actions: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))
            ),
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("No"),
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))
            ),
            onPressed: (){
              Navigator.pop(context);
              Navigator.pop(context);

            },
            child: Text("Yes"),
          ),
        ],

      );
    });
  }

  hotspotCloseWarning(context){
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text("Are you sure to close Hotspot"),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        actions: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))
            ),
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("No"),
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))
            ),
            onPressed: ()async{
              await platformForConnectivity.invokeMethod("HotspotOff");
              Navigator.pop(context);
              Navigator.pop(context);

            },
            child: Text("Yes"),
          ),
        ],

      );
    });
  }

}