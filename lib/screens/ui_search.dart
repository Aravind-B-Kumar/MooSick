import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moosick/screens/ui_now_playing.dart';
import 'package:moosick/screens/ui_search_category.dart';
import 'package:moosick/services/spotify_api.dart';
import 'package:spotify/spotify.dart' as sp;
import '../extractor.dart';
import '../services/spotify_types.dart';
import '../spotify_data_contents.dart';
import '../startup_init.dart';
import 'colors.dart';


class SearchUi extends StatefulWidget {
  const SearchUi({super.key});

  @override
  State<SearchUi> createState() => _SearchUiState();
}

class _SearchUiState extends State<SearchUi> {

  List<String> imagePaths = [ // TODO: make api call get categories, releases ,recommendations
    'assets/splash.png',
    'assets/splash.png',
    'assets/splash.png',
    'assets/splash.png',
    'assets/splash.png',
    'assets/splash.png',
  ];



  Future<List<SpotifyCategoryItem>?> _populateList() async{
    if (searchPageContents==null) {
      searchPageContents = await getCategories();
      if(searchPageContents!.length%2==1) searchPageContents?.removeLast();
    }
    return searchPageContents;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Search",style: GoogleFonts.raleway(fontSize: 30,color: Colors.green),),
      ),
      
      body: FutureBuilder<List<SpotifyCategoryItem>?>(
        future: _populateList(),
        builder: (context, snapshot) {

          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: selectedColor,),);
          }

          else if (snapshot.hasData) {
            List<SpotifyCategoryItem> items = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(

                children: [

                  GestureDetector(

                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute( builder: (_) => const SearchBar() ));
                    },

                    child: Container(
                      height: MediaQuery.of(context).size.height/14.5,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(30)),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text("What do you want to listen to...", style: TextStyle(fontSize: 17),),
                      ),
                    ),
                  ),


                  const SizedBox(height: 20,),

                  Align(
                      alignment: Alignment.topLeft,
                      child: getHeading("Categories")//Text("Categories",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),)
                  ),
                  Expanded(
                      child: ListView.builder(
                        itemCount: items.length ~/ 2 ,
                        itemBuilder:  (context,index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),// gap between two rows
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),// padding for text content inside
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(10),),
                                        color: Colors.black,
                                        image: DecorationImage(image: NetworkImage(items[index*2].imgUrl),fit: BoxFit.fill),
                                      ),
                                      height: MediaQuery.of(context).size.height/ 8,
                                      width: MediaQuery.of(context).size.width / 2.3,
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: getHeading(items[index*2].name,fontSize: 16),
                                      ),
                                    ),

                                    onTap: () async {
                                      // https://developer.spotify.com/documentation/web-api/reference/get-a-categories-playlists

                                      //if(items[index*2].name=="New Releases"){
                                      //}

                                    },

                                  ),

                                  const SizedBox(width: 15,),

                                  GestureDetector(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(10),),
                                        color: Colors.black,
                                        image: DecorationImage(image: NetworkImage(items[index*2+1].imgUrl),fit: BoxFit.fill),
                                      ),
                                      height: MediaQuery.of(context).size.height/ 8,
                                      width: MediaQuery.of(context).size.width / 2.3,
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: getHeading(items[index*2+1].name,fontSize: 16),
                                      ),
                                    ),

                                    onTap: () {
                                      //Navigator.of(context).push(MaterialPageRoute( builder: (_) =>  MyPage() ));
                                    },
                                  ),
                                ],
                              )
                            );
                          }

                      )
                  )


                ],

              ),
            );

          } else {
            return Center(child: getHeading("Unable to fetch data!", color: selectedColor));
          }


        }
      ),
    );
  }
}

//-----------------------------------------------------------
class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> with SingleTickerProviderStateMixin {

  late TextEditingController _searchController; //Debounce text field
  late TabController _tabController;
  bool _isloaded = false;

  Timer _debounce = Timer(Duration.zero, () {});

  List<dynamic> _trackResults = [];
  List<dynamic> _artistResults = [];
  List<dynamic> _albumResults = [];
  List<dynamic> _playlistResults = [];

  // List<String> topics = [
  //   'Recently Played',
  //   'Recommendations',
  //   'Popular Albums',
  //   'Popular Artists',
  // ];
//-----------------------------------------------

  // ListView _getListView(sp.SearchType type){
  //   String title,imageUrl;
  //   int lenght;
  //
  //   if(type == sp.SearchType.track){
  //     List<sp.Track> tracks = _trackResults as List<sp.Track>;
  //   }
  //
  //   return ListView.separated(
  //     itemBuilder: (context, index){
  //       //sp.Track track = [index] as sp.Track;
  //       return ListTile(
  //         leading: FadeInImage.assetNetwork(
  //           placeholder: "assets/defaultSongIcon.png",
  //           image:,
  //           fit: BoxFit.cover,
  //         ),
  //         title: getHeading( ?? "N/A",),
  //       );
  //     },
  //     itemCount: .length,
  //     separatorBuilder: (_,__) => const SizedBox(height: 5,),
  //   );
  // }

  ListView _trackListView(){
    return ListView.separated(
      itemBuilder: (context, index){
        sp.Track track = _trackResults[index] as sp.Track;
        return GestureDetector(
          child: ListTile(
            leading: FadeInImage.assetNetwork(
                placeholder: "assets/defaultSongIcon.png",
                image: track.album!.images!.last.url!,
                fit: BoxFit.cover,
            ),
            title: getHeading(track.name ?? "N/A",),
          ),

          onDoubleTap: () async {
            //fdprint("${track.name} ${track.id!}");
            final song = await getSongInfo(track.id!, isId : true );

            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NowPlayingUi(song: song))
            );
          },
        );
      },
      itemCount: _trackResults.length,
      separatorBuilder: (_,__) => const SizedBox(height: 5,),
    );
  }

  ListView _albumListView(){
    return ListView.separated(
      itemBuilder: (context, index){
        sp.AlbumSimple album = _albumResults[index] as sp.AlbumSimple;
        return ListTile(
          leading: FadeInImage.assetNetwork(
            placeholder: "assets/defaultSongIcon.png", ////////
            image: album.images!.last.url!,
            fit: BoxFit.cover,
          ),
          title: getHeading(album.name ?? "N/A",),
        );
      },
      itemCount: _albumResults.length,
      separatorBuilder: (_,__) => const SizedBox(height: 5,),
    );
  }

  ListView _artistListView(){
    return ListView.separated(
      itemBuilder: (context, index){
        sp.Artist artist = _artistResults[index] as sp.Artist;
        return ListTile(
          leading: ClipOval(
            child: FadeInImage.assetNetwork(
              placeholder: "assets/defaultSongIcon.png", //////////
              image: artist.images!.last.url!,
              fit: BoxFit.contain,
            ),
          ),
          title: getHeading(artist.name ?? "N/A",),
        );
      },
      itemCount: _artistResults.length,
      separatorBuilder: (_,__) => const SizedBox(height: 5,),
    );
  }

  ListView _playlistListView(){
    return ListView.separated(
      itemBuilder: (context, index){
        sp.PlaylistSimple plist = _playlistResults[index] as sp.PlaylistSimple;
        return ListTile(
          leading: FadeInImage.assetNetwork(
            placeholder: "assets/defaultSongIcon.png",
            image: plist.images!.last.url!,
            fit: BoxFit.cover,
          ),
          title: getHeading(plist.name ?? "N/A",),
        );
      },
      itemCount: _playlistResults.length,
      separatorBuilder: (_,__) => const SizedBox(height: 5,),
    );
  }

  //-------------------------------------------------------------
  final List<Tab> _tabs = <Tab>[
    const Tab(text: "Track",icon: Icon(Icons.audiotrack),),
    const Tab(text: "Album",icon: Icon(Icons.album),),
    const Tab(text: "Artist",icon: Icon(Icons.person),),
    const Tab(text: "Playlist",icon: Icon(Icons.playlist_play),),
  ];

  void _clearData(){
    _trackResults.clear();
    _albumResults.clear();
    _artistResults.clear();
    _playlistResults.clear();
  }

  Future<void> _search(String query) async {
    sp.BundledPages? result = spotify?.search.get(query,types: [sp.SearchType.track, sp.SearchType.album, sp.SearchType.artist, sp.SearchType.playlist]);
    try {
      _clearData();
      (await result?.getPage(20) )?.forEach( (_pages) {
      _pages.items?.forEach( (_item) {

        if(_item is sp.PlaylistSimple){
          _playlistResults.add(_item);
        } else if(_item is sp.AlbumSimple){
          _albumResults.add(_item);
        } else if(_item is sp.Track){
          _trackResults.add(_item);
        } else if(_item is sp.Artist){
          _artistResults.add(_item);
        }

      });
    });

      _isloaded=true;

      // ALL THINGS IN LIST, IMPLEMENT LIKE TAGS ->TRACKS, ALBUMS,PLaylist.....
      // print("2 $_isloaded");
      // print(_trackResults.length);
      // for (var (track as Track) in _trackResults) {
      //   print("${track.name} ${track.artists?.first.name}");
      // }

    } catch(_){
      _clearData();
    } finally{
      setState(() {});
    }
  }


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length:_tabs.length, vsync: this);
    _searchController =  TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black,foregroundColor: Colors.white,),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "What do you want to listen to...",
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey ), borderRadius: BorderRadius.circular(30)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black,width: 1.5),borderRadius: BorderRadius.circular(30)),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.all(13),
              ),
              onChanged: (text) {
                setState(() {_isloaded=false;});
                _debounce.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if(text.isNotEmpty){
                    _search(text);
                  } else {
                    _clearData();
                  }

                });
              },
            ),

            _searchController.text.isEmpty
                ?SizedBox(
                  height: MediaQuery.of(context).size.height/1.5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        getHeading("Play what you love"), // Text("Play what you love", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                        Text("Search for an artist, song or playlist.", style: TextStyle(color: Colors.grey.shade400),),
                      ],
                    )
                  ),
                )

                : !_isloaded
                ? SizedBox(height:MediaQuery.of(context).size.height/1.5,child: const Center(child: CircularProgressIndicator(color: Colors.green,)),)
                : Expanded(
                  child: Column(
                    children: [

                      TabBar(
                        tabs: _tabs,
                        controller: _tabController,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        labelColor: Colors.green,
                        indicatorColor: Colors.green,
                        unselectedLabelColor: Colors.grey,
                      ),

                      Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _trackListView(),
                              _albumListView(),
                              _artistListView(),
                              _playlistListView(),
                            ],
                          )
                                  ),
                    ],
                  ),
                )

          ],
        ),
      ),

    );
  }
}


