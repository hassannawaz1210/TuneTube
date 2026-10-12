import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tunetube/models/PlaylistItem.dart';
import 'HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.tunetube.audio',
    androidNotificationChannelName: 'TuneTube playback',
    androidNotificationOngoing: true,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(PlaylistItemAdapter());
  await Hive.openBox<PlaylistItem>('playlist');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF101211),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

ThemeData tuneTubeTheme() {
  const mint = Color(0xFFCAEF86);
  final scheme = ColorScheme.fromSeed(
    seedColor: mint,
    brightness: Brightness.dark,
    surface: const Color(0xFF191C19),
    primary: mint,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF101211),
    fontFamily: 'sans-serif',
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF101211)),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF202420),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF101211),
      indicatorColor: Color(0xFF303D25),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'TuneTube',
    theme: tuneTubeTheme(),
    home: const HomePage(),
  );
}
