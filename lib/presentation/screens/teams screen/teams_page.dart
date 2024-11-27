import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/cubits/teams_cubit.dart';
import 'package:lm_teams_app/logic/cubits/users_cubit.dart';
import 'package:lm_teams_app/presentation/screens/empty_list_screen.dart';
import 'package:lm_teams_app/presentation/screens/teams%20screen/team_form.dart';
import 'package:lm_teams_app/presentation/screens/teams%20screen/team_view.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';

// ignore: must_be_immutable
class TeamsPage extends StatefulWidget {
  const TeamsPage(this.accountId, {Key? key}) : super(key: key);

  final String accountId;

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    context.read<TeamsCubit>().getAccountTeams(widget.accountId);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _teams = context.read<TeamsCubit>().state.teams;
    final _users = context.read<UsersCubit>().state.users;

    return AppFrame(
        title: "Teams",
        floatingActionButton: IconAndTextButton(
            icon: Icons.group_add,
            color: Theme.of(context).colorScheme.secondary,
            buttonName: "NEW TEAM",
            onPressed: () async {
              final team =
                  await Navigator.push<Team>(context, MaterialPageRoute(builder: (newContext) {
                return BlocProvider.value(
                    value: BlocProvider.of<HomeScreenBloc>(context),
                    child: TeamForm(teams: _teams, users: _users));
              }));

              if (team != null) {
                context.read<TeamsCubit>().addTeam(team);
              }
            }),
        content: BlocBuilder<TeamsCubit, TeamsState>(builder: (context, state) {
          void _onChange(String text) {
            if (text.isNotEmpty) {
              BlocProvider.of<TeamsCubit>(context).searchTeam(text);
              if (_isSearching == false) {
                BlocProvider.of<TeamsCubit>(context).searchStatusChanged(true);
                setState(() => _isSearching = true);
              }
            } else {
              BlocProvider.of<TeamsCubit>(context).searchStatusChanged(false);
              setState(() => _isSearching = false);
            }
          }

          void _clearSearchInput() {
            _searchController.clear();
            BlocProvider.of<TeamsCubit>(context).searchStatusChanged(false);
            setState(() => _isSearching = false);
          }

          return Visibility(
              visible: state.teams.isNotEmpty,
              replacement: const EmptyListScreen(
                  text: 'No team found', assetName: 'assets/logo/no_teams.png'),
              child: Column(children: [
                GenericSearchBar(
                    onchanged: _onChange,
                    controller: _searchController,
                    icon: Icon(_isSearching ? Icons.close : Icons.search),
                    onpressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      _clearSearchInput();
                    }),
                const DividerWithText(title: 'T E A M S'),
                getExpansionTiles(
                    context,
                    _isSearching
                        ? state.getSearchedParentsObjects(_searchController.text)
                        : state.parentObjects)
              ]));
        }));
  }
}

Widget getExpansionTiles(BuildContext context, List<Parent> parents) {
  List<Widget> expansionTiles = [];
  for (var parent in parents) {
    expansionTiles.add(_createExpansionTilesTree(context, parent, 1));
  }
  return Expanded(child: Scrollbar(child: ListView(children: expansionTiles)));
}

Widget _createExpansionTilesTree(BuildContext context, Parent parent, int depth) {
  final List<Widget> children =
      parent.children.map((e) => _createExpansionTilesTree(context, e, depth + 1)).toList();

  return TeamExpansionTile(
      parent: parent,
      children: children,
      depth: depth,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (newContext) {
          return BlocProvider.value(
              value: BlocProvider.of<HomeScreenBloc>(context), child: TeamView(team: parent.self));
        }));
      });
}
