import 'package:flutter/material.dart';

class ImageLoadingScreen extends StatelessWidget {
  const ImageLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Uploading image... please wait..."),
          SizedBox(height: 15),
          CircularProgressIndicator()
        ])));
  }
}
