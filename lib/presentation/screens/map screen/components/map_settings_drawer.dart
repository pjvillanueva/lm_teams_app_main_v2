import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/map_cubit.dart';
import '../../../widgets/form_fields.dart';

class MapSettingsDrawer extends StatelessWidget {
  MapSettingsDrawer({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _mapTypes = [
    {'value': '0', 'label': 'Standard View'},
    {'value': '1', 'label': 'Satellite Imagery'},
    {'value': '2', 'label': 'Hybrid'},
    {'value': '3', 'label': 'Terrain'}
  ];

  final TextEditingController _mapStyleController =
      TextEditingController(text: mapTypeToString(MapType.normal));

  @override
  Widget build(BuildContext context) {
    final _currentUser = context.read<UserBloc>().state.user;

    return BlocBuilder<MapCubit, MapCubitState>(builder: (context, state) {
      _mapStyleController.text = mapTypeToString(state.mapType);
      return Drawer(
          backgroundColor: Theme.of(context).colorScheme.background,
          child: Padding(
              padding: EdgeInsets.all(10.0.spMin),
              child: ListView(padding: EdgeInsets.zero, children: [
                Row(children: [
                  IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: 22.0.spMin),
                      onPressed: () => Navigator.pop(context)),
                  Text('Map Settings', style: TextStyle(fontSize: 18.0.spMin))
                ]),
                const Divider(thickness: 1),
                SizedBox(height: 10.0.spMin),
                AppDropdownField(
                    items: _mapTypes,
                    labelText: 'Map View',
                    hintText: '',
                    controller: _mapStyleController,
                    onChanged: (value) => context.read<MapCubit>().changeMapType(value)),
                const MapSettingsDivider(text: 'L A Y E R S', icon: Icons.layers),
                SizedBox(
                    height: 40.spMin,
                    child: SwitchListTile(
                        value: state.showMemberMarkers,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        onChanged: (value) {
                          context.read<MapCubit>().toggleShowMarker(
                              ShowMarkerToggle.showMembers, value, _currentUser, context);
                        },
                        title: Text("Team/Event Members", style: TextStyle(fontSize: 14.0.spMin)))),
                SizedBox(
                    height: 40.spMin,
                    child: SwitchListTile(
                        title: Text('Contacts', style: TextStyle(fontSize: 14.0.spMin)),
                        value: state.showContactMarkers,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        onChanged: (value) {
                          context.read<MapCubit>().toggleShowMarker(
                              ShowMarkerToggle.showContacts, value, _currentUser, context);
                        })),
                SizedBox(
                    height: 40.spMin,
                    child: SwitchListTile(
                        title: Text('Book Entries', style: TextStyle(fontSize: 14.0.spMin)),
                        value: state.showItemMarkers,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        onChanged: (value) {
                          context.read<MapCubit>().toggleShowMarker(
                              ShowMarkerToggle.showItems, value, _currentUser, context);
                        })),
                SizedBox(height: 10.spMin),
                const MapSettingsDivider(
                    text: 'L O C A T I O N  S H A R I N G', icon: Icons.share_location),
                SizedBox(height: 10.spMin),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                      height: 40.spMin,
                      child: ToggleButtons(
                          selectedColor: Theme.of(context).colorScheme.secondary,
                          fillColor: Colors.orange.withOpacity(0.1),
                          children: [
                            Text('Off', style: TextStyle(fontSize: 12.0.spMin)),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.spMin),
                                child:
                                    Text('with Leaders', style: TextStyle(fontSize: 12.0.spMin))),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.spMin),
                                child: Text('with Members', style: TextStyle(fontSize: 12.0.spMin)))
                          ],
                          isSelected: state.sharingSettings,
                          onPressed: (index) {
                            context.read<MapCubit>().updateLocationSharing(index);
                          }))
                ]),
                // SizedBox(height: 10.spMin),
                // const MapSettingsDivider(
                //     text: 'N O T I F I C A T I O N', icon: Icons.share_location),
                // SizedBox(
                //     height: 40.spMin,
                //     child: SwitchListTile(
                //         title: Text('Notifications', style: TextStyle(fontSize: 14.0.spMin)),
                //         value: mapState.showItemMarkers,
                //         activeColor: Theme.of(context).colorScheme.secondary,
                //         onChanged: (value) {})),
                // SizedBox(
                //     height: 40.spMin,
                //     child: SwitchListTile(
                //         title: Text('Sound', style: TextStyle(fontSize: 14.0.spMin)),
                //         value: mapState.showItemMarkers,
                //         activeColor: Theme.of(context).colorScheme.secondary,
                //         onChanged: (value) {})),
              ])));
    });
  }
}

String mapTypeToString(MapType type) {
  switch (type) {
    case MapType.normal:
      return '0';
    case MapType.satellite:
      return '1';
    case MapType.hybrid:
      return '2';
    case MapType.terrain:
      return '3';
    default:
      return '0';
  }
}

class MapSettingsDivider extends StatelessWidget {
  const MapSettingsDivider({Key? key, required this.text, required this.icon}) : super(key: key);

  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.0.spMin),
        Row(children: [
          Icon(icon, size: 18.0.spMin),
          SizedBox(width: 10.spMin),
          Text(text, style: TextStyle(fontSize: 16.0.spMin)),
          SizedBox(width: 10.spMin),
          const Expanded(child: Divider(thickness: 1))
        ]),
        SizedBox(height: 10.0.spMin),
      ],
    );
  }
}
