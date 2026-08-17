import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/model/server_info.dart';
import 'package:mpd_remote_z/mpd/model/mpd_output.dart';
import 'package:mpd_remote_z/mpd/mpd_client.dart';
import 'package:mpd_remote_z/service/general_audio_handler.dart';
import 'package:mpd_remote_z/ui/widget/dialog/new_partition_dialog.dart';
import 'package:mpd_remote_z/ui/widget/loading_display.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';
import 'package:mpd_remote_z/ui/widget/dialog/simple_dialog_option_default.dart';
import 'package:mpd_remote_z/ui/widget/menu/simple_popup_menu.dart';

@RoutePage()
class PartitionPage extends StatefulWidget {
  const PartitionPage({super.key});

  @override
  State<PartitionPage> createState() => _PartitionPageState();
}

class _PartitionPageState extends State<PartitionPage> {
  final Map<String, List<MpdOutput>> outputs = {};
  String? _currentPartition;
  Map<String, List<MpdOutput>> _data = {};

  StreamSubscription? _sub;
  StreamSubscription? _subEvent;

  @override
  void initState() {
    _currentPartition = audioService.mpdStatus?.partition;
    super.initState();
    _sub = audioService.customEvent.listen((value) {
      if (value == AudioHandlerEvent.outputUpdate && mounted) {
        _loadPartitionOutput();
      }
    });

    _subEvent = audioService.customEvent.listen((value) async {
      if (value == AudioHandlerEvent.partitionChange && mounted) {
        _loadPartitionOutput();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _loadPartitionOutput();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _subEvent?.cancel();
    super.dispose();
  }

  Future<void> _loadPartitionOutput() async {
    var partitions = await audioService.custom.listPartitions();
    var cs = await ServerInfo.getCurrentServer();
    var client = await MpdClient.connect(
      host: cs!.host,
      port: cs.port,
      password: cs.password,
    );

    Map<String, List<MpdOutput>> res = {};

    for (var element in partitions) {
      await client.partition(element);
      var outputRes = await client.outputs();
      res[element] = outputRes.isValid
          ? outputRes.data.where((o) => o.plugin != "dummy").toList()
          : [];
    }
    client.disconnect();
    if (mounted && context.mounted) {
      setState(() {
        _currentPartition = audioService.mpdStatus?.partition;
        _data = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tile = [];
    for (var element in _data.entries) {
      tile.add(
        ListTileDefault(
          leading: CircleAvatar(child: Icon(Icons.meeting_room)),
          title: Text(element.key),
          onTap: () async {
            if (_currentPartition != element.key && element.value.isNotEmpty) {
              await audioService.custom.switchPartition(element.key);
            }
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              element.value.isEmpty && _currentPartition != element.key
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await audioService.custom.delPartition(element.key);
                        _loadPartitionOutput();
                      },
                    )
                  : SizedBox.shrink(),
              _currentPartition == element.key
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      width: 20,
                      height: 20,
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      );

      for (var output in element.value) {
        var items = {
          output.enabled ? "Disable" : "Enable": () async {
            var cs = await ServerInfo.getCurrentServer();
            var client = await MpdClient.connect(
              host: cs!.host,
              port: cs.port,
              password: cs.password,
              partition: element.key,
            );

            if (audioService.mpdStatus?.partition != element.key) {
              var cIdle = await MpdClient.connect(
                host: cs.host,
                port: cs.port,
                password: cs.password,
                partition: element.key,
              );
              cIdle.autoIdle(
                onOutput: () async {
                  await cIdle.noIdle();
                  await cIdle.disconnect();
                  _loadPartitionOutput();
                },
              );
            }
            await client.toggleOutput(output.id);
            await client.disconnect();
          },
        };

        if (_data.keys.length > 1) {
          items["Move"] = () async {
            var selected = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  title: const Text('Select Partition'),
                  children: _data.keys
                      .where((e) => e != element.key)
                      .map((e) => SimpleDialogOptionDefault(title: e, value: e))
                      .toList(),
                );
              },
            );

            if (selected != null) {
              var cs = await ServerInfo.getCurrentServer();
              var client = await MpdClient.connect(
                host: cs!.host,
                port: cs.port,
                password: cs.password,
                partition: selected,
              );
              await client.moveOutput(output.name);
              await client.disconnect();
            }
          };
        }

        tile.add(
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ListTileDefault(
              leading: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: output.enabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.errorContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(child: Icon(Icons.multitrack_audio)),
                ),
              ),
              title: Text(output.name),
              subtitle: Text(
                "plugin: ${output.plugin}${output.attribute == null ? "" : " - ${output.attribute}"}",
              ),
              onTap: () {},
              trailing: SimplePopupMenu(
                icon: Icon(Icons.more_horiz),
                items: items,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      children: [
        AppBar(
          leading: context.router.stack.length > 2
              ? IconButton(
                  onPressed: () {
                    AutoRouter.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back),
                )
              : null,
          title: Text("Partitions & Outputs"),
          actions: [
            IconButton(
              onPressed: () async {
                var res = await NewPartitionDialog.show(context);
                if (res) {
                  _loadPartitionOutput();
                }
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        Expanded(
          child: _data.isEmpty
              ? LoadingDisplay()
              : ListView(
                  // padding: EdgeInsets.symmetric(horizontal: 20),
                  children: tile,
                ),
        ),
      ],
    );
  }
}
