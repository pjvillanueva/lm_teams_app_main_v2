import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/entry_history_cubit.dart';
import 'package:lm_teams_app/logic/cubits/statistics_cubit.dart';
import 'package:lm_teams_app/logic/cubits/teams_cubit.dart';
import 'package:lm_teams_app/logic/cubits/users_cubit.dart';
import 'package:lm_teams_app/presentation/screens/home%20screen/components/bottom_navigation_bar.dart';
import 'package:lm_teams_app/presentation/screens/home%20screen/components/geolocation_switch.dart';
import 'package:lm_teams_app/presentation/screens/contact%20screen/contact_page.dart';
import 'package:lm_teams_app/presentation/screens/entry%20screen/entry_page.dart';
import 'package:lm_teams_app/presentation/screens/map%20screen%202/app_map.dart';
import 'package:lm_teams_app/presentation/screens/statistics%20screen/statistics_page.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/entry_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../logic/blocs/account_bloc.dart';
import '../../../logic/cubits/inventory_item_grid_cubit.dart';
import '../../../logic/cubits/message_queue_cubit.dart';
import '../../../services/items_service.dart';
import 'components/app_drawer.dart';
import 'components/connectivity_indicator.dart';
import 'components/context_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var dateRangeController = TextEditingController();
  final GlobalKey<ScaffoldState> homeScreenScaffoldKey = GlobalKey();
  final _pageController = PageController();
  var _selectedItem = 0;
  var user = User.empty;

  @override
  initState() {
    var account = context.read<AccountBloc>().state.account;
    context.read<UsersCubit>().getUsers(account.id);
    context.read<TeamsCubit>().getAccountTeams(account.id);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _user = context.read<UserBloc>().state.user;

    return MultiBlocProvider(
        providers: [
          BlocProvider<HomeScreenBloc>(create: (context) {
            return HomeScreenBloc()..add(InitialEvent(userID: _user.id, context: context));
          }),
          BlocProvider<EntryHistoryCubit>(create: (context) {
            final homeScreenBloc = context.read<HomeScreenBloc>().state;
            return EntryHistoryCubit()
              ..getEntries(EntryFilter(
                  dateRangeStart: homeScreenBloc.dateRangeStart,
                  dateRangeEnd: homeScreenBloc.dateRangeEnd));
          }),
          BlocProvider(create: ((context) => StatisticsCubit())),
          BlocProvider(create: (context) {
            final homeState = context.read<HomeScreenBloc>().state;
            return InventoryItemGridCubit()
              ..getInventoryItems(IReadItemContext(
                  userId: _user.id, teamId: homeState.team.id, eventId: homeState.event.id));
          })
        ],
        child: BlocListener<ConnectivityBloc, ConnectivityState>(
            listenWhen: (previous, current) => previous != current,
            listener: (context, state) async {
              if (state is ConnectedState) {
                _connectionRestoredRefresh(context, _user);
              } else {
                showAppSnackbar(context, 'Disconnected from server', isError: true);
              }
            },
            child: BlocConsumer<HomeScreenBloc, HomeScreenState>(
                listenWhen: (previousState, currentState) => previousState != currentState,
                listener: (context, state) {
                  _homeStateChangeRefresh(context, _user, state);
                },
                builder: (context, state) {
                  dateRangeController = TextEditingController(text: state.dateRangeString);

                  void updateState() {
                    //refetch user team and events
                    context.read<HomeScreenBloc>().add(FetchUserTeamsAndEvents(userID: _user.id));
                    //refetch item inventories
                    BlocProvider.of<InventoryItemGridCubit>(context).getInventoryItems(
                        IReadItemContext(
                            userId: _user.id, teamId: state.team.id, eventId: state.event.id));
                  }

                  return Scaffold(
                      key: homeScreenScaffoldKey,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      extendBody: true,
                      appBar: PreferredSize(
                          preferredSize: Size(double.infinity, 110.spMin),
                          child: AppBar(
                              elevation: 5.0,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              leading: IconButton(
                                  icon: Icon(Icons.dehaze, size: 25.0.sp, color: Colors.white),
                                  onPressed: () {
                                    if (homeScreenScaffoldKey.currentState?.isDrawerOpen == false) {
                                      homeScreenScaffoldKey.currentState?.openDrawer();
                                    } else {
                                      homeScreenScaffoldKey.currentState?.openEndDrawer();
                                    }
                                  }),
                              leadingWidth: 56.0.spMin,
                              actions: [
                                const ConnectivityIndicator(),
                                GeolocationSwitch(onToggle: (value) {
                                  context
                                      .read<GeolocationBloc>()
                                      .add(EnableGeolocation(isEnabled: value, context: context));
                                })
                              ],
                              bottom: ContextBar(height: 70.spMin))),
                      body: PageView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            EntryPage(),
                            ContactsPage(),
                            AppMap(),
                            StatisticsPage(isFullScreen: false)
                          ],
                          onPageChanged: (index) {
                            setState(() {
                              _selectedItem = index;
                            });
                          },
                          controller: _pageController),
                      drawer: AppDrawer(updateParentState: updateState, homeContext: context),
                      bottomNavigationBar: HomeBottomNavigationBar(
                          pageController: _pageController, selectedItem: _selectedItem));
                })));
  }
}

Future<void> _connectionRestoredRefresh(BuildContext context, User user) async {
  final homeState = context.read<HomeScreenBloc>().state;

  showAppSnackbar(context, 'Connected to server');

  //2 seconds delay
  await Future.delayed(const Duration(seconds: 2));

  //Send queued messages while offline
  await context.read<MessageQueueCubit>().sendMessagesToBackend();

  //Fetch item inventories
  BlocProvider.of<InventoryItemGridCubit>(context).getInventoryItems(
      IReadItemContext(userId: user.id, teamId: homeState.team.id, eventId: homeState.event.id));

  //Fetch user teams and events
  context.read<HomeScreenBloc>().add(FetchUserTeamsAndEvents(userID: user.id));

  //Fetch entry history
  context.read<EntryHistoryCubit>().getEntries(
      EntryFilter(dateRangeStart: homeState.dateRangeStart, dateRangeEnd: homeState.dateRangeEnd));
}

void _homeStateChangeRefresh(BuildContext context, User user, HomeScreenState state) {
  //update entry history
  BlocProvider.of<EntryHistoryCubit>(context).getEntries(
      EntryFilter(dateRangeStart: state.dateRangeStart, dateRangeEnd: state.dateRangeEnd));
  //update inventory items
  BlocProvider.of<InventoryItemGridCubit>(context).getInventoryItems(
      IReadItemContext(userId: user.id, teamId: state.team.id, eventId: state.event.id));
}
