import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:audioplayers/audioplayers.dart';
import '../models/lyric_line.dart';
import '../models/lyric_word.dart';
import 'constant_widget.dart';

class LyricFileLine extends StatefulWidget {
  final AudioPlayer advancedPlayer;

  const LyricFileLine({Key? key, required this.advancedPlayer}) : super(key: key);

  @override
  _LyricFileLineState createState() => _LyricFileLineState();
}

class _LyricFileLineState extends State<LyricFileLine> {
  List<LyricLine> lyrics = [];
  Duration _currentDuration = Duration.zero;
  Duration _startLyricsTime = Duration.zero;
  Duration _displayStartTime = Duration.zero;

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
      _displayStartTime = _startLyricsTime - const Duration(seconds: 2);
      setState(() {});
    } else {
      print(Text(
        'Không thể tải được lời bài hát',
        style: TextStyle(
            color: Colors.grey,
            fontSize: 20,
            fontWeight: FontWeight.w800
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentLineIndex = _findCurrentLineIndex();

    if (_currentDuration < _displayStartTime) {
      return ConstantWidget();
    }

    return lyrics.isEmpty?Center(child: CircularProgressIndicator()):Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentLineIndex >= 0 && currentLineIndex < lyrics.length)
          _buildLyricLine(lyrics[currentLineIndex], false),
        if (currentLineIndex + 1 < lyrics.length)
          _buildLyricLine(lyrics[currentLineIndex + 1], true),
      ],
    );
  }

  Widget _buildLyricLine(LyricLine line, bool isCurrent) {
    String lyricText = line.words.map((word) => word.word).join(' ');


    Duration displayStart = _startLyricsTime - const Duration(seconds: 2);


    bool isHighlighted = _currentDuration >= displayStart && _currentDuration >= line.words.first.startTime;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        lyricText,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          color: isHighlighted ? Colors.red : (isCurrent ? Colors.black : Colors.white),
        ),
        textAlign: TextAlign.center,
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
