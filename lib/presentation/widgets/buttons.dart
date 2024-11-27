import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import '../dialogs/location_off_alert_dialog.dart';

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({Key? key, required this.child, this.onPressed}) : super(key: key);

  final Widget child;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: child,
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary)),
      onPressed: onPressed,
    );
  }
}

class AppFullWidthButton extends StatelessWidget {
  const AppFullWidthButton(
      {Key? key, required this.title, required this.color, this.width, required this.onPressed})
      : super(key: key);

  final String title;
  final Color color;
  final double? width;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 45.0.h,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey[400];
            } else {
              return color;
            }
          }),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 16.0.sp),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  const AppTextButton(
      {Key? key,
      required this.text,
      this.fontSize,
      required this.color,
      this.fontWeight,
      required this.onPressed})
      : super(key: key);

  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: TextButton(
        onPressed: onPressed,
        child: Text(text,
            style: TextStyle(fontSize: 14.0.spMin, fontWeight: fontWeight, color: color)),
      ),
    );
  }
}

class IconAndTextButton extends StatelessWidget {
  const IconAndTextButton(
      {Key? key, required this.icon, required this.buttonName, this.color, required this.onPressed})
      : super(key: key);

  final IconData icon;
  final String buttonName;
  final Color? color;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all(color ?? Theme.of(context).colorScheme.secondary)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 5),
          Text(buttonName, style: const TextStyle(color: Colors.white))
        ]));
  }
}

class FullWidthButton extends StatelessWidget {
  const FullWidthButton(
      {Key? key, required this.title, required this.color, required this.onPressed})
      : super(key: key);
  final String title;
  final Color color;

  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45.0.spMin,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey[400];
            } else {
              return color;
            }
          }),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 16.0.spMin),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class GenericTextButton extends StatelessWidget {
  const GenericTextButton(
      {Key? key,
      required this.text,
      this.fontSize,
      required this.color,
      this.fontWeight,
      required this.onPressed})
      : super(key: key);

  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontWeight: fontWeight, color: color)),
    );
  }
}

class StatisticsDateFilterButton extends StatelessWidget {
  const StatisticsDateFilterButton(
      {Key? key,
      required this.buttonText,
      required this.initialValue,
      required this.itemBuilder,
      required this.onPressedLeftArrow,
      required this.onPressedRightArrow,
      required this.onSelected})
      : super(key: key);

  final String buttonText;
  final dynamic initialValue;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext) itemBuilder;

  final void Function()? onPressedLeftArrow;
  final void Function()? onPressedRightArrow;
  final void Function(dynamic)? onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 35.spMin,
        width: 180.spMin,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 30.0.spMin,
              child: IconButton(
                icon: Icon(Icons.arrow_left, size: 24.0.spMin),
                onPressed: onPressedLeftArrow,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ),
            Expanded(
              child: PopupMenuButton(
                elevation: 10.0,
                initialValue: initialValue,
                itemBuilder: itemBuilder,
                color: Theme.of(context).colorScheme.surface,
                child: Text(
                  buttonText,
                  style: TextStyle(fontSize: 16.0.spMin),
                  textAlign: TextAlign.center,
                ),
                onSelected: onSelected,
              ),
            ),
            SizedBox(
              width: 30.0.spMin,
              child: IconButton(
                icon: Icon(Icons.arrow_right, size: 24.0.spMin),
                onPressed: onPressedRightArrow,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ),
          ],
        ));
  }
}

class AddCurrentLocationButton extends StatelessWidget {
  const AddCurrentLocationButton({Key? key, required this.visible}) : super(key: key);

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeolocationBloc, GeolocationState>(builder: (context, state) {
      return Visibility(
          visible: visible && !state.isEnabled,
          child: GestureDetector(
              child: const ListTile(
                  leading: Icon(Icons.add_location_alt),
                  title: Text('Add current location'),
                  contentPadding: EdgeInsets.zero),
              onTap: () async {
                if (!state.isEnabled) {
                  var turnOnLocationService = await showLocationOffDialog(context);
                  if (turnOnLocationService) {
                    context
                        .read<GeolocationBloc>()
                        .add(EnableGeolocation(isEnabled: true, context: context));
                  }
                }
              }));
    });
  }
}
