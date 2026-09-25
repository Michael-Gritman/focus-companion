import 'package:flutter/material.dart';

import '../domain/home_state.dart';

import '../theme/focus_theme.dart';

class FocusPrimaryButton extends StatefulWidget {
  const FocusPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailing,
    this.loading = false,
    this.semanticsLabel,
    this.faceColor,
    this.depthColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? trailing;
  final bool loading;
  final String? semanticsLabel;
  final Color? faceColor;
  final Color? depthColor;
  final Color? foregroundColor;

  @override
  State<FocusPrimaryButton> createState() => _FocusPrimaryButtonState();
}

class _FocusPrimaryButtonState extends State<FocusPrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  void didUpdateWidget(FocusPrimaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && _pressed) _pressed = false;
  }

  void _setPressed(bool value) {
    final next = _enabled && value;
    if (_pressed != next) setState(() => _pressed = next);
  }

  @override
  Widget build(BuildContext context) {
    final faceColor = _enabled
        ? widget.faceColor ?? FocusTokens.actionPrimary
        : FocusTokens.actionDisabled;
    final depthColor = _enabled
        ? widget.depthColor ?? FocusTokens.actionPrimaryDepth
        : FocusTokens.actionDisabledDepth;
    final foregroundColor = _enabled
        ? widget.foregroundColor ?? FocusTokens.onActionPrimary
        : FocusTokens.onActionDisabled;
    final radius = BorderRadius.circular(FocusTokens.primaryButtonRadius);

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticsLabel ?? widget.label,
      child: SizedBox(
        height:
            FocusTokens.primaryButtonFaceHeight +
            FocusTokens.primaryButtonDepth,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: FocusTokens.primaryButtonDepth,
              left: 0,
              right: 0,
              height: FocusTokens.primaryButtonFaceHeight,
              child: DecoratedBox(
                key: const Key('focus-primary-button-depth'),
                decoration: BoxDecoration(
                  color: depthColor,
                  borderRadius: radius,
                ),
              ),
            ),
            AnimatedPositioned(
              key: const Key('focus-primary-button-face-position'),
              duration: Duration(milliseconds: _pressed ? 70 : 110),
              curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
              top: _pressed ? FocusTokens.primaryButtonPressedTravel : 0,
              left: 0,
              right: 0,
              height: FocusTokens.primaryButtonFaceHeight,
              child: Material(
                color: faceColor,
                borderRadius: radius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _enabled ? widget.onPressed : null,
                  onHighlightChanged: _setPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.loading) ...[
                          SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: foregroundColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: foregroundColor,
                              fontSize: 16,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (widget.trailing case final trailing?) ...[
                          const SizedBox(width: 12),
                          IconTheme(
                            data: IconThemeData(
                              color: foregroundColor,
                              size: 20,
                            ),
                            child: trailing,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.color = FocusTokens.surface,
    this.padding = const EdgeInsets.all(22),
    this.border = true,
  });
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final bool border;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    elevation: border ? 1 : 0,
    shadowColor: const Color(0x22000000),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(FocusTokens.cardRadius),
      side: border
          ? const BorderSide(color: FocusTokens.line)
          : BorderSide.none,
    ),
    child: Padding(padding: padding, child: child),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.dark = false});
  final String label;
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: dark ? FocusTokens.sage : FocusTokens.accentLight,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: dark ? FocusTokens.onDark : FocusTokens.ink,
      ),
    ),
  );
}

class AppLabels extends StatelessWidget {
  const AppLabels(this.apps, {super.key, this.dark = false});
  final List<TargetApp> apps;
  final bool dark;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: apps
        .map(
          (name) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(
                color: dark ? FocusTokens.onDarkMuted : FocusTokens.line,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              name.name,
              style: TextStyle(
                fontSize: 12,
                color: dark ? FocusTokens.onDark : FocusTokens.muted,
              ),
            ),
          ),
        )
        .toList(),
  );
}

String clockLabel(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';
String timeLabel(DateTime time) => clockLabel(time.hour * 60 + time.minute);
String dateTimeLabel(DateTime time) =>
    '${time.month}/${time.day} ${timeLabel(time)}';
String durationLabel(Duration duration, {bool roundUp = false}) {
  // Keep settlement precision in the domain; label truncated display values.
  final prefix = !roundUp && duration.inMicroseconds % 1000000 != 0 ? '约 ' : '';
  final seconds =
      (roundUp
              ? (duration.inMicroseconds / 1000000).ceil()
              : duration.inSeconds)
          .clamp(0, 999999999);
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final rest = seconds % 60;
  if (hours > 0) {
    return '$prefix$hours 小时${minutes > 0 ? ' $minutes 分' : ''}${rest > 0 ? ' $rest 秒' : ''}';
  }
  if (minutes > 0) return '$prefix$minutes 分钟${rest > 0 ? ' $rest 秒' : ''}';
  return '$prefix$rest 秒';
}

String remainingLabel(Duration remaining) {
  final seconds = (remaining.inMilliseconds / 1000).ceil().clamp(0, 86400000);
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final tail =
      '${minutes.toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  return hours > 0 ? '${hours.toString().padLeft(2, '0')}:$tail' : tail;
}
