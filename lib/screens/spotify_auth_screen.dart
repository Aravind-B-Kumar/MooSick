import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:moosick/screens/home.dart';

import '../startup_init.dart';
import 'landing_screen.dart';

String TAG="shit";

class SpotifyAuthScreen extends StatefulWidget {
  const SpotifyAuthScreen({super.key});

  @override
  State<SpotifyAuthScreen> createState() => _SpotifyAuthScreenState();
}

class _SpotifyAuthScreenState extends State<SpotifyAuthScreen> {
  final _clientIDController = TextEditingController();
  final _clientSecretController = TextEditingController();
  final _clientIDFocusNode = FocusNode();
  final _clientSecretFocusNode = FocusNode();

  //------------------------

  Future<void> storeCredentials(String clientId, String clientSecret) async {
    await credStorage.write(key: 'clientId', value: clientId);
    await credStorage.write(key: 'clientSecret', value: clientSecret);
  } //TODO:enth myr

  Future<void> startJourney(BuildContext context,String clientId, String clientSecret ) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final (bool result, int statuscode) = await testCredentials(clientId,clientSecret);
    Completer<bool>().complete(result); //
    Navigator.of(context).pop();

    _clientIDFocusNode.unfocus();
    _clientSecretFocusNode.unfocus();

    if(result){  // Successfull
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(context, "Successful!", color: Colors.green.shade600,milliseconds: 200));
      await storeCredentials(clientId, clientSecret);
      Future.delayed(const Duration(milliseconds: 400), () async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Landing() )); //navigate:TODO
      });

    } else { // Failed
      String msg="Error!!";

      if(clientId=="" || clientSecret==""){
        msg="Please fill the required fields!";
      } else {
        if (statuscode == 400) {
          msg = "Invalid Credentials!";
        }
        else if (statuscode == 420) {
          msg = "Too Many Requests! Please try again later.";
        }
        _clientIDController.clear();
        _clientSecretController.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(context,msg,color: Colors.red.shade800,milliseconds: 1500));
    }


  }
//------------------------------



  @override
  void dispose() {
    _clientIDController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange,Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child:  Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50,),

              Image.asset("assets/splashNoBG.png" ,height: 250,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/spotifyNoBG.png", height: 60,),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                        "Authorization",
                        style: GoogleFonts.pacifico(
                            fontSize: 30
                        )
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  controller: _clientIDController,
                  focusNode: _clientIDFocusNode,
                  decoration: InputDecoration(
                      hintText: "Client ID",
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey),),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                      fillColor: Colors.orange.shade300,
                      filled: true
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
                child: TextField(
                  controller: _clientSecretController,
                  focusNode: _clientSecretFocusNode,
                  decoration: InputDecoration(
                      hintText: "Client Secret",
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey),),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 1.5)),
                      fillColor: Colors.orange.shade300,
                      filled: true
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
                child: GestureDetector(
                  onTap: () async => {
                    await startJourney(context, _clientIDController.text.trim(),_clientSecretController.text.trim())
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        color: const Color(0xFF1DB954),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black,width: 4)
                    ),
                    child: Center(
                      child: Text(
                          "Start Journey",
                          style: GoogleFonts.pacifico(fontSize: 20)
                      ),
                    ),
                  ),
                )
              )

            ],
          ),
        ),
      ),
    );

  }
}


Future<(bool,int)> testCredentials(String clientId, String clientSecret) async {

  if(clientId=="" || clientSecret==""){
    return (false,-1);
  }

  final credentials = base64.encode(utf8.encode('$clientId:$clientSecret'));
  const tokenUrl = 'https://accounts.spotify.com/api/token';
  final tokenData = {
    'grant_type': 'client_credentials', // Use 'client_credentials' grant type
  };

  try {
    final response = await http.post(Uri.parse(tokenUrl), body: tokenData, headers: {
      'Authorization': 'Basic $credentials',
      'Content-Type': 'application/x-www-form-urlencoded',
    });

    return (response.statusCode == 200, response.statusCode);

  } on Exception catch (e) {
    return (false,-1);
  }
}


SnackBar createSnackBar(BuildContext context, String msg, {Color? color, int milliseconds = 3000} ) {
  return SnackBar(
    content: Text(msg,style: GoogleFonts.openSans(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),),
    backgroundColor: color,
    duration: Duration(milliseconds: milliseconds),
    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
    // action: SnackBarAction(
    //   label: 'Dismiss',
    //   onPressed: () {
    //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //   },
    // ),
  );
}




