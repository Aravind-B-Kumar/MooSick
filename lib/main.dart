import 'package:flutter/material.dart';
import 'package:moosick/screens/home.dart';
import 'startup_init.dart';
import 'package:moosick/screens/splash_screen.dart';



Future<void> main() async {
  await initBGAudio();
  //await initHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),

    );
  }
}

