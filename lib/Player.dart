import 'package:a1/listPage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

List<Audio> audioList=[];
AudioPlayer player=AudioPlayer();
int z=0;

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
    
    player.currentIndexStream.listen((newIndex)
    {
      setState(() {
        cindex=newIndex!;
      });
    });
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

void goToList()
{
  Navigator.of(context).pop();
}


  @override
  Widget build(BuildContext context) {
    Audio audio=audioList[cindex];
    final sw=MediaQuery.of(context).size.width;
    return MaterialApp(home: Scaffold(body:Align(alignment: Alignment.topCenter,   child: Container(
      width: sw*0.95,//color: Colors.green,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [   
        SizedBox(height: 40,),   
        ClipRRect(borderRadius: BorderRadius.circular(20),child: 
      Container(width: 0.95*sw,height: 0.95*sw,
      child:Stack(children: [
      FittedBox(
        fit: BoxFit.contain,
        child: audioList[cindex].albumArt,)
        ,Positioned(bottom: 10,left:10,child: 
        Column(children: [
         InkWell(onTap: goToList,  child: Container(padding: EdgeInsets.all(5),   decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10)
          ),child: Text(audio.name!,style: TextStyle(
            color: Colors.white,fontWeight: FontWeight.w900
          ),),),),
          SizedBox(height: 2.5,),
        InkWell(onTap: goToList,  child: Container(padding: EdgeInsets.all(5), decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10)
          ),child: Text(audio.albumName!,style: TextStyle(
            color: Colors.white,fontWeight: FontWeight.w900
          ),),))
        ],),)
      ])),),
        SizedBox(height: 30,),
        Text(audioList.length.toString()+'  '+cindex.toString()+' '+z.toString()+' '+
       formatDuration( Duration(milliseconds:audioList[cindex].duration!))),
        Controls(curIndex: cindex,),
      ],)
    ) ),));
  }
}


class Controls extends StatefulWidget {

  int curIndex;
  Controls({super.key,required this.curIndex});

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
  sliderMax=audioList[widget.curIndex].duration!.toDouble();
  
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
    z++;
    sliderMax=audioList[widget.curIndex].duration!.toDouble();
    final sw=MediaQuery.of(context).size.width;
    return Container(width:0.95*sw ,height: 230,//color: Colors.red,
    child: Column( children: [Container(width: 0.7*sw,
    height: 100,//color: Colors.blue,
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
    Container(//color: Colors.green, 
    width: 0.9*sw,child: Slider(min: 0,
    max: sliderMax,activeColor: Colors.black,
      
      onChanged:onSliderChange,value: sliderPos,),),
      Container( //color: Colors.blue, 
      width: sw*0.9,  child:Row(children: [
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