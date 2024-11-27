import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyListScreen extends StatelessWidget {
  const EmptyListScreen({Key? key, required this.text, required this.assetName}) : super(key: key);

  final String text;
  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Image.asset(assetName, width: 200.spMin, height: 200.spMin),
          Text(text, style: TextStyle(fontSize: 16.spMin))
        ]));
  }
}
