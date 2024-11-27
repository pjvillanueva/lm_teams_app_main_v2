import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_model.dart';
import 'package:percent_indicator/percent_indicator.dart';

class FollowUpEntry extends StatefulWidget {
  const FollowUpEntry({Key? key}) : super(key: key);

  @override
  State<FollowUpEntry> createState() => _FollowUpEntryState();
}

class _FollowUpEntryState extends State<FollowUpEntry> {
  late CountdownTimerController _controller;
  int endTime = DateTime.now().millisecondsSinceEpoch + 10000;
  List<EntryType> entryQueue = [];

  @override
  void initState() {
    _controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  onEnd() {
    Navigator.pop(context, entryQueue);
  }

  @override
  Widget build(BuildContext context) {
    // int? remainingTime = _controller.currentRemainingTime != null
    //     ? _controller.currentRemainingTime!.sec
    //     : 0;

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.90),
        body: Column(children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.done_all, color: Colors.green),
                    const Text("Saved successfully.",
                        style: TextStyle(color: Colors.green, fontSize: 16.0)),
                    const SizedBox(height: 10),
                    CountdownTimer(
                        widgetBuilder: (context, time) {
                          var progress = time != null && time.sec != null ? time.sec : 0;
                          var sec = progress ?? 0;
                          var percent = sec / 10;

                          return Column(children: [
                            CircularPercentIndicator(
                                radius: 100.0,
                                lineWidth: 5.0,
                                percent: percent,
                                animationDuration: 500,
                                center: SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Stack(children: [
                                      Positioned(
                                          top: 15,
                                          right: 75,
                                          child: _floatingActionButton(EntryType.contact, () {
                                            addToQueue(EntryType.contact);
                                          }, 'contacts.svg')),
                                      Positioned(
                                          top: 75,
                                          left: 15,
                                          child: _floatingActionButton(EntryType.money, () {
                                            addToQueue(EntryType.money);
                                          }, 'money.svg')),
                                      Positioned(
                                          top: 75,
                                          right: 15,
                                          child: _floatingActionButton(EntryType.prayer, () {
                                            addToQueue(EntryType.prayer);
                                          }, 'pray.svg')),
                                      Positioned(
                                          bottom: 15,
                                          right: 75,
                                          child: _floatingActionButton(EntryType.notes, () {
                                            addToQueue(EntryType.notes);
                                          }, 'notes.svg'))
                                    ])),
                                backgroundColor: Colors.transparent,
                                progressColor: Theme.of(context).colorScheme.primary,
                                animateFromLastPercent: true),
                            const SizedBox(height: 5),
                            Text(
                              sec.toString(),
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            )
                          ]);
                        },
                        controller: _controller,
                        endTime: endTime)
                  ])))),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Flexible(
                flex: 1,
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context, entryQueue..clear());
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.surface,
                      child: const Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.arrow_back), Text("Back")])),
                    ))),
            Flexible(
                flex: 1,
                child: GestureDetector(
                    onTap: entryQueue.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context, entryQueue);
                          },
                    child: Container(
                        height: 60,
                        width: double.infinity,
                        color: entryQueue.isEmpty
                            ? Theme.of(context).colorScheme.background
                            : Theme.of(context).colorScheme.secondary,
                        child: Center(
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text("Next",
                              style: TextStyle(
                                  color: entryQueue.isEmpty
                                      ? Colors.transparent
                                      : Theme.of(context).colorScheme.onPrimary)),
                          Icon(
                            Icons.arrow_forward,
                            color: entryQueue.isEmpty
                                ? Colors.transparent
                                : Theme.of(context).colorScheme.onPrimary,
                          )
                        ])))))
          ])
        ]));
  }

  addToQueue(EntryType type) {
    setState(() {
      entryQueue.add(type);
    });
  }

  bool inEntryQueue(EntryType entryType) {
    return entryQueue.contains(entryType);
  }

  Widget _floatingActionButton(EntryType entryType, void Function()? onPressed, String assetName) {
    return FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0.spMin)),
        onPressed: onPressed,
        heroTag: null,
        child: SvgPicture.asset('assets/svgIcons/' + assetName,
            width: 30.0,
            height: 30.0,
            allowDrawingOutsideViewBox: false,
            fit: BoxFit.cover,
            colorFilter:
                ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn)),
        backgroundColor: inEntryQueue(entryType)
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.surface);
  }
}
