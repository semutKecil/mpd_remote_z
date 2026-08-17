import 'package:flutter/material.dart';
import 'package:mpd_remote_z/ui/widget/dialog/common_dialog.dart';
import 'package:orient_text_field/orient_text_field.dart';

class InputSettingDialog extends StatefulWidget {
  final String titleText;
  final String? prefixText;
  final String? suffixText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final String? Function(String? value)? validator;
  const InputSettingDialog({
    super.key,
    required this.titleText,
    this.prefixText,
    this.suffixText,
    this.initialValue,
    this.keyboardType,
    this.validator,
  });

  static Future<String?> show(
    BuildContext context,
    String titleText, {
    String? initialValue,
    String? Function(String? value)? validator,
    String? prefixText,
    String? suffixText,
    TextInputType? keyboardType,
  }) async {
    return await showDialog<String?>(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return InputSettingDialog(
          titleText: titleText,
          initialValue: initialValue,
          validator: validator,
          prefixText: prefixText,
          suffixText: suffixText,
          keyboardType: keyboardType,
        );
      },
    );
  }

  @override
  State<InputSettingDialog> createState() => _InputSettingDialogState();
}

class _InputSettingDialogState extends State<InputSettingDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _controller.text = widget.initialValue ?? "";
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      titleText: widget.titleText,
      builder: (context) => Form(
        key: _formKey,
        child: OrientTextFormField(
          autofocus: true,
          validator: widget.validator,
          controller: _controller,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
          ),
          onFieldSubmitted: (value) {
            if (_formKey.currentState?.validate() != true) {
              return;
            }
            Navigator.of(context).pop(_controller.text);
          },
        ),
      ),
      actionsBuilder: (context) => [
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) {
              return;
            }
            Navigator.of(context).pop(_controller.text);
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
  }
}
