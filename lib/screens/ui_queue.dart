import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moosick/player_data.dart';
import 'package:moosick/screens/ui_now_playing.dart';
import 'package:moosick/startup_init.dart';

import '../extractor.dart';

class QueueUi extends StatefulWidget {
  const QueueUi({super.key});

  @override
  State<QueueUi> createState() => _QueueUiState();
}

class _QueueUiState extends State<QueueUi> {
  final player = AudioPlayer();
  final songNameControl = TextEditingController();

  SongInfo? song;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;


  @override
  void dispose() {
    songNameControl.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    //return Center(child: getHeading("$height $width", fontSize: 10),);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("TEST",style: GoogleFonts.raleway(fontSize: 30,color: Colors.green),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'song'),
                controller: songNameControl,
              ),
            ),
            const SizedBox(height: 20,),
            FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                print("---------------------------");
                //await getAudioStreamUrl(songNameControl.text, player); //"USUM71301306"

                song = await getSongInfo(songNameControl.text);

                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => NowPlayingUi(song: song!))
                );

                // setState(() {});
                // //print("${song.title} ${song.audioStreamUrl}");
                //
                // player.positionStream.listen((p){
                //   setState(() => position = p );
                // });
                // player.durationStream.listen((d){
                //   setState(() => duration = d! );
                // });
                // player.playerStateStream.listen((state) {
                //   if(state.processingState == ProcessingState.completed){
                //     setState(() {
                //       position=Duration.zero;
                //     });
                //     player.pause();
                //     player.seek(position);
                //   }
                // });

              },
              child: const Text("Search"),
            ),

            //if(song!=null) PlayerWidget(song: song!,),

            // Text(getDuration(position.inSeconds)),
            // SliderTheme(
            //   data: SliderTheme.of(context).copyWith(
            //     activeTrackColor: Colors.green,
            //     inactiveTrackColor: Colors.grey.shade900,
            //     thumbShape: SliderComponentShape.noThumb,
            //     overlayColor: Colors.transparent, // when pressing slider, a shape pops up
            //     trackHeight: 1,
            //   ),
            //   child: Slider(
            //     min: 0.0,
            //     max: duration.inSeconds.toDouble(),
            //     value: position.inSeconds.toDouble(),
            //     onChanged: (double value) async {
            //       await player.seek(Duration(seconds: value.toInt()));
            //     },
            //   ),
            // ),
            //
            //
            // Text(getDuration(duration.inSeconds)),
            // IconButton(
            //   onPressed: () async {
            //     if(player.playing) {
            //       await player.pause();
            //     } else {
            //       await player.play();
            //     }
            //   },
            //   icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
            // )

          ],
        ),
      ),

    );
  }
}
