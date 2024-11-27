import 'package:flutter/material.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';

class UnderMaintenance extends StatelessWidget {
  const UnderMaintenance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppFrame(
        title: "Coming soon",
        content: Center(
            child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(children: [
                  Image.asset('assets/logo/building_screen.png'),
                  Text(
                      'LE Teams is under development. This page and many more features are coming soon.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground))
                ]))));
  }
}
