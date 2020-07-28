import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class PlayVideo extends StatefulWidget {
  String path;
  PlayVideo(this.path);
  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  VideoPlayerController controller;
  @override
  void initState() {
    controller=VideoPlayerController.file(File.fromUri(Uri.parse(widget.path)));
    controller.initialize();
    controller.play();
    super.initState();
  }
  @override
  void dispose() {
    controller.pause();
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Stack(
            children: <Widget>[
              Center(
                child: AspectRatio(
                  aspectRatio:controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: (){
                    if(controller.value.isPlaying){
                      controller.pause();
                      setState(() {

                      });
                    }
                    else{
                      controller.play();
                      setState(() {

                      });
                    }
                  },
                  icon:!controller.value.isPlaying?Icon(Icons.play_circle_outline,size: 40.0,):Icon(Icons.pause,size: 40.0,),
                ),
              )



            ],
          ),
        ),
      ),
    );
  }
}


