import 'package:flutter/material.dart';
import 'package:moosick/screens/ui_search.dart';
import 'package:moosick/startup_init.dart';

class QueueUi extends StatefulWidget {
  const QueueUi({super.key});

  @override
  State<QueueUi> createState() => _QueueUiState();
}

class _QueueUiState extends State<QueueUi> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    //return Center(child: getHeading("$height $width", fontSize: 10),);
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),// padding for text content inside
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10),),
            color: Colors.deepPurple,
            image: DecorationImage(image: NetworkImage("https://t.scdn.co/images/728ed47fc1674feb95f7ac20236eb6d7.jpeg"),fit: BoxFit.fill),
          ),
          height: MediaQuery.of(context).size.height/ 8,
          width: MediaQuery.of(context).size.width / 2.2,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text("Sed"),
          ),
        ),
      ),
      );
  }
}
