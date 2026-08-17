import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/ui/widget/dialog/common_dialog.dart';
import 'package:orient_text_field/orient_text_field.dart';

class NewPartitionDialog extends StatefulWidget {
  const NewPartitionDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    var res = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) => const NewPartitionDialog(),
    );

    if (res == null) return false;
    await audioService.custom.newPartition(res);
    return true;
  }

  @override
  State<NewPartitionDialog> createState() => _NewPartitionDialogState();
}

class _NewPartitionDialogState extends State<NewPartitionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      titleText: "New Partition",
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name :"),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
            title: OrientTextField(
              controller: _controller,
              autocorrect: true,
              decoration: InputDecoration(hintText: "Insert name"),
            ),
          ),
        ],
      ),

      actionsBuilder: (context) => [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
