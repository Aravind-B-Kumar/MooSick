import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:line_icons/line_icons.dart';
import 'package:moosick/extractor.dart';
import 'package:moosick/startup_init.dart';
import 'package:rxdart/rxdart.dart';

import '../player_data.dart';
import '../spotify_data_contents.dart';

class NowPlayingUi extends StatefulWidget {
  const NowPlayingUi({super.key, required this.song});

  final SongInfo song;

  @override
  State<NowPlayingUi> createState() => _NowPlayingUiState();
}

class _NowPlayingUiState extends State<NowPlayingUi> {

  final _player = AudioPlayer(audioLoadConfiguration: const AudioLoadConfiguration(androidLoadControl: AndroidLoadControl(bufferForPlaybackDuration:Duration(milliseconds: 50)),darwinLoadControl: DarwinLoadControl(preferredPeakBitRate: 2000.0))) ; // audioLoadConfiguration: const AudioLoadConfiguration(androidLoadControl: AndroidLoadControl(),darwinLoadControl: DarwinLoadControl(preferredPeakBitRate: 2000.0))

  Duration defaultDuration = Duration.zero;

  bool isFavourite = false; //NOTE: load from db


  @override
  void initState() {
    songName = widget.song.spTrack.name! ;
    songUrl = widget.song.spTrack.externalUrls!.spotify! ;
    artistName = widget.song.spTrack.artists!.map( (artist) => artist.name ).join(", ");
    artistUrl = widget.song.spTrack.artists!.map( (artist)=>artist.externalUrls!.spotify!) ;
    thumbUrl = widget.song.spTrack.album!.images!.first.url!;

    _initAudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _initAudioPlayer() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });
    // Try to load audio from a source and catch any errors.
    try {
      await _player.setAudioSource(
        AudioSource.uri(widget.song.audioStreamUrl,
        tag: MediaItem(
          id: widget.song.spTrack.id!,
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black,foregroundColor: Colors.white,),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                const SizedBox(height: 16,),

                getHeading("Singing Now",fontWeight: FontWeight.normal, color: Colors.green,fontSize: 20,style: GoogleFonts.raleway),

                const SizedBox(height: 16,),

                Image.network(thumbUrl),

                const SizedBox(height: 20,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: _width*0.7,child: getHeading(songName,fontSize: 22,fontWeight: FontWeight.normal,style: GoogleFonts.raleway,overflow: TextOverflow.ellipsis)),
                        SizedBox(width: _width*0.7,child: getHeading(artistName,fontWeight: FontWeight.normal,fontSize: 16,color: Colors.grey)),
                      ],
                    ),

                    const SizedBox(height: 16,),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: isFavourite //NOTE use db
                              ? const Icon(Icons.favorite, color: Colors.red,)
                              : const Icon(Icons.favorite_border,color: Colors.red,),
                          onPressed: () {
                            setState(() {
                              isFavourite = !isFavourite;
                            });
                          } ,
                        )
                      ],
                    )
                  ],
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: _width * 0.03),
                  child: StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return SeekBar(
                        duration: positionData?.duration ??  defaultDuration,
                        position: positionData?.position ??  Duration.zero,
                        bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                        onChanged: _player.seek,
                      );
                    },
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    IconButton(
                        onPressed: () {

                        },
                        icon: Icon(
                          LineIcons.random,
                          color: shuffle ?Colors.white : Colors.grey,
                          size: _width * 0.07,
                        )),

                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          LineIcons.stepBackward,
                          color: Colors.grey,
                          size: _width * 0.07,
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
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(_width),
                              ),
                              width: _width * 0.19,
                              height: _width * 0.19,
                              child: Theme(
                                data: nosplash,
                                child: SpinKitRipple(
                                  color: Colors.black,
                                  duration: const Duration(milliseconds: 500),
                                  size: _width * 0.09,
                                ),
                              ));
                        } else if (playing != true) {
                          return Theme(
                            data: nosplash,
                            child: InkWell(
                              onTap: () async {
                                await _player.play();
                              },
                              child: Container(
                                width: _width * 0.165,
                                height: _width * 0.165,
                                padding: EdgeInsets.all(_width * 0.05),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(_width),
                                ),
                                child: Icon(
                                  LineIcons.play,
                                  color: Colors.black,
                                  size: _width * 0.07,
                                ),
                              ),
                            ),
                          );
                        } else if (processingState != ProcessingState.completed) {
                          return Theme(
                            data: nosplash,
                            child: InkWell(
                              onTap: () async {
                                await _player.pause();
                              },
                              child: Container(
                                width: _width * 0.165,
                                height: _width * 0.165,
                                padding: EdgeInsets.all(_width * 0.05),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(_width),
                                ),
                                child: Icon(
                                  LineIcons.pause,
                                  color: Colors.black,
                                  size: _width * 0.07,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Theme(
                            data: nosplash,
                            child: InkWell(
                              onTap: () async {
                                await _player.seek(Duration.zero);
                              },
                              child: Container(
                                width: _width * 0.165,
                                height: _width * 0.165,
                                padding: EdgeInsets.all(_width * 0.05),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(_width),
                                ),
                                child: Icon(
                                  LineIcons.alternateRedo,
                                  color: Colors.black,
                                  size: _width * 0.07,
                                ),
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
                        size: _width * 0.07,
                      ),
                    ),
                    IconButton(
                      onPressed: () => handleLooping(),
                      icon: Icon(
                        LineIcons.retweet,
                        color: isLoopingCurrentItem ? Colors.white : Colors.grey,
                        size: _width * 0.07,
                      ),
                    ),


                  ],
                ),

                const SizedBox(height: 16,)

              ],
            ),
          ),
        ),
      ),

    );
  }

}
