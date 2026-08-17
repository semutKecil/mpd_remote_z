import 'package:flutter/material.dart';
import 'package:mpd_remote_z/ui/widget/loading_display.dart';

class LoadingMask extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  const LoadingMask({super.key, required this.child, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        AnimatedSwitcher(
          duration: Duration(milliseconds: 1000),
          child: isLoading
              ? Container(
                  key: ValueKey("loading-mask"),
                  width: double.infinity,
                  height: double.infinity,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                  child: Material(
                    color: Colors.transparent,
                    child: Center(child: LoadingDisplay()),
                  ),
                )
              : SizedBox.shrink(key: ValueKey("loading-mask-hide")),
        ),
      ],
    );
  }
}
