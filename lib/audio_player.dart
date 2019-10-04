import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const BACKGROUND_COLOR = Color(0xffF1F1F1);
const TEXT_COLOR = Color(0xff999999);
const PLAYED_COLOR = Color(0xffC1272D);

enum PlayerState { stopped, playing, paused }

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final String text;

  AudioPlayerWidget({@required this.url, this.text});

  @override
  State<StatefulWidget> createState() {
    return _AudioPlayerWidgetState(url, text);
  }
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final String url;
  String text;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;

  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;

  get _isPaused => _playerState == PlayerState.paused;

  get _durationText => _duration?.toString()?.split('.')?.first ?? '';

  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  _AudioPlayerWidgetState(this.url, this.text);

  @override
  void initState() {
    if (text == null) {
      text = '';
    }

    _audioPlayer = AudioPlayer();
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: BACKGROUND_COLOR,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: <Widget>[
          progressIndicator(),
          textWidget(),
          scrubberController(context),
          buttonWidget()
        ],
      ),
    );
  }

  Widget textWidget() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 13, right: 37),
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: _playerState == PlayerState.stopped
                    ? TEXT_COLOR
                    : PLAYED_COLOR,
                fontSize: 14))
      ),
    );
  }

  Widget progressIndicator() {
    return Opacity(
      opacity: 0.1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final width = (_position != null &&
                  _duration != null &&
                  _position.inMilliseconds > 0 &&
                  _position.inMilliseconds < _duration.inMilliseconds)
              ? constraints.maxWidth *
                  _position.inMilliseconds /
                  _duration.inMilliseconds
              : 0.0;
          return Container(
            width: width,
            decoration: BoxDecoration(
                color: PLAYED_COLOR, borderRadius: BorderRadius.circular(4)
//                constraints.maxWidth - width > 4
//                    ? BorderRadius.only(
//                    topLeft: Radius.circular(4),
//                    bottomLeft: Radius.circular(4))
//                    : BorderRadius.circular(4)
                ),
          );
        },
      ),
    );
  }

  Widget scrubberController(context) {
    if (_audioPlayerState == AudioPlayerState.STOPPED) return Container();
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        seekToRelativePosition(details.localPosition.dx);
      },
      onTapUp: (TapUpDetails details) {
        seekToRelativePosition(details.localPosition.dx);
      },
    );
  }

  Widget buttonWidget(){
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () {
            if (_isPlaying)
              _pause();
            else
              _play();
            setState(() {});
          },
          child: SizedBox(
            height: 24,
            width: 24,
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: TEXT_COLOR,
            ),
          ),
        ),
      ),
    );
  }

  seekToRelativePosition(double tapPosition) {
    final position = tapPosition * _duration.inMilliseconds;
    final RenderBox box = context.findRenderObject();
    final double relative = position / box.size.width;
    _audioPlayer.seek(Duration(milliseconds: relative.round()));
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);
    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }
}
