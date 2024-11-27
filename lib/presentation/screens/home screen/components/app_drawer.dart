import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import '../../../../data/models/account.dart';
import '../../../../data/models/event model/event.dart';
import '../../../../data/models/team model/team.dart';
import '../../../../data/models/user model/user.dart';
import '../../../../logic/blocs/account_bloc.dart';
import '../../../../logic/blocs/authentication_bloc.dart';
import '../../../../logic/blocs/home_screen_bloc.dart';
import '../../../../logic/cubits/events_cubit.dart';
import '../../../../logic/cubits/teams_cubit.dart';
import '../../../../logic/cubits/users_cubit.dart';
import '../../../widgets/list_tiles.dart';
import '../../events/event_view.dart';
import '../../events/events_page.dart';
import '../../master inventory screen/master_inventory_page.dart';
import '../../no_user_group_screen.dart';
import '../../profile_view.dart';
import '../../settings_screen.dart';
import '../../teams screen/team_view.dart';
import '../../teams screen/teams_page.dart';
import '../../user inventory screen/user_inventory_page.dart';
import '../../users screen/users_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key, required this.updateParentState, required this.homeContext})
      : super(key: key);
  final VoidCallback updateParentState;
  final BuildContext homeContext;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext appDrawerContext) {
    final BuildContext homeContext = widget.homeContext;
    final _user = homeContext.read<UserBloc>().state.user;
    final _homeState = homeContext.read<HomeScreenBloc>().state;
    final _accountState = homeContext.read<AccountBloc>().state;

    final List<Map<String, dynamic>> _adminDrawerItems = [
      {
        'label': 'Users',
        'assetName': 'users.svg',
        'onTap': () {
          Navigator.pop(appDrawerContext);
          Navigator.push(homeContext, MaterialPageRoute(builder: (newContext) {
            return BlocProvider.value(
                value: BlocProvider.of<UsersCubit>(homeContext), child: const UsersScreen());
          }));
        }
      },
      {
        'label': 'Teams',
        'assetName': 'teams.svg',
        'onTap': () async {
          Navigator.pop(appDrawerContext);
          await Navigator.push(homeContext, MaterialPageRoute(builder: (newContext) {
            return MultiBlocProvider(providers: [
              BlocProvider.value(value: BlocProvider.of<TeamsCubit>(homeContext)),
              BlocProvider.value(value: BlocProvider.of<HomeScreenBloc>(homeContext))
            ], child: TeamsPage(_user.accountId ?? ''));
          })).then((_) => widget.updateParentState());
        }
      },
      {
        'label': 'Events',
        'assetName': 'events.svg',
        'onTap': () async {
          Navigator.pop(appDrawerContext);
          await Navigator.push(homeContext, MaterialPageRoute(builder: (newContext) {
            return MultiBlocProvider(providers: [
              BlocProvider.value(value: BlocProvider.of<EventsCubit>(homeContext)),
              BlocProvider.value(value: BlocProvider.of<HomeScreenBloc>(homeContext))
            ], child: EventsPage(_user.accountId ?? ''));
          })).then((_) => widget.updateParentState());
        }
      }
    ];

    final List<Map<String, dynamic>> _drawerItems = [
      {
        'label': 'Master Inventory',
        'assetName': 'master-inventory.svg',
        'onTap': () async {
          Navigator.pop(appDrawerContext);
          await Navigator.push(homeContext, MaterialPageRoute(builder: (newContext) {
            return BlocProvider.value(
                value: BlocProvider.of<HomeScreenBloc>(homeContext),
                child: const MasterInventoryPage());
          })).then((_) => widget.updateParentState());
        }
      },
      {
        'label': 'My Inventory',
        'assetName': 'inventory.svg',
        'onTap': () async {
          Navigator.pop(appDrawerContext);
          await Navigator.push(homeContext, MaterialPageRoute(builder: (newContext) {
            return BlocProvider.value(
                value: BlocProvider.of<HomeScreenBloc>(homeContext),
                child: const UserInventoryPage());
          })).then((_) => widget.updateParentState());
        }
      },
      {
        'label': 'My Team',
        'assetName': 'team.svg',
        'onTap': () async {
          Navigator.pop(appDrawerContext);
          Team _myTeam = _homeState.team;

          if (_myTeam == Team.empty) {
            Team? newTeam =
                await Navigator.push<Team>(homeContext, MaterialPageRoute(builder: (newContext) {
              return BlocProvider.value(
                  value: BlocProvider.of<HomeScreenBloc>(homeContext),
                  child: const NoUserGroupScreen(isTeam: true));
            }));
            if (newTeam == null) {
              showAppSnackbar(homeContext, 'No Team Selected', isError: true);
              return;
            }
            homeContext.read<TeamsCubit>().addTeam(newTeam);
            homeContext.read<HomeScreenBloc>().add(AddTeam(team: newTeam));
            homeContext.read<HomeScreenBloc>().add(SelectTeam(teamID: newTeam.id));
            _myTeam = newTeam;
          }

          await Navigator.push(homeContext, MaterialPageRoute(builder: (newContext) {
            return BlocProvider.value(
                value: BlocProvider.of<HomeScreenBloc>(homeContext),
                child: TeamView(team: _myTeam));
          })).then((_) => widget.updateParentState());
        }
      },
      {
        'label': 'My Event',
        'assetName': 'events.svg',
        'onTap': () async {
          Navigator.pop(appDrawerContext);
          Event _myEvent = _homeState.event;

          if (_myEvent == Event.empty) {
            Event? newEvent =
                await Navigator.push<Event>(homeContext, MaterialPageRoute(builder: (newContext) {
              return BlocProvider.value(
                  value: BlocProvider.of<HomeScreenBloc>(homeContext),
                  child: const NoUserGroupScreen(isTeam: false));
            }));

            if (newEvent == null) {
              showAppSnackbar(homeContext, 'No Event Selected', isError: true);
              return;
            }

            homeContext.read<EventsCubit>().addEvent(newEvent);
            homeContext.read<HomeScreenBloc>().add(AddEvent(event: newEvent));
            homeContext.read<HomeScreenBloc>().add(SelectEvent(eventID: newEvent.id));
            _myEvent = newEvent;
          }

          await Navigator.push(homeContext, MaterialPageRoute(builder: (newContext) {
            return BlocProvider.value(
                value: BlocProvider.of<HomeScreenBloc>(homeContext),
                child: EventView(event: _myEvent));
          })).then((_) => widget.updateParentState());
        }
      },
      {'label': 'My Profile', 'assetName': 'profile.svg', 'navigateTo': const ProfileView()},
      {'label': 'Settings', 'assetName': 'settings.svg', 'navigateTo': const Settings()},
      {
        'label': 'Logout',
        'assetName': 'logout.svg',
        'onTap': () async {
          homeContext.read<AuthenticationBloc>().add(LoggedOut(homeContext));
        }
      }
    ];

    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      return SizedBox(
          width: 300.0.spMin,
          child: Drawer(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: ListView(padding: EdgeInsets.zero, children: [
                SizedBox(
                    height: 220.spMin,
                    child: UserAccountsDrawerHeader(
                        margin: EdgeInsets.only(bottom: 8.0.w),
                        currentAccountPicture: Image.asset('assets/logo/logo.png'),
                        currentAccountPictureSize: Size(80.0.spMin, 70.0.spMin),
                        accountName: BlocBuilder<AccountBloc, AccountState>(
                            builder: (context, accountState) {
                          return Text(
                              accountState.account != Account.empty
                                  ? accountState.account.name
                                  : "No Account Name",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 16.0.spMin));
                        }),
                        accountEmail: Text(state.user != User.empty ? state.user.name : "",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 15.0.spMin)),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary))),
                Visibility(
                    visible: _accountState.role != AccountRole.le,
                    child: Column(children: <DrawerListTile>[
                      for (var item in _adminDrawerItems)
                        DrawerListTile(item['label'], item['assetName'], item['navigateTo'],
                            onTap: item['onTap'])
                    ])),
                for (var item in _drawerItems)
                  DrawerListTile(item['label'], item['assetName'], item['navigateTo'],
                      onTap: item['onTap'])
              ])));
    });
  }
}
