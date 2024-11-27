import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lm_teams_app/logic/cubits/map_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/markers.dart';
import 'package:lm_teams_app/services/time_helpers.dart';

enum MarkerType { members, items, contacts }

Future<LatLng?> showMarkerListDialog({
  required BuildContext context,
  required Set<MemberMarker> memberMarkers,
  required Set<ItemMarker> itemMarkers,
  required Set<ContactMarker> contactMarkers,
  required bool showMembers,
  required bool showItems,
  required bool showContacts,
}) async {
  return await showDialog(
      context: context,
      builder: (newContext) {
        return AppDialog(title: 'Map Markers', contents: [
          SizedBox(
              width: double.maxFinite,
              child: DefaultTabController(
                  length: 3,
                  child: Column(children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                          child: TabBar(
                              indicatorColor: Theme.of(context).colorScheme.secondary,
                              labelColor: Theme.of(context).colorScheme.onSurface,
                              tabs: const [
                            Tab(height: 50, text: 'Members'),
                            Tab(height: 50, text: 'Items'),
                            Tab(height: 50, text: 'Contacts')
                          ]))
                    ]),
                    SizedBox(
                        height: 300,
                        child: TabBarView(children: [
                          getTabView(
                              context,
                              memberMarkers.toList(),
                              MarkerType.members,
                              'M E M B E R  M A R K E R S [ ${memberMarkers.length} ]',
                              showMembers),
                          getTabView(context, itemMarkers.toList(), MarkerType.items,
                              'I T E M  M A R K E R S [ ${itemMarkers.length} ]', showItems),
                          getTabView(
                              context,
                              contactMarkers.toList(),
                              MarkerType.contacts,
                              'C O N T A C T  M A R K E R S [ ${contactMarkers.length} ]',
                              showContacts)
                        ]))
                  ])))
        ]);
      });
}

Widget getTabView(BuildContext context, List<dynamic> markers, MarkerType markerType,
    String dividerText, bool showMarkers) {
  return Column(children: [
    DividerWithText(title: dividerText),
    Expanded(child: getTabContent(context, markers, markerType, showMarkers))
  ]);
}

getTabContent(
    BuildContext context, List<dynamic> markers, MarkerType markerType, bool showMarkers) {
  if (markers.isEmpty) {
    return Column(children: [
      Center(child: Image.asset('assets/logo/event.png', width: 200, height: 200)),
      const Text('No marker found in this category')
    ]);
  } else if (!showMarkers) {
    return Column(children: [
      Center(child: Image.asset('assets/logo/ex.png', width: 200, height: 200)),
      Text('The ${markerType.name} layer is turned off')
    ]);
  }
  return Scrollbar(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: markers.length,
          itemBuilder: (newContext, int index) {
            return Card(
                color: Theme.of(context).colorScheme.surface,
                child: getMarkerListTile(context, markerType, markers, index));
          }));
}

ListTile getMarkerListTile(
    BuildContext context, MarkerType markerType, List<dynamic> markers, int index) {
  switch (markerType) {
    case MarkerType.members:
      MemberMarker _marker = markers[index];
      return ListTile(
          leading: Avatar(
              image: _marker.user.image,
              size: Size(40.spMin, 40.spMin),
              placeholder: Text(_marker.user.initials),
              isCircle: true),
          title: Text(_marker.user.name),
          subtitle: Text(_marker.userLocation.latestLocation!.timeStamp.timeAgo),
          onTap: () {
            context.read<MapCubit>().focusMarker(_marker.markerId.value);
            Navigator.pop(context, _marker.position);
          });
    case MarkerType.items:
      ItemMarker _marker = markers[index];
      return ListTile(
          leading: Avatar(
              image: _marker.data.item?.image,
              size: Size(30.spMin, 40.spMin),
              placeholder: Text(_marker.data.item?.code ?? '')),
          title: Text(_marker.data.item?.name ?? ''),
          subtitle: Text('Quantity: ${_marker.data.quantity}'),
          onTap: () {
            context.read<MapCubit>().focusMarker(_marker.markerId.value);
            Navigator.pop(context, _marker.position);
          });
    case MarkerType.contacts:
      ContactMarker _marker = markers[index];
      return ListTile(
          leading: Avatar(
              placeholder: Text(_marker.contact.initials),
              backgroundColor: Color(_marker.contact.avatarColor),
              size: Size(40.spMin, 40.spMin),
              isCircle: true),
          title: Text(_marker.contact.name),
          subtitle: Text(_marker.contact.fullAddress, overflow: TextOverflow.ellipsis, maxLines: 1),
          onTap: () {
            context.read<MapCubit>().focusMarker(_marker.markerId.value);
            Navigator.pop(context, _marker.position);
          });
  }
}
