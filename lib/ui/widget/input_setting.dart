import 'package:flutter/material.dart';
import 'package:mpd_remote_z/ui/widget/dialog/input_setting_dialog.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';

class InputSetting extends StatelessWidget {
  final String titleText;
  final Widget leading;
  final String? prefixText;
  final String? suffixText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final String? Function(String? value)? validator;
  final void Function(String value)? onChanged;
  const InputSetting({
    super.key,
    required this.titleText,
    required this.leading,
    this.prefixText,
    this.suffixText,
    this.initialValue,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTileDefault(
      leading: leading,
      title: Text(titleText),
      onTap: () async {
        var res = await InputSettingDialog.show(
          context,
          titleText,
          initialValue: initialValue,
          keyboardType: keyboardType,
          prefixText: prefixText,
          suffixText: suffixText,
          validator: validator,
        );

        if (res != null && res != initialValue) {
          onChanged?.call(res);
        }
      },
      trailing: Row(
        spacing: 5,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(prefixText ?? "", style: TextStyle(fontSize: 16)),
          Text(
            initialValue ?? "",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
            ),
          ),
          Text(suffixText ?? "", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
