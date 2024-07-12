import 'dart:convert';
import 'package:http/http.dart' as http;

import '../spotify_data_contents.dart';

class MusixLyricsApi {


  static const String tokenUrl =
      'https://apic-desktop.musixmatch.com/ws/1.1/token.get?app_id=web-desktop-app-v1.0';
  static const String searchTermUrl =
      'https://apic-desktop.musixmatch.com/ws/1.1/macro.search?app_id=web-desktop-app-v1.0&page_size=5&page=1&s_track_rating=desc&quorum_factor=1.0';
  static const String lyricsUrl =
      'https://apic-desktop.musixmatch.com/ws/1.1/track.subtitle.get?app_id=web-desktop-app-v1.0&subtitle_format=lrc';
  static const String lyricsAlternative =
      'https://apic-desktop.musixmatch.com/ws/1.1/macro.subtitles.get?format=json&namespace=lyrics_richsynched&subtitle_format=mxm&app_id=web-desktop-app-v1.0';

  Future<String?> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'authority': 'apic-desktop.musixmatch.com',
        'cookie': 'AWSELBCORS=0; AWSELB=0;',
      });
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch(_){}
    return null;
  }

  Future<void> setToken() async {
    String? result = await get(tokenUrl);
    Map<String, dynamic> tokenJson = jsonDecode(result!);
    if (tokenJson['message']['header']['status_code'] != 200) {
      throw Exception(result);
    }
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    token = tokenJson['message']['body']['user_token'];
    expireTime =currentTime + (600 * 1000); // 600 seconds in milliseconds
  }

  Future<void> checkTokenExpire() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if(token==null || expireTime==null || expireTime! < now){
      await setToken();
    }
  }

  Future<String?> searchTrack(String query) async {
    await checkTokenExpire();
    String formattedUrl = '$searchTermUrl&q=$query&usertoken=$token';
    String? result = await get(formattedUrl);
    Map<String, dynamic> listResult = jsonDecode(result!);

    if (!listResult.containsKey('message') ||
        !listResult['message'].containsKey('body') ||
        !listResult['message']['body'].containsKey('macro_result_list') ||
        !listResult['message']['body']['macro_result_list'].containsKey('track_list')) {
      return null;
    }

    for (final track in listResult['message']['body']['macro_result_list']['track_list']) {
      Map<String, dynamic> trackObj = track['track'] ;
      String trackName = '${trackObj['track_name']} ${trackObj['artist_name'] ?? ''}';
      if (trackName.toLowerCase().contains(query.toLowerCase())) {
        return trackObj['track_id'].toString();
      }
    }

    return listResult['message']['body']['macro_result_list']['track_list'][0]['track']['track_id'].toString();
  }


  Future<String> getLyrics(String trackId) async {
    await checkTokenExpire();
    String formattedUrl = '$lyricsUrl&track_id=$trackId&usertoken=$token';
    String? result = await get(formattedUrl);
    String lyrics = "";
    lyrics = jsonDecode(result!)['message']['body']['subtitle']['subtitle_body'].toString();
    //print(jsonDecode(result)['message']['body']['subtitle']);
    return lyrics;
  }

  Future<String> getLrcLyrics(String lyrics) async {
    final data = jsonDecode(lyrics);
    if (data.isEmpty) return '';

    String lrc = '';
    for (final item in data) {
      int minutes = item['time']['minutes'] ;
      int seconds = item['time']['seconds'] ;
      int hundredths = item['time']['hundredths'] ;
      String text = item['text'] ?? '♪';
      lrc += '[${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundredths.toString().padLeft(2, '0')}]$text\n';
    }
    return lrc;
  }

  Future<String> getLyricsAlternative(String title, String artist,{int? duration}) async {
    await checkTokenExpire();
    String formattedUrl = duration != null
        ? '$lyricsAlternative&usertoken=$token&q_album=&q_artist=$artist&q_artists=$artist&q_track=$title&q_duration=$duration&f_subtitle_length=$duration'
        : '$lyricsAlternative&usertoken=$token&q_album=&q_artist=$artist&q_artists=$artist&q_track=$title';

    String? result = await get(formattedUrl);
    Map<String, dynamic> lyrics = jsonDecode(result!);
    String trackLyrics = lyrics['message']['body']['macro_calls']['track.subtitles.get']['message']['body']['subtitle_list'][0]['subtitle']['subtitle_body'] ;
    String lyricsText = "";
    lyricsText = await getLrcLyrics(trackLyrics);
    return lyricsText;
  }
}
