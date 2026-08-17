import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/ui/widget/dialog/common_dialog.dart';
import 'package:mpd_remote_z/ui/widget/menu/simple_popup_menu.dart';
import 'package:orient_text_field/orient_text_field.dart';

class AddPlaylistDialog extends StatefulWidget {
  // final MpdSong song;
  final List<MpdPlaylist> playlists;
  const AddPlaylistDialog({
    super.key,
    // required this.song,
    required this.playlists,
  });

  static Future<void> addToPlaylist(
    BuildContext context,
    FutureOr<void> Function(String playlist) onSelected,
  ) async {
    var pl = await audioService.custom.listPlaylists();
    if (pl == null) return;
    if (!context.mounted) return;
    var res = await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return AddPlaylistDialog(playlists: pl);
      },
    );

    if (res is String) {
      await onSelected(res);
    }
  }

  @override
  State<AddPlaylistDialog> createState() => _AddPlaylistDialogState();
}

class _AddPlaylistDialogState extends State<AddPlaylistDialog> {
  final TextEditingController _newPlaylistController = TextEditingController();
  final TextEditingController _selectedPlaylist = TextEditingController();
  bool _createNew = false;
  final GlobalKey<PopupMenuButtonState> _popupKey =
      GlobalKey<PopupMenuButtonState>();
  // String _selectedPlaylist = "";
  String? _error;

  @override
  void dispose() {
    _newPlaylistController.dispose();
    _selectedPlaylist.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      titleText: "Add To Playlist",
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            readOnly: true,
            controller: _selectedPlaylist,
            onTap: () {
              _popupKey.currentState?.showButtonMenu();
            },
            decoration: InputDecoration(
              suffixIcon: SimplePopupMenu(
                popupMenuKey: _popupKey,
                icon: Icon(Icons.arrow_drop_down),
                items: Map<String, void Function()>.fromEntries(
                  widget.playlists.map((e) {
                    return MapEntry(e.playlist, () {
                      _selectedPlaylist.text = e.playlist;
                    });

                    // PopupMenuItem<String>(
                    //   value: e.playlist,
                    //   child: Text(e.playlist, style: TextStyle(fontSize: 18)),
                    // );
                  }).toList(),
                ),
              ),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              shadowColor:
                  Colors.transparent, // Also remove hover color if needed
            ),
            child: CheckboxListTile(
              title: Text("Create new playlist"),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              splashRadius: 0.0,
              value: _createNew,
              onChanged: (value) {
                setState(() {
                  _createNew = !_createNew;
                });
              },
            ),
          ),
          _createNew
              ? OrientTextField(
                  controller: _newPlaylistController,
                  autofocus: true,
                  decoration: InputDecoration(hintText: "Playlist name"),
                )
              : SizedBox.shrink(),
          _error != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
      actionsBuilder: (context) => [
        TextButton(
          onPressed: () {
            if (_createNew && _newPlaylistController.text.trim().isEmpty) {
              setState(() {
                _error = "Playlist name cannot be empty";
              });
              return;
            } else if (!_createNew && _selectedPlaylist.text.isEmpty) {
              setState(() {
                _error = "Please select a playlist";
              });
              return;
            }

            Navigator.of(
              context,
            ).pop(_createNew ? _newPlaylistController.text : _selectedPlaylist);
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
