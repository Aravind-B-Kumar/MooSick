import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moosick/services/spotify_types.dart';
import 'package:spotify/spotify.dart';
import '../startup_init.dart';

  // 77c511f475fa4bd6ae478926c45ddee2
// e05684c7d1bd47778b66cedc4f515cb5

String? CLIENTID=clientID;
String? CLIENTSECRET=clientSecret;

String? accessToken;
DateTime? _lastTokenRefresh;

String credentials = base64.encode(utf8.encode('$CLIENTID:$CLIENTSECRET'));

bool _checkResponseStatus(http.Response response){
  return response.statusCode==200;
}

Future<void> _loadCreds() async{
  if (CLIENTID==null || CLIENTSECRET==null) {
    CLIENTID = await credStorage.read(key: 'clientId');
    CLIENTSECRET =  await credStorage.read(key: 'clientSecret');
  }
  credentials = base64.encode(utf8.encode('$CLIENTID:$CLIENTSECRET'));
}

Future<void> _setAccessToken() async {
  if (accessToken==null || _lastTokenRefresh==null || DateTime.now().difference(_lastTokenRefresh!) >= const Duration(seconds: 3600)) {
    await _loadCreds();
    const tokenUrl = 'https://accounts.spotify.com/api/token';
    final response = await http.post(
        Uri.parse(tokenUrl),
        body: {'grant_type': 'client_credentials'},
        headers: {'Authorization': 'Basic $credentials','Content-Type': 'application/x-www-form-urlencoded',}
    );
    if(_checkResponseStatus(response)) {
      _lastTokenRefresh = DateTime.now();
      accessToken =  (jsonDecode(response.body))["access_token"];
    }
  }
}

Future<http.Response> _getResponse(String url) async{
  await _setAccessToken();
  return await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $accessToken',});
}

Future<List<SpotifyAlbum>?> getNewReleases() async {

  // a['albums']['items'][INDEX]['name']
  //{'album_type': 'single', 'artists': [{'external_urls': {'spotify': 'https://open.spotify.com/artist/1wRPtKGflJrBx9BmLsSwlU'}, 'href': 'https://api.spotify.com/v1/artists/1wRPtKGflJrBx9BmLsSwlU', 'id': '1wRPtKGflJrBx9BmLsSwlU', 'name': 'Pritam', 'type': 'artist', 'uri': 'spotify:artist:1wRPtKGflJrBx9BmLsSwlU'}, {'external_urls': {'spotify': 'https://open.spotify.com/artist/4YRxDV8wJFPHPTeXepOstw'}, 'href': 'https://api.spotify.com/v1/artists/4YRxDV8wJFPHPTeXepOstw', 'id': '4YRxDV8wJFPHPTeXepOstw', 'name': 'Arijit Singh', 'type': 'artist', 'uri': 'spotify:artist:4YRxDV8wJFPHPTeXepOstw'}, {'external_urls': {'spotify': 'https://open.spotify.com/artist/2LgKrgRJcbJlt14i1LTzDU'}, 'href': 'https://api.spotify.com/v1/artists/2LgKrgRJcbJlt14i1LTzDU', 'id': '2LgKrgRJcbJlt14i1LTzDU', 'name': 'Amit Mishra', 'type': 'artist', 'uri': 'spotify:artist:2LgKrgRJcbJlt14i1LTzDU'}], 'available_markets': ['AR', 'AU', 'AT', 'BE', 'BO', 'BR', 'BG', 'CA', 'CL', 'CO', 'CR', 'CY', 'CZ', 'DK', 'DO', 'DE', 'EC', 'EE', 'SV', 'FI', 'FR', 'GR', 'GT', 'HN', 'HK', 'HU', 'IS', 'IE', 'IT', 'LV', 'LT', 'LU', 'MY', 'MT', 'MX', 'NL', 'NZ', 'NI', 'NO', 'PA', 'PY', 'PE', 'PH', 'PL', 'PT', 'SG', 'SK', 'ES', 'SE', 'CH', 'TW', 'TR', 'UY', 'US', 'GB', 'AD', 'LI', 'MC', 'ID', 'JP', 'TH', 'VN', 'RO', 'IL', 'ZA', 'SA', 'AE', 'BH', 'QA', 'OM', 'KW', 'EG', 'MA', 'DZ', 'TN', 'LB', 'JO', 'PS', 'IN', 'BY', 'KZ', 'MD', 'UA', 'AL', 'BA', 'HR', 'ME', 'MK', 'RS', 'SI', 'KR', 'BD', 'PK', 'LK', 'GH', 'KE', 'NG', 'TZ', 'UG', 'AG', 'AM', 'BS', 'BB', 'BZ', 'BT', 'BW', 'BF', 'CV', 'CW', 'DM', 'FJ', 'GM', 'GE', 'GD', 'GW', 'GY', 'HT', 'JM', 'KI', 'LS', 'LR', 'MW', 'MV', 'ML', 'MH', 'FM', 'NA', 'NR', 'NE', 'PW', 'PG', 'PR', 'WS', 'SM', 'ST', 'SN', 'SC', 'SL', 'SB', 'KN', 'LC', 'VC', 'SR', 'TL', 'TO', 'TT', 'TV', 'VU', 'AZ', 'BN', 'BI', 'KH', 'CM', 'TD', 'KM', 'GQ', 'SZ', 'GA', 'GN', 'KG', 'LA', 'MO', 'MR', 'MN', 'NP', 'RW', 'TG', 'UZ', 'ZW', 'BJ', 'MG', 'MU', 'MZ', 'AO', 'CI', 'DJ', 'ZM', 'CD', 'CG', 'IQ', 'LY', 'TJ', 'VE', 'ET', 'XK'], 'external_urls': {'spotify': 'https://open.spotify.com/album/6LVS3ciZv4mt2m1dA5FWnx'}, 'href': 'https://api.spotify.com/v1/albums/6LVS3ciZv4mt2m1dA5FWnx', 'id': '6LVS3ciZv4mt2m1dA5FWnx', 'images': [{'height': 300, 'url': 'https://i.scdn.co/image/ab67616d00001e02d45d964b438b8297eb908384', 'width': 300}, {'height': 64, 'url': 'https://i.scdn.co/image/ab67616d00004851d45d964b438b8297eb908384', 'width': 64}, {'height': 640, 'url': 'https://i.scdn.co/image/ab67616d0000b273d45d964b438b8297eb908384', 'width': 640}], 'name': 'Tu Hai Champion (From "Chandu Champion")', 'release_date': '2024-05-30', 'release_date_precision': 'day', 'total_tracks': 1, 'type': 'album', 'uri': 'spotify:album:6LVS3ciZv4mt2m1dA5FWnx'}
  // each item -> ['album_type', 'artists', 'available_markets', 'external_urls', 'href', 'id', 'images', 'name', 'release_date', 'release_date_precision', 'total_tracks', 'type', 'uri']

  await _setAccessToken();
  const String url = 'https://api.spotify.com/v1/browse/new-releases';
  final response = await _getResponse(url);
  if (_checkResponseStatus(response)) {
    final data = jsonDecode(response.body);
    return List<SpotifyAlbum>.from(data['albums']['items'].map((item) => SpotifyAlbum(data: item))) ;
  }
  return null;
}

Future<List<String>?> getGenresList() async {
  const String url = 'https://api.spotify.com/v1/recommendations/available-genre-seeds';
  final response = await _getResponse(url);
  if(_checkResponseStatus(response)){
    final data = jsonDecode(response.body);
    return data["genres"];
  }
  return null;
}

Future<List<SpotifyCategoryItem>?> getCategories() async {
  const String url = 'https://api.spotify.com/v1/browse/categories?locale=en-IN&limit=20&offset=1';
  final response = await _getResponse(url);
  if(_checkResponseStatus(response)){
    final data = jsonDecode(response.body);
    return List<SpotifyCategoryItem>.from(data['categories']['items'].map((item) => SpotifyCategoryItem(data: item))) ;
  }
  return null;
}

//---------------------------------------------------------
Future<Track?> getTrack(String query) async {
  final result = spotify?.search.get(query,types: [SearchType.track]);
  try {
    Track track = (await result?.getPage(1))?.first.items?.first;
    return track;
  } catch(_){
    return null ;
  }
}

Future<String?> getISRCCode(String query) async{
  final Track? track = await getTrack(query);
  try{
    return track?.externalIds!.isrc;
  } catch (_){
    return null;
  }
}

String? getISRCCodeFromTrack(Track track) {
  try{
    return track.externalIds!.isrc;
  } catch (_){
    return null;
  }
}
//------------------------------------------------






































// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// String? accessToken="BQBxbzF4gepUN54k-yE-O8dpcQPEb6Scz6ahl0hAlqA7YHx6qi1gdRGIoYMYAJlq_E2De1Wpn7vuH07ZdyqWbMybbZx0Amrp2r1Sr7NZ-M1_9VwBdTA";
// DateTime? _lastTokenRefresh;
// String? CLIENTID="77c511f475fa4bd6ae478926c45ddee2";
// String? CLIENTSECRET="e05684c7d1bd47778b66cedc4f515cb5";
// String credentials = base64.encode(utf8.encode('$CLIENTID:$CLIENTSECRET'));
//
//
// bool _checkResponseStatus(http.Response response){
//   return response.statusCode==200;
// }
// Future<void> _loadCreds() async{
//   credentials = base64.encode(utf8.encode('$CLIENTID:$CLIENTSECRET'));
// }
//
// Future<void> _setAccessToken() async {
//   if (accessToken==null || _lastTokenRefresh==null || DateTime.now().difference(_lastTokenRefresh!) >= const Duration(seconds: 3600)) {
//     await _loadCreds();
//     const tokenUrl = 'https://accounts.spotify.com/api/token';
//     final response = await http.post(
//         Uri.parse(tokenUrl),
//         body: {'grant_type': 'client_credentials'},
//         headers: {'Authorization': 'Basic $credentials','Content-Type': 'application/x-www-form-urlencoded',}
//     );
//     if(_checkResponseStatus(response)) {
//       _lastTokenRefresh = DateTime.now();
//       accessToken =  (jsonDecode(response.body))["access_token"];
//     }
//   }
// }
//
// Future<http.Response> _getResponse(String url) async{
//   await _setAccessToken();
//   print(accessToken);
//   return await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $accessToken',});
// }
//
// void main() async {
//   const String url = 'https://api.spotify.com/v1/browse/categories?locale=en-IN&limit=20&offset=0';
//   final response = await _getResponse(url);
//   print(jsonDecode(response.body));
//
// }



