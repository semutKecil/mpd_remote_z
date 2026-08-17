import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/app_router.gr.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/model/server_info.dart';
import 'package:mpd_remote_z/mpd/model/mpd_consume_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_random_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_repeat_mode.dart';
import 'package:mpd_remote_z/mpd/model/mpd_single_mode.dart';
import 'package:mpd_remote_z/mpd/string_ext.dart';
import 'package:mpd_remote_z/ui/widget/dialog/common_dialog.dart';
import 'package:mpd_remote_z/ui/widget/future_widget.dart';
import 'package:mpd_remote_z/ui/widget/status_input_setting.dart';
import 'package:mpd_remote_z/ui/widget/status_option_setting.dart';
import 'package:mpd_remote_z/ui/widget/status_switch_setting.dart';
import 'package:mpd_remote_z/ui/widget/tile/list_tile_default.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          title: FutureBuilder<ServerInfo?>(
            future: ServerInfo.getCurrentServer(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Settings"),
                    Text(
                      "MPD ${snapshot.data!.version}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                );
              }
              return const Text("Settings");
            },
          ),
        ),
        Expanded(
          child: FutureWidget(
            future: ServerInfo.getCurrentServer,
            builder: (context, data) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("Playback"),
                  ),
                  StatusSwitchSetting(
                    leading: CircleAvatar(child: Icon(Icons.repeat)),
                    title: Text("Repeat"),
                    condition: (status) {
                      return status.repeat == MpdRepeatMode.on;
                    },
                    action: (value) {
                      audioService.custom.toggleRepeat();
                    },
                  ),
                  StatusSwitchSetting(
                    leading: CircleAvatar(child: Icon(Icons.shuffle)),
                    title: Text("Random"),
                    condition: (status) {
                      return status.random == MpdRandomMode.on;
                    },
                    action: (value) {
                      audioService.custom.toggleRandom();
                    },
                  ),
                  StatusOptionSetting<MpdSingleMode>(
                    leading: CircleAvatar(
                      child: Icon(Icons.looks_one_outlined),
                    ),
                    title: Text("Single"),
                    options: Map.fromEntries(
                      MpdSingleMode.values.map(
                        (e) => MapEntry(e, e.name.capitalize()),
                      ),
                    ),
                    action: (value) {
                      audioService.custom.setSingle(value);
                    },
                    condition: (status) => status.single,
                  ),
                  data?.version?.isVersionSupported("0.24") == true
                      ? StatusOptionSetting<MpdConsumeMode>(
                          leading: CircleAvatar(
                            child: Icon(Icons.playlist_remove),
                          ),
                          title: Text("Consume"),
                          options: Map.fromEntries(
                            MpdConsumeMode.values.map(
                              (e) => MapEntry(e, e.name.capitalize()),
                            ),
                          ),
                          action: (value) {
                            audioService.custom.setConsume(value);
                          },
                          condition: (status) => status.consume,
                        )
                      : StatusSwitchSetting(
                          leading: CircleAvatar(
                            child: Icon(Icons.playlist_remove),
                          ),
                          title: Text("Consume"),
                          condition: (status) {
                            return status.consume != MpdConsumeMode.off;
                          },
                          action: (value) {
                            audioService.custom.toggleConsume();
                          },
                        ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(child: Text("Crossfade")),
                        GestureDetector(
                          onTap: () {
                            launchUrl(
                              Uri.parse(
                                "https://mpd.readthedocs.io/en/latest/user.html#crossfading",
                              ),
                              mode: LaunchMode.inAppBrowserView,
                            );
                          },
                          child: Icon(Icons.help_outline, size: 16),
                        ),
                      ],
                    ),
                  ),

                  StatusInputSetting(
                    leading: CircleAvatar(child: Icon(Icons.multiple_stop)),
                    titleText: "Crossfade",
                    suffixText: "S",
                    initialValue: "0",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field is required";
                      }
                      var dbl = int.tryParse(value);
                      if (dbl == null) return "Value must be a number";
                      if (dbl < 0) return "Value must be greater than 0";
                      return null;
                    },
                    action: (value) {
                      audioService.custom.crossFade(int.parse(value));
                    },
                    condition: (status) =>
                        status.xfade?.toStringAsFixed(0) ?? "0",
                  ),

                  StatusInputSetting(
                    leading: CircleAvatar(
                      child: Icon(Icons.volume_mute_outlined),
                    ),
                    titleText: "Max Ramp Db",
                    suffixText: "db",
                    initialValue: "0",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field is required";
                      }
                      var dbl = int.tryParse(value);
                      if (dbl == null) return "Value must be a number";
                      return null;
                    },
                    action: (value) {
                      var db = int.parse(value);
                      if (db > 0) {
                        db * -1;
                      }
                      audioService.custom.mixRampDb(db);
                    },
                    condition: (status) =>
                        status.mixrampDb?.toStringAsFixed(0) ?? "0",
                  ),

                  StatusInputSetting(
                    leading: CircleAvatar(child: Icon(Icons.timer)),
                    titleText: "Max Ramp Delay",
                    suffixText: "S",
                    initialValue: "0",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field is required";
                      }
                      return null;
                    },
                    action: (value) {
                      var db = int.tryParse(value);

                      audioService.custom.mixRampDelay(
                        db == null ? "nan" : value,
                      );
                    },
                    condition: (status) =>
                        status.mixrampDelay?.toStringAsFixed(0) ?? "0",
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("ReplayGain"),
                  ),
                  StatusOptionSetting<MpdReplayGainMode>(
                    leading: CircleAvatar(child: Icon(Icons.equalizer)),
                    title: Text("ReplayGain Mode"),
                    options: Map.fromEntries(
                      MpdReplayGainMode.values.map(
                        (e) => MapEntry(e, e.name.capitalize()),
                      ),
                    ),
                    action: (value) {
                      audioService.custom.replayGainMode(value);
                    },
                    condition: (status) =>
                        audioService.custom.replayGainStatus(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("Database"),
                  ),
                  ListTileDefault(
                    leading: CircleAvatar(child: Icon(Icons.replay_outlined)),
                    title: Text("Update"),
                    onTap: () async {
                      var update = await CommonDialog.showConfirm(
                        context,
                        titleText: "Update Database",
                        contentText:
                            "Updating database will take a while. Do you want to continue?",
                      );
                      if (update) {
                        await audioService.custom.update();
                        // Fluttertoast.showToast(
                        //   msg: "Updating database",
                        //   toastLength: Toast.LENGTH_SHORT,
                        //   gravity: ToastGravity.BOTTOM,
                        //   timeInSecForIosWeb: 1,
                        //   backgroundColor: Colors.red,
                        //   textColor: Colors.white,
                        //   fontSize: 16.0,
                        // );
                      }
                    },
                  ),
                  ListTileDefault(
                    leading: CircleAvatar(
                      child: Icon(Icons.screen_search_desktop_outlined),
                    ),
                    title: Text("Rescan"),
                    onTap: () async {
                      var update = await CommonDialog.showConfirm(
                        context,
                        titleText: "Update Database",
                        contentText:
                            "Rescanning database will take a while. Do you want to continue ?",
                      );

                      if (update) {
                        await audioService.custom.rescan();
                        // Fluttertoast.showToast(
                        //   msg: "Rescanning database",
                        //   toastLength: Toast.LENGTH_SHORT,
                        //   gravity: ToastGravity.BOTTOM,
                        //   timeInSecForIosWeb: 1,
                        //   backgroundColor: Colors.red,
                        //   textColor: Colors.white,
                        //   fontSize: 16.0,
                        // );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("Partition & Output"),
                  ),
                  ListTileDefault(
                    leading: CircleAvatar(
                      child: Icon(Icons.library_books_outlined),
                    ),
                    title: Text("Partition & Output"),
                    onTap: () {
                      AutoRouter.of(context).push(PartitionRoute());
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
