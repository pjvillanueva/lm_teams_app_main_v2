import 'package:flutter/material.dart';

typedef OnToggle = void Function(int? index);

// ignore: must_be_immutable
class ToggleTabs extends StatefulWidget {
  ToggleTabs(
      {Key? key,
      required this.totalSwitches,
      required this.labels,
      this.borderColor,
      this.borderWidth,
      this.dividerColor = Colors.white30,
      this.activeBgColor,
      this.activeFgColor,
      this.inactiveBgColor,
      this.inactiveFgColor,
      this.onToggle,
      this.cornerRadius = 8.0,
      this.initialLabelIndex = 0,
      this.minWidth = 72.0,
      this.minHeight = 40.0,
      this.changeOnTap = true,
      this.icons,
      this.activeBgColors,
      this.customIcons,
      this.customWidths,
      this.animate = false,
      this.animationDuration = 800,
      this.curve = Curves.easeIn,
      this.radiusStyle = false,
      this.textDirectionRTL = false,
      this.fontSize = 14.0,
      this.iconSize = 17.0,
      this.doubleTapDisable = false})
      : super(key: key);

  final List<Color>? borderColor;
  final Color dividerColor;
  final List<Color>? activeBgColor;
  final Color? activeFgColor;
  final Color? inactiveBgColor;
  final Color? inactiveFgColor;
  final List<Widget> labels;
  final int totalSwitches;
  final List<IconData?>? icons;
  final List<List<Color>?>? activeBgColors;
  final List<Icon?>? customIcons;
  final List<double>? customWidths;
  final double minWidth;
  final double minHeight;
  final double cornerRadius;
  final double fontSize;
  final double iconSize;
  final double? borderWidth;
  final OnToggle? onToggle;
  final bool changeOnTap;
  final bool animate;
  final int animationDuration;
  final bool radiusStyle;
  final bool textDirectionRTL;
  final Curve curve;
  int? initialLabelIndex;
  bool doubleTapDisable;

  @override
  State<ToggleTabs> createState() => _ToggleTabsState();
}

class _ToggleTabsState extends State<ToggleTabs>
    with AutomaticKeepAliveClientMixin<ToggleTabs> {
  List<Color>? activeBgColor;
  Color? activeFgColor;
  Color? inactiveBgColor;
  Color? inactiveFgColor;
  List<Color>? borderColor;
  double? borderWidth;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    activeBgColor = widget.activeBgColor ?? [Theme.of(context).primaryColor];

    activeFgColor = widget.activeFgColor ??
        Theme.of(context).primaryTextTheme.bodyLarge!.color;

    inactiveBgColor = widget.inactiveBgColor ?? Theme.of(context).disabledColor;

    inactiveFgColor =
        widget.inactiveFgColor ?? Theme.of(context).textTheme.bodyLarge!.color;

    borderColor = widget.borderColor ?? [Colors.transparent];
    borderWidth =
        widget.borderWidth ?? (widget.borderColor == null ? 0.0 : 3.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.cornerRadius),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: borderColor!.length == 1
                ? [borderColor![0], borderColor![0]]
                : borderColor!,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(borderWidth!),
          decoration: BoxDecoration(
              color: inactiveBgColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.cornerRadius),
                  bottomLeft: Radius.circular(widget.cornerRadius),
                  topRight: Radius.circular(widget.cornerRadius),
                  bottomRight: Radius.circular(widget.cornerRadius))),
          height: widget.minHeight + borderWidth!,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.totalSwitches * 2 - 1, (index) {
              final active = index ~/ 2 == widget.initialLabelIndex;
              final fgColor = active ? activeFgColor : inactiveFgColor;
              List<Color>? bgColor = [Colors.transparent];
              if (active) {
                bgColor = widget.activeBgColors == null
                    ? activeBgColor
                    : (widget.activeBgColors![index ~/ 2] ?? activeBgColor);
              }

              if (index % 2 == 1) {
                final activeDivider = active ||
                    (widget.initialLabelIndex != null &&
                        index ~/ 2 == widget.initialLabelIndex! - 1);

                return Container(
                  width: 1,
                  color:
                      activeDivider ? Colors.transparent : widget.dividerColor,
                  margin: EdgeInsets.symmetric(vertical: activeDivider ? 0 : 8),
                );
              } else {
                BorderRadius? cornerRadius;
                if (index == 0) {
                  cornerRadius = widget.textDirectionRTL
                      ? BorderRadius.only(
                          topRight: Radius.circular(widget.cornerRadius),
                          bottomRight: Radius.circular(widget.cornerRadius))
                      : BorderRadius.only(
                          topLeft: Radius.circular(widget.cornerRadius),
                          bottomLeft: Radius.circular(widget.cornerRadius));
                }
                if (index ~/ 2 == widget.totalSwitches - 1) {
                  cornerRadius = widget.textDirectionRTL
                      ? BorderRadius.only(
                          topLeft: Radius.circular(widget.cornerRadius),
                          bottomLeft: Radius.circular(widget.cornerRadius))
                      : BorderRadius.only(
                          topRight: Radius.circular(widget.cornerRadius),
                          bottomRight: Radius.circular(widget.cornerRadius));
                }
                // ignore: unused_local_variable
                var icon =
                    widget.icons != null && widget.icons![index ~/ 2] != null
                        ? Icon(
                            widget.icons![index ~/ 2],
                            color: fgColor,
                            size: widget.iconSize >
                                    (_calculateWidth(index ~/ 2) / 3)
                                ? (_calculateWidth(index ~/ 2)) / 3
                                : widget.iconSize,
                          )
                        : Container();
                if (widget.customIcons != null &&
                    widget.customIcons![index ~/ 2] != null) {
                  icon = widget.customIcons![index ~/ 2]!;
                }
                return GestureDetector(
                  onTap: () => _handleOnTap(index ~/ 2),
                  child: AnimatedContainer(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                    constraints:
                        BoxConstraints(maxWidth: _calculateWidth(index ~/ 2)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: widget.radiusStyle
                          ? BorderRadius.all(
                              Radius.circular(widget.cornerRadius))
                          : cornerRadius,
                      gradient: LinearGradient(
                        colors: bgColor!.length == 1
                            ? [bgColor[0], bgColor[0]]
                            : bgColor,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    duration: Duration(
                        milliseconds:
                            widget.animate ? widget.animationDuration : 0),
                    curve: widget.curve,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            child: widget.labels[index ~/ 2],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
          ),
        ),
      ),
    );
  }

  void _handleOnTap(int index) async {
    bool notifyNull = false;
    if (widget.changeOnTap) {
      if (widget.doubleTapDisable && widget.initialLabelIndex == index) {
        setState(() => widget.initialLabelIndex = null);
        notifyNull = true;
      } else {
        setState(() => widget.initialLabelIndex = index);
      }
    }
    if (widget.onToggle != null) {
      if (notifyNull) {
        widget.onToggle!(null);
      } else {
        widget.onToggle!(index);
      }
    }
  }

  double _calculateWidth(int index) {
    double extraWidth = 0.10 * widget.totalSwitches;
    double screenWidth = MediaQuery.of(context).size.width;
    return (widget.totalSwitches + extraWidth) *
                (widget.customWidths != null
                    ? widget.customWidths![index]
                    : widget.minWidth) <
            screenWidth
        ? (widget.customWidths != null
            ? widget.customWidths![index]
            : widget.minWidth)
        : screenWidth / (widget.totalSwitches + extraWidth);
  }
}
