import 'dart:collection';
import 'dart:io';
import 'package:sharethings/AleartDialogs/LocationTurnOnAlertDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sharethings/Screens/listOfUserInAndroid10.dart';
import 'package:sharethings/config.dart';
import 'ViewFilesReceiver.dart';
//import 'package:wifi/wifi.dart';
import 'package:qrscan/qrscan.dart' as scanner;
class ListOfUser extends StatefulWidget {
  @override
  _ListOfUserState createState() => _ListOfUserState();
}

class _ListOfUserState extends State<ListOfUser> {
  var wifiBSSID;
  var wifiIP;
  var wifiName;
  bool wait,isConnected;
  String connectedWifiSSID="";
  TextEditingController passwordController=TextEditingController();
  List listWifi=List();
  String sdk;
  RefreshController _refreshController=RefreshController();
  RefreshController _refreshController1=RefreshController();
  static const platform=MethodChannel("Native.code/deviceList");

  Future getPermission()async{
    try{
      bool permission= await platform.invokeMethod("locationPermission");
      if(permission){
        LocationTurnOnAlertDialog().dialog(context);
      }
    }
    on PlatformException catch(e){

    }
  }

  Future getDetails()async{
//    Connectivity().onConnectivityChanged.listen((ConnectivityResult result){

//    });
//   print(await(Connectivity().checkConnectivity()));
//    wifiBSSID=await Wifi.ssid;
//    wifiIP=await Wifi.ip;
//    listWifi=await Wifi.list("").catchError((onError){
//      print(onError);
//    });

    try{
      sdk= await platform.invokeMethod("GetAndroidVersion");
       listWifi=await platform.invokeMethod("deviceList");
    }
    on PlatformException catch(e){
      print("failed");
    }
    setState(() {


    });
  }
  onRefresh()async{
    getPermission();
    NativeCodeGetConnectionInfo();
    try{

      listWifi=await platform.invokeMethod("deviceList");
      print(await platform.invokeMethod("deviceList"));
      _refreshController.refreshCompleted();
      _refreshController1.refreshCompleted();
    }
    on PlatformException catch(e){
      _refreshController.refreshCompleted();
      _refreshController1.refreshCompleted();

      print("failed");
    }
//    listWifi=await Wifi.list("").then((onValue){
//        _refreshController.refreshCompleted();
//      }).catchError((onError){
//        print(onError);
//
//    });

  }

  NativeCodeGetConnectionInfo()async{
    try{
//     <unknown ssid>
      connectedWifiSSID=await platform.invokeMethod("ConnectedDeviceInfo");
      if(connectedWifiSSID=="<unknown ssid>"){
        connectedWifiSSID="";
        isConnected=false;
      }else{
        isConnected=true;
      }
      setState(() {

      });
    } on PlatformException catch(e){
      print("failed");
    }
  }
  @override
  void initState() {
    wait=false;
    isConnected=false;
    getPermission();
    getDetails();
    NativeCodeGetConnectionInfo();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: isConnected?()async{
            String ip=await scanner.scan();
            if(ip!=null){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return ViewFilesReceiver(ip);
              }));
            }
          }:()async{
           await platform.invokeMethod("CheckConnectivityOfWifiOnScanQrCodePress");
          },
           backgroundColor: !isConnected && themeChanger.themeMode()==ThemeMode.dark?Colors.white:
           !isConnected && themeChanger.themeMode()==ThemeMode.light?Colors.black26:null,
          child: Text("ScanCode",
          style: TextStyle(
            fontSize: 10.0
          ),
          )
        ),
        body:wait?Center(child: CircularProgressIndicator()): SmartRefresher(
          controller:  _refreshController1,
          header: WaterDropMaterialHeader(),
          onRefresh:(){
            onRefresh();
          },
          child: SafeArea(
            child: SmartRefresher(
              controller:  _refreshController,
              header: WaterDropMaterialHeader(),
              onRefresh:(){
                onRefresh();
              },
              child:listOfUserAndroid10().view(connectedWifiSSID)
//              listWifi.isEmpty?Center(
//                child: Text("No wifi connection found"),
//              ): ListView.builder(
//                    itemCount: listWifi.length,
//                    itemBuilder: (context,i){
//                      return Padding(
//                          padding: const EdgeInsets.all(8.0),
//                            child: Column(
//                              children: <Widget>[
//                                ListTile(
//                                  title: Text((i+1).toString()+". "+listWifi[i]["ssid"],style:TextStyle(
//                                      fontSize: 25
//                                  ),
//                                  ),
//                                  trailing: connectedWifiSSID=='"'+listWifi[i]['ssid']+'"'?Icon(Icons.check_circle):null,
//                                onTap:(){
//                                  connectedWifiSSID!='"'+listWifi[i]['ssid']+'"'?PasswordEnterDialog(listWifi[i]["ssid"]):null;
//                                },
//                                ),
//                                Divider(),
//                              ],
//                            ),
//
//                        );
//
//                    },
//                  ),

            ),
          ),
        )
    );
  }
  PasswordEnterDialog(String ssid){
    return showDialog(context: context,builder: (context){
      return Stack(
        children: <Widget>[
          AlertDialog(
            title: Text("Enter Password For "+ssid),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller:passwordController,
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))
            ),
            actions: <Widget>[
              RaisedButton(
                onPressed: (){

                  connectNetwork(ssid,passwordController.text);
                },
                child: Text("Confirm"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              )
            ],
          ),
        ],

      );
    });
  }

  Future connectNetwork(String ssid,String password)async {
    Navigator.pop(context);
    setState(() {
      wait=true;
    });
    try {
      await platform.invokeMethod(
          "ConnectToDevice", {"ssid": ssid.trim(), "password": password.trim()}).then((
          value) {
            print(value);
        wait = false;
        isConnected = true;
        NativeCodeGetConnectionInfo();
        setState(() {

        });
      });
    }
    on PlatformException catch(e){
      print(e.details);
    }

//    await Wifi.connection(ssid, password);

  }
  errorDialog(){

    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text("Wrong password"),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        actions: <Widget>[
          RaisedButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("Try again"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))
            ),
          )
        ],
      );
    });
  }
}
