import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
//import 'package:device_apps/device_apps.dart';
import 'package:sharethings/Screens/SendScreen.dart';
import 'package:flutter/services.dart';
import 'package:http_server/http_server.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../AleartDialogs/ErrorDialog.dart';
class test extends StatefulWidget {
  List files=List();
  String ip;
  List filesPath=List();
  test(this.files,this.ip,this.filesPath);

  @override
  _testState createState() => _testState(this.files,this.ip,this.filesPath);
}
class _testState extends State<test> {
  static const platform=MethodChannel("Native.code/SplitFiles");
  List files=List();
  Map<String,Map> packets = Map();
  String ip;
  List filesPath=List();
  static var server2;
  var server1;
  String applicationName;
  Isolate isolate;
  bool _running=false;
  bool isPacketMaking;
  ReceivePort _receiverPort;
  Capability  capability;
  Map<String,Map<String,int>> packetsDistribitionIp=Map<String,Map<String,int>>();
  int j = 1024*1024;
  int packetNo = 0;
  int i=0 ;
  File file;
  int packetsSize=1024*1024;
  var fileLength=0;
  _testState(this.files,this.ip,this.filesPath);
  sendFilesName()async{
    server1=await HttpServer.bind(ip, 8000);
    List filesName=List();
    Map fileSize=Map();
    Map<String,List> apkName=Map<String,List>();
    filesPath.forEach((f)async {
      int size=0;
      filesName.add(f);
      size=await File(f).length();
      fileSize.addAll({f:size});
    });
    files.forEach((element)async {
      try{
        if(element["Path"].toString().contains(".apk")){
          int size=0;
          apkName.addAll({element["Path"]:[element["name"]]});
          size=await File(element["Path"]).length();
          fileSize.addAll({element["Path"]:size});
        }
      }
      catch(e){

      }
    });
    await for(var request in server1){
      request.response..headers.contentType=new ContentType("application", "json")..write(jsonEncode({"file":filesName,"apkdetails":apkName,"Size":fileSize}))..close();
    }


  }


  connect()async {
    server2= await HttpServer.bind(ip, 8080);
    await for(HttpRequest request in server2){
      if (request.uri.toFilePath() != "/favicon.ico") {
        HttpConnectionInfo connectionInfo=request.connectionInfo;
        String ip=connectionInfo.remoteAddress.address;
        String filePath="";
        String packetInUrl=request.uri.toFilePath().split("/").last;
        List fp =request.uri.toFilePath().split("/");
        fp.remove( request.uri.toFilePath().split("/").last);
        fp.forEach((element) {
          if(fp.indexOf(element)!=fp.length-1) {
            filePath += element + '/';
          }
          else{
            filePath += element;
          }
        });
        if(!packetsDistribitionIp.containsKey(ip)){
          packetsDistribitionIp.addAll({ip:{"i":0,"j":packetsSize,"packetSum":0}});
        }
        Directory directory=await getExternalStorageDirectory();
//         if(packetInUrl=="Packet0") {
//           platform.invokeMethod(
//               "splitfiles", {"filepath": filePath, "dir": directory.path,"size":10});
//         }
//         VirtualDirectory staticFiles;
//         staticFiles = VirtualDirectory(".", pathPrefix: "..");
//         staticFiles.followLinks = true;
//         staticFiles.allowDirectoryListing = true;
////         print(File.fromUri(Uri.parse(directory.path +"/"+packetInUrl +" "+filePath
////             .split("/")
////             .last)).path);
//         await staticFiles.serveFile(
//             File.fromUri(Uri.parse(directory.path+"/"+ packetInUrl +" "+filePath
//                 .split("/")
//                 .last)), request);


//         print(File.fromUri(Uri.parse(filePath)).readAsBytesSync().buffer.asUint8List());
        if(packetInUrl=="Packet0" && await Directory(directory.parent.path+"/Packets/").exists()){
          List<FileSystemEntity> allFiles=  Directory(directory.parent.path+"/Packets/").listSync();
          allFiles.forEach((element) {
            element.delete(recursive: true);
          });
        }
//           if(!(await Directory(directory.parent.path+"/Packets/").exists())){
        Directory(directory.parent.path+"/Packets/").create(recursive: true).whenComplete(()async{
          try {
            List data=List();
            File(filePath).openRead(packetsDistribitionIp[ip]["i"],
                packetsDistribitionIp[ip]["j"]).listen((event) {
              data.addAll(event);
            }).onDone(() {
              File(directory.parent.path + "/Packets/" + ip +packetInUrl + " " + filePath
                  .split("/")
                  .last).writeAsBytes(List<int>.from(data)).whenComplete(()async{
                VirtualDirectory staticFiles;
                staticFiles = VirtualDirectory(".", pathPrefix: "..");
                staticFiles.followLinks = true;
                staticFiles.allowDirectoryListing = true;
                await staticFiles.serveFile(
                    File.fromUri(Uri.parse(directory.parent.path+"/Packets/"+ ip+packetInUrl +" "+filePath
                        .split("/")
                        .last)), request);
                //   if  its not work  deleted it
                if(packetInUrl!="Packet0" && await File(directory.parent.path + "/Packets/${ip}Packet" + (int.parse(packetInUrl.split("t").last)-1).toString() + " " + filePath
                    .split("/")
                    .last).exists()){
                  File(directory.parent.path + "/Packets/${ip}Packet" + (int.parse(packetInUrl.split("t").last)-1).toString() + " " + filePath
                      .split("/")
                      .last).delete(recursive: true);
                }
                packetsDistribitionIp.update(ip, (value)=>{"i":value['i']+packetsSize,"j":value["j"]+packetsSize,"packetSum":value["packetSum"]+0});
                //               if  its not work  deleted it
                fileLength+=await File(directory.parent.path+"/Packets/"+ip+packetInUrl +" "+filePath
                    .split("/")
                    .last).length();
                if(fileLength==await File(filePath).length()){
                  packetsDistribitionIp.addAll({ip:{"i":0,"j":packetsSize,"packetSum":0}});
                  fileLength=0;
                }
              });
            });
          }
          catch(e){
            List data=List();
            File(filePath).openRead(packetsDistribitionIp[ip]["i"],
                await File(filePath).length()).listen((event) {
              data.addAll(event);
            }).onDone(() {
              File(directory.parent.path + "/Packets/" +ip+packetInUrl + " " + filePath
                  .split("/")
                  .last).writeAsBytes(List<int>.from(data)).whenComplete(()async{
                VirtualDirectory staticFiles;
                staticFiles = VirtualDirectory(".", pathPrefix: "..");
                staticFiles.followLinks = true;
                staticFiles.allowDirectoryListing = true;
                await staticFiles.serveFile(
                    File.fromUri(Uri.parse(directory.parent.path+"/Packets/"+ip+packetInUrl +" "+filePath
                        .split("/")
                        .last)), request);
//               if  its not work  deleted it
                if(packetInUrl!="Packet0"){
                  File(directory.parent.path + "/Packets/${ip}Packet" + (int.parse(packetInUrl.split("t").last)-1).toString() + " " + filePath
                      .split("/")
                      .last).delete(recursive: true);
                }

                packetsDistribitionIp.update(ip, (value)=>{"i":value['i']+packetsSize,"j":value["j"]+packetsSize,"packetSum":value["packetSum"]+0});
                //               if  its not work  deleted it
                fileLength+=await File(directory.parent.path+"/Packets/"+ip+packetInUrl +" "+filePath
                    .split("/")
                    .last).length();
                if(fileLength==await File(filePath).length()){
                  packetsDistribitionIp.addAll({ip:{"i":0,"j":packetsSize,"packetSum":0}});
                  fileLength=0;
                }
              });
            });

          }
        });
//           }



//         try {
//          File(filePath)
//              .openRead(
//              packetsDistribitionIp[ip]["i"], packetsDistribitionIp[ip]['j'])
//              .listen((event) async {
//            if (await File(directory.path + packetInUrl + filePath
//                .split("/")
//                .last).exists()){
//                File(directory.path + packetInUrl + filePath
//                    .split("/")
//                    .last).writeAsBytesSync(
//                    event, mode: FileMode.append);
//            }
//            else {
//              File(directory.path + "/" + packetInUrl + " " + filePath
//                  .split("/")
//                  .last).writeAsBytesSync(
//                  event, mode: FileMode.append);
//
//
////           if(int.parse(packetInUrl.split("t").last)>0){
////             File(directory.path + "Packet"+(int.parse(packetInUrl.split("t").last)-1).toString() + filePath
////                 .split("/")
////                 .last).delete();
////           }
//            }
//          }).onDone(() async {
//              VirtualDirectory staticFiles;
//              staticFiles = VirtualDirectory(".", pathPrefix: "..");
//              staticFiles.followLinks = true;
//              staticFiles.allowDirectoryListing = true;
//              await staticFiles.serveFile(
//                  File(directory.path + "/" + packetInUrl + " " + filePath
//                  .split("/")
//                  .last), request);
//              fileLength =
//                  await File(directory.path + "/" + packetInUrl + " " + filePath
//                  .split("/")
//                  .last).length();
//              packetsDistribitionIp.update(ip, (value) =>
//              {
//                "i": value['i'] + packetsSize,
//                "j": value["j"] + packetsSize,
//                "packetSum": value["packetSum"] +
//                    fileLength
//              });
//
//
//          });
//        }catch(e){
//          File(filePath)
//              .openRead(
//              packetsDistribitionIp[ip]["i"], await File(filePath).length())
//              .listen((event) async {
//            if (await File(directory.path + packetInUrl + filePath
//                .split("/")
//                .last).exists()) {
//                File(directory.path + packetInUrl + filePath
//                    .split("/")
//                    .last).writeAsBytesSync(
//                    event, mode: FileMode.append);
//            }
//            else {
//              File(directory.path + "/" + packetInUrl + " " + filePath
//                  .split("/")
//                  .last).writeAsBytesSync(
//                  event, mode: FileMode.append);
////           if(int.parse(packetInUrl.split("t").last)>0){
////             File(directory.path + "Packet"+(int.parse(packetInUrl.split("t").last)-1).toString() + filePath
////                 .split("/")
////                 .last).delete();
////           }
//            }
//          }).onDone(() async {
//              VirtualDirectory staticFiles;
//              staticFiles = VirtualDirectory(".", pathPrefix: "..");
//              staticFiles.followLinks = true;
//              staticFiles.allowDirectoryListing = true;
//              await staticFiles.serveFile(
//                  File(directory.path + "/" + packetInUrl + " " + filePath
//                  .split("/")
//                  .last), request);
//              fileLength =
//                  await File(directory.path + "/" + packetInUrl + " " + filePath
//                  .split("/")
//                  .last).length();
//              packetsDistribitionIp.update(ip, (value) =>
//              {
//                "i": value['i'] + packetsSize,
//                "j": value["j"] + packetsSize,
//                "packetSum": value["packetSum"] +
//                    fileLength
//              });
//
//
//
//          });
//        }
//       if(fileLength==File(filePath).length()){
//         packetsDistribitionIp.addAll({ip:{"i":0,"j":packetsSize,"packetSum":0}});
//         fileLength=0;
//       }

//         print(packetInUrl);
//        createPackets(filePath,packetInUrl,ip).then((value){
//          request.response
//             ..headers.contentType = new ContentType("application", "json")
//             ..write(packets == null ? "downloadingDone" : jsonEncode(
//                 packets[filePath][packetInUrl]))
//             ..close();
//        });
//           File file= File("/storage/emulated/0/"+filePath.split("/").last);
//      await file.writeAsBytes(List<int>.from(packets[filePath][packetInUrl][0]),mode: FileMode.append).whenComplete((){
//        File("/storage/emulated/0/"+"Packet${(packetNo-1).toString()}").delete();
//      });

//           request.response
//             ..headers.contentType = new ContentType("application", "json")
//             ..write(packets == null ? "downloadingDone" :
//                 uint8list.sublist(packetsDistribitionIp[ip]["i"],packetsDistribitionIp[ip]["j"]))
//             ..close();





//      File file= File("/storage/emulated/0/"+request.uri.toFilePath().split("/").last);
//      await file.writeAsBytes(File.fromUri(Uri.parse(filePath)).readAsBytesSync());
//         int size=0;
//         for(var l in this.packets[filePath].values ){
//           size+=l[0].length;
//
//         }
//         print(size);

      }
    }




  }
  Future<Map> createPackets(String filePath,String packetInUrl,String ip) async{
//    for(var fp in filesPath ){
    Map packets=Map();
//      for (; i <j; i += 1000000) {
    List packet = List();
    if(packetInUrl=="Packet0") {
      file = File(filePath);
      fileLength=await file.length();
    }

    try {
      await File(filePath).openRead(packetsDistribitionIp[ip]['i'],
          packetsDistribitionIp[ip]['j']).forEach((element) {
        packet.addAll(element);
      });
    }
    catch(e){
      await File(filePath).openRead(packetsDistribitionIp[ip]['i'],fileLength ).forEach((element) {
        packet.addAll(element);
      });
    }
    packets = {packetInUrl: packet};
    this.packets = {filePath: packets};
    packetsDistribitionIp.update(ip, (value)=>{"i":value['i']+5000000,"j":value["j"]+5000000,"packetSum":value["packetSum"]+packet.length});
    if(fileLength==packetsDistribitionIp[ip]["packetSum"]){
      packetsDistribitionIp.update(ip, (value)=>{"i":0,"j":5000000,"packetSum":0});
    }

    return packets;



//      await  File(filePath).readAsBytes().asStream().listen((event) {
////        print(event.length);
//          if (event.length >= 1000000){
//            try {
//              packet.add(
//                  event.sublist(i, j));
//            }
//            catch(e){
//              try {
//                packet.add(
//                    event.sublist(i, event.length));
//              }
//              catch(e){
//                i=0;j=1000000;
//                packetNo=0;
//                packets=null;
//                this.packets=null;
//                return;
//              }
//            }
//            print(packet);
//            packets={packetInUrl: packet};
//            print(packets.keys);
//          }
//          else {
//            packets={packetInUrl: event};
//
//            print(packets["Packet0"].length);
//          }
//          packetNo++;
//          i+=1000000;
//          j+=1000000;
////      }
//          this.packets={filePath.toString():packets};
//          setState(() {
//            isPacketMaking=false;
//          });
//        });

//        Sync type
//       File file =File(filePath);
//        if (file.readAsBytesSync().length >= 1000000){
//          try {
//            packet.add(
//                file.readAsBytesSync().sublist(i, j));
//          }
//          catch(e){
//            try {
//              packet.add(
//                  file.readAsBytesSync().sublist(i, file.readAsBytesSync().length));
//            }
//            catch(e){
//              i=0;j=1000000;
//              packetNo=0;
//              packets=null;
//              this.packets=null;
//              return;
//            }
//          }
//          packets={packetInUrl: packet};
//          print(packets.keys);
//        }
//        else {
//          packets={packetInUrl: file.readAsBytesSync()};
//
//          print(packets["Packet0"].length);
//        }
//        packetNo++;
//        i+=1000000;
//        j+=1000000;
////      }
//      this.packets={file.path.toString():packets};
//
  }
//  }


  @override
  void initState() {
    isPacketMaking=false;
//    _start();
//      createPackets().whenComplete((){
//
//      });
    sendFilesName();
    connect();


    super.initState();
  }
  @override
  void dispose() {
    server1.close();
    server2.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: ()async{
       Dialogs().OnBackPressWarning(context);
        return true;
      },
      child: Scaffold(

        body: SafeArea(
          child: Container(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Center(
                  child: Text("Files"),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: filesPath.length,
                      itemBuilder: (BuildContext context, i) {
                        if (filesPath[i].toString().contains(".apk") &&
                            files[i].runtimeType.toString() != "_File") {
                          applicationName = files[i]['name'];
                        }
                        int fileSize=File(filesPath[i].toString()).lengthSync();
                        return ListTile(
                          leading: filesPath[i].toString().contains(".apk") &&
                              files[i].runtimeType.toString() != "_File" ? Image
                              .memory(files[i]["logo"], height: 30, width: 30,) :
                          filesPath[i].contains(".jpg") ||
                              filesPath[i].contains(".png") ||
                              filesPath[i].contains(".jpeg") ||
                              filesPath[i].contains(".svg")
                              ?
                          Icon(Icons.image, size: 30, color: Colors.blueGrey,)
                              : filesPath[i].toString().contains(".mp4") ? Icon(
                            Icons.videocam, size: 30, color: Colors.blueGrey,) :
                          filesPath[i].toString().contains(".pdf") ? Icon(Icons
                              .picture_as_pdf, size: 30, color: Colors
                              .blueGrey,) :
                          filesPath[i].toString().contains(".mp3") ? Icon(Icons
                              .music_note, size: 30, color: Colors.blueGrey,) :
                          Icon(Icons.insert_drive_file, size: 30,
                              color: Colors.blueGrey),
                          title: filesPath[i].toString().contains(".apk") &&
                              files[i].runtimeType.toString() != "_File" ? Text(
                              applicationName) :
                          Text(filesPath[i]
                              .toString()
                              .split("/")
                              .last),
                          trailing: Text(int.parse((fileSize/1000000).toString().split(".").first)>1000?
                          (fileSize/1000000000).toString().substring(0,fileSize.toString().length-3)+" GB"
                              :fileSize<1000000?(fileSize/1000).toString()+"KB":(fileSize/1000000).toString().substring(0,fileSize.toString().length-3)
                              +" MB"),
                        );
                      }
                  ),
                ),
                Container(
//                  color: Colors.white,
                  child: Center(
                    child: QrImage(
                      data: ip,
                      version: QrVersions.auto,
                      gapless: true,
                      size: 200,
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),

      ),
    );
  }
}

