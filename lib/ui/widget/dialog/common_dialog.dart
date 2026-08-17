import 'package:flutter/material.dart';

class CommonDialog extends StatelessWidget {
  final String titleText;
  final Widget Function(BuildContext context) builder;
  final List<Widget> Function(BuildContext context)? actionsBuilder;
  const CommonDialog({
    super.key,
    required this.titleText,
    required this.builder,
    this.actionsBuilder,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String titleText,
    required Widget Function(BuildContext context) builder,
    List<Widget> Function(BuildContext context)? actionsBuilder,
  }) {
    return showDialog<T>(
      // useRootNavigator: true,
      useRootNavigator: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CommonDialog(
          titleText: titleText,
          builder: builder,
          actionsBuilder: actionsBuilder,
        );
      },
    );
  }

  static Future<void> showInfo(
    BuildContext context, {
    required String titleText,
    required String contentText,
  }) {
    return show<void>(
      context,
      titleText: titleText,
      builder: (context) =>
          Center(child: Text(contentText, textAlign: TextAlign.center)),
      actionsBuilder: (context) => [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK"),
        ),
      ],
    );
  }

  static Future<bool> showConfirm(
    BuildContext context, {
    required String titleText,
    required String contentText,
  }) async {
    var res = await show<bool>(
      context,
      titleText: titleText,
      builder: (context) =>
          Center(child: Text(contentText, textAlign: TextAlign.center)),
      actionsBuilder: (context) => [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text("OK"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
      ],
    );

    if (res == null) return false;
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      contentPadding: EdgeInsets.only(bottom: 10, left: 20, right: 20, top: 10),
      actionsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      title: Text(titleText),
      content: Center(child: builder(context)),
      actions: actionsBuilder?.call(context),
    );
  }
}
