import 'package:flutter/material.dart';
import 'package:mpd_remote_z/service/u.dart';
import 'package:mpd_remote_z/ui/widget/info/cover_loader.dart';

class BackgroundContainer extends StatelessWidget {
  final bool withArtBackground;
  const BackgroundContainer({super.key, this.withArtBackground = false});

  factory BackgroundContainer.withArtBackground() =>
      const BackgroundContainer(withArtBackground: true);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: colorScheme.surface,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: .5,
            child: withArtBackground
                ? CoverLoader(
                    builder: (context, file) {
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 1000),
                        child: file == null
                            ? const SizedBox.shrink()
                            : SizedBox(
                                key: ValueKey(file.path),
                                width: double.infinity,
                                height: double.infinity,
                                child: Image.file(file, fit: BoxFit.cover),
                              ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.surfaceContainerHigh.withAlpha(150),
                colorScheme.primaryContainer.withAlpha(200),
                colorScheme.primaryContainer.darken(0.07),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              stops: const [.2, 0.5, 0.7],
            ),
          ),
        ),
      ],
    );
  }
}
