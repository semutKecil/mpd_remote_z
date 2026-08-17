import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/ui/widget/dialog/common_dialog.dart';
import 'package:orient_text_field/orient_text_field.dart';

class RenamePlaylistDialog extends StatefulWidget {
  final MpdPlaylist playlist;
  const RenamePlaylistDialog({super.key, required this.playlist});

  @override
  State<RenamePlaylistDialog> createState() => _RenamePlaylistDialogState();

  static Future<void> show(BuildContext context, MpdPlaylist playlist) async {
    var res = await showDialog<String?>(
      context: context,
      useRootNavigator: false,
      builder: (context) => RenamePlaylistDialog(playlist: playlist),
    );

    if (res == null) return;
    audioService.custom.rename(playlist.playlist, res);
  }
}

class _RenamePlaylistDialogState extends State<RenamePlaylistDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      titleText: "Rename playlist",
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Old Name :"),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
            title: TextFormField(
              initialValue: widget.playlist.playlist,
              readOnly: true,
            ),
          ),
          Text("New Name :"),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
            title: OrientTextField(
              autofocus: true,
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Insert new name",
                errorText: _error,
              ),
            ),
          ),
        ],
      ),
      actionsBuilder: (context) => [
        TextButton(
          onPressed: () {
            if (_controller.text.trim().isEmpty) {
              setState(() {
                _error = "Playlist name cannot be empty";
              });
              return;
            }

            return Navigator.of(context).pop(_controller.text.trim());
          },
          child: const Text("OK"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
