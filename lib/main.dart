import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/logic/blocs/authentication_bloc.dart';
import 'package:lm_teams_app/logic/cubits/theme_cubit.dart';
import 'package:lm_teams_app/logic/utility/app_bloc_providers.dart';
import 'package:lm_teams_app/presentation/widgets/auth_navigator.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';
import 'package:lm_teams_app/services/preference_utils.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import 'package:lm_teams_app/themes/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterBranchSdk.validateSDKIntegration();

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  try {
    WebSocketService().init();
    PreferenceUtils().init();
    GeolocationService().init();
    // await NotificationService().init();
    // await NotificationService().requestIOSPermissions();
    await FlutterBranchSdk.init(useTestKey: true, enableLogging: true, disableTracking: false);
  } catch (e) {
    print("[ERROR] - $e");
  }

  //responsible for saving the last state of a cubit/bloc to local storage
  HydratedBloc.storage =
      await HydratedStorage.build(storageDirectory: await getApplicationDocumentsDirectory());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const AppBlocProviders(child: LETeamsApp());
  }
}

class LETeamsApp extends StatefulWidget {
  const LETeamsApp({
    Key? key,
  }) : super(key: key);
  @override
  _LETeamsAppState createState() => _LETeamsAppState();
}

class _LETeamsAppState extends State<LETeamsApp> {
  @override
  Widget build(BuildContext context) {
    var themeMode = context.select((ThemeCubit themeCubit) => themeCubit.state.themeMode);

    return ScreenUtilInit(
        designSize: const Size(412, 820),
        minTextAdapt: true,
        splitScreenMode: true,
        child: AuthNavigator(authBloc: context.read<AuthenticationBloc>()),
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
              home: child,
              title: 'LE-TEAMS',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode);
        });
  }
}
