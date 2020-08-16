import 'dart:async';
import 'dart:io';
import 'package:sharethings/AleartDialogs/ErrorDialog.dart';
import 'package:sharethings/AleartDialogs/ImageShowDialog.dart';
import 'package:sharethings/AleartDialogs/LocationTurnOnAlertDialog.dart';
import 'package:sharethings/Screens/PlayVideo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:device_apps/device_apps.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sharethings/config.dart';
import 'package:video_player/video_player.dart';
import 'test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_multimedia_picker/data/MediaFile.dart';
import 'package:flutter_multimedia_picker/fullter_multimedia_picker.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
class SendScreen extends StatefulWidget {

  @override
  _SendScreenState createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen>with SingleTickerProviderStateMixin {

  List selectToShare=List();
  List selectedPath=List();
  List selectedImagesPath=List();
  List<MediaFile> selectedImages=List<MediaFile>();

  TabController _tabController;
  ValueNotifier<int> indexTab;
  Directory changeDirectory;
  List listDirectories=List();
  List files=List();
  String directoryPath;
  String IP;
  static const platformForLocation=const MethodChannel("Native.code/deviceList");
  static const platformForHotspot=const MethodChannel("Native.code/wifi");
  ValueNotifier<String> notifierImageThumbnail=ValueNotifier<String>("");
  ValueNotifier<String> notifierVideoThumbnail=ValueNotifier<String>("");
  static const platform=MethodChannel("Native.code/GetMedia");
  static const platformForConnectivity=const MethodChannel("Native.code/wifi");
  static List<MediaFile> images=List<MediaFile>();

  Future <List>getApps()async{
     return await platform.invokeMethod("getAllApps");
//      installApps=await DeviceApps.getInstalledApplications(includeAppIcons: true,includeSystemApps: true,onlyAppsWithLaunchIntent: true);

  }
// Padding(
// padding: const EdgeInsets.all(8.0),
// child: Center(
// child: Container(
// height: 160,
// decoration: BoxDecoration(
// shape: BoxShape.rectangle,
// color: Colors.blueGrey,
// border: Border.all(color: Colors.black),
// borderRadius: BorderRadius.all(Radius.circular(15.0))
// ),
// padding: EdgeInsets.all(20.0),
// child: Center(
// child: Text(
// "Please Turn on Data for geting Ip address of your Mobile and restart app(Only one Time)"
// ),
// ),
// ),
// ),
// )
  Future getIpAddress()async{
      for(var interface in await NetworkInterface.list()){
      if(interface.name.contains("wlan")){
      IP= interface.addresses[0].address;
      break;
      }
      }
//      print(IP);
  }
  @override
  void initState(){
//      getIpAddress();
    indexTab=ValueNotifier<int>(0);
    Timer(Duration(seconds: 2),(){
      if(installApps.isEmpty) {
        getApps().then((value) {
          setState(() {
            installApps = value;
          });
        });

      }
      if(listImages.isEmpty) {
        _getAllPhotos().whenComplete(() {
          setState(() {

          });
        });
      }
      if(videos.isEmpty) {
        _getAllVideos().whenComplete(() {
          setState(() {

          });
        });
      }
    });

    _setpathForDirectory();
    _tabController=TabController(
        length: 4,
        initialIndex: 0,
        vsync: this
    );
    _tabController.addListener(()async{

      indexTab.value=_tabController.index;

      if(_tabController.index==2){


      }
      else if(_tabController.index==3){

      }
      else if(_tabController.index==1){
        setState(() {

        });
      }
    });
    super.initState();
  }

  NativeCodeHotspot()async{
    try {
      if (!(await platformForLocation.invokeMethod("checkLocationPermission"))){
        if(await platformForLocation.invokeMethod("checkLocationOn")){
          await platformForHotspot.invokeMethod("Hotspot").then((value){
            if (value != null){
              Map hotspotDetails=value;
              var wifiip;
              if(!hotspotDetails.containsKey("IP")) {
                getIpAddress().whenComplete(()async{
                  wifiip = IP;
                  if(wifiip==null){
                    wifiip=await platformForHotspot.invokeMethod("GetIp");
                  }
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) {
                    return test(selectToShare, wifiip, selectedPath, value);
                  }));
                });
              }
              else{
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return test(selectToShare,hotspotDetails["IP"],selectedPath,value);
                }));
              }

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


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
//        Dialogs dialogs=Dialogs();
//        dialogs.hotspotCloseWarning(context);

        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text("Share Things"),
            leading: ValueListenableBuilder(
              valueListenable: indexTab,
              builder: (BuildContext context,int text,Widget value){
                return  text==3? IconButton(
                  icon: Icon((Icons.arrow_back),
                  ),
                  onPressed: ()async{
                    if(directoryPath!="/storage"){
                      directoryPath=Directory(directoryPath).parent.path.toString();
                      files.clear();
                      listDirectories=await _directories();
                      setState(() {

                      });
                    }
                    else if(directoryPath=="/storage/emulated/0"){
                      setState(()async{
                        directoryPath="/storage";
                        files.clear();
                        listDirectories=await _directories();
                        setState((){

                        });
                      });
                    }
                  },
                ):Container();
              },

            ),
            actions: <Widget>[
              IconButton(
                onPressed: selectedPath.isNotEmpty?()async{
                  NativeCodeHotspot();
//                  var wifiip;
//                  if(IP!=null){
//                    wifiip=IP;
//                    Navigator.push(context, MaterialPageRoute(builder: (context){
//                      return test(selectToShare,wifiip,selectedPath);
//                    }));
//                  }
//                  else{
//                    getIpAddress().whenComplete((){
//                      Navigator.push(context, MaterialPageRoute(builder: (context){
//                        wifiip=IP;
//                        return test(selectToShare,wifiip,selectedPath);
//                      }));
//                    });
//
//                  }

                }:null,
                iconSize: 30,
                splashColor: Colors.blueAccent,
                icon: Stack(
                  children: <Widget>[
                    Icon(Icons.send,color: selectedPath.isNotEmpty?Colors.teal:Colors.grey,),
                    selectedPath.isNotEmpty? Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeChanger.themeMode()==ThemeMode.dark?Colors.blueGrey:Colors.black26,
                        ),
                        child: Center(
                          child: Text( selectedPath.length>=10000?"10000+":selectedPath.length.toString(),
                            style: TextStyle(
                              fontSize: selectedPath.length>=100 && selectedPath.length<1000?10:selectedPath.length>=1000 &&
                                  selectedPath.length<10000 ?7:
                              selectedPath.length>=10000?5:null,
                            ),
                          ),
                        ),
                      ),
                    ):Container()
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: TabBar(
            controller: _tabController,
            unselectedLabelColor: themeChanger.themeMode()==ThemeMode.dark?Colors.white:Colors.black,
            labelColor: Colors.teal,
            indicatorWeight: 2.0,
            indicatorColor: Colors.blueGrey,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.android),
                child: Text("Apk",
                  style: TextStyle(
                      fontSize: 10.0
                  ),
                ),

              ),
              Tab(
                icon: Icon(Icons.image),
                child: Text("Photos",
                  style: TextStyle(
                      fontSize: 10.0
                  ),
                ),
              ),
              Tab(
                icon: Icon(Icons.videocam),
                child: Text("Videos",
                  style: TextStyle(
                      fontSize: 10.0
                  ),
                ),
              ),
              Tab(
                icon: Icon(Icons.folder),
                child: Text("Files",
                  style: TextStyle(
                      fontSize: 10.0
                  ),
                ),
              )
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              ShowApk(),
              ShowPhotos(),
              showVideos(),
              showFiles(),
            ],
          )
      ),
    );
  }




  // Get All Photos
  Future _getAllPhotos()async{
    List<MediaFile> images1;
//    try {
//      images1 = await FlutterMultiMediaPicker.getImage();
//         images1.forEach((f)async{
//     imageThumbnail.add(await FlutterMultiMediaPicker.getThumbnail(fileId: f.id, type: f.type));
//   });
//
//     images=images1;
//    }
//    catch(e){
    List listImagesBeforeShowing=List();
    await platform.invokeMethod("Photos").then((value){
      listImages.addAll(value);
      if(imageThumbnail.isEmpty) {
        listImages.forEach((element) async {
//         imageThumbnail.add(await FlutterMultiMediaPicker.getThumbnail(fileId: element["id"], type: MediaType.IMAGE));
          notifierImageThumbnail.value =
          await FlutterMultiMediaPicker.getThumbnail(
              fileId: element["id"], type: MediaType.IMAGE).whenComplete(() {

          });
          imageThumbnail.add(notifierImageThumbnail.value);
        });
      }
    });

//    }

  }


// Get All Videos
  Future _getAllVideos()async {
//     try {
//       await FlutterMultiMediaPicker.getVideo().then((value){
//         videos=value;
//         videos.forEach((element)async{
//           notifierVideoThumbnail.value=await FlutterMultiMediaPicker.getThumbnail(fileId:element.id , type: element.type);
//           videosThumbnail.add(notifierVideoThumbnail.value);
//         });
//       });

////
////       print(videosThumbnail.length);
//     } catch (e) {


   await platform.invokeMethod("Videos").then((value)async {
     videos.addAll(value);
     if (videosThumbnail.isEmpty){
       for (int i = 0; i < videos.length; i++) {
         if ((await getTemporaryDirectory())
             .listSync()
             .isNotEmpty) {
           if (!(File.fromUri(Uri.parse(
               (await getTemporaryDirectory()).path + "/" + videos[i]["Path"]
                   .toString()
                   .split("/")
                   .last
                   .split(".")
                   .first + ".jpg")).existsSync())) {
             notifierVideoThumbnail.value = await VideoThumbnail.thumbnailFile(
                 video: File
                     .fromUri(Uri.parse(videos[i]["Path"]))
                     .path,
                 thumbnailPath: (await getTemporaryDirectory()).path,
                 imageFormat: ImageFormat.JPEG,
                 maxHeight: 50,
                 quality: 100
             );
             videosThumbnail.add(
                 notifierVideoThumbnail.value
             );
           }
           else {
             notifierVideoThumbnail.value =
                 (await getTemporaryDirectory()).path + "/" + videos[i]["Path"]
                     .toString()
                     .split("/")
                     .last
                     .split(".")
                     .first + ".jpg";
             videosThumbnail.add(notifierVideoThumbnail.value);
           }
         }
         else {
           notifierVideoThumbnail.value = await VideoThumbnail.thumbnailFile(
               video: File
                   .fromUri(Uri.parse(videos[i]["Path"]))
                   .path,
               thumbnailPath: (await getTemporaryDirectory()).path,
               imageFormat: ImageFormat.JPEG,
               maxHeight: 500,
               quality: 50
           );
           videosThumbnail.add(
               notifierVideoThumbnail.value
           );
         }
       }
   }
    });


//    notifierVideoThumbnail.value = await FlutterMultiMediaPicker.getThumbnail(
//        fileId: videos[0]["id"], type: MediaType.VIDEO);
//    videosThumbnail.add(notifierVideoThumbnail.value);
//    int nextVideo=1;
//    for(int i=0;i<nextVideo;i++){
//      if(i<videos.length){
//
//        notifierVideoThumbnail.value = await FlutterMultiMediaPicker.getThumbnail(
//            fileId: videos[i]["id"], type: MediaType.VIDEO).whenComplete((){
//        });
//        videosThumbnail.add(notifierVideoThumbnail.value);
//        nextVideo++;
//      }
//    }




//     }

  }



  _setpathForDirectory()async{
    Directory directory=await getExternalStorageDirectory();
    directoryPath=(directory.parent.parent.parent.parent).path;
    listDirectories= await _directories();
  }

  Future<List> _directories()async{
    if(directoryPath=="/storage/emulated"){
      changeDirectory=Directory(directoryPath+"/0");
    }
    else{
      changeDirectory=Directory(directoryPath);
    }
    List files=await FileManager.listDirectories(changeDirectory,excludeHidden: true);
    List<File> files1= await FileManager.listFiles(changeDirectory.path);
    this.files = files1;
    return files;
  }

//  Show Files
  Widget showFiles(){
    return Container(
      child:
      listDirectories!=null? (listDirectories.isEmpty) && files.isEmpty?Center(
        child: Text("Nothing Found"),
      ): ListView.builder(
        itemCount: listDirectories.length+files.length,
        itemBuilder: (context,i){
          return ListTile(
              leading: i<listDirectories.length ?Container(
                  child: Icon(Icons.folder,color:Colors.blueAccent,size: 30,)
              ):
              Icon(files[i-listDirectories.length].path.toString().contains(".apk")?Icons.android:Icons.insert_drive_file,
                size: 30,
              ),
              title:
              Container(
                child:  i<listDirectories.length?Text(
                    directoryPath!="/storage"? listDirectories[i].path.toString().split("/").last:"Storage"+(i+1).toString()
                ):files.isNotEmpty?Container(
                  child: Text(files[i-listDirectories.length].path.toString().split("/").last,
                  ),
                )
                    : Center(
                  child: Text("Nothing Found"),
                ),
              ),
              onTap: ()async{
                if(i<listDirectories.length) {
                  directoryPath = listDirectories[i].path;
                  files.clear();
                  listDirectories=await _directories();
                  setState(() {

                  });

                }
                else{
                  if(selectedPath.contains(files[i-listDirectories.length].path)) {
                    setState(() {
                      selectToShare.remove(files[i -listDirectories.length]);
                      selectedPath.remove(files[i-listDirectories.length].path);
                    });

                  }
                  else{
                    setState(() {
                      selectToShare.add(files[i-listDirectories.length]);
                      selectedPath.add(files[i-listDirectories.length].path);
                    });

                  }
                }

              },
              trailing:(i<listDirectories.length)? null
                  :Icon(selectedPath.contains(files[i-listDirectories.length].path)? Icons.check_circle:null,color: Colors.blueAccent,)


          );
        },

      ):Center(
        child: Text("Nothing Found"),
      ),




    );


  }

  //ShowVideos
  Widget showVideos(){
        return ValueListenableBuilder(
          valueListenable: notifierVideoThumbnail,
          builder: (BuildContext context,String path,Widget w){
            return Container(
              child:videos.isEmpty?Center(
                child: Text("No Videos Found"),
              ):Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GridView.builder(
                        gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            childAspectRatio: 0.5
                        ),
                        itemCount: videos.length,
                        itemBuilder: (BuildContext context,i){
                          return GestureDetector(
                            onTap: (){
                              if(selectToShare.contains(videos[i])){
                                setState(() {
                                  selectToShare.remove(videos[i]);
                                  selectedPath.remove(videos[i]["Path"]);
                                });

                              }
                              else{
                                setState(() {
                                  selectToShare.add(videos[i]);
                                  selectedPath.add(videos[i]["Path"]);
                                });

                              }
                            },
                            onLongPress: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return PlayVideo(
                                    videos[i]["Path"]
                                );
                              }));
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(selectToShare.contains(videos[i])?20:12)),
                                  border: Border.all(color:selectToShare.contains(videos[i])?Colors.teal:themeChanger.themeMode()==ThemeMode.dark?Colors.white60:Colors.black,
                                      width: selectToShare.contains(videos[i])?2.5:1
                                  )
                              ),
                              child: videosThumbnail.length>i? Image.file(File.fromUri(Uri.parse(videosThumbnail[i])),
                                fit: BoxFit.cover,
                              ):Container(),
                            ),
                          );
                        }
                    ),
                  ),
                ],
              ),

            );
          },

        );







  }
  //ShowPhotos
  Widget ShowPhotos(){
    return
      ValueListenableBuilder(
        valueListenable: notifierImageThumbnail,
        builder: (BuildContext context,String path,Widget w){
          return Container(
            child:(images.isEmpty && listImages.isEmpty)?Center(
              child: Container(
                child: Text("No Photos Found"),
              ),
            ):imageThumbnail.isEmpty?Center(
              child: Container(
                child:CircularProgressIndicator(
                  valueColor:AlwaysStoppedAnimation(themeChanger.themeMode()==ThemeMode.dark?Colors.white70:Colors.black),
                  strokeWidth: 1.50,
                ),
              ),
            ):Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                      gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          childAspectRatio: 0.5
                      ),
                      itemCount: images.isNotEmpty?images.length:imageThumbnail.length,
                      itemBuilder: (BuildContext context,i){
                        return images.isNotEmpty? GestureDetector(
                          onTap: (){
                            if(selectToShare.contains(images[i])){
                              setState(() {
                                selectToShare.remove(images[i]);
                                selectedPath.remove(images[i].path);
                              });

                            }
                            else{
                              setState(() {
                                selectToShare.add(images[i]);
                                selectedPath.add(images[i].path);
                              });

                            }
                          },
                          onLongPress: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return ImageShowDialog(images[i].path);
                            }));

                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(!selectToShare.contains(images[i])?12:20)),
                                border: Border.all(color:selectToShare.contains(images[i])?Colors.teal:Colors.black,
                                    width: selectToShare.contains(images[i])?2.5:1
                                )
                            ),
                            child: Image.file(File.fromUri(Uri.parse(imageThumbnail[i])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ):GestureDetector(
                          onTap: (){
                            if(selectToShare.contains(listImages[i])){
                              setState(() {
                                selectToShare.remove(listImages[i]);
                                selectedPath.remove(listImages[i]["Path"]);
                              });

                            }
                            else{
                              setState(() {
                                selectToShare.add(listImages[i]);
                                selectedPath.add(listImages[i]["Path"]);
                              });

                            }
                          },
                          onLongPress: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return  ImageShowDialog(listImages[i]["Path"]);
                            }));

                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(!selectToShare.contains(listImages[i])?12:20)),
                                border: Border.all(color:selectToShare.contains(listImages[i])?Colors.teal:themeChanger.themeMode()==ThemeMode.dark?Colors.white60:Colors.black,
                                    width: selectToShare.contains(listImages[i])?2.5:1
                                )
                            ),
                            child: Image.file(File.fromUri(Uri.parse(imageThumbnail[i])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                  ),
                ),


              ],
            ),

          );
        },

      );

  }
  // ShowApk
  Widget ShowApk(){
    return   SafeArea(
      child: Container(
        padding: EdgeInsets.all(15),
        child:installApps.isEmpty?Center(
          child: Container(
            child:CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(themeChanger.themeMode()==ThemeMode.dark?Colors.white70:Colors.black),
              strokeWidth: 1.50,
            ),
          ),
        ):
        Stack(
          children: <Widget>[
            GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 0.52,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 20
                ),
                itemCount: installApps.length,
                itemBuilder:(BuildContext context,i){

//                  Application apps;
//                  if(installApps.isNotEmpty){
//                    apps=installApps[i];
//                  }
                  return
                    GestureDetector(
                      onTap: (){
                        if(selectToShare.contains(installApps[i])){
                          setState(() {
                            selectToShare.remove(installApps[i]);
                            selectedPath.remove(installApps[i]["Path"]);
                          });

                        }
                        else{
                          setState(() {
                            selectToShare.add(installApps[i]);
                            selectedPath.add(installApps[i]["Path"]);
                          });

                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius:BorderRadius.all(Radius.circular(12)),
                          color: selectToShare.contains(installApps[i])?Colors.teal:Colors.blueGrey,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.memory(installApps[i]["logo"],height: 30,width: 30,),
                            Padding(
                              padding: const EdgeInsets.only(top:8.0),
                              child: Center(
                                child: Text(installApps[i]["name"].length<14?installApps[i]["name"]:installApps[i]["name"].substring(0,11)+"....",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                }
            ),
          ],
        ),
      ),
    );
  }
}
