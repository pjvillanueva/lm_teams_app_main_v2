import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GenericCard extends StatelessWidget {
  const GenericCard({
    Key? key,
    required this.content,
    this.margin,
  }) : super(key: key);
  final List<Widget> content;
  final double? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      color: Theme.of(context).colorScheme.surface,
      margin: EdgeInsets.all(margin ?? 0.0),
      child: Padding(
        padding: EdgeInsets.all(20.0.spMin),
        child: Column(
          children: content,
        ),
      ),
    );
  }
}
