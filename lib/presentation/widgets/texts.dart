import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({Key? key, required this.title, this.color}) : super(key: key);
  final String title;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
            fontSize: 22.0.spMin, color: color ?? Theme.of(context).colorScheme.onSurface),
        maxLines: 1,
        overflow: TextOverflow.clip);
  }
}

class DialogTitle extends StatelessWidget {
  const DialogTitle({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 20.0.spMin, color: Theme.of(context).colorScheme.onSurface),
      maxLines: 1,
      overflow: TextOverflow.clip,
    );
  }
}

class TextAboveDivider extends StatelessWidget {
  const TextAboveDivider({
    Key? key,
    required this.leadingText,
    this.trailingText,
    this.leadingFontWeight,
    this.trailingFontWeight,
    this.leadingFontSize,
    this.trailingFontSize,
    this.dividerThickness,
  }) : super(key: key);

  final String leadingText;
  final String? trailingText;
  final FontWeight? leadingFontWeight;
  final FontWeight? trailingFontWeight;
  final double? leadingFontSize;
  final double? trailingFontSize;
  final double? dividerThickness;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(leadingText,
              style: TextStyle(
                  fontWeight: leadingFontWeight ?? FontWeight.normal,
                  fontSize: leadingFontSize ?? 20.0.spMin)),
          Text(trailingText ?? '',
              style: TextStyle(
                  fontWeight: trailingFontWeight ?? FontWeight.normal,
                  fontSize: trailingFontSize ?? 20.0.spMin))
        ]),
        Divider(thickness: dividerThickness ?? 2.0.spMin)
      ],
    );
  }
}

class SubtitleInDivider extends StatelessWidget {
  const SubtitleInDivider({Key? key, required this.subtitle}) : super(key: key);

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(subtitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0.spMin)),
        SizedBox(width: 10.0.spMin),
        Expanded(child: Divider(thickness: 2.0.spMin))
      ],
    );
  }
}
