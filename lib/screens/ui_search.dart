import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moosick/services/spotify_api.dart';
//import 'package:spotify/spotify.dart';
import '../services/spotify_types.dart';
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
    List<SpotifyCategoryItem>? items = await getCategories();
    if(items!.length%2==1) items.removeLast();
    return items;
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
                                      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10),), color: Colors.deepPurple),
                                      height: MediaQuery.of(context).size.height/ 9,
                                      width: MediaQuery.of(context).size.width / 2.3,
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: getHeading(items[index*2].name,fontSize: 16),
                                      ),
                                    ),

                                    onTap: () {
                                      if(items[index*2].name=="New Releases"){

                                      }

                                    },

                                  ),

                                  const SizedBox(width: 15,),

                                  GestureDetector(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9),
                                      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10),), color: Colors.red),
                                      height: MediaQuery.of(context).size.height/ 10,
                                      width: MediaQuery.of(context).size.width / 2.3,
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: getHeading(items[index*2+1].name,fontSize: 16),
                                      ),
                                    ),

                                    onTap: () {

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

class _SearchBarState extends State<SearchBar> {
  final searchController = TextEditingController(); //Debounce text field


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black,foregroundColor: Colors.white,),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),

        child: Stack(
          children: [

            TextField(
              controller: searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "What do you want to listen to...",
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey ), borderRadius: BorderRadius.circular(30)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black,width: 1.5),borderRadius: BorderRadius.circular(30)),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.all(13),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getHeading("Play what you love"), // Text("Play what you love", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                  Text("Search for an artist, song or playlist.", style: TextStyle(color: Colors.grey.shade400),),
                ],
              )
            )

          ],
        ),
      ),

    );
  }
}
