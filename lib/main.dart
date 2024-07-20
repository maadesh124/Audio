import 'package:a1/Player.dart';
import 'package:a1/listPage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    AudioPlayer player=AudioPlayer();
    double songDuration=0;

    return MaterialApp(home: Scaffold(body: ListPage(hindex: 2,),),);
  }
}


