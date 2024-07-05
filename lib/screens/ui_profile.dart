import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moosick/screens/spotify_auth_screen.dart';
import 'package:moosick/startup_init.dart';

class ProfileUi extends StatefulWidget {
  const ProfileUi({super.key});

  @override
  State<ProfileUi> createState() => _ProfileUiState();
}

class _ProfileUiState extends State<ProfileUi> {
  //TODO: logout& history button, liked, favourite, playlist, history

  bool historySwitch = false; //TODO: store in db

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black,),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [

            // HEADING
            Row(
              children: [
                getCircleImage("assets/library.png",height: 37,width: 37),
                const SizedBox(width: 10,),
                getHeading("Your Library",fontSize: 23,color: Colors.green, style: GoogleFonts.raleway),
              ],
            ),

            // BODY - TODO: liked, favorite, playlist, history
            getListTile(context, "History", Icons.history, HistoryPage()),
            getListTile(context, "Favorite", Icons.favorite, HistoryPage()),
            getListTile(context, "Liked", Icons.thumb_up, HistoryPage()),
            getListTile(context, "Playlist", Icons.my_library_music, HistoryPage()),

            const Divider(thickness: 0.5, color: Colors.blueGrey,height: 50,),

            Row(
              children: [
                getCircleImage("assets/settings.png"),
                const SizedBox(width: 10,),
                getHeading("Settings",fontSize: 23,color: Colors.green, style: GoogleFonts.raleway),
              ],
            ),

            Theme(
              data: nosplash,
              child: SwitchListTile(
                title: getHeading("Store history",fontWeight: FontWeight.normal,fontSize: 18),
                secondary: const Icon(Icons.history_toggle_off,color: Colors.green),
                activeTrackColor: Colors.green,
                inactiveTrackColor: Colors.black,
                value: historySwitch, //TODO: store in db
                onChanged: (newValue){
                  setState(() {
                    historySwitch = newValue;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout),
              textColor: Colors.white,
              iconColor: Colors.green,
              onTap: () async {

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return const Center(child: CircularProgressIndicator(color: Colors.red,));
                  },
                );

                Future.delayed(const Duration(milliseconds: 500), () async {
                  await credStorage.delete(key: "clientId");
                  await credStorage.delete(key: "clientSecret");
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(context,'/',(_) => false);
                  }

                });

              },
            ),






          ],
        ),
      ),

    );
  }
}


// class LibraryItem{
//   final String name;
//   final IconData leadingIcon;
//   final Widget routeWidget;
//   LibraryItem(this.name, this.leadingIcon, this.routeWidget);
// }
//
// List<LibraryItem> libraryItems = [
//   LibraryItem("History", Icons.history, HistoryPage() ),
//   LibraryItem("Favourites", Icons.favorite, HistoryPage() ), // implement pages
//   LibraryItem("Liked", Icons.thumb_up, HistoryPage() ),
// ];

ListTile getListTile(BuildContext context, String title, IconData leadingIcon, Widget routeWidget,){
  return ListTile(
    title: Text(title),
    leading: Icon(leadingIcon),
    textColor: Colors.white,
    iconColor: Colors.green,
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => routeWidget)
      );
    },
  );
}

//-----------------PAGES---------------------------------------
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      
      body: Center(child: getHeading("test",fontWeight: FontWeight.normal, fontSize: 20,style: GoogleFonts.calligraffitti),),
    );
  }
}
