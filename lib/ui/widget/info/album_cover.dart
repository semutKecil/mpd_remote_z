import 'package:flutter/material.dart';
import 'package:mpd_remote_z/ui/widget/info/cover_loader.dart';

class AlbumCover extends StatelessWidget {
  const AlbumCover({super.key});

  @override
  Widget build(BuildContext context) {
    return CoverLoader(
      builder: (context, file) => AnimatedSwitcher(
        duration: Duration(milliseconds: 1000),
        child: file != null
            ? SizedBox(
                key: ValueKey(file.path),
                height: double.infinity,
                width: double.infinity,
                child: Image.file(file, fit: BoxFit.cover),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
