import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/spotify.dart';

const credStorage = FlutterSecureStorage();
SpotifyApi? spotify;
String? clientID,clientSecret;

ThemeData nosplash = ThemeData(splashColor: Colors.transparent,highlightColor: Colors.transparent,splashFactory: NoSplash.splashFactory);

Text getHeading(String text, {double fontSize=20, FontWeight fontWeight=FontWeight.bold, Color color=Colors.white, style=GoogleFonts.roboto,TextOverflow overflow=TextOverflow.visible}) {
  return Text(text, overflow: overflow, style: style (fontSize: fontSize, fontWeight: fontWeight, color: color));
}

Container getCircleImage( String path, {double height=40.0, double width=40.0}){
  return Container(
    width: width, // Adjust width and height for desired size
    height: height,
    decoration: BoxDecoration(
      image: DecorationImage(
        image:  AssetImage(path), // Or use NetworkImage for online images
        fit: BoxFit.cover, // Adjust fit for image scaling within the circle
      ),
    ),
  );
}

Future<void> initBGAudio() async {
  await JustAudioBackground.init(
      androidNotificationChannelId: 'com.aravind.moosick.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidNotificationIcon: "mipmap/ic_notif"
  );
}

Future<void> initHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
}

String getDuration(int duration) {
  if(duration<0 || duration==0) return "00:00";

  int minutes = duration ~/ 60;
  int seconds = duration % 60;
  int hours = minutes ~/ 60;
  minutes = minutes % 60;
  int days = hours ~/ 24;
  hours = hours % 24;
  List<String> durationParts = [];
  if (days > 0) {
    durationParts.add('$days'.padLeft(2, '0'));
  }
  if (hours > 0) {
    durationParts.add('$hours'.padLeft(2, '0'));
  }
  if (minutes >= 0) {
    durationParts.add('$minutes'.padLeft(2, '0'));
  }
  if (seconds >= 0) {
    durationParts.add('$seconds'.padLeft(2, '0'));
  }
  return durationParts.join(':');
}