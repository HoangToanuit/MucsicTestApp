import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AudioFile extends StatefulWidget {
  final AudioPlayer advancedPlayer;
  const AudioFile({super.key,  required this.advancedPlayer});

  @override
  State<AudioFile> createState() => _AudioFileState();
}

class _AudioFileState extends State<AudioFile> {
 Duration _duration = new Duration();
 Duration _position = new Duration();
 final String path = "https://storage.googleapis.com/ikara-storage/tmp/beat.mp3";
 bool isPlaying = false;
 bool isPaused = false;
 bool isRepeat = false;
 Color color = Colors.black;
 List<IconData> _icons =[
   Icons.play_circle_fill,
   Icons.pause_circle_filled
 ];
  @override
  void initState(){
    super.initState();
    widget.advancedPlayer.onDurationChanged.listen((d) {
    setState(() {
      _duration = d;
    });
    });
    widget.advancedPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });
    widget.advancedPlayer.setSourceUrl(path);
    widget.advancedPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _position = Duration(seconds: 0);
        if(isRepeat == true){
          isPlaying == true;
        }else{
          isPlaying = false;
          isRepeat = false;
        }
      });
    });
  }
  Widget startButton(){
    return IconButton(
        onPressed: (){
         if(isPlaying == false){
           widget.advancedPlayer.play(UrlSource(path));
           setState(() {
             isPlaying = true;
           });
         }else if(isPlaying == true){
           widget.advancedPlayer.pause();
           setState(() {
             isPlaying = false;
           });
         }
        },
        icon: isPlaying==false?Icon(_icons[0],size: 60):Icon(_icons[1],size: 60,)
    );
  }
 Widget nextButton(){
   return GestureDetector(
     onTap: (){
       widget.advancedPlayer.setPlaybackRate(1.5);
     },
     child: Container(
       height: 30,
       width: 30,
       child: Image.asset("lib/image/next.png"),
     ),
   );
 }
 Widget backButton(){
   return GestureDetector(
     onTap: (){
       widget.advancedPlayer.setPlaybackRate(0.5);
     },
     child: Container(
       height: 30,
       width: 30,
       child: Image.asset("lib/image/back.png"),
     ),
   );
 }
 Widget repeatButton(){
    return IconButton(
      onPressed: () {
        if(isRepeat == false){
          widget.advancedPlayer.setReleaseMode(ReleaseMode.loop);
          setState(() {
            isRepeat = true;
            color = Colors.blue;
          });
        }else if(isRepeat == true){
          widget.advancedPlayer.setReleaseMode(ReleaseMode.release);
           color =Colors.black;
           isRepeat = false;
        }
      },
      icon: ImageIcon(
        size: 30,
        color: color,
        AssetImage("lib/image/loop.png")
      ),
    );
 }
 Widget loopButton(){
   return IconButton(
     onPressed: () {
     },
     icon: ImageIcon(
         size: 30,
         color: Colors.black,
         AssetImage("lib/image/loop.png")
     ),
   );
 }
 Widget adjustButton(){
    return IconButton(
        onPressed: (){
        },
        icon: ImageIcon(
            color: Colors.black,
            AssetImage("lib/image/adjust.png")
        )
    );
 }

  Widget loadMusic(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          slider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                repeatButton(),
                backButton(),
                startButton(),
                nextButton(),
                adjustButton()
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget slider(){
    return Slider(
      value: _position.inSeconds.toDouble(),
      max: _duration.inSeconds.toDouble(),
      min: 0.0,
      onChanged: (double value) {
        setState(() {
          changeToSecond(value.toInt());
          value=value;
        });
      },

    );
  }
  void changeToSecond(int second){
    Duration newDuration = new Duration(seconds: second);
    widget.advancedPlayer.seek(newDuration);
  }
  Widget build(BuildContext context) {
    return  Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20,right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_position.toString().split(".")[0],style: TextStyle(fontSize: 14),),
                Text(_duration.toString().split(".")[0],style:  TextStyle(fontSize: 14),)
              ],
            ),
          ),
          loadMusic(),
        ],
      ),
    );
  }
}
