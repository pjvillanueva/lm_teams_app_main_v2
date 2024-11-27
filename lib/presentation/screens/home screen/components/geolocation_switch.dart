import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../../../logic/blocs/geolocation_bloc.dart';

class GeolocationSwitch extends StatelessWidget {
  const GeolocationSwitch({Key? key, required this.onToggle}) : super(key: key);

  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeolocationBloc, GeolocationState>(builder: (context, state) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0.spMin),
          child: FlutterSwitch(
              value: state.isEnabled,
              activeToggleColor: Colors.white,
              inactiveToggleColor: Colors.white,
              activeColor: Colors.green,
              inactiveColor: Colors.red,
              activeText: 'ON',
              inactiveText: 'OFF',
              showOnOff: true,
              width: 70.spMin,
              height: 35.spMin,
              valueFontSize: 12.0.spMin,
              padding: 2.0.spMin,
              toggleSize: 30.0.spMin,
              switchBorder: Border.all(width: 2.0.spMin, color: Colors.white70),
              activeIcon: Icon(Icons.location_on, color: Colors.green, size: 25.spMin),
              inactiveIcon: Icon(Icons.location_off, color: Colors.red, size: 25.spMin),
              onToggle: onToggle));
    });
  }
}
