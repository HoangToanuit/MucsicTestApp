import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_test/widget/constant_widget.dart';
import 'package:xml/xml.dart' as xml;
import 'package:audioplayers/audioplayers.dart';
import '../models/lyric_line.dart';
import '../models/lyric_word.dart';

class AllLyricFile extends StatefulWidget {
  final AudioPlayer advancedPlayer;

  const AllLyricFile({Key? key, required this.advancedPlayer}) : super(key: key);

  @override
  _AllLyricFileState createState() => _AllLyricFileState();
}

class _AllLyricFileState extends State<AllLyricFile> {
  List<LyricLine> lyrics = [];
  Duration _currentDuration = Duration.zero;
  Duration _startLyricsTime = Duration.zero;
  Duration _displayStartTime = Duration.zero;

  final double lineHeight = 25.0;
  final int linesToShow = 5;
  final Duration animationDuration = Duration(milliseconds: 500);

  final String lyricsUrl = "https://storage.googleapis.com/ikara-storage/ikara/lyrics.xml";

  @override
  void initState() {
    super.initState();
    _fetchAndParseLyrics();
    widget.advancedPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _currentDuration = p;
      });
    });
  }

  Future<void> _fetchAndParseLyrics() async {
    final response = await http.get(Uri.parse(lyricsUrl));
    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
      final params = document.findAllElements('param');

      for (var param in params) {
        List<LyricWord> words = [];
        for (var item in param.findElements('i')) {
          final va = double.parse(item.getAttribute('va')!);
          final startTime = Duration(seconds: va.toInt());
          words.add(LyricWord(
            word: item.text,
            startTime: startTime,
          ));

          if (_startLyricsTime == Duration.zero || startTime < _startLyricsTime) {
            _startLyricsTime = startTime;
          }
        }
        lyrics.add(LyricLine(words: words));
      }
      _displayStartTime = _startLyricsTime - Duration(seconds: 2);
      setState(() {});
    } else {
      print(Text(
          'Không thể tải được lời bài hát',
           style: TextStyle(
               color: Colors.grey,
               fontSize: 20,
               fontWeight: FontWeight.w800
             ),
           )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentLineIndex = _findCurrentLineIndex();

    if (_currentDuration < _displayStartTime) {
          return ConstantWidget();
    }

    double animatedPositionedTop = -(currentLineIndex * lineHeight);

    return lyrics.isEmpty?Center(child: CircularProgressIndicator()):SizedBox(
      height: lineHeight * linesToShow,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: animationDuration,
            curve: Curves.easeInOut,
            top: animatedPositionedTop,
            child: Column(
              children: [
                for (int i = 0; i < lyrics.length; i++)
                  _buildLyricLine(lyrics[i], i == currentLineIndex),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricLine(LyricLine line, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: line.words.map((word) {
            final isHighlighted = _currentDuration >= word.startTime;
            return TextSpan(
              text: word.word,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? Colors.red : (isCurrent ? Colors.white : Colors.black),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  int _findCurrentLineIndex() {
    for (int i = 0; i < lyrics.length; i++) {
      for (var word in lyrics[i].words) {
        if (_currentDuration < word.startTime) {
          return i;
        }
      }
    }
    return lyrics.length;
  }
}
