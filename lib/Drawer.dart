import 'package:flutter/material.dart';
import 'About.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white, width: 2.0), // Add border here
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Drawer(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const DrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Center(
                            child: Text(
                          'Tune Tube',
                          style: TextStyle(color: Colors.white),
                        )),
                      ),
                      ListTile(
                        title: const Text('Home'),
                        onTap: () {
                          //navigator pop to home
                        },
                      ),
                      ListTile(
                        title: const Text('About'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const About()),
                          );
                        },
                      ),
                    ],
                  ),
                ))));
  }
}
