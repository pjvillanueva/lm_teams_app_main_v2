import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';

// ignore: must_be_immutable
class AppDialog extends StatelessWidget {
  AppDialog(
      {Key? key,
      required this.title,
      required this.contents,
      this.actions,
      this.crossAxisAlignment = CrossAxisAlignment.start})
      : super(key: key);

  final String title;
  final List<Widget> contents;
  List<Widget>? actions = [];
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.all(20.0.spMin),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: crossAxisAlignment,
                  children: [
                    Visibility(visible: title.isNotEmpty, child: DialogTitle(title: title)),
                    ...contents,
                    ...actions ?? [],
                  ]),
            )));
  }
}
