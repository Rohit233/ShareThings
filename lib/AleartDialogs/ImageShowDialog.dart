import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ImageShowDialog extends StatefulWidget {
  String path;
  ImageShowDialog(this.path);
  @override
  _ImageShowDialogState createState() => _ImageShowDialogState();
}

class _ImageShowDialogState extends State<ImageShowDialog> with TickerProviderStateMixin {
  Animation animationRadius,sizeAnimation,colorAnimation;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController=AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 50000)
    );
    animationRadius=BorderRadiusTween(
      begin: BorderRadius.all(Radius.circular(0.0)),
      end: BorderRadius.all(Radius.circular(15.0)),
    ).animate(CurvedAnimation(
        curve: Curves.ease,parent: _animationController
    ));
    sizeAnimation=Tween(
        begin: 0.0,
        end: 2.0
    ).animate(
        CurvedAnimation(
            curve: Curves.ease,
            parent: _animationController
        )
    );
    colorAnimation=ColorTween(
      begin: Colors.black,
      end: Colors.red,
    ).animate(
        CurvedAnimation(
            curve: Curves.ease,parent: _animationController
        )
    );

    super.initState();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return
      Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.file(
              File.fromUri(Uri.parse(widget.path)),
              fit: BoxFit.fitHeight,
            ),

          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
            child: GestureDetector(
              onHorizontalDragEnd: (value){
                Navigator.pop(context);
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius:BorderRadius.all(Radius.circular(15.0))
                ),
                content: SingleChildScrollView(
                  child: Image.file(File.fromUri(Uri.parse(widget.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],

      );



  }
}


