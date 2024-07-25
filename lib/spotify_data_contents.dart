import 'package:moosick/services/spotify_types.dart';

List<SpotifyCategoryItem>? searchPageContents;
String? token;
int? expireTime;

// ui now playing

bool shuffle = false;
bool isLoopingCurrentItem = false;
String songName = "";
String songUrl = "";
String artistName = "";
Iterable<String> artistUrl = [];
String thumbUrl = "";
