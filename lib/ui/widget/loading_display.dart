import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingDisplay extends StatelessWidget {
  const LoadingDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    var spinkit = SpinKitSpinningLines(
      color: Theme.of(context).colorScheme.primary.withAlpha(150),
      size: 50.0,
    );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          spinkit,
          Text(
            "Loading...",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}
