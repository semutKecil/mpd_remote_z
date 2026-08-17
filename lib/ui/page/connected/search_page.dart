import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_song.dart';
import 'package:mpd_remote_z/ui/page/connected/album_list_page.dart';
import 'package:mpd_remote_z/ui/widget/loading_display.dart';
import 'package:mpd_remote_z/ui/widget/menu/simple_popup_menu.dart';
import 'package:mpd_remote_z/ui/widget/tile/album_card.dart';
import 'package:mpd_remote_z/ui/widget/tile/general_tag_tile.dart';
import 'package:mpd_remote_z/ui/widget/tile/song_tile.dart';
import 'package:orient_text_field/orient_text_field.dart';

enum Tags {
  title("Title", "Title"),
  album("Album", "Album"),
  artist("Artist", "Artist"),
  genre("Genre", "Genre"),
  composer("Composer", "Composer"),
  performer("Performer", "Performer"),
  conductor("Conductor", "Conductor");

  final String value;
  final String label;
  const Tags(this.value, this.label);
}

@RoutePage()
class SearchPage extends StatefulWidget {
  final String? tags;
  const SearchPage({super.key, @PathParam('tags') this.tags});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> result = [];
  bool isLoading = false;
  Tags searchType = Tags.title;
  final searchController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // print("tags :${widget.tags}");
    if (widget.tags != null) {
      searchType = Tags.values.firstWhere((e) => e.value == widget.tags);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> search() async {
    if (searchController.text.trim().isEmpty) return;
    setState(() {
      isLoading = true;
    });
    result.clear();
    switch (searchType) {
      case Tags.title:
        result = await audioService.custom.search(
          '(${searchType.value} contains "${searchController.text}")',
        );
        break;
      case Tags.album:
        result =
            (await audioService.custom.list("AlbumArtist", groups: ["Album"]))
                .where(
                  (e) => e.value.toLowerCase().contains(
                    searchController.text.toLowerCase(),
                  ),
                )
                .map(
                  (e) => AlbumAndArtist(
                    album: e.value,
                    artist: e.children.map((a) => a.value).join(", "),
                  ),
                )
                .toList();
        break;
      default:
        result = (await audioService.custom.list(searchType.value))
            .where(
              (e) => e.value.toLowerCase().contains(
                searchController.text.toLowerCase(),
              ),
            )
            .map((e) => e.value)
            .toList();
        break;
    }
    setState(() {
      isLoading = false;
    });
    focusNode.unfocus();
  }

  Widget buildList() {
    if (result.isEmpty) {
      return const Center(child: Text("Nothing found, try again"));
    }
    if (searchType == Tags.title) {
      var data = result.whereType<MpdSong>().toList();
      return ListView.builder(
        // padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return SongTile(song: data[index]);
        },
      );
    } else if (searchType == Tags.album) {
      var data = result.whereType<AlbumAndArtist>().toList();
      return LayoutBuilder(
        builder: (context, constraints) {
          var albumWidth = 150.0;
          var row = (constraints.maxWidth / albumWidth).floor();

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: row, // number of columns
              crossAxisSpacing: 10, // horizontal spacing
              mainAxisSpacing: 8, // vertical spacing
            ),
            itemBuilder: (context, index) {
              return AlbumCard(
                key: ValueKey("$index-${data[index].album}"),
                data: data[index],
              );
            },
            itemCount: data.length,
          );
        },
      );
    } else {
      var data = result.whereType<String>().toList();
      return ListView.builder(
        // padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return GeneralTagTile(
            tag: searchType.value,
            value: data[index],
            title: searchType.label,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var searchText = OrientTextField(
      autofocus: true,
      controller: searchController,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: searchType.label,
        //  Scaffold.of(context).openDrawer()
        // prefixIcon: widget.tags == null ? Icon(Icons.search) : null,
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            context.router.stack.length > 2
                ? IconButton(
                    onPressed: () {
                      AutoRouter.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back),
                  )
                : IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(Icons.menu),
                  ),
            Icon(Icons.search),
          ],
        ),
        contentPadding: EdgeInsets.zero,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                search();
              },
            ),
            widget.tags == null
                ? SimplePopupMenu(
                    icon: Icon(Icons.arrow_drop_down),
                    items: Map<String, void Function()>.fromEntries(
                      Tags.values.map((e) {
                        return MapEntry(e.value, () {
                          setState(() {
                            searchType = e;
                            result = [];
                            search();
                          });
                        });
                      }).toList(),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
      onSubmitted: (value) {
        search();
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBar(automaticallyImplyLeading: false, title: searchText),
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 5),
          child: Text("Search for [${searchType.label}]"),
        ),
        Expanded(child: isLoading ? const LoadingDisplay() : buildList()),
      ],
    );
  }
}
