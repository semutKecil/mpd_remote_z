import 'package:flutter/material.dart';
import 'package:mpd_remote_z/ui/widget/loading_display.dart';

class FutureWidget<T> extends StatefulWidget {
  final Future<T> Function() future;
  final Widget Function(BuildContext context, T data) builder;
  const FutureWidget({super.key, required this.future, required this.builder});

  @override
  State<FutureWidget<T>> createState() => _FutureWidgetState<T>();
}

class _FutureWidgetState<T> extends State<FutureWidget<T>> {
  T? data;
  String? error;
  bool done = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return error != null
        ? Center(child: Text(error!))
        : done
        ? widget.builder(context, data as T)
        : FutureBuilder<T>(
            future: widget.future(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  debugPrintStack(stackTrace: snapshot.stackTrace);
                  error = snapshot.error.toString();
                  return Center(
                    key: ValueKey("error-data"),
                    child: Text(error!),
                  );
                } else {
                  data = snapshot.data;
                  // child = widget.builder(context, snapshot.data);
                  done = true;
                  return Builder(
                    key: ValueKey("success-data"),
                    builder: (context) {
                      return widget.builder(context, snapshot.data as T);
                    },
                  );
                }
              }
              return const LoadingDisplay(key: ValueKey("loading-data"));
            },
          );
  }
}
