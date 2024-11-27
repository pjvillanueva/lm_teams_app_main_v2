import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:lm_teams_app/logic/cubits/theme_cubit.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import '../../data/constants/constants.dart';
import 'app_web_view.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return AppFrame(
      title: "Settings",
      content: ListView(children: [
        SizedBox(height: 20.spMin),
        // const SubtitleWithIcon(icon: Icons.person, subtitle: 'Account'),
        // const SettingsItemTile(title: 'Edit Profile'),
        // const SettingsItemTile(title: 'Change Password'),
        // const SettingsItemTile(title: 'Switch Account'),
        // SizedBox(height: 10.spMin),
        const SubtitleWithIcon(icon: Icons.style, subtitle: 'Apperance'),
        SizedBox(
            height: 50.spMin,
            child: Row(children: [
              Text('Dark Mode', style: TextStyle(fontSize: 16.spMin)),
              const Spacer(flex: 1),
              BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
                return FlutterSwitch(
                    width: 50.spMin,
                    height: 30.spMin,
                    padding: 2.0.spMin,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: state.themeMode == ThemeMode.dark,
                    onToggle: (value) {
                      context.read<ThemeCubit>().setTheme(value);
                    });
              })
            ])),
        SizedBox(height: 10.spMin),
        const SubtitleWithIcon(icon: Icons.policy, subtitle: 'App Usage & Privacy'),
        SettingsItemTile(
            title: 'Terms of Service',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AppWebView(title: 'Terms of Service', url: termsOfServiceUrl)))),
        SettingsItemTile(
            title: 'Privacy Policy',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AppWebView(title: 'Privacy Policy', url: privacyPolicyUrl))))
      ]),
    );
  }
}

class SubtitleWithIcon extends StatelessWidget {
  const SubtitleWithIcon({
    Key? key,
    required this.icon,
    required this.subtitle,
  }) : super(key: key);

  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Icon(icon, size: 25.spMin),
        SizedBox(width: 10.spMin),
        Text(subtitle, style: TextStyle(fontSize: 20.spMin))
      ]),
      Divider(thickness: 1.0.spMin)
    ]);
  }
}

class SettingsItemTile extends StatelessWidget {
  const SettingsItemTile({Key? key, required this.title, this.onPressed}) : super(key: key);

  final String title;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50.h,
        child: Row(children: [
          Text(title, style: TextStyle(fontSize: 16.spMin)),
          const Spacer(flex: 1),
          IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: onPressed)
        ]));
  }
}
