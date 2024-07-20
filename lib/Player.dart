import 'package:a1/listPage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Player extends StatefulWidget {
  Audio audio;
   Player({super.key,required this.audio});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  Widget build(BuildContext context) {
    final sw=MediaQuery.of(context).size.width;
    return MaterialApp(home: Scaffold(body:Container(
      width: sw*0.95,
    ) ),);
  }
}


class Controls extends StatefulWidget {


  Controls({super.key});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {

  AudioPlayer player=  AudioPlayer();
  double sliderPos=0;
  double sliderMax=0;
  bool isPlaying=false;

  @override
  void initState()
  {
  super.initState();
  String url='https://www2.cs.uic.edu/~i101/SoundFiles/BabyElephantWalk60.wav';
   player.setUrl(url).then((duration)
   {
    sliderMax=duration!.inMilliseconds+0.0;
   });
  player.positionStream.listen((duration)
  {
    setState(() {
      sliderPos=duration.inMilliseconds+0.0;
    });
  });
  }

  void onClickPause()
  {
    if(isPlaying)
    player.pause();
    else
    player.play();
    setState(() {
        isPlaying=!isPlaying;
      });
  }

  void onClickNext()
  {

  }

  void onClickPrevious()
  {

  }

  void onSliderChange(val)
  {
      print(val);
      setState(()
     {
      player.seek(Duration(milliseconds: val.toInt()));
      sliderPos=val;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw=MediaQuery.of(context).size.width;
    return Container(width:0.95*sw ,height: 400,color: Colors.red,
    child: Column( children: [Container(width: 0.7*sw,
    height: 100,color: Colors.blue,
    child: Row(children: [
      IconButton(icon:Icon(Icons.skip_previous_rounded,size: 60,color: Colors.black,),
      onPressed: onClickPrevious,),
      Spacer(flex:1),
      IconButton(onPressed: onClickPause, icon:Icon(isPlaying?Icons.pause_rounded:Icons.play_arrow_rounded
      ,size: 90,color: Colors.black)),
      Spacer(flex: 1,),
      IconButton(icon: Icon(Icons.skip_next_rounded,size: 60,color: Colors.black),
      onPressed: onClickNext,)
    ],),
    ),
    Spacer(flex: 1,),
    Container(width: 0.9*sw,child: Slider(min: 0,
    max: sliderMax,activeColor: Colors.black,
      
      onChanged:onSliderChange,value: sliderPos,),),
      Container(width: sw*0.80,  child:Row(children: [Text(formatDuration(Duration(milliseconds: sliderPos.toInt()))),
      Spacer(flex: 1,),
      Text(formatDuration(Duration(milliseconds: sliderMax.toInt())))
      ],))
    ],),);
  }
}

String formatDuration(Duration duration) {
  String minutes = duration.inMinutes.toString().padLeft(2, '0');
  String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}