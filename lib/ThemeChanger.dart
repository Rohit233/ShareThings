import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ThemeChanger with ChangeNotifier{
  static bool _isDarkTheme=false;
  Future getThemeDetailFromSharePreference()async{
    final _preference=await SharedPreferences.getInstance();
    if(_preference.containsKey("Dark")) {
      _isDarkTheme = _preference.getBool("Dark");
    }
    else{
      _preference.setBool("Dark", _isDarkTheme);
    }
  }
  ThemeMode themeMode(){
    getThemeDetailFromSharePreference();
      return _isDarkTheme?ThemeMode.dark:ThemeMode.light;



  }
  void switchTheme()async{
    _isDarkTheme=!_isDarkTheme;
    final _preference=await SharedPreferences.getInstance();
    _preference.setBool("Dark", _isDarkTheme).whenComplete((){
      notifyListeners();
    });


  }
}