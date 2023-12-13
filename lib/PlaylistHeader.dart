import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunetube/PlaylistStateManagement.dart';


class PlaylistHeader extends StatefulWidget {
  const PlaylistHeader({Key? key}) : super(key: key);

  @override
  _PlaylistHeaderState createState() => _PlaylistHeaderState();
}

class _PlaylistHeaderState extends State<PlaylistHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: ListTile(
        title: const Text(
          'Playlist',
          style: TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon:
              Provider.of<PlaylistStateManagement>(context, listen: false).buttonPressed
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
          color: Colors.white,
          onPressed: () {
            bool value =
                Provider.of<PlaylistStateManagement>(context, listen: false)
                    .buttonPressed;
            if (value) {
              // Pause the audio
             context.read<PlaylistStateManagement>().setButtonPressed(false);
              print("value changed to false");
              setState(() {});
            } else {
              // Play the audio
              context.read<PlaylistStateManagement>().setButtonPressed(true);
              print("value changed to true");
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
