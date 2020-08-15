import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

//import 'package:device_apps/device_apps.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:sharethings/AleartDialogs/ErrorDialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
class ViewFilesReceiver extends StatefulWidget {
  String ip;
  ViewFilesReceiver(this.ip);

  @override
  _ViewFilesReceiverState createState() => _ViewFilesReceiverState(this.ip);
}

class _ViewFilesReceiverState extends State<ViewFilesReceiver> {
  String ip;
  List listFilesPath = List();
  Map<dynamic, dynamic> apkDetails = Map();
  Map<String, Map> fileDetails = Map();
  List<Map> filesName = List<Map>();
  List<Map> apkIcons = List<Map>();
  Map fileSize = Map();

  _ViewFilesReceiverState(this.ip);

  Directory directory;
  int countDownloadedFile;
  int packetNo = 0;
  int fileSaveAfter;
  Directory createdDir;
  List packetsData = List();
  var _downloadData = List<int>();

  getfilesPath() async {
    var url = "http://" + ip + ":8000";
    var response = await http.get(Uri.parse(url));
    listFilesPath = jsonDecode(response.body)["file"];
    apkDetails = jsonDecode(response.body)['apkdetails'];
    fileSize = jsonDecode(response.body)["Size"];
    setState(() {
      listFilesPath.forEach((element) {
        fileDetails.addAll({
          element: {
            "fileSize": fileSize[element],
            "fileName": element.toString().contains(".apk")
                ? apkDetails[element][0]
                : element
                .toString()
                .split("/")
                .last,
            "downloaded": 0
          }
        });
      });
    });
    getfiles();
  }

  hitUrl(Directory createdDir) async {

    var url = "http://" + ip + ":8080" + listFilesPath[countDownloadedFile] +
        "/Packet${packetNo}";
    HttpClient client = HttpClient();
    client.getUrl(Uri.parse(url)).then((HttpClientRequest request) =>
        request.close()
    ).then((HttpClientResponse response) {
      if (listFilesPath[countDownloadedFile].contains(".jpg") ||
          listFilesPath[countDownloadedFile].contains(".png")
          || listFilesPath[countDownloadedFile].contains(".jpeg")
          || listFilesPath[countDownloadedFile].contains("svg")) {
        var _downloadData = List<int>();
        response.listen((event) {
          setState(() {
            fileDetails[listFilesPath[countDownloadedFile]].update(
                "downloaded", (value) => value += event.length);
          });
          _downloadData.addAll(event);
        }).onDone(() {
          File(createdDir.path + "/Photos/" + listFilesPath[countDownloadedFile]
              .toString()
              .split("/")
              .last).writeAsBytesSync(
              _downloadData, mode: FileMode.append);
          if (fileDetails[listFilesPath[countDownloadedFile]]["downloaded"] ==
              fileDetails[listFilesPath[countDownloadedFile]]["fileSize"]) {
//                for(int i=0;i<=packetNo;i++) {
//                 File(createdDir.path + "/Others/" +i.toString()+listFilesPath[countDownloadedFile].toString().split("/").last)
//                  .openRead(0,await File(createdDir.path + "/Others/" +i.toString()+listFilesPath[countDownloadedFile].toString().split("/").last).length())
//                  .listen((event) {
//
//            }).onData((data) {
//                   File(createdDir.path + "/Others/" +
//                       listFilesPath[countDownloadedFile]
//                           .toString()
//                           .split("/")
//                           .last).writeAsBytes(data,mode: FileMode.append);
//                 });
//
//                }
            countDownloadedFile++;
            packetNo = 0;
            getfiles();
          }
          else {
            packetNo++;
            getfiles();
          }


//          File(createdDir.path + "/Photos/" +listFilesPath[countDownloadedFile].toString().split("/").last).writeAsBytes(
//              _downloadData).whenComplete(() {
//            countDownloadedFile++;
//            getfiles();
//          });
        });
      }
      else if (listFilesPath[countDownloadedFile].toString().contains(".apk")) {
        response.listen((event) async {
          setState(() {
            fileDetails[listFilesPath[countDownloadedFile]].update(
                "downloaded", (value) => value += event.length);
          });
          _downloadData.addAll(event);
        }).onDone(() async {
          if (_downloadData.length >= fileSaveAfter) {
            File(createdDir.path + "/Apk/" +
                apkDetails[listFilesPath[countDownloadedFile]][0] + ".apk")
                .writeAsBytesSync(
                _downloadData, mode: FileMode.append);
            _downloadData = [];
            fileSaveAfter += 10000000;
          }
          if (fileDetails[listFilesPath[countDownloadedFile]]["downloaded"] ==
              fileDetails[listFilesPath[countDownloadedFile]]["fileSize"]) {
            File(createdDir.path + "/Apk/" +
                apkDetails[listFilesPath[countDownloadedFile]][0] + ".apk")
                .writeAsBytesSync(
                _downloadData, mode: FileMode.append);
//                for(int i=0;i<=packetNo;i++) {
//                 File(createdDir.path + "/Others/" +i.toString()+listFilesPath[countDownloadedFile].toString().split("/").last)
//                  .openRead(0,await File(createdDir.path + "/Others/" +i.toString()+listFilesPath[countDownloadedFile].toString().split("/").last).length())
//                  .listen((event) {
//
//            }).onData((data) {
//                   File(createdDir.path + "/Others/" +
//                       listFilesPath[countDownloadedFile]
//                           .toString()
//                           .split("/")
//                           .last).writeAsBytes(data,mode: FileMode.append);
//                 });
//
//                }
            countDownloadedFile++;
            _downloadData = [];
            fileSaveAfter = 10000000;
            packetNo = 0;
            getfiles();
          }
          else {
            packetNo++;
            getfiles();
          }
        });
      }
      else {
//        var _downloadData = List<int>();

        response.listen((event) async {
          setState(() {
            fileDetails[listFilesPath[countDownloadedFile]].update(
                "downloaded", (value) => value += event.length);
          });
          _downloadData.addAll(event);
        }).onDone(() async {
          if (this._downloadData.length >= fileSaveAfter) {
            File(createdDir.path + "/Others/" +
                listFilesPath[countDownloadedFile]
                    .toString()
                    .split("/")
                    .last)
                .writeAsBytesSync(
                this._downloadData, mode: FileMode.append);
            this._downloadData = [];
            fileSaveAfter += 10000000;
          }
          if (fileDetails[listFilesPath[countDownloadedFile]]["downloaded"] ==
              fileDetails[listFilesPath[countDownloadedFile]]["fileSize"]) {
            File(createdDir.path + "/Others/" +
                listFilesPath[countDownloadedFile]
                    .toString()
                    .split("/")
                    .last)
                .writeAsBytesSync(
                this._downloadData, mode: FileMode.append);
//                for(int i=0;i<=packetNo;i++) {
//                 File(createdDir.path + "/Others/" +i.toString()+listFilesPath[countDownloadedFile].toString().split("/").last)
//                  .openRead(0,await File(createdDir.path + "/Others/" +i.toString()+listFilesPath[countDownloadedFile].toString().split("/").last).length())
//                  .listen((event) {
//
//            }).onData((data) {
//                   File(createdDir.path + "/Others/" +
//                       listFilesPath[countDownloadedFile]
//                           .toString()
//                           .split("/")
//                           .last).writeAsBytes(data,mode: FileMode.append);
//                 });
//
//                }
            countDownloadedFile++;
            this._downloadData = [];
            fileSaveAfter = 10000000;
            packetNo = 0;
            getfiles();
          }
          else {
            packetNo++;
            getfiles();
          }


//          File(createdDir.path + "/Others/" +listFilesPath[countDownloadedFile].toString().split("/").last).writeAsBytesSync(
//              _downloadData,mode: FileMode.append);
//          if (fileDetails[listFilesPath[countDownloadedFile]]["downloaded"] ==
//              fileDetails[listFilesPath[countDownloadedFile]]["fileSize"]){
////                for(int i=0;i<=packetNo;i++) {
////                 File(createdDir.path + "/Others/" +i.toString()+listFilesPath[countDownloadedFile].toString().split("/").last)
////                  .openRead(0,await File(createdDir.path + "/Others/" +i.toString()+listFilesPath[countDownloadedFile].toString().split("/").last).length())
////                  .listen((event) {
////
////            }).onData((data) {
////                   File(createdDir.path + "/Others/" +
////                       listFilesPath[countDownloadedFile]
////                           .toString()
////                           .split("/")
////                           .last).writeAsBytes(data,mode: FileMode.append);
////                 });
////
////                }
//            countDownloadedFile++;
//            packetNo=0;
//            getfiles();
//          }
//          else{
//            packetNo++;
//            getfiles();
//          }


        });
//          response.pipe(File(
//              createdDir.path + "/Others/" + listFilesPath[countDownloadedFile]
//                  .split("/")
//                  .last).openWrite());
      }
    });
//
//      Using Http module
//    http.get(Uri.parse(url)).asStream().listen((value){
//      setState((){
//        fileDetails[listFilesPath[countDownloadedFile]].update("downloaded", (values) => values+jsonDecode(value.body).length);
//      });
//      packetsData.addAll(jsonDecode(value.body));
//      String storePath;
//      if(listFilesPath[countDownloadedFile].contains(".jpg") ||
//          listFilesPath[countDownloadedFile].contains(".png")
//          || listFilesPath[countDownloadedFile].contains(".jpeg")
//          || listFilesPath[countDownloadedFile].contains("svg")){
//        storePath="/Photos/";
//      }
//      else if(listFilesPath[countDownloadedFile].toString().contains(".apk")){
//        storePath="/Apk/";
//      }
//      else{
//        storePath='/Others/';
//      }
//
//     if(packetsData.length>fileSaveAfter ||fileDetails[listFilesPath[countDownloadedFile]]['fileSize']<2000000) {
//       File(
//          listFilesPath[countDownloadedFile].toString().contains(".apk")?
//          createdDir.path + storePath + fileDetails[listFilesPath[countDownloadedFile]]["fileName"]
//              .toString()+".apk"
//              :createdDir.path + storePath + fileDetails[listFilesPath[countDownloadedFile]]["fileName"]
//               .toString())
//           .writeAsBytes(List<int>.from(packetsData), mode: FileMode.append)
//           .whenComplete(() {
//         if (fileDetails[listFilesPath[countDownloadedFile]]["downloaded"] ==
//             fileDetails[listFilesPath[countDownloadedFile]]["fileSize"]) {
//           countDownloadedFile++;
//           packetNo = 0;
//           fileSaveAfter=20;
//           getfiles();
//         }
//         else {
//           packetNo++;
//           fileSaveAfter+=20;
//           getfiles();
//         }
//       });
//       packetsData=[];
//
//     }
//     else{
//       if (fileDetails[listFilesPath[countDownloadedFile]]["downloaded"] ==
//           fileDetails[listFilesPath[countDownloadedFile]]["fileSize"]) {
//         File(
//             listFilesPath[countDownloadedFile].toString().contains(".apk")?
//             createdDir.path + storePath + fileDetails[listFilesPath[countDownloadedFile]]["fileName"]
//                 .toString()+".apk"
//                 : createdDir.path + storePath +
//                 fileDetails[listFilesPath[countDownloadedFile]]["fileName"])
//             .writeAsBytes(List<int>.from(packetsData), mode: FileMode.append);
//         countDownloadedFile++;
//         packetNo = 0;
//         fileSaveAfter=20;
//         packetsData=[];
//         getfiles();
//       }
//       else {
//         packetNo++;
//         getfiles();
//       }
//     }
//    });

//    http.get(Uri.parse(url)).asStream().listen((event) {
//      setState(() {
//        fileDetails[listFilesPath[countDownloadedFile]].update("downloaded", (value) => value+jsonDecode(event.body).length);
//      });
//      packetsData.addAll(jsonDecode(event.body));
//      print(fileDetails[listFilesPath[countDownloadedFile]]["downloaded"]);
//    }).onDone(()async {
//      File(
//          createdDir.path + "/Others/" + listFilesPath[countDownloadedFile]
//              .toString()
//              .split("/")
//              .last)
//          .writeAsBytes(List<int>.from(packetsData),mode: FileMode.append)
//          .whenComplete(() {
//        if (fileDetails[listFilesPath[countDownloadedFile]]["downloaded"] ==
//            fileDetails[listFilesPath[countDownloadedFile]]["fileSize"]) {
//          countDownloadedFile++;
//          packetNo = 0;
//          getfiles();
//        }
//        else {
//          packetNo++;
//          getfiles();
//        }
//      });
//    });
}
  getfiles()async{
    if(countDownloadedFile<listFilesPath.length) {
      var dir = await getExternalStorageDirectory();
      if(packetNo==0) {
        createdDir  = await Directory(
            (dir.parent.parent.parent.parent).path + "/Share Things").create(
            recursive: true);
        await Directory(
            (dir.parent.parent.parent.parent).path + "/Share Things/Photos")
            .create(recursive: true);
        await Directory((dir.parent.parent.parent.parent).path + "/Share Things/Apk")
            .create(recursive: true);
        await Directory(
            (dir.parent.parent.parent.parent).path + "/Share Things/Others")
            .create(recursive: true);
      }
      hitUrl(createdDir);


//      File(createdDir.path+"/Others/"+listFilesPath[countDownloadedFile].toString().split("/").last);


      //      HttpClient client = new HttpClient();
////    for(var i in listFilesPath) {
//      var url = "http://" + ip + ":8080" + listFilesPath[countDownloadedFile];
//      client.getUrl(Uri.parse(url)).then((HttpClientRequest request) =>
//          request.close()
//      ).then((HttpClientResponse response) {
//        if (listFilesPath[countDownloadedFile].contains(".jpg") ||
//            listFilesPath[countDownloadedFile].contains(".png")
//            || listFilesPath[countDownloadedFile].contains(".jpeg")
//            || listFilesPath[countDownloadedFile].contains("svg")) {
//
//           setState(() {
//             fileDetails.addAll({listFilesPath[countDownloadedFile]: {"fileSize":response.contentLength,
//               "fileName":listFilesPath[countDownloadedFile].toString(),"downloaded": 0}});
//           });
//
//
//          int downloadingProg = 0;
//          var _downloadData = List<int>();
//          response.listen((event) {
//            setState(() {
//              fileDetails[listFilesPath[countDownloadedFile]].update(
//                  "downloaded", (value) => downloadingProg += event.length);
//            });
//
//            _downloadData.addAll(event);
//          }).onDone(() {
//            File(createdDir.path + "/Photos/" +listFilesPath[countDownloadedFile].toString().split("/").last).writeAsBytes(
//                _downloadData).whenComplete(() {
//              countDownloadedFile++;
//              getfiles();
//            });
//          });
//
////          response.pipe(new File(
////              createdDir.path + "/Photos/" + listFilesPath[countDownloadedFile]
////                  .split("/")
////                  .last).openWrite());
//        }
//        else if (listFilesPath[countDownloadedFile].contains(".apk")) {
//          if (apkDetails.isNotEmpty) {
//            String apkName;
//            apkDetails.forEach((element) {
//              try {
//                apkName = element[listFilesPath[countDownloadedFile]][0];
//                setState(() {
//                  fileDetails.addAll(({
//                    listFilesPath[countDownloadedFile]: {"fileSize": response
//                        .contentLength, "downloaded": 0,
//                      "fileName": apkName}
//                  }));
//                });
//              }
//              catch (e) {}
//            });
//
//            int downloadingProg = 0;
//            var _downloadData = List<int>();
//            response.listen((event) {
//              setState(() {
//                fileDetails[listFilesPath[countDownloadedFile]].update(
//                    "downloaded", (value) => downloadingProg += event.length);
//              });
//
//              _downloadData.addAll(event);
//            }).onDone(() {
//              File(createdDir.path + "/Apk/" + apkName + ".apk").writeAsBytes(
//                  _downloadData).whenComplete(() {
//                countDownloadedFile++;
//                getfiles();
//              });
//            });
////              response.pipe(File(createdDir.path + "/Apk/" + apkName + ".apk")
////                  .openWrite());
//
//
//          }
//          else {
//            response.transform(utf8.decoder).listen((event) {
//              int downloadingProg = 0;
//              print(downloadingProg += event.length);
//            });
//            response.pipe(File(
//                createdDir.path + "/Apk/" + listFilesPath[countDownloadedFile]
//                    .split("/")
//                    .last).openWrite());
//          }
//        }
//        else {
//          setState(() {
//            fileDetails.addAll({listFilesPath[countDownloadedFile]: {"fileSize":response.contentLength,
//              "fileName":listFilesPath[countDownloadedFile].toString(),"downloaded": 0}});
//          });
//
//          int downloadingProg = 0;
//          var _downloadData = List<int>();
//          response.listen((event) async {
//          downloadingProg+= await compute(_downloadedFiles,event);
//            setState(() {
//              fileDetails[listFilesPath[countDownloadedFile]].update(
//                  "downloaded", (value) => downloadingProg);
//            });
//
//            _downloadData.addAll(event);
//          }).onDone(() {
//            File(createdDir.path + "/Others/" +listFilesPath[countDownloadedFile].toString().split("/").last).writeAsBytes(
//                _downloadData).whenComplete(() {
//              countDownloadedFile++;
//              getfiles();
//            });
//          });
////          response.pipe(File(
////              createdDir.path + "/Others/" + listFilesPath[countDownloadedFile]
////                  .split("/")
////                  .last).openWrite());
//        }
//      });
//    }
    }
  }
  @override
  void initState(){
    countDownloadedFile=0;
    fileSaveAfter=10000000;
    getfilesPath();

    super.initState();
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
          child: listFilesPath.isEmpty?Center(
            child: CircularProgressIndicator(),
          ):Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: listFilesPath.length,
                    itemBuilder:(BuildContext,i){
                      String fileName;
                      double fileSize;
                      int downloaded;
//              print(fileDetails.indexOf({listFilesPath[1]:[]}));
//                  fileDetails.forEach((element) {
//                    try{
//                      print(element);
//                      print(element[listFilesPath[i]]);
//                      fileSize=element[listFilesPath[i][3]["fileSize"]];
//                      fileName=element[listFilesPath[i][2]["fileName"]];
//                    downloaded= element[listFilesPath[i]][1]["downloaded"];
//
//                    }
//                    catch(e){
//
//                    }
//                  });
                      return ListTile(
                        onTap: ()async{
                          var dir = await getExternalStorageDirectory();
                          if(listFilesPath[i].toString().contains(".apk")){
                            OpenFile.open((dir.parent.parent.parent.parent).path +"/Share Things/Apk/"+fileDetails[listFilesPath[i]]["fileName"].toString()+".apk");
                          }
                          else if(listFilesPath[i].contains(".jpg") || listFilesPath[i].toString().contains(".jpeg")
                          ||listFilesPath[i].toString().contains(".svg") || listFilesPath[i].toString().contains(".png")
                          ){
                            OpenFile.open((dir.parent.parent.parent.parent).path +"/Share Things/Photos/"+fileDetails[listFilesPath[i]]["fileName"].toString());
                          }
                          else{
                            OpenFile.open((dir.parent.parent.parent.parent).path +"/Share Things/Others/"+fileDetails[listFilesPath[i]]["fileName"].toString());
                          }

                        },
                        title: Text(fileDetails[listFilesPath[i]]["fileName"].toString()),
                        leading:listFilesPath[i].toString().contains(".apk")?Icon(Icons.android):Icon(Icons.insert_drive_file),
                        trailing:fileDetails[listFilesPath[i]]["downloaded"]==fileDetails[listFilesPath[i]]["fileSize"]?Icon(Icons.check_circle):null,
                        subtitle: Row(
                          children: <Widget>[
                            Text(fileDetails[listFilesPath[i]]['fileSize']<=999999?(fileDetails[listFilesPath[i]]["fileSize"]/1000).toString()+" KB/":fileDetails[listFilesPath[i]]['downloaded']<1000000000?(fileDetails[listFilesPath[i]]["downloaded"]/1000000).toString()+" MB"+"/":

                            (fileDetails[listFilesPath[i]]["downloaded"]/1000000).toString()+" GB"+"/"
                            ),
                            Text(fileDetails[listFilesPath[i]]["fileSize"]>1000000?(fileDetails[listFilesPath[i]]["fileSize"]/1000000).toString()+" MB":
                            (fileDetails[listFilesPath[i]]["fileSize"]/1000).toString()+" KB"
                            ),
                          ],
                        ),
                      );
                    },


                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
