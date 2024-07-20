import 'dart:io';
import 'dart:ui';
import 'package:a1/Player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

String st='not';
int k=0;

class ListPage extends StatefulWidget {

  
   ListPage({super.key,});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {

String pa="Not set";
List<Audio> list=[];
String t="not pressed";
List<String> paths=[];
bool isGranted=false;



Future<bool> getPermission() async
{
  bool isGranted= await Permission.manageExternalStorage.request().isGranted;
  this.isGranted=isGranted;
  return isGranted;
}

Stream<Audio> getAudio(List<String> paths) async*
{
  for (String path in paths)
  {
  await Future.delayed(Duration(microseconds: 100));
  Audio audio=await Audio.create(path: path);
  yield audio; 
  }

}

void onPressed()
{
     Directory directory = Directory('/storage/emulated/0/Music');
     paths=_listAudioFiles(directory);

  }


 List<String> _listAudioFiles(Directory directory) {
    List<String> audioPaths = [];

    List<FileSystemEntity> files = directory.listSync(recursive:true, followLinks: false);
    for (var file in files) {
      if (file is File) {
        String path = file.path;
        if (path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.m4a')) {
          audioPaths.add(path);
        }
      }
    }

  return audioPaths;
  }


  void startReading() 
  {
    final stream=  getAudio(paths);
    stream.listen((audio)
    {
      setState(() {
        list.add(audio);
      });
    });
  }

  

    
// void updateStatus() async
// {
//      if (await Permission.audio.request().isGranted)
//        st='permission granted';
//   setState(() {
//     t=st+k.toString();
//   });
// }



void updateStatus(){

}
@override
  void initState()
  {
    super.initState();
    if(isGranted==false)
    {
    getPermission().then((isGranted)
    {
    if (isGranted) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission granted')),
      );
      onPressed();
      startReading();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
    });
    }


  }
void goToPlayer(int index)
{
    Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => Player(list:list ,index: index,)),
);
}

 @override
  Widget build(BuildContext context) {
   final sw=MediaQuery.of(context).size.width;
   
    return Container(
      child:Center(child: Column(
        children: [
          TopBanner(imagePath: 'assets/images/logo.jpeg', height: 200),
          

       Expanded(
  child: ListView.builder(
    itemCount: list.length,
    itemBuilder: (context, index) => AudioOverview(goTo: goToPlayer,audio: list[index],index:index),
  ),
)

        ],
      ),
    ));
  }
}




class Audio
{
  String path;
  Metadata? metaData;
  String? name;
  String? albumName;
  int? duration;
  Widget? albumArt;



 Audio._({required this.path});

 static Future<Audio> create({required String path}) async
 {
  st='in audio creation';
    Audio a=Audio._(path: path);
    a.metaData = await MetadataRetriever.fromFile(File(path));
    a.name=(a.metaData!.trackName!=null)? a.metaData!.trackName : extractFilename(path);
    a.albumName=(a.metaData!.albumName!=null)? a.metaData!.albumName:'Unknown';
    a.duration=a.metaData!.trackDuration;
    a.albumArt= (a.metaData!.albumArt!=null)?Image.memory(a.metaData!.albumArt!):Icon(Icons.audiotrack);
    return a;

 }

@override
 String toString()=> '$name|$albumName|$duration|$path';
 

}

class AudioOverview extends StatelessWidget {

  final Audio audio;
  Function goTo;
  // List<Audio> audioList;
   int index;
  // BuildContext context;
  AudioOverview({required this.index,super.key,required this.audio,required this.goTo});




void goToPlayer( )
{
  goTo(index);
}


  @override
  Widget build(BuildContext context)  {
    final sw=MediaQuery.of(context).size.width;
    return InkWell(onTap: goToPlayer, child:ClipRect(child:  Container(width: sw*0.95,
    height: 100,
    //color: Colors.blue,
    child: Row(mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
      children: [SizedBox(width: 10,),
        ClipRRect(borderRadius: BorderRadius.circular(10),child: 
      Container(width: 90,height: 90,child: FittedBox(
        fit: BoxFit.contain,
        child: audio.albumArt,
      )),),
        SizedBox(width: 8,),
        Container(child: Column(  crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
          children: [SizedBox(height: 10,),
          Text(audio.name!,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w900)),
          Text(audio.albumName!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w900)),
          Text(audio.duration!.toString(),style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900))
        ],),)
    
        ],
    ),)));
  }
}

String extractFilename(String path) {
  int lastSlashIndex = path.lastIndexOf('/');
  int mp3Index = path.lastIndexOf('.mp3');
  if (lastSlashIndex != -1 && mp3Index != -1 && lastSlashIndex < mp3Index) {
    return path.substring(lastSlashIndex + 1, mp3Index );
  }
  return 'Invalid path';
}

class TopBanner extends StatelessWidget {
  final String imagePath;
  final double height;

  TopBanner({required this.imagePath, required this.height});

  @override
  Widget build(BuildContext context) {
    final sw= MediaQuery.of(context).size.width;
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(30.0),
      ),
      child: Container(
        height: height,width:sw,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(imagePath),
                ),
                SizedBox(height: 10),
                Text(
                  'My Music App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


