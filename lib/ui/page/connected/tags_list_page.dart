import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/mpd/model/mpd_tag_group.dart';
import 'package:mpd_remote_z/ui/widget/future_widget.dart';
import 'package:mpd_remote_z/ui/widget/tile/general_tag_tile.dart';

@RoutePage()
class TagsListPage extends StatelessWidget {
  final String title;
  final String tag;
  const TagsListPage({
    super.key,
    @PathParam("title") required this.title,
    @PathParam("tag") required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: context.router.stack.length > 2
              ? IconButton(
                  onPressed: () {
                    AutoRouter.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back),
                )
              : null,
          title: Text(title),
          actions: [
            IconButton(
              onPressed: () {
                AutoRouter.of(context).push(SearchRoute(tags: tag));
              },
              icon: Icon(Icons.search),
            ),
          ],
        ),
        Expanded(
          child: FutureWidget<List<MpdTagGroup>>(
            future: () async => (await audioService.custom.list(
              tag,
            )).where((e) => e.value.isNotEmpty).toList(),
            builder: (context, data) {
              return data.isEmpty
                  ? Center(child: Text("Data not found"))
                  : ListView.builder(
                      // padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        return GeneralTagTile(
                          tag: tag,
                          value: data[index].value,
                          title: title,
                        );
                      },
                      itemCount: data.length,
                    );
            },
          ),
        ),
      ],
    );
  }
}
