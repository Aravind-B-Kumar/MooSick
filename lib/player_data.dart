import 'dart:math';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:line_icons/line_icons.dart';
import 'package:moosick/extractor.dart';
import 'package:moosick/startup_init.dart';
import 'package:rxdart/rxdart.dart';


class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}


class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;

  const SeekBar({super.key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.green,
            inactiveTrackColor: Colors.grey.shade900,
            thumbShape: SliderComponentShape.noThumb,
            overlayColor: Colors.transparent, // when pressing slider, a shape pops up
            trackHeight: 5,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
                widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
              _dragValue = null;
            },
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: _width * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getHeading(getDuration(widget.position.inSeconds),fontSize: 15),
              getHeading(getDuration(widget.duration.inSeconds),fontSize: 15)
            ],
          ),
        ),
      ],
    );
  }
}

//-------------------------------------------------------------------------------------

class PlayerWidget extends StatefulWidget {
  final SongInfo song;

  const PlayerWidget({
    super.key,
    required this.song,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {

  final _player = AudioPlayer(audioLoadConfiguration: const AudioLoadConfiguration(androidLoadControl: AndroidLoadControl(bufferForPlaybackDuration:Duration(milliseconds: 50)),darwinLoadControl: DarwinLoadControl(preferredPeakBitRate: 2000.0))) ; // audioLoadConfiguration: const AudioLoadConfiguration(androidLoadControl: AndroidLoadControl(),darwinLoadControl: DarwinLoadControl(preferredPeakBitRate: 2000.0))
  
  bool isLoopingCurrentItem = false;
  Duration defaultDuration = Duration.zero;

  @override
  void initState() {
    _initAudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _player.stop();
    }
  }

  void handleLooping() async {
    if (isLoopingCurrentItem) {
      await _player.setLoopMode(LoopMode.one);
    } else {
      await _player.setLoopMode(LoopMode.off);
    }
    setState(() {
      isLoopingCurrentItem = !isLoopingCurrentItem;
    });
  }


  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
              (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero)
      );


  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
              vertical: _width * 0.1, horizontal: _width * 0.015),
          child: StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return SeekBar(
                duration: positionData?.duration ?? defaultDuration,
                position: positionData?.position ?? Duration.zero,
                bufferedPosition:
                positionData?.bufferedPosition ?? Duration.zero,
                onChanged: _player.seek,
              );
            },
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: _width * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    LineIcons.random,
                    color: Colors.grey,
                    size: _width * 0.1,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    LineIcons.stepBackward,
                    color: Colors.grey,
                    size: _width * 0.1,
                  )),

              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                    return Container(
                        padding: EdgeInsets.all(_width * 0.05),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(_width),
                        ),
                        width: _width * 0.24,
                        height: _width * 0.24,
                        child: SpinKitRipple(
                          color: Colors.black,
                          duration: const Duration(milliseconds: 500),
                          size: _width * 0.07,
                        ));
                  } else if (playing != true) {
                    return InkWell(
                      onTap: _player.play,
                      child: Container(
                        width: _width * 0.24,
                        height: _width * 0.24,
                        padding: EdgeInsets.all(_width * 0.05),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(_width),
                        ),
                        child: Icon(
                          LineIcons.play,
                          color: Colors.black,
                          size: _width * 0.07,
                        ),
                      ),
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return InkWell(
                      onTap: _player.pause,
                      child: Container(
                        width: _width * 0.24,
                        height: _width * 0.24,
                        padding: EdgeInsets.all(_width * 0.05),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(_width),
                        ),
                        child: Icon(
                          LineIcons.pause,
                          color: Colors.black,
                          size: _width * 0.07,
                        ),
                      ),
                    );
                  } else {
                    return InkWell(
                      onTap: () => _player.seek(Duration.zero),
                      child: Container(
                        width: _width * 0.24,
                        height: _width * 0.24,
                        padding: EdgeInsets.all(_width * 0.05),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(_width),
                        ),
                        child: Icon(
                          LineIcons.alternateRedo,
                          color: Colors.black,
                          size: _width * 0.07,
                        ),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  LineIcons.stepForward,
                  color: Colors.grey,
                  size: _width * 0.1,
                ),
              ),
              IconButton(
                onPressed: () => handleLooping(),
                icon: Icon(
                  LineIcons.retweet,
                  color: isLoopingCurrentItem ? Colors.grey : Colors.white,
                  size: _width * 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _initAudioPlayer() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });
    // Try to load audio from a source and catch any errors.
    try {
      Duration? d = await _player.setAudioSource( AudioSource.uri(
        Uri.parse(widget.song.audioStreamUrl.toString()),
        tag: MediaItem(
          id: "sed",
          artist: widget.song.artist,
          title: widget.song.title,
          artUri: Uri.parse(widget.song.thumbUrl),
        ),
      ),
      );

      await _player.play();

      _player.durationStream.listen((d){
        setState(() => defaultDuration = d! );
      });

    } catch (e) {
      print("Error loading audio source: $e");
    }
  }
}
