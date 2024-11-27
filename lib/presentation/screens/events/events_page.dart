import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/event%20model/event.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/cubits/events_cubit.dart';
import 'package:lm_teams_app/logic/cubits/users_cubit.dart';
import 'package:lm_teams_app/presentation/screens/empty_list_screen.dart';
import 'package:lm_teams_app/presentation/screens/events/event_form.dart';
import 'package:lm_teams_app/presentation/screens/events/event_view.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';

// ignore: must_be_immutable
class EventsPage extends StatefulWidget {
  const EventsPage(this.accountId, {Key? key}) : super(key: key);

  final String accountId;
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    context.read<EventsCubit>().getEvents(widget.accountId);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var users = context.read<UsersCubit>().state.users;

    return AppFrame(
        title: 'Events',
        floatingActionButton: IconAndTextButton(
            icon: Icons.event,
            color: Theme.of(context).colorScheme.secondary,
            buttonName: "NEW EVENT",
            onPressed: () async {
              final event =
                  await Navigator.push<Event>(context, MaterialPageRoute(builder: (newContext) {
                return BlocProvider.value(
                    value: BlocProvider.of<HomeScreenBloc>(context),
                    child: EventForm(users: users));
              }));
              if (event != null) {
                context.read<EventsCubit>().addEvent(event);
              }
            }),
        content: BlocBuilder<EventsCubit, EventsState>(builder: (context, state) {
          var events = _isSearching ? state.filteredEvents : state.events;

          void _onChange(String text) {
            if (text.isNotEmpty) {
              BlocProvider.of<EventsCubit>(context).searchEvent(text);
              if (_isSearching == false) {
                BlocProvider.of<EventsCubit>(context).searchStatusChanged(true);
                setState(() => _isSearching = true);
              }
            } else {
              BlocProvider.of<EventsCubit>(context).searchStatusChanged(false);
              setState(() => _isSearching = false);
            }
          }

          void _clearSearchInput() {
            _searchController.clear();
            BlocProvider.of<EventsCubit>(context).searchStatusChanged(false);
            setState(() => _isSearching = false);
          }

          return Visibility(
            visible: state.events.isNotEmpty,
            replacement: const EmptyListScreen(
                text: 'No event found', assetName: 'assets/logo/no_events.png'),
            child: Column(children: [
              GenericSearchBar(
                  onchanged: _onChange,
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  controller: _searchController,
                  onpressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _clearSearchInput();
                  }),
              const DividerWithText(title: 'E V E N T S'),
              Expanded(
                  child: Scrollbar(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: events.length,
                          itemBuilder: (context, int index) {
                            Event event = events[index];

                            return Card(
                                color: Theme.of(context).colorScheme.surface,
                                child: ListTile(
                                    title: Text(event.name),
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (newContext) {
                                        return BlocProvider.value(
                                            value: BlocProvider.of<HomeScreenBloc>(context),
                                            child: EventView(event: event));
                                      }));
                                    },
                                    subtitle: Text(
                                        event.isOngoing ? 'Ongoing Event' : 'Event Ended',
                                        style: TextStyle(
                                            color: event.isOngoing ? Colors.green : Colors.red)),
                                    leading: Avatar(
                                        image: event.image,
                                        placeholder: const Icon(Icons.event),
                                        size: Size(50.spMin, 50.spMin))));
                          })))
            ]),
          );
        }));
  }
}
