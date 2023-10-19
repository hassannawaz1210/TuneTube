import 'package:flutter/material.dart';
import 'package:tunetube/AudioStream.dart';
import 'HomePage.dart';
import 'MainPlayer.dart';
import 'AudioStream.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TuneTube',
      home: Scaffold( 
        body: HomePage(),
        // MusicPlayer(
        //   musicInfo:  {
        //     'title': 'title',
        //     'author': 'author',
        //     'thumbnail': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJOIH3Nz5CvHBWCv2RPVgSQf_CPKOvvpzyAw&usqp=CAU',
        //     'audioUrl': 'https://cdn.pixabay.com/download/audio/2023/04/21/audio_8579ca297f.mp3?filename=my-universe-147152.mp3&g-recaptcha-response=03AFcWeA60paXr3twiFtY6MljGEStRzvUmXDHfmejBxtItvRVFU2cYanhH1PaQO2OOLQLCfgI5LvICo7zPm4L0lvueg1yTQpCc6iI1gaabMfyA9xZkKUQ-itEFXOGXpY8g5E49eK2Auz8jmlI4ucCSnXpv8dHQ2_C5awUQtV3yKNR9uv6HN4jdUC2wVJIvf04sUu_EBxFQas7IS8dFxu_1UXj71H_aqGiitmI2urx-_uSjdEom1CmSYma02liNVLqcUBCrc4-Kjehe5-MiVa5Gbtt8fXku82H-B2Sx65iJ2zOBKSV96d09F67j7XjMaXLksfeQYvvAR7D-QCb1ajQZtROLibisiZR_mQzIg_HAKBKI40e6P-O7DO6W8T38vDPIOnMBOJy_KKM-lxXoUAgL5GTTWsFhPujyGcYDtjk3u-JTqMZK_EhtxAwazDEinwe_G93IZM0NJ7sDox3gxDd60Qo7b7eAoFabsctETMWLK1zV05s5-5bnCW261Z-m3jn401sEuymxJ4zd5DBEf1TciPGpxsA2Xg0lyVskrQI-a2Y0-q3NMQ-Lso2N682KTdrDwAnfQZWBcRPC&remote_template=1',
        //   }
        //),
      ),
    );
  }
}
