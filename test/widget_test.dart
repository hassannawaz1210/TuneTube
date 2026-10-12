import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tunetube/HomePage.dart';
import 'package:tunetube/PlayerController.dart';
import 'package:tunetube/main.dart';
import 'package:tunetube/models/PlaylistItem.dart';

void main() {
  late Directory storage;
  late Box<PlaylistItem> library;

  setUpAll(() async {
    storage = await Directory.systemTemp.createTemp('tunetube-test-');
    Hive.init(storage.path);
    Hive.registerAdapter(PlaylistItemAdapter());
  });
  setUp(() async {
    library = await Hive.openBox<PlaylistItem>('playlist');
    await library.clear();
  });
  tearDown(() async => Hive.close());
  tearDownAll(() async => storage.delete(recursive: true));

  Future<void> mount(WidgetTester tester, PlayerController controller,
      {Size size = const Size(390, 844), double textScale = 1}) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      theme: tuneTubeTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: HomePage(controller: controller),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('discover and empty library work on a narrow screen with large text', (tester) async {
    final controller = PlayerController();
    addTearDown(controller.dispose);
    await mount(tester, controller, size: const Size(320, 640), textScale: 1.4);
    expect(find.text('tunetube'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Your library'));
    await tester.pumpAndSettle();
    expect(find.text('Make yourself a mixtape'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search, save once, and remove a track from persistent library', (tester) async {
    final controller = PlayerController(searchTracks: (_) async => [{
      'title': 'A quiet morning', 'author': 'Test artist',
      'videoUrl': 'https://www.youtube.com/watch?v=jfKfPfyJRdk',
      'thumbnails': '', 'duration': '3:20', 'description': '',
    }]);
    addTearDown(controller.dispose);
    await mount(tester, controller);
    await tester.enterText(find.byType(TextField), 'quiet morning');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('A quiet morning'), findsOneWidget);
    // Hive writes use real disk I/O outside the widget test's fake clock.
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Save to library'));
      await library.flush();
    });
    await tester.pumpAndSettle();
    expect(library.length, 1);
    expect(library.values.single.audioUrl, isEmpty);
    expect(find.byTooltip('Saved to library'), findsOneWidget);
    await tester.tap(find.text('Your library'));
    await tester.pumpAndSettle();
    expect(find.text('A quiet morning'), findsOneWidget);
    // Hive writes use real disk I/O outside the widget test's fake clock.
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Remove from library'));
      await library.flush();
    });
    await tester.pumpAndSettle();
    expect(library.isEmpty, isTrue);
    expect(find.text('Make yourself a mixtape'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed search exposes retry and recovers to empty results', (tester) async {
    var fail = true;
    final controller = PlayerController(searchTracks: (_) async {
      if (fail) throw const SocketException('offline');
      return [];
    });
    addTearDown(controller.dispose);
    await mount(tester, controller);
    await tester.enterText(find.byType(TextField), 'test');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Couldn’t search YouTube'), findsOneWidget);
    fail = false;
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No tracks found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
