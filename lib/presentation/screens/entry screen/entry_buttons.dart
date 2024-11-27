import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/contact_entry_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/money_entry_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/notes_entry_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/prayer_entry_dialog.dart';
import 'package:lm_teams_app/presentation/screens/entry%20screen/book_cart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EntryButtons extends StatefulWidget {
  const EntryButtons({Key? key, required this.isVisible}) : super(key: key);

  final bool isVisible;

  @override
  State<EntryButtons> createState() => _EntryButtonsState();
}

class _EntryButtonsState extends State<EntryButtons> {
  bool isLoading = false;
  bool addCurrentLocation = false;

  @override
  Widget build(BuildContext context) {
    final homeBloc = context.read<HomeScreenBloc>().state;
    return BlocBuilder<GeolocationBloc, GeolocationState>(builder: (context, state) {
      return Visibility(
        visible: widget.isVisible,
        child: Padding(
            padding: EdgeInsets.fromLTRB(10.0.spMin, 0, 10.0.spMin, 60.0.spMin),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              _floatingActionButton(() {
                showMoneyEntryDialog(context, EntryDialogMode.add,
                    teamID: homeBloc.team.id, eventID: homeBloc.event.id);
              }, 'money.svg'),
              _floatingActionButton(() {
                showNoteEntryDialog(context, EntryDialogMode.add,
                    teamID: homeBloc.team.id, eventID: homeBloc.event.id);
              }, 'notes.svg'),
              SizedBox(width: 60.w),
              _floatingActionButton(() {
                showPrayerEntryDialog(context, EntryDialogMode.add,
                    teamID: homeBloc.team.id, eventID: homeBloc.event.id);
              }, 'pray.svg'),
              _floatingActionButton(() {
                showContactEntryDialog(context, EntryDialogMode.add,
                    teamID: homeBloc.team.id, eventID: homeBloc.event.id);
              }, 'contacts.svg')
            ])),
        replacement: BookCart(homeContext: context),
      );
    });
  }

  Widget _floatingActionButton(void Function()? onPressed, String assetName) {
    return SizedBox(
        height: 60.spMin,
        width: 60.spMin,
        child: FloatingActionButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0.spMin)),
            onPressed: onPressed,
            heroTag: null,
            child: SvgPicture.asset('assets/svgIcons/' + assetName,
                width: 30.0.spMin,
                height: 30.0.spMin,
                allowDrawingOutsideViewBox: false,
                fit: BoxFit.cover,
                colorFilter:
                    ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn)),
            backgroundColor: Theme.of(context).colorScheme.surface));
  }
}
