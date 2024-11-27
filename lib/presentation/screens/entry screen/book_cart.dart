import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_model.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/cubits/entry_page_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/contact_entry_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/money_entry_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/notes_entry_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/prayer_entry_dialog.dart';
import 'package:lm_teams_app/presentation/screens/follow_up_entry.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';
import 'package:badges/badges.dart' as bd;

class BookCart extends StatefulWidget {
  const BookCart({Key? key, required this.homeContext}) : super(key: key);

  final BuildContext homeContext;

  @override
  State<BookCart> createState() => _BookCartState();
}

class _BookCartState extends State<BookCart> {
  final _geolocationService = GeolocationService();
  bool isLoading = false;
  bool addCurrentLocation = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<EntryPageCubit, EntryPageState>(builder: (cartContext, state) {
      return Padding(
          padding: EdgeInsets.only(bottom: 40.spMin),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                height: 80.spMin,
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Expanded(
                      child: ListView.builder(
                          itemCount: state.pickedItems.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: ((listContext, index) {
                            return Padding(
                                padding: EdgeInsets.fromLTRB(
                                    5.0.spMin, 10.0.spMin, 5.0.spMin, 10.0.spMin),
                                child: bd.Badge(
                                    badgeStyle: bd.BadgeStyle(
                                        badgeColor: Theme.of(context).colorScheme.secondary),
                                    badgeContent:
                                        Text(state.pickedItems[index].quantity.toString()),
                                    showBadge: state.pickedItems[index].quantity > 1,
                                    child: Avatar(
                                        image: state.pickedItems[index].item.image,
                                        size: Size(screenWidth / 9.spMin, 80.spMin),
                                        placeholder: Text(state.pickedItems[index].item.code,
                                            style: TextStyle(fontSize: 16.0.spMin)))));
                          }))),
                  IconButton(
                      icon: SizedBox(
                          height: 30.0.spMin,
                          width: 30.0.spMin,
                          child: CircleAvatar(
                              backgroundColor:
                                  isLoading ? Colors.grey : Theme.of(context).colorScheme.secondary,
                              child: Icon(Icons.check, size: 24.0.spMin, color: Colors.white))),
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = !isLoading);
                              LocationEvent? _latestLocation;
                              if (context.read<GeolocationBloc>().state.isEnabled) {
                                _latestLocation =
                                    await _geolocationService.getCurrentLocation(context);
                              }
                              final homeBloc = context.read<HomeScreenBloc>().state;
                              BlocProvider.of<EntryPageCubit>(context).submitBookEntry(
                                  context, _latestLocation, homeBloc.team.id, homeBloc.event.id);

                              var entryQueue = await Navigator.of(context)
                                  .push<List<EntryType>>(PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (BuildContext newContext, _, __) {
                                        return BlocProvider.value(
                                            value: BlocProvider.of<EntryPageCubit>(context),
                                            child: const FollowUpEntry());
                                      }));

                              if (entryQueue != null && entryQueue.isNotEmpty) {
                                playEntryQueue(
                                    entryQueue, _latestLocation, homeBloc, widget.homeContext);
                              }
                            }),
                  IconButton(
                      icon: SizedBox(
                          width: 30.0.spMin,
                          height: 30.0.spMin,
                          child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.close, size: 24.0.spMin, color: Colors.white))),
                      onPressed: isLoading
                          ? null
                          : () {
                              BlocProvider.of<EntryPageCubit>(context).clearPickedItems();
                            })
                ])),
            const AddCurrentLocationButton(visible: true)
          ]));
    });
  }

  playEntryQueue(List<EntryType> entryQueue, LocationEvent? locationEvent, HomeScreenState homeBloc,
      BuildContext homeContext) {
    Future.forEach<EntryType>(entryQueue, (entryType) async {
      switch (entryType) {
        case EntryType.contact:
          await showContactEntryDialog(homeContext, EntryDialogMode.add,
              locationEvent: locationEvent, teamID: homeBloc.team.id, eventID: homeBloc.event.id);
          break;
        case EntryType.money:
          await showMoneyEntryDialog(homeContext, EntryDialogMode.add,
              locationEvent: locationEvent, teamID: homeBloc.team.id, eventID: homeBloc.event.id);
          break;
        case EntryType.notes:
          await showNoteEntryDialog(homeContext, EntryDialogMode.add,
              locationEvent: locationEvent, teamID: homeBloc.team.id, eventID: homeBloc.event.id);
          break;
        case EntryType.prayer:
          await showPrayerEntryDialog(homeContext, EntryDialogMode.add,
              locationEvent: locationEvent, teamID: homeBloc.team.id, eventID: homeBloc.event.id);
          break;
        case EntryType.book:
          break;
      }
    });
  }
}
