import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'PlayerController.dart';
import 'models/PlaylistItem.dart';

const _mint = Color(0xFFCAEF86);
const _muted = Color(0xFF9AA397);
const _panel = Color(0xFF1C211C);

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.controller});
  final PlayerController? controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PlayerController _music = widget.controller ?? PlayerController();
  final _search = TextEditingController();
  final _focus = FocusNode();
  int _tab = 0;
  Box<PlaylistItem> get _library => Hive.box<PlaylistItem>('playlist');

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    if (widget.controller == null) _music.dispose();
    super.dispose();
  }

  void _find(String query) {
    if (query.trim().isEmpty) return;
    _search.text = query;
    _focus.unfocus();
    setState(() => _tab = 0);
    _music.search(query);
  }

  Map<String, dynamic> _asTrack(PlaylistItem item) => {
    'title': item.title, 'author': item.author,
    'thumbnails': item.thumbnails, 'videoUrl': item.videoUrl,
    'description': item.description, 'duration': item.duration,
  };

  Future<void> _save(Map<String, dynamic> track) async {
    if (_library.values.any((item) => item.videoUrl == track['videoUrl'])) return;
    try {
      await _library.add(PlaylistItem(
        title: track['title'] as String, author: track['author'] as String,
        thumbnails: track['thumbnails'] as String,
        videoUrl: track['videoUrl'] as String,
        description: track['description'] as String? ?? '',
        duration: track['duration'] as String? ?? '',
      ));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to your library')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save this track. Please try again.')));
    }
  }

  Future<void> _remove(int index) async {
    final item = _library.getAt(index);
    if (item == null) return;
    try {
      await _library.deleteAt(index);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Removed from library'),
        action: SnackBarAction(label: 'Undo', onPressed: () => _save(_asTrack(item))),
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not remove this track.')));
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _music,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 20, 20),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _mint, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.graphic_eq_rounded, color: Color(0xFF17210F), size: 25),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('tunetube', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -1))),
                  IconButton(
                    tooltip: 'About TuneTube',
                    onPressed: () => showAboutDialog(context: context, applicationName: 'TuneTube', applicationVersion: '1.1.0', children: const [Text('Find your next favorite sound. Search YouTube, save tracks, and listen with your screen off.\n\nSaved tracks require an internet connection. TuneTube is an independent app and is not affiliated with YouTube.')]),
                    icon: const Icon(Icons.info_outline_rounded, color: _muted),
                  ),
                ]),
              ),
              Expanded(child: _tab == 1 ? _libraryView() : _discover()),
              if (_music.playbackError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: const Color(0xFF492C28), borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      leading: const Icon(Icons.error_outline),
                      title: Text(_music.playbackError!, style: const TextStyle(fontSize: 13)),
                      trailing: IconButton(tooltip: 'Dismiss error', onPressed: _music.clearPlaybackError, icon: const Icon(Icons.close)),
                    ),
                  ),
                ),
              if (_music.currentTrack != null) _miniPlayer(),
            ]),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore_rounded), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music_rounded), label: 'Your library'),
        ],
      ),
    ),
  );

  Widget _discover() => CustomScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(delegate: SliverChildListDelegate([
          const Text('A little discovery.\nA lot of good music.', style: TextStyle(fontSize: 32, height: 1.12, fontWeight: FontWeight.w700, letterSpacing: -1.3)),
          const SizedBox(height: 12),
          const Text('Your next favorite is a search away.', style: TextStyle(color: _muted, fontSize: 14)),
          const SizedBox(height: 24),
          TextField(
            controller: _search, focusNode: _focus,
            textInputAction: TextInputAction.search,
            onSubmitted: _find,
            decoration: InputDecoration(
              hintText: 'Songs, artists, or a YouTube link',
              prefixIcon: const Icon(Icons.search_rounded, color: _muted),
              suffixIcon: IconButton(tooltip: 'Search', onPressed: () => _find(_search.text), icon: const Icon(Icons.arrow_forward_rounded, color: _mint)),
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ['Lofi', 'Indie', 'Jazz', 'Acoustic', 'Electronic'].map((label) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(label: Text(label), onPressed: () => _find('$label music'), side: const BorderSide(color: Color(0xFF343B32)), backgroundColor: const Color(0xFF151915), shape: const StadiumBorder()),
            )).toList()),
          ),
          const SizedBox(height: 26),
          if (_music.results == null && !_music.searching && _music.searchError == null) ...[
            DiscoveryCard(onTap: () => _find('lofi beats chill music')),
            const SizedBox(height: 30),
            const Text('Set the mood', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: -.5)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _mood('Deep focus', 'Find your flow', Icons.blur_on_rounded, const Color(0xFFB9C4F5), 'ambient focus music')),
              const SizedBox(width: 12),
              Expanded(child: _mood('Slow mornings', 'Ease into the day', Icons.wb_sunny_outlined, const Color(0xFFEAC4A2), 'acoustic morning music')),
            ]),
            const SizedBox(height: 24),
            const Row(children: [Icon(Icons.headphones_rounded, size: 16, color: _muted), SizedBox(width: 8), Expanded(child: Text('Less scrolling. More listening.', style: TextStyle(color: _muted, fontSize: 12)))]),
            const SizedBox(height: 24),
          ],
          if (_music.searching) const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator())),
          if (_music.searchError != null) _empty(Icons.wifi_off_rounded, 'Couldn’t search YouTube', _music.searchError!, action: TextButton.icon(onPressed: () => _find(_music.query), icon: const Icon(Icons.refresh), label: const Text('Try again'))),
          if (!_music.searching && _music.searchError == null && _music.results != null)
            Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [
              const Expanded(child: Text('Search results', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
              Text('${_music.results!.length} tracks', style: const TextStyle(color: _muted, fontSize: 12)),
            ])),
          if (!_music.searching && _music.searchError == null && _music.results?.isEmpty == true) _empty(Icons.search_off_rounded, 'No tracks found', 'Try another artist, song title, or YouTube link.'),
        ])),
      ),
      if (!_music.searching && _music.searchError == null && _music.results != null)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
            final track = _music.results![index];
            return ValueListenableBuilder<Box<PlaylistItem>>(
              valueListenable: _library.listenable(),
              builder: (context, box, _) {
                final saved = box.values.any((item) => item.videoUrl == track['videoUrl']);
                return TrackRow(track: track, active: _music.currentTrack?['videoUrl'] == track['videoUrl'], onTap: () => _music.playTrack(track, tracks: _music.results), trailing: IconButton(tooltip: saved ? 'Saved to library' : 'Save to library', onPressed: saved ? null : () => _save(track), icon: Icon(saved ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded, color: saved ? _mint : _muted)));
              },
            );
          }, childCount: _music.results!.length)),
        ),
    ],
  );

  Widget _mood(String title, String subtitle, IconData icon, Color color, String query) => Material(
    color: _panel, borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20), onTap: () => _find(query),
      child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 36), const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 5), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
      ])),
    ),
  );

  Widget _libraryView() => ValueListenableBuilder<Box<PlaylistItem>>(
    valueListenable: _library.listenable(),
    builder: (context, box, _) {
      final tracks = box.values.map(_asTrack).toList();
      return CustomScrollView(slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 24), sliver: SliverList(delegate: SliverChildListDelegate([
          const Text('Your library', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1)),
          const SizedBox(height: 10),
          Text('${tracks.length} saved tracks · Always your favorites', style: const TextStyle(color: _muted)),
          const SizedBox(height: 24),
          if (tracks.isNotEmpty) Align(alignment: Alignment.centerLeft, child: FilledButton.icon(onPressed: () => _music.playTrack(tracks.first, tracks: tracks), icon: const Icon(Icons.play_arrow_rounded), label: const Text('Play all'))),
          if (tracks.isEmpty) _empty(Icons.library_music_outlined, 'Make yourself a mixtape', 'Tap + on any search result to keep your favorite tracks here.', action: FilledButton(onPressed: () => setState(() => _tab = 0), child: const Text('Discover music'))),
        ]))),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => TrackRow(
          track: tracks[index], active: _music.currentTrack?['videoUrl'] == tracks[index]['videoUrl'],
          onTap: () => _music.playTrack(tracks[index], tracks: tracks),
          trailing: IconButton(tooltip: 'Remove from library', icon: const Icon(Icons.remove_circle_outline, color: _muted), onPressed: () => _remove(index)),
        ), childCount: tracks.length))),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]);
    },
  );

  Widget _miniPlayer() {
    final track = _music.currentTrack!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Material(
        color: const Color(0xFF2A3526), borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: const Color(0xFF171D16), builder: (_) => NowPlaying(controller: _music)),
          child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
            TrackArtwork(url: track['thumbnails'] as String? ?? '', size: 48),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(track['title'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              Text(_music.loadingTrack ? 'Finding your sound…' : track['author'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 12)),
            ])),
            PlayButton(controller: _music),
          ])),
        ),
      ),
    );
  }
}

Widget _empty(IconData icon, String title, String message, {Widget? action}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 12),
  child: Column(children: [Icon(icon, size: 42, color: _mint), const SizedBox(height: 18), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _muted, height: 1.5)), if (action != null) ...[const SizedBox(height: 18), action]]),
);

class TrackRow extends StatelessWidget {
  const TrackRow({super.key, required this.track, required this.onTap, required this.trailing, this.active = false});
  final Map<String, dynamic> track;
  final VoidCallback onTap;
  final Widget trailing;
  final bool active;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Material(
      color: active ? const Color(0xFF232E20) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        onTap: onTap,
        leading: TrackArtwork(url: track['thumbnails'] as String? ?? '', size: 56),
        title: Text(track['title'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: active ? _mint : null)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(track['author'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 12))),
        trailing: trailing,
      ),
    ),
  );
}

class TrackArtwork extends StatelessWidget {
  const TrackArtwork({super.key, required this.url, required this.size});
  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(color: _panel, alignment: Alignment.center, child: Icon(Icons.music_note_rounded, color: _mint, size: size * .4));
    return ClipRRect(borderRadius: BorderRadius.circular(size > 100 ? 28 : 10), child: SizedBox.square(dimension: size, child: url.isEmpty ? placeholder : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder, loadingBuilder: (_, child, progress) => progress == null ? child : placeholder)));
  }
}

class DiscoveryCard extends StatelessWidget {
  const DiscoveryCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: _mint, borderRadius: BorderRadius.circular(24), clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: onTap, child: Stack(children: [
      const Positioned(right: -45, top: 15, bottom: -45, width: 220, child: IgnorePointer(child: CustomPaint(painter: _RecordPainter()))),
      Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PRESS PLAY. TUNE OUT.', style: TextStyle(fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w800, color: Color(0xFF354829))),
        const SizedBox(height: 20),
        const Text('Find your\nquiet rhythm.', style: TextStyle(fontSize: 30, height: 1.05, letterSpacing: -1, fontWeight: FontWeight.w800, color: Color(0xFF17210F))),
        const SizedBox(height: 22),
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: const Color(0xFF17210F), borderRadius: BorderRadius.circular(30)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.play_arrow_rounded, size: 18, color: _mint), SizedBox(width: 6), Text('Explore lofi', style: TextStyle(color: _mint, fontSize: 12, fontWeight: FontWeight.w600))])),
      ])),
    ])),
  );
}

class _RecordPainter extends CustomPainter {
  const _RecordPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .7, size.height * .58);
    final radius = size.width * .6;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF253122));
    for (double r = radius * .4; r < radius; r += 7) {
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFF44523A)..style = PaintingStyle.stroke..strokeWidth = .8);
    }
    canvas.drawCircle(center, radius * .3, Paint()..color = const Color(0xFFECF7D5));
    canvas.drawCircle(center, 5, Paint()..color = const Color(0xFF253122));
  }
  @override
  bool shouldRepaint(_RecordPainter oldDelegate) => false;
}

class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.controller, this.large = false});
  final PlayerController controller;
  final bool large;
  @override
  Widget build(BuildContext context) => StreamBuilder<PlayerState>(
    stream: controller.player.playerStateStream,
    builder: (context, snapshot) {
      final loading = controller.loadingTrack || (controller.hasPlayableSource && (snapshot.data?.processingState == ProcessingState.loading || snapshot.data?.processingState == ProcessingState.buffering));
      final playing = controller.hasPlayableSource && snapshot.data?.playing == true && snapshot.data?.processingState != ProcessingState.completed;
      return SizedBox.square(dimension: large ? 76 : 48, child: loading
        ? Padding(padding: EdgeInsets.all(large ? 22 : 14), child: const CircularProgressIndicator(strokeWidth: 2, color: _mint))
        : IconButton.filled(
          tooltip: playing ? 'Pause' : 'Play',
          style: IconButton.styleFrom(backgroundColor: _mint, foregroundColor: const Color(0xFF17210F)),
          iconSize: large ? 40 : 28,
          onPressed: controller.togglePlayback,
          icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
        ));
    },
  );
}

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.controller});
  final PlayerController controller;
  String _time(Duration value) => '${value.inMinutes}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final track = controller.currentTrack;
      if (track == null) return const SizedBox.shrink();
      return FractionallySizedBox(heightFactor: .95, child: SafeArea(child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
        child: Column(children: [
          Row(children: [IconButton(tooltip: 'Close player', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.keyboard_arrow_down_rounded)), const Expanded(child: Text('NOW PLAYING', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, letterSpacing: 2, color: _muted, fontWeight: FontWeight.w700))), const SizedBox(width: 48)]),
          const SizedBox(height: 24),
          TrackArtwork(url: track['thumbnails'] as String? ?? '', size: math.min(constraints.maxWidth - 56, 340)),
          const SizedBox(height: 32),
          Text(track['title'] as String, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 23, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: -.6)),
          const SizedBox(height: 12),
          Text(track['author'] as String, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 15)),
          const SizedBox(height: 28),
          if (controller.playbackError != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(controller.playbackError!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          StreamBuilder<Duration?>(stream: controller.player.durationStream, builder: (context, durationSnapshot) => StreamBuilder<Duration>(stream: controller.player.positionStream, builder: (context, positionSnapshot) {
            final total = controller.hasPlayableSource ? durationSnapshot.data ?? Duration.zero : Duration.zero;
            final position = controller.hasPlayableSource ? positionSnapshot.data ?? Duration.zero : Duration.zero;
            final max = total.inMilliseconds.toDouble();
            return Column(children: [
              Slider(value: position.inMilliseconds.toDouble().clamp(0.0, max > 0 ? max : 1.0), max: max > 0 ? max : 1.0, onChanged: max > 0 && controller.hasPlayableSource ? (value) => controller.player.seek(Duration(milliseconds: value.round())) : null),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_time(position), style: const TextStyle(color: _muted, fontSize: 12)), Text(_time(total), style: const TextStyle(color: _muted, fontSize: 12))])),
            ]);
          })),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(tooltip: 'Previous track', iconSize: 36, onPressed: controller.queueIndex > 0 && !controller.loadingTrack ? controller.previous : null, icon: const Icon(Icons.skip_previous_rounded)),
            const SizedBox(width: 20), PlayButton(controller: controller, large: true), const SizedBox(width: 20),
            IconButton(tooltip: 'Next track', iconSize: 36, onPressed: controller.queueIndex < controller.queue.length - 1 && !controller.loadingTrack ? controller.next : null, icon: const Icon(Icons.skip_next_rounded)),
          ]),
          const SizedBox(height: 20),
          TextButton.icon(onPressed: controller.toggleRepeat, icon: Icon(Icons.repeat_one_rounded, color: controller.repeat ? _mint : _muted), label: Text(controller.repeat ? 'Repeat on' : 'Repeat off', style: TextStyle(color: controller.repeat ? _mint : _muted))),
          Text('Track ${controller.queueIndex + 1} of ${controller.queue.length}', style: const TextStyle(color: _muted, fontSize: 12)),
        ]),
      ))));
    },
  );
}
