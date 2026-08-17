import 'package:flutter/material.dart';

class ListTileDefault extends StatefulWidget {
  final bool? multiSelectMode;
  final GestureTapCallback? onTap;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool selected;
  const ListTileDefault({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.selected = false,
    this.multiSelectMode,
  });

  @override
  State<ListTileDefault> createState() => _ListTileDefaultState();
}

class _ListTileDefaultState extends State<ListTileDefault> {
  bool _isMultiSelect = false;
  bool _selected = false;

  @override
  void initState() {
    super.initState();
    if (widget.multiSelectMode != null) {
      _isMultiSelect = widget.multiSelectMode!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: widget.title,
        selected: widget.selected,
        subtitle: widget.subtitle,
        trailing: _isMultiSelect ? null : widget.trailing,
        contentPadding: const EdgeInsets.only(left: 20, right: 20),
        leading: _isMultiSelect
            ? Container(
                width: 20,
                color: Colors.red,
                child: Checkbox(
                  value: _selected,
                  onChanged: (value) =>
                      setState(() => _selected = value ?? false),
                  splashRadius: 0,
                ),
              )
            : widget.leading,
        onTap: _isMultiSelect
            ? () {
                setState(() {
                  _selected = !_selected;
                });
              }
            : widget.onTap,
        onLongPress: widget.multiSelectMode != null
            ? () {
                setState(() {
                  if (!_isMultiSelect) {
                    setState(() {
                      _isMultiSelect = true;
                      _selected = true;
                    });
                  }
                });
              }
            : null,
      ),
    );
  }
}
