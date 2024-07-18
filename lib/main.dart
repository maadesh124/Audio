import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: HomeScreen(),),);
  }
}



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(child: Container(width: 100,height: 50,color: Colors.blue,),onTap: onPressed,);
  }




  void onPressed() async
{
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
}
}