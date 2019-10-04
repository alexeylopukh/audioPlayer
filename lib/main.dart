import 'package:flutter/material.dart';
import 'package:url_player/audio_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'player'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AudioPlayerWidget(
              url: "https://cdn5.sefon.me/download/9oMiCKtY_bIoiqgz-tNMfQ/1570220151/69/Linkin%20Park%20-%20In%20The%20End.mp3",
              text: "RR Podcasts S2E14 - Trump or Drumm?"),
        ),
      ),
    );
  }
}
