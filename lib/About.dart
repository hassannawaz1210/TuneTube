import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), backgroundColor: Colors.black),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 50),
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Column(children: [
            Image.asset('assets/images/icon/icon.jpeg', height: 170, width: 170),
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
      )
    );
  }
}
