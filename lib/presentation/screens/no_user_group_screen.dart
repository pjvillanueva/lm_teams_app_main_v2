import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/event%20model/event.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/presentation/screens/events/event_form.dart';
import 'package:lm_teams_app/presentation/screens/teams%20screen/team_form.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import '../../logic/blocs/home_screen_bloc.dart';
import '../../logic/cubits/teams_cubit.dart';
import '../../logic/cubits/users_cubit.dart';

class NoUserGroupScreen extends StatelessWidget {
  const NoUserGroupScreen({Key? key, required this.isTeam}) : super(key: key);

  final bool isTeam;

  @override
  Widget build(BuildContext context) {
    var teams = context.read<TeamsCubit>().state.teams;
    var users = context.read<UsersCubit>().state.users;

    return Scaffold(
        key: key,
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop()),
            elevation: 0.0),
        body: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0.spMin, vertical: 40.0.spMin),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Image.asset('assets/logo/error.png', width: 200.spMin, height: 200.spMin),
                  Text(
                      'No selected ${isTeam ? 'team' : 'event'}. Please select a ${isTeam ? 'team' : 'event'} and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20.0, color: Theme.of(context).colorScheme.onBackground)),
                  SizedBox(height: 20.0.spMin),
                  const DividerWithText(title: 'OR'),
                  SizedBox(height: 20.0.spMin),
                  BlocBuilder<ConnectivityBloc, ConnectivityState>(builder: (context, state) {
                    return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0.spMin)),
                            backgroundColor: Theme.of(context).colorScheme.secondary),
                        child: Text('CREATE NEW ${isTeam ? 'TEAM' : 'EVENT'}',
                            style: const TextStyle(color: Colors.white)),
                        onPressed: state is ConnectedState
                            ? () async {
                                if (isTeam) {
                                  Team? team = await Navigator.push(context,
                                      MaterialPageRoute(builder: (newContext) {
                                    return BlocProvider.value(
                                        value: BlocProvider.of<HomeScreenBloc>(context),
                                        child: TeamForm(teams: teams, users: users));
                                  }));
                                  Navigator.pop(context, team);
                                } else {
                                  Event? event = await Navigator.push<Event>(context,
                                      MaterialPageRoute(builder: (newContext) {
                                    return BlocProvider.value(
                                        value: BlocProvider.of<HomeScreenBloc>(context),
                                        child: EventForm(users: users));
                                  }));
                                  Navigator.pop(context, event);
                                }
                              }
                            : null);
                  })
                ]))));
  }
}
