import 'package:a1/listPage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

List<Audio> audioList=[];
AudioPlayer player=AudioPlayer();


class Player extends StatefulWidget {
List<Audio> list;
int index;
   Player({super.key,required this.list,required this.index})
   {
    audioList=list;
   }

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {

int cindex=0;


ConcatenatingAudioSource? playlist;

  @override
  void initState() {
    cindex=widget.index;
    super.initState();
    getPlaylist().then((_)
    {
      player.setAudioSource(playlist!,initialIndex: cindex);
    });
    player.play();
    

  }

Future<void> getPlaylist() async
{
  List<AudioSource> audioSourceList=[];
  for(Audio audio in audioList)
  {
   audioSourceList.add(AudioSource.file(audio.path));
  }
    playlist=ConcatenatingAudioSource(children: audioSourceList);
}

  @override
  Widget build(BuildContext context) {
    final sw=MediaQuery.of(context).size.width;
    return MaterialApp(home: Scaffold(body:Align(alignment: Alignment.topCenter,   child: Container(
      width: sw*0.95,//color: Colors.green,
      child: Column(children: [
        SizedBox(height: 30,),
        Text(widget.list.length.toString()+'  '+widget.index.toString()),
        Controls(songDuration: audioList[cindex].duration!.toDouble()),
      ],)
    ) ),));
  }
}


class Controls extends StatefulWidget {

double songDuration;
  Controls({super.key,required this.songDuration});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {


  double sliderPos=0;
  double sliderMax=0;
  bool isPlaying=true;

  @override
  void initState()
  {
   
  super.initState();
  sliderMax=widget.songDuration;
   player=player;
  player.positionStream.listen((duration)
  {
    setState(() {
      sliderPos=duration.inMilliseconds+0.0;
    });
  });
  player.play();
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
    player.seekToNext();
  }

  void onClickPrevious()
  {
    player.seekToPrevious();
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
    Container(color: Colors.green, width: 0.9*sw,child: Slider(min: 0,
    max: sliderMax,activeColor: Colors.black,
      
      onChanged:onSliderChange,value: sliderPos,),),
      Container( color: Colors.blue, width: sw*0.9,  child:Row(children: [
        SizedBox(width: 20,),
        Text(formatDuration(Duration(milliseconds: sliderPos.toInt()))),
      Spacer(flex: 1,),
      Text(formatDuration(Duration(milliseconds: sliderMax.toInt()))),
      SizedBox(width: 20,),
      ],))
    ],),);
  }
}

String formatDuration(Duration duration) {
  String minutes = duration.inMinutes.toString().padLeft(2, '0');
  String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}