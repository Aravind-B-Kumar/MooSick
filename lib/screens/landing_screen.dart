import 'package:flutter/material.dart';
import 'package:moosick/screens/ui_home.dart';
import 'package:moosick/screens/ui_profile.dart';
import 'package:moosick/screens/ui_queue.dart';
import 'package:moosick/screens/ui_search.dart';

import '../startup_init.dart';
import 'colors.dart';


class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  int currentIndex = 0;

  List<Widget> uiPages() {
    return <Widget>[
      const HomeUi(),
      const SearchUi(),
      const QueueUi(),
      const ProfileUi(),
    ];
  }

  List<BottomNavigationBarItem> items = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
    BottomNavigationBarItem(icon: Icon(Icons.queue_music), label: "Queue"),
    BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profile"),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent ,
      bottomNavigationBar: Theme(
        data: nosplash,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 5),
          color: Colors.black.withOpacity(0.8),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent, // Set background color
            selectedFontSize: 12,
            unselectedItemColor: unselectedColor,
            selectedItemColor: selectedColor,

            currentIndex: currentIndex,
            items: items,

            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
      ),

      body: uiPages()[currentIndex],
    );
  }
}
