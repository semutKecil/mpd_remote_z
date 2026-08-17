import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/model/server_info.dart';
import 'package:mpd_remote_z/ui/page/connect_server_page.dart';
import 'package:mpd_remote_z/ui/widget/dialog/common_dialog.dart';
import 'package:mpd_remote_z/ui/widget/menu/simple_popup_menu.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';

@RoutePage()
class ServerListPage extends StatefulWidget {
  final FutureOr<void> Function(BuildContext context)? onConnect;
  const ServerListPage({super.key, this.onConnect});

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  List<ServerInfo> _data = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _data = await findAllServer();
      if (mounted && context.mounted) {
        setState(() {});
      }
    });
  }

  Future<List<ServerInfo>> findAllServer() async {
    return await ServerInfo.findAll();
  }

  Future<void> connect(ServerInfo info) async {
    try {
      await audioService.custom.connect(info);
      if (context.mounted && mounted) {
        widget.onConnect?.call(context);
      }
    } catch (e, s) {
      if (!context.mounted) return;
      if (e.toString().contains("invalid password")) {
        if (context.mounted && mounted) {
          CommonDialog.showInfo(
            context,
            titleText: "Invalid Password",
            contentText: "Can't connect to server. Invalid password",
          );
        }
      } else {
        debugPrintStack(stackTrace: s, label: e.toString());
        if (context.mounted && mounted) {
          CommonDialog.showInfo(
            context,
            titleText: "Connection Failed",
            contentText: "Can't connect to server. Invalid connection settings",
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Servers"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ConnectServerPage(onConnect: widget.onConnect),
                ),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: _data.isEmpty
          ? EmptyMessage(text: "No Server available. Add one.")
          : ListView.builder(
              // padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                return ListTileDefault(
                  key: ValueKey(_data[index].id),
                  leading: Icon(Icons.lan),
                  title: Text(_data[index].name),
                  subtitle: Text("${_data[index].host}:${_data[index].port}"),
                  trailing: SimplePopupMenu(
                    icon: Icon(Icons.more_horiz),
                    items: {
                      "Connect": () async {
                        connect(_data[index]);
                      },
                      "Edit": () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConnectServerPage(
                              onConnect: widget.onConnect,
                              serverInfo: _data[index],
                            ),
                          ),
                        );
                      },
                      "Delete": () async {
                        await ServerInfo.delete(_data[index]);
                        if (mounted && context.mounted) {
                          _data.removeAt(index);
                          setState(() {});
                        }
                      },
                    },
                  ),
                  onTap: () {
                    connect(_data[index]);
                  },
                );
              },
              itemCount: _data.length,
            ),
    );
  }
}

class EmptyMessage extends StatelessWidget {
  final String text;
  const EmptyMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 50,
          ),
          Text(text),
        ],
      ),
    );
  }
}
