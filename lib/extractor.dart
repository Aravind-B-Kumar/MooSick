import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:just_audio/just_audio.dart';

Future<Uri?> getAudioStreamUrl(String videoId) async {
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

    final player = AudioPlayer(); // Create the player instance
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
    await player.dispose();

    // Dispose the player when it's no longer needed
    //await player.dispose();

    return null;
  } on YoutubeExplodeException catch (e) {
    // Handle error
    print("Error getting streams: $e");
    return null;
  }
}

