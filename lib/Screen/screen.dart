import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:music_test/widget/audio.dart';
import 'package:music_test/widget/lyrics_word.dart';

import '../widget/lyric_all.dart';
import '../widget/lyrics_line.dart';

class MainSCreen extends StatefulWidget {
  const MainSCreen({super.key});

  @override
  State<MainSCreen> createState() => _MainSCreenState();
}

class _MainSCreenState extends State<MainSCreen> {
  late AudioPlayer advancedPlayer;
  @override
  void initState(){
    super.initState();
    advancedPlayer = AudioPlayer();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/image/cover.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Container(
               height: 300,
               width: double.maxFinite,
               // child:  LyricFileLine(advancedPlayer: advancedPlayer),
               // child:  LyricWordFile(advancedPlayer: advancedPlayer),
               child: AllLyricFile(advancedPlayer: advancedPlayer),
             )
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: AudioFile(advancedPlayer: advancedPlayer),
          ),
        ],
      ),
    );
  }

}
