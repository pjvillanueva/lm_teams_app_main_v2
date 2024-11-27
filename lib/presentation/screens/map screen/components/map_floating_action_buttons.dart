import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:badges/badges.dart' as bd;
import 'package:lm_teams_app/logic/cubits/map_cubit.dart';
import '../../../dialogs/marker_list_dialog.dart';

class MapFloatingActionButtons extends StatelessWidget {
  const MapFloatingActionButtons({Key? key, required this.scaffoldKey, required this.completer})
      : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Completer<GoogleMapController> completer;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapCubitState>(builder: (context, mapState) {
      return Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 60.spMin),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Visibility(
                visible: mapState.userMarker != null,
                child: FloatingActionButton(
                    heroTag: 'btn0',
                    child: Icon(Icons.my_location_rounded, size: 24.0.spMin),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0.spMin)),
                    backgroundColor: mapState.isDragging ?? false
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey,
                    onPressed: mapState.isDragging ?? false
                        ? () async {
                            if (mapState.userMarker != null) {
                              //update camera position
                              final cameraPosition = CameraPosition(
                                  target: mapState.userMarker!.position, zoom: mapState.mapZoom);

                              final _controller = await completer.future;
                              //move camera
                              _controller
                                  .moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
                              //on camera move event
                              context
                                  .read<MapCubit>()
                                  .onCameraMove(context, cameraPosition, completer);
                            }
                          }
                        : null)),
            SizedBox(height: 10.spMin),
            bd.Badge(
                badgeStyle: const bd.BadgeStyle(badgeColor: Colors.blue),
                showBadge: mapState.allMarkersLength > 0,
                badgeContent: Text((mapState.allMarkersLength).toString()),
                child: FloatingActionButton(
                    heroTag: 'btn1',
                    child: Icon(Icons.location_on, size: 24.0.spMin),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0.spMin)),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    onPressed: () async {
                      var position = await showMarkerListDialog(
                          context: context,
                          memberMarkers:
                              mapState.memberMarkers != null ? mapState.memberMarkers!.toSet() : {},
                          itemMarkers:
                              mapState.itemMarkers != null ? mapState.itemMarkers!.toSet() : {},
                          contactMarkers: mapState.contactMarkers != null
                              ? mapState.contactMarkers!.toSet()
                              : {},
                          showMembers: mapState.showMemberMarkers,
                          showItems: mapState.showItemMarkers,
                          showContacts: mapState.showContactMarkers);

                      if (position != null) {
                        final GoogleMapController _completer = await completer.future;
                        _completer.moveCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(target: position, zoom: mapState.mapZoom)));
                      }
                    })),
            SizedBox(height: 10.spMin),
            FloatingActionButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0.spMin)),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                heroTag: 'btn2',
                child: const Icon(Icons.layers),
                onPressed: () => scaffoldKey.currentState!.openEndDrawer())
          ]));
    });
  }
}
