import 'package:flutter/material.dart';

class ProgressMask extends StatelessWidget {
  const ProgressMask({super.key});

  static Future<T?> show<T>(
    BuildContext context,
    Future<T?> Function() progress,
  ) {
    return showDialog<T>(
      // useRootNavigator: true,
      context: context,
      useRootNavigator: false,
      builder: (context) {
        Future(() {
          progress().then((value) {
            if (!context.mounted) return;
            Navigator.of(context).pop(value);
          });
        });
        return const ProgressMask();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surface.withAlpha(100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            spacing: 5,
            children: [
              Expanded(
                child: Center(child: CircularProgressIndicator(strokeWidth: 4)),
              ),
              Text("Loading"),
            ],
          ),
        ),
      ),
    );
  }
}
