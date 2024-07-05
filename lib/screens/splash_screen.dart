import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moosick/screens/home.dart';
import 'package:moosick/screens/landing_screen.dart';
import 'package:moosick/screens/spotify_auth_screen.dart';
import 'package:spotify/spotify.dart' as sp;
import '../startup_init.dart';




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  //--------------------------------------------------

  Future<bool> checkLocalCredentials() async {
    clientID = await credStorage.read(key: 'clientId');
    clientSecret =  await credStorage.read(key: 'clientSecret');
    return clientID != null && clientSecret != null;
  }

  Future<Widget> choosePage() async {
    if(await checkLocalCredentials()){
      try {
        final credentials = sp.SpotifyApiCredentials(clientID, clientSecret);
        spotify = sp.SpotifyApi(credentials);
        return const Landing();
      } on Exception catch (e) {
        await credStorage.delete(key: "clientId");
        await credStorage.delete(key: "clientSecret");
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(context, "An Error occurred!", color:  Colors.red.shade800 ,milliseconds: 800));
        return const SpotifyAuthScreen();
      }  //const MyHomePage(title: "sed");      // true-> go to home
    } else{
      return const SpotifyAuthScreen(); //invalid-> stay in auth screen
    }
  }

  //--------------------------------------------------

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 2), () async {
      final widget = await choosePage();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => widget,
      ));
    });
  }
//-----------------------------------------------------------------------------
  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange,Colors.deepOrange],
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/splashNoBG.png",),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}
