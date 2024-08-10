import 'dart:async';
import 'dart:convert';

import 'package:just_audio_background/just_audio_background.dart';
import 'package:moosick/services/spotify_api.dart';
import 'package:moosick/services/spotify_types.dart';
import 'package:moosick/startup_init.dart';
import 'package:spotify/spotify.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:just_audio/just_audio.dart';

class SongInfo{
  final String videoId;
  final String title;
  final String artist;
  final String thumbUrl;
  final Uri audioStreamUrl;
  final Track spTrack;

  SongInfo({required Video video, required Uri audioUrl, required Track sptrack}):
      videoId = video.id.toString(),
      title = video.title,
      artist = video.author,
      thumbUrl = video.thumbnails.mediumResUrl,
      audioStreamUrl = audioUrl,
      spTrack = sptrack;
}

// Future<void> testfucntion(String query) async{
//   //String? isrc = getISRCCode(query);
//   //print(isrc);
//
//   final result = spotify?.search.get(query,types: [SearchType.track]);
//   //final a = SpotifyTrack(data: jsonDecode(result.toString())["tracks"]["items"][0]);
//   Track b = (await result?.getPage(1))?.first.items?.first;
//   print(b.externalIds?.isrc );
// }

Future<SongInfo> getSongInfo(String query,{bool isId = false}) async {
  Track? track = await getTrack(query,isId);
  String? isrc = await getISRCCodeFromTrack(track!);
  final youtube = YoutubeExplode();
  var vid =(await youtube.search.search(isrc!)).first;
  final streamManifest = await youtube.videos.streamsClient.getManifest(vid.id);
  youtube.close();
  return SongInfo(video: vid, audioUrl: streamManifest.audioOnly.where((stream) => stream.tag == 249).first.url, sptrack: track);
}

//--------------------------
Future<Uri?> getAudioStreamUrl(String videoId, AudioPlayer player) async {
  /*
     Bitrate: 49.36 Kbit/s kbps
    Tag: 139  1.66MiB

    Bitrate: 59.56 Kbit/s kbps
    Tag: 249  1.84MiB

    Bitrate: 78.30 Kbit/s kbps
    Tag: 250 2.44MiB

    Bitrate: 128.04 Kbit/s kbps
    Tag: 140  4.41MiB

    Bitrate: 153.17 Kbit/s kbps
    Tag: 251  4.82MiB
  */

  try {
    final youtube = YoutubeExplode();
    var vid =(await youtube.search.search(videoId)).first;
    print(vid);
    final streamManifest = await youtube.videos.streamsClient.getManifest(vid.id);
    for (var audioStream in streamManifest.audioOnly) {
      // Access audio stream properties here (e.g., bitrate, codec)
      print("Bitrate: ${audioStream.bitrate} kbps");
      print("Codec: ${audioStream.tag}\n");
    }
    // Create the player instance
    //print(streamManifest.audioOnly.withHighestBitrate().url);

    //await player.setUrl(streamManifest.audioOnly.where((stream) => stream.tag <= 139).first.url.toString());
    //await player.play();
    await player.setAudioSource(
        AudioSource.uri(
            streamManifest.audioOnly.where((stream) => stream.tag == 249).first.url,
            tag: MediaItem(id: "1",
              title: vid.title,
              album: vid.author,
              artUri: Uri.parse(vid.thumbnails.standardResUrl),
            )
        )
    );

    await player.play();
    //await player.dispose();

    // Dispose the player when it's no longer needed
    //await player.dispose();

    return null;
  } on YoutubeExplodeException catch (e) {
    // Handle error
    print("Error getting streams: $e");
    return null;
  }
}

