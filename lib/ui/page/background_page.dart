import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/ui/widget/background_container.dart';

@RoutePage()
class BackgroundPage extends StatelessWidget {
  const BackgroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: BackgroundContainer.withArtBackground()),
        const AutoRouter(),
      ],
    );
  }
}
