import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SimpleCircularSlider extends StatefulWidget {
  final double angleMax;
  final double angleStart;
  final double? initialValue;
  final double min;
  final double max;
  final int? divisions;
  final FutureOr<void> Function(double value)? onChanged;
  final FutureOr<void> Function(double value)? onChangedEnd;
  final SimpleCircularSliderStyle? style;
  final SimpleCircularSliderStyle? activeStyle;
  final Widget Function(BuildContext context, double value)? builder;
  const SimpleCircularSlider({
    super.key,
    this.initialValue,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.angleMax = 1.5 * pi,
    this.angleStart = pi / 1.3333333333333333,
    this.style,
    this.activeStyle,
    this.onChanged,
    this.onChangedEnd,
    this.builder,
  });

  @override
  State<SimpleCircularSlider> createState() => _SimpleCircularSliderState();
}

class _SimpleCircularSliderState extends State<SimpleCircularSlider>
    with SingleTickerProviderStateMixin {
  bool _process = false;
  bool _dragStart = false;

  double _value = 0;
  bool _initialized = false;

  late final AnimationController _controller;
  Animation<double>? _radiusShadowAnimation;
  Animation<double>? _radiusAnimation;
  Animation<double>? _trackWidthAnimation;
  Animation<double>? _progressWidthAnimation;
  Animation<Color?>? _shadowColorAnimation;
  Animation<Color?>? _pointerColorAnimation;
  Animation<Color?>? _trackColorAnimation;
  Animation<Color?>? _progressColorAnimation;
  late final SimpleCircularSliderStyle _styleActive;
  late final SimpleCircularSliderStyle _styleInActive;

  late final double _padding;
  // late SimpleCircularSliderStyle _style;

  @override
  void initState() {
    super.initState();
    if (widget.min == 0 && widget.max == 1) {
      _value = widget.initialValue ?? 0;
    } else {
      _value =
          (widget.initialValue ?? widget.min - widget.min) /
          (widget.max - widget.min);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _styleInActive = widget.style ?? SimpleCircularSliderStyle.of(context);
      _styleActive =
          widget.activeStyle ?? _styleInActive.copyWith(pointerShadowSize: 32);

      // _style = _styleInActive;

      _padding = <double>[
        _styleActive.trackWidth / 2,
        _styleActive.progressWidth / 2,
        _styleActive.pointerSize,
        _styleActive.pointerShadowSize,
        _styleInActive.trackWidth / 2,
        _styleInActive.progressWidth / 2,
        _styleInActive.pointerSize,
        _styleInActive.pointerShadowSize,
      ].reduce(max);

      _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 100),
      );

      if (_styleInActive.pointerShadowSize != _styleActive.pointerShadowSize) {
        _radiusShadowAnimation =
            Tween<double>(
              begin: _styleInActive.pointerShadowSize,
              end: _styleActive.pointerShadowSize,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            );
      }

      if (_styleInActive.pointerSize != _styleActive.pointerSize) {
        _radiusAnimation =
            Tween<double>(
              begin: _styleInActive.pointerSize,
              end: _styleActive.pointerSize,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.bounceInOut),
            );
      }

      if (_styleInActive.trackWidth != _styleActive.trackWidth) {
        _trackWidthAnimation =
            Tween<double>(
              begin: _styleInActive.trackWidth,
              end: _styleActive.trackWidth,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.bounceInOut),
            );
      }

      if (_styleInActive.progressWidth != _styleActive.progressWidth) {
        _progressWidthAnimation =
            Tween<double>(
              begin: _styleInActive.progressWidth,
              end: _styleActive.progressWidth,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.bounceInOut),
            );
      }

      if (_styleInActive.pointerShadowColor !=
          _styleActive.pointerShadowColor) {
        _shadowColorAnimation =
            ColorTween(
              begin: _styleInActive.pointerShadowColor,
              end: _styleActive.pointerShadowColor,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            );
      }

      if (_styleInActive.pointerColor != _styleActive.pointerColor) {
        _pointerColorAnimation =
            ColorTween(
              begin: _styleInActive.pointerColor,
              end: _styleActive.pointerColor,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            );
      }

      if (_styleInActive.trackColor != _styleActive.trackColor) {
        _trackColorAnimation =
            ColorTween(
              begin: _styleInActive.trackColor,
              end: _styleActive.trackColor,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            );
      }

      if (_styleInActive.progressColor != _styleActive.progressColor) {
        _progressColorAnimation =
            ColorTween(
              begin: _styleInActive.progressColor,
              end: _styleActive.progressColor,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double realValue() => _value * (widget.max - widget.min) + widget.min;

  void updateValue(Offset localPosition, Size size, {bool force = false}) {
    final center = size.center(Offset.zero);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    double angle = atan2(dy, dx);
    if (angle < 0) angle += 2 * pi;
    var aValue = angle > widget.angleStart
        ? ((angle - widget.angleStart) / widget.angleMax)
        : ((angle - widget.angleStart + (2 * pi)) / widget.angleMax);

    if (aValue < 0 || aValue > 1) return;

    if (!(force || _dragStart) && (aValue - _value).abs() > 0.2) {
      inActivateStyle();
      return;
    }

    _dragStart = false;

    if (widget.divisions != null) {
      aValue = (aValue * widget.divisions!).round() / widget.divisions!;
    }

    if (aValue != _value) {
      setState(() {
        _value = aValue;
      });
    }
  }

  void inActivateStyle() {
    _process = false;
    _dragStart = false;
    _controller.reverse();
  }

  void activateStyle() {
    _process = true;
    _dragStart = true;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onPanEnd: (details) {
                      if (_process) {
                        final box = context.findRenderObject() as RenderBox;
                        updateValue(
                          box.globalToLocal(details.globalPosition),
                          box.size,
                          force: true,
                        );
                      }
                      inActivateStyle();
                      widget.onChangedEnd?.call(realValue());
                    },
                    onPanUpdate: (details) {
                      if (_process) {
                        final box = context.findRenderObject() as RenderBox;
                        updateValue(
                          box.globalToLocal(details.globalPosition),
                          box.size,
                        );
                      }
                      widget.onChanged?.call(realValue());
                    },
                    onPanStart: (details) {
                      activateStyle();
                    },
                    child: Container(
                      width: size,
                      height: size,
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(_padding),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _CircularPainter(
                                value: _value,
                                start: widget.angleStart,
                                trackColor:
                                    _trackColorAnimation?.value ??
                                    _styleInActive.trackColor,
                                progressColor:
                                    _progressColorAnimation?.value ??
                                    _styleInActive.progressColor,
                                pointerColor:
                                    _pointerColorAnimation?.value ??
                                    _styleInActive.pointerColor,
                                pointerShadowColor:
                                    _shadowColorAnimation?.value ??
                                    _styleInActive.pointerShadowColor,
                                trackWidth:
                                    _trackWidthAnimation?.value ??
                                    _styleInActive.trackWidth,
                                progressWidth:
                                    _progressWidthAnimation?.value ??
                                    _styleInActive.progressWidth,
                                pointerSize:
                                    _radiusAnimation?.value ??
                                    _styleInActive.pointerSize,
                                pointerShadowSize:
                                    _radiusShadowAnimation?.value ??
                                    _styleInActive.pointerShadowSize,
                                max: widget.angleMax,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: size - _padding * 4,
                    height: size - _padding * 4,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: Center(
                      child:
                          widget.builder?.call(context, realValue()) ??
                          Container(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircularPainter extends CustomPainter {
  final double value;
  final double start;
  final Color progressColor;
  final Color trackColor;
  final Color pointerColor;
  final Color pointerShadowColor;
  final double trackWidth;
  final double progressWidth;
  final double pointerSize;
  final double pointerShadowSize;
  final double max;
  _CircularPainter({
    required this.value,
    required this.start,
    required this.progressColor,
    required this.trackColor,
    required this.pointerColor,
    required this.pointerShadowColor,
    this.pointerSize = 10,
    this.pointerShadowSize = 15,
    this.trackWidth = 12,
    this.progressWidth = 12,
    this.max = 1.5 * pi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width > size.height ? size.height / 2 : size.width / 2;
    final center = size.center(Offset.zero);
    double maxedValue = value > 1
        ? 1
        : value < 0
        ? 0
        : value;

    var data = maxedValue * max;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = progressWidth
      ..strokeCap = StrokeCap.round;

    final shadowPointer = Paint()
      ..color = pointerShadowColor
      ..style = PaintingStyle.fill;

    final pointer = Paint()
      ..color = pointerColor
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      max,
      false,
      trackPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      data,
      false,
      progressPaint,
    );

    final double x = center.dx + radius * cos(data + start);
    final double y = center.dy + radius * sin(data + start);

    canvas.drawCircle(Offset(x, y), pointerShadowSize, shadowPointer);
    canvas.drawCircle(Offset(x, y), pointerSize, pointer);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SimpleCircularSliderStyle {
  final Color progressColor;
  final Color trackColor;
  final Color pointerColor;
  final Color pointerShadowColor;
  final double trackWidth;
  final double progressWidth;
  final double pointerSize;
  final double pointerShadowSize;

  SimpleCircularSliderStyle({
    this.progressColor = Colors.green,
    this.trackColor = Colors.grey,
    this.pointerColor = Colors.green,
    this.pointerShadowColor = Colors.grey,
    this.trackWidth = 12,
    this.progressWidth = 12,
    this.pointerSize = 15,
    this.pointerShadowSize = 15,
  });

  SimpleCircularSliderStyle copyWith({
    Color? progressColor,
    Color? trackColor,
    Color? pointerColor,
    Color? pointerShadowColor,
    double? trackWidth,
    double? progressWidth,
    double? pointerSize,
    double? pointerShadowSize,
  }) => SimpleCircularSliderStyle(
    progressColor: progressColor ?? this.progressColor,
    trackColor: trackColor ?? this.trackColor,
    pointerColor: pointerColor ?? this.pointerColor,
    pointerShadowColor: pointerShadowColor ?? this.pointerShadowColor,
    trackWidth: trackWidth ?? this.trackWidth,
    progressWidth: progressWidth ?? this.progressWidth,
    pointerSize: pointerSize ?? this.pointerSize,
    pointerShadowSize: pointerShadowSize ?? this.pointerShadowSize,
  );

  factory SimpleCircularSliderStyle.of(BuildContext context) =>
      SimpleCircularSliderStyle(
        progressColor: Theme.of(context).colorScheme.secondary,
        trackColor: Theme.of(context).colorScheme.primaryContainer,
        pointerColor: Theme.of(context).colorScheme.primary,
        pointerShadowColor: Theme.of(
          context,
        ).colorScheme.primary.withAlpha(100),
        trackWidth: 5,
        progressWidth: 5,
        pointerSize: 10,
        pointerShadowSize: 0,
      );

  // factory SimpleCircularSliderStyle.activeOf(BuildContext context) =>
  //     SimpleCircularSliderStyle(
  //       progressColor: Theme.of(context).colorScheme.secondary,
  //       trackColor: Theme.of(context).colorScheme.primaryContainer,
  //       pointerColor: Theme.of(context).colorScheme.primary,
  //       pointerShadowColor: Theme.of(
  //         context,
  //       ).colorScheme.primary.withAlpha(100),
  //       trackWidth: 5,
  //       progressWidth: 5,
  //       pointerSize: 10,
  //       pointerShadowSize: 32,
  //     );
}
