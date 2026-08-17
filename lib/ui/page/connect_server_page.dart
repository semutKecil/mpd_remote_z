import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mpd_remote_z/main.dart';
import 'package:mpd_remote_z/model/server_info.dart';
import 'package:mpd_remote_z/ui/widget/dialog/common_dialog.dart';
import 'package:mpd_remote_z/ui/widget/loading_mask.dart';
import 'package:orient_text_field/orient_text_field.dart';

@RoutePage()
class ConnectServerPage extends StatefulWidget {
  final ServerInfo? serverInfo;
  final FutureOr<void> Function(BuildContext context)? onConnect;
  const ConnectServerPage({super.key, this.serverInfo, this.onConnect});

  @override
  State<ConnectServerPage> createState() => _ConnectServerPageState();
}

class _ConnectServerPageState extends State<ConnectServerPage> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  // late final StreamSubscription<dynamic> _sub;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  String? _passwordError;
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.serverInfo?.name ?? "My Mpd Server";
    _hostController.text = widget.serverInfo?.host ?? "127.0.0.1";
    _portController.text = widget.serverInfo?.port.toString() ?? "6600";
    _passwordController.text = widget.serverInfo?.password ?? "";
  }

  @override
  void dispose() {
    // _sub.cancel();
    _hostController.dispose();
    _nameController.dispose();
    _portController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingMask(
      isLoading: _loading,
      child: Scaffold(
        appBar: AppBar(title: const Text("Connect to Server")),
        resizeToAvoidBottomInset:
            MediaQuery.orientationOf(context) != Orientation.landscape,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          title: OrientTextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Name *",
                              helperText: "Input unique server name",
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          title: OrientTextFormField(
                            controller: _hostController,
                            decoration: InputDecoration(
                              labelText: "Host *",
                              helperText: "example : 192.168.100.100",
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          title: OrientTextFormField(
                            controller: _portController,
                            decoration: InputDecoration(
                              labelText: "Port *",
                              helperText: "example : 6600",
                            ),
                            keyboardType: TextInputType.number,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Field is required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid port';
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          title: OrientTextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.password),
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _passwordError = null;
                              });
                            },
                            forceErrorText: _passwordError,
                            fullScreenFieldConfig: FullScreenFieldConfig(
                              withObscureToggle: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FilledButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() != true) {
                          return;
                        }
                        setState(() {
                          _loading = true;
                        });
                        Future.delayed(Duration(seconds: 5));
                        try {
                          await audioService.custom.connect(
                            widget.serverInfo?.copyWith(
                                  name: _nameController.text,
                                  host: _hostController.text,
                                  port: int.parse(_portController.text),
                                  password: _passwordController.text.isEmpty
                                      ? null
                                      : _passwordController.text,
                                ) ??
                                ServerInfo.create(
                                  name: _nameController.text,
                                  host: _hostController.text,
                                  port: int.parse(_portController.text),
                                  password: _passwordController.text.isEmpty
                                      ? null
                                      : _passwordController.text,
                                ),
                          );
                          if (context.mounted) {
                            widget.onConnect?.call(context);
                          }
                        } catch (e, s) {
                          if (!context.mounted) return;
                          if (e.toString().contains("invalid password")) {
                            setState(() {
                              _passwordError = "Invalid password";
                            });
                          } else {
                            debugPrintStack(stackTrace: s, label: e.toString());
                            CommonDialog.showInfo(
                              context,
                              titleText: "Connection Failed",
                              contentText:
                                  "Can't connect to server. Invalid connection settings",
                            );
                          }
                        }
                        setState(() {
                          _loading = false;
                        });
                      },
                      child: Text("Connect"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // PageWarp(
      //   bottomPadding: true,
      //   child:
      // ),
    );
  }
}
