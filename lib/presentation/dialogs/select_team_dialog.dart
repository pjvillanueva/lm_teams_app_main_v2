import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/services/team_service.dart';

Future<List<Team>?> showSelectTeamDialog({
  required BuildContext context,
  required String title,
  required String accountId,
  required List<Team> selectedTeams,
}) async {
  final _teamService = TeamService();
  var allTeams = await _teamService.getAccountTeams(accountId);
  return await showDialog(
      context: context,
      builder: (context) {
        bool isSearching = false;
        List<TeamCheckboxItem> items = teamToCheckboxItem(allTeams, selectedTeams);
        final _controller = TextEditingController();

        return StatefulBuilder(builder: ((context, setState) {
          void searchTeam(String query) {
            var _items = items;
            if (query.isNotEmpty) {
              var filteredItems = _items
                  .where((_item) => _item.team.name
                      .toLowerCase()
                      .replaceAll(' ', '')
                      .contains(query.toLowerCase().replaceAll(' ', '')))
                  .toList();
              setState(() {
                items = filteredItems;
              });
            } else {
              setState(() {
                items = teamToCheckboxItem(allTeams, selectedTeams);
              });
            }
          }

          return AppDialog(title: title, contents: [
            SizedBox(
                width: double.maxFinite,
                child: Column(children: [
                  SizedBox(height: 20.0.spMin),
                  GenericSearchBar(
                      icon:
                          isSearching == true ? const Icon(Icons.close) : const Icon(Icons.search),
                      onchanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            isSearching = true;
                          });
                        } else {
                          setState(() {
                            isSearching = false;
                          });
                        }
                        searchTeam(value);
                      },
                      controller: _controller,
                      onpressed: () {
                        if (isSearching == true) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _controller.clear();
                          setState(() {
                            items = teamToCheckboxItem(allTeams, selectedTeams);
                            isSearching = false;
                          });
                        }
                      }),
                  Container(
                      child: items != []
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                TeamCheckboxItem _item = items[index];

                                return CheckboxListTile(
                                    title: Text(_item.team.name, overflow: TextOverflow.ellipsis),
                                    activeColor: Theme.of(context).colorScheme.secondary,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    value: _item.isChecked,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _item.isChecked = value;
                                        });
                                      }
                                    });
                              })
                          : null),
                  const SizedBox(height: 15),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
                    TextButton(
                        onPressed: () {
                          List<Team> _selectedTeams = [];
                          for (var item in items) {
                            if (item.isChecked) {
                              _selectedTeams.add(item.team);
                            }
                          }
                          Navigator.pop(context, _selectedTeams);
                        },
                        child: Text('DONE',
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary)))
                  ])
                ]))
          ]);
        }));
      });
}

class TeamCheckboxItem {
  TeamCheckboxItem({required this.team, required this.isChecked});
  final Team team;
  bool isChecked;

  @override
  String toString() => "TeamCheckboxItem: team: $team, isChecked: $isChecked";
}

List<TeamCheckboxItem> teamToCheckboxItem(List<Team> allTeams, List<Team> selectedTeams) {
  List<TeamCheckboxItem> items = [];
  for (var team in allTeams) {
    items.add(TeamCheckboxItem(team: team, isChecked: selectedTeams.contains(team)));
  }
  return items;
}
