import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), backgroundColor: Colors.black),
      body: Container(
        padding: EdgeInsets.only(top: 50),
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Column(children: [
          //load image
          Image.network('https://i.imgur.com/xQKO5NL.jpg', height: 170, width: 170),
            const SizedBox(height: 20),
          const Text(
            'Tune Tube',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          const Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          const SizedBox(height: 20),
          const Text(
            'Developed by Hassan Nawaz ',
            style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Roboto'),
          ),
        ]),
      )
    );
  }
}
