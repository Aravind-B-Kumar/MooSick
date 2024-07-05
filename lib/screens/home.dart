import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moosick/screens/landing_screen.dart';
import '../extractor.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final songNameControl = TextEditingController();


  @override
  void dispose() {
    songNameControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title,style: GoogleFonts.raleway(fontSize: 30,color: Colors.green),),
      ),
      bottomNavigationBar: const Landing(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextField(
                  decoration: const InputDecoration(hintText: 'song'),
                  controller: songNameControl,
              ),
            ),
            const SizedBox(height: 20,),
            FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                print("---------------------------");
                await getAudioStreamUrl(songNameControl.text); //"USUM71301306"
              },
              child: const Icon(Icons.play_arrow),
            ),
          ],
        ),
      ),

    );
  }
}
