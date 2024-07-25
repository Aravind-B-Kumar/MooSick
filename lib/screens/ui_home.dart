import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/spotify_api.dart';
import '../services/spotify_types.dart';
import '../startup_init.dart';
import 'colors.dart';

class HomeUi extends StatefulWidget {
  const HomeUi({super.key});

  @override
  State<HomeUi> createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  bool _isLoaded = false;
  int _itemcount = 5;
  String _title ="iehfiuhehwerjveusgigvkshggggggggggggggggggggggggggggggggggggggggg";

  List<String> _imagePaths = [
    // TODO: make api call get categories, releases ,recommendations
    'assets/splash.png',
    'assets/splash.png',
    'assets/splash.png',
    'assets/splash.png',
    'assets/splash.png',
    'assets/splash.png',
  ];

  List<String> topics = [
    'Recently Played',
    'Recommendations',
    'Popular Albums',
    'Popular Artists',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () {
      setState(() {
        _isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Welcome,",
          style: GoogleFonts.raleway(fontSize: 30, color: Colors.green),
        ),
      ),
      body: !_isLoaded
          ? Center(
              child: CircularProgressIndicator(
                color: selectedColor,
              ),
            )
          : ListView(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    //TODO: recently played if any (first row)
                    Align(
                      alignment: Alignment.topLeft,
                      child: getHeading("Popular albums",
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    getSlideItem(_itemcount, _title),

                    Align(
                      alignment: Alignment.topLeft,
                      child: getHeading("Popular artists",
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    getSlideItem(_itemcount, _title),

                    Align(
                      alignment: Alignment.topLeft,
                      child: getHeading("Popular artists",
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    getSlideItem(_itemcount, _title),

                    Align(
                      alignment: Alignment.topLeft,
                      child: getHeading("Popular artists",
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    getSlideItem(_itemcount, _title),

                    Align(
                      alignment: Alignment.topLeft,
                      child: getHeading("Popular artists",
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    getSlideItem(_itemcount, _title),

                    //TODO: Add more items according to result
                  ],
                ),
              ),
            ]),
    );
  }
}

//TODO: not itemcount and title, pass search result
Widget getSlideItem(int _itemcount, String _title) {
  //TODO artist/albums ......(if artist circular frame)
  return SizedBox(
    height: 200,
    child: ListView.builder(
      itemCount: _itemcount, //
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 160,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10), // padding for text content inside
                    decoration: const BoxDecoration(color: Colors.deepPurple),
                    height: 150,
                    width: 150,
                    child: Text("${index + 1}"),
                  ),
                  getHeading(_title,
                      fontSize: 15, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
          onTap: () async {
            //final a = await spotify?.categories.get(category_id);

            // var newReleases = await spotify?.browse.newReleases().first();
            // for (var album in newReleases!.items!) {
            //   print(album.name);
            // }

            // var newReleases = await spotify?.recommendations.get(
            //   seedGenres: ["pop"],
            //   seedArtists: ['spotify:artist:0OdUWJ0sBjDrqHygGUXeCF'],
            //   limit: 20
            // );
            // print(newReleases?.tracks);


            var data1 = await getNewReleases();
            //print(data['albums']['items']);
            if (data1 != null) {
              //print(data['albums']['items'][0]['external_urls']); // {spotify: https://open.spotify.com/album/6LVS3ciZv4mt2m1dA5FWnx}
              //final s = SpotifyAlbum(data: data['albums']['items'][0]);
              print("${data1[0].external_urls} \n\n ${data1[0].images[0].url}");
            }

            // var usersPlaylists =
            // await spotify?.playlists.getUsersPlaylists('superinteressante').all();
            // for (var playlist in usersPlaylists!) {
            //   print(playlist.name);
            // }

            // String? clientID = await credStorage.read(key: 'clientId');
            // String? clientSecret =  await credStorage.read(key: 'clientSecret');
            // print("$clientID $clientSecret");
          },
        );
      },
    ),
  );
}
