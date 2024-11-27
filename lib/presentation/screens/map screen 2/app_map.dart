import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/user_location.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/map_cubit.dart';
import 'package:lm_teams_app/presentation/screens/map%20screen/components/map_floating_action_buttons.dart';
import 'package:lm_teams_app/presentation/screens/map%20screen/components/map_settings_drawer.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';
import 'package:lm_teams_app/services/helpers/debouncer.dart';

class AppMap extends StatefulWidget {
  const AppMap({Key? key}) : super(key: key);

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final Completer<GoogleMapController> _completer = Completer();
  final _geolocationService = GeolocationService();
  final _onCameraMoveDebouncer = Debouncer(milliseconds: 1000);

  String mapTheme = '';

  @override
  void initState() {
    super.initState();
    var state = context.read<GeolocationBloc>().state;
    if (state.isEnabled) {
      _geolocationService.getCurrentLocation(context);
    }
    DefaultAssetBundle.of(context)
        .loadString('assets/map_themes/aubergine_theme.json')
        .then((value) => mapTheme = value);
  }

  @override
  void dispose() {
    _completer.future.then((value) => value.dispose());
    _onCameraMoveDebouncer.dispose();
    super.dispose();
  }

  Future<LatLngBounds> _getVisibleRegion() async {
    final GoogleMapController controller = await _completer.future;
    return await controller.getVisibleRegion();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserBloc>().state.user;
    return BlocProvider(
        create: (context) => MapCubit(userId: user.id, context: context)..initialEvent(context),
        child: BlocConsumer<MapCubit, MapCubitState>(
            //listen only to changes of user location sharing
            listenWhen: (previous, current) =>
                previous.shareWithLeader != current.shareWithLeader ||
                previous.shareWithMembers != current.shareWithMembers,
            //update userlocation's location sharing settings
            listener: (context, mapState) => _geolocationService.updateUserLocation(
                UserLocationUpdate(
                    id: user.id,
                    shareWithLeader: mapState.shareWithLeader,
                    shareWithMembers: mapState.shareWithMembers)),
            builder: (context, mapState) {
              return BlocConsumer<HomeScreenBloc, HomeScreenState>(
                  //listen only to changes of team/event
                  listenWhen: (previous, current) =>
                      previous.team != current.team || previous.event != current.event,
                  listener: (context, homeState) {
                    //update userlocation when team/event context changes
                    _geolocationService.updateUserLocation(UserLocationUpdate(
                        id: user.id, teamId: homeState.team.id, eventId: homeState.event.id));

                    //get members when team/event context changes
                    context.read<MapCubit>().getMarkers(
                        context,
                        user.id,
                        [user.id],
                        homeState.team.id,
                        homeState.event.id,
                        mapState.mapBounds,
                        mapState.itemIds);
                  },
                  builder: (context, homeState) {
                    return BlocConsumer<GeolocationBloc, GeolocationState>(
                        // listen only on latestLocation changes
                        listenWhen: (previous, current) =>
                            previous.latestLocation != current.latestLocation,
                        listener: (context, geoState) => context
                            .read<MapCubit>()
                            .updateUserMarkerPosition(context, _completer, mapState.mapZoom,
                                geoState.latestLocation?.latLng),
                        builder: (context, geoState) {
                          return Scaffold(
                              key: _key,
                              body: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                      target: geoState.latestLocation?.latLng ?? kDefaultMapCoords,
                                      zoom: mapState.mapZoom),
                                  markers: mapState.allMarkers,
                                  mapType: mapState.mapType,
                                  zoomControlsEnabled: false,
                                  onMapCreated: (controller) async {
                                    controller.setMapStyle(mapTheme);
                                    _completer.complete(controller);

                                    //update map bounds state
                                    LatLngBounds bounds = await _getVisibleRegion();
                                    context.read<MapCubit>().changeMapBounds(bounds);

                                    //get markers events
                                    context.read<MapCubit>().getMarkers(
                                        context,
                                        user.id,
                                        [user.id],
                                        homeState.team.id,
                                        homeState.event.id,
                                        bounds,
                                        mapState.itemIds);
                                  },
                                  onCameraMove: (position) {
                                    _onCameraMoveDebouncer.run(() => context
                                        .read<MapCubit>()
                                        .onCameraMove(context, position, _completer));
                                  },
                                  onTap: (coords) {
                                    print('ccordinates: $coords');
                                  }),
                              endDrawer: MapSettingsDrawer(),
                              floatingActionButton: MapFloatingActionButtons(
                                  scaffoldKey: _key, completer: _completer));
                        });
                  });
            }));
  }
}
