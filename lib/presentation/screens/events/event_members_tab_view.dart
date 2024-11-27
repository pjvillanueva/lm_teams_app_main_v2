import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/event%20model/event.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';
import 'package:lm_teams_app/services/event_service.dart';
import '../../../data/models/event model/event_member.dart';
import '../../widgets/avatars.dart';

class EventMembersTabView extends StatefulWidget {
  const EventMembersTabView({required this.event, Key? key}) : super(key: key);

  final Event event;
  @override
  State<EventMembersTabView> createState() => _EventMembersTabViewState();
}

class _EventMembersTabViewState extends State<EventMembersTabView> {
  final _eventService = EventService();
  List<EventMember> eventMembers = [];

  @override
  void initState() {
    getEventMembers(widget.event.id);
    super.initState();
  }

  getEventMembers(String eventId) async {
    final List<EventMember> _eventMembers = await _eventService.getEventMembers(eventId);

    if (mounted) {
      setState(() {
        eventMembers = _eventMembers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(20.0.spMin),
                    child: Column(mainAxisSize: MainAxisSize.max, children: [
                      Visibility(
                          visible: eventMembers.isNotEmpty,
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const SubtitleInDivider(subtitle: 'MEMBERS'),
                            ListView.builder(
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: eventMembers.length,
                                itemBuilder: (context, index) {
                                  EventMember eventMember = eventMembers[index];
                                  return Card(
                                      color: Theme.of(context).colorScheme.surface,
                                      child: ListTile(
                                          leading: Avatar(
                                              isCircle: true,
                                              size: Size(40.0.spMin, 40.0.spMin),
                                              image: eventMember.user?.image,
                                              placeholder: Text(eventMember.user?.initials,
                                                  style: TextStyle(fontSize: 16.0.spMin))),
                                          title: Text(eventMember.name),
                                          subtitle: Text(eventMember.role)));
                                })
                          ]))
                    ])))));
  }
}
