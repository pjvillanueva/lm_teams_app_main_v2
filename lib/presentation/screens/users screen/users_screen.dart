import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/users_cubit.dart';
import 'package:lm_teams_app/presentation/screens/empty_list_screen.dart';
import 'package:lm_teams_app/presentation/screens/users%20screen/user_admin_edit.dart';
import 'package:lm_teams_app/presentation/screens/users%20screen/user_view.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import '../../../logic/blocs/account_bloc.dart';
import '../../widgets/avatars.dart';
import '../../widgets/snackbar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen> {
  final _controller = TextEditingController();
  bool _isSearching = false;

  final List<Map<String, dynamic>> _userOptions = [
    {'value': 0, 'label': 'Edit User'},
    {'value': 1, 'label': 'Delete User'}
  ];

  @override
  void initState() {
    var account = context.read<AccountBloc>().state.account;
    context.read<UsersCubit>().getUsers(account.id);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = context.read<UserBloc>().state.user;

    return AppFrame(
        title: "Users",
        content: BlocBuilder<UsersCubit, UsersState>(builder: (context, state) {
          var users = _isSearching ? state.filteredUsers : state.users;

          void _onChange(String text) {
            if (text.isNotEmpty) {
              BlocProvider.of<UsersCubit>(context).searchUser(text);
              if (_isSearching == false) {
                BlocProvider.of<UsersCubit>(context).searchStatusChanged(true);
                setState(() => _isSearching = true);
              }
            } else {
              BlocProvider.of<UsersCubit>(context).searchStatusChanged(false);
              setState(() => _isSearching = false);
            }
          }

          void _clearSearchInput() {
            _controller.clear();
            BlocProvider.of<UsersCubit>(context).searchStatusChanged(false);
            setState(() => _isSearching = false);
          }

          return Visibility(
            visible: state.users.isNotEmpty,
            replacement:
                const EmptyListScreen(text: 'No user found', assetName: 'assets/logo/no_users.png'),
            child: Column(children: [
              GenericSearchBar(
                  onchanged: _onChange,
                  controller: _controller,
                  icon: Icon(_isSearching ? Icons.close : Icons.search, size: 24.0.spMin),
                  onpressed: () {
                    if (_isSearching) {
                      FocusScope.of(context).requestFocus(FocusNode());
                      _clearSearchInput();
                    }
                  }),
              const DividerWithText(title: "U S E R S"),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, int index) {
                        return Card(
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 20.0.spMin),
                                title:
                                    Text(users[index].name, style: TextStyle(fontSize: 16.0.spMin)),
                                leading: Avatar(
                                    isCircle: true,
                                    size: Size(40.0.spMin, 40.0.spMin),
                                    borderWidth: 1.0.spMin,
                                    image: users[index].image,
                                    placeholder: Text(users[index].initials,
                                        style: TextStyle(fontSize: 12.0.spMin))),
                                subtitle: Text(state.getaccountMemberRole(users[index].id)),
                                trailing: Visibility(
                                    visible: true,
                                    child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
                                        builder: (context, connectivityState) {
                                      return PopupMenuButton(
                                          icon: Icon(Icons.more_vert, size: 24.0.spMin),
                                          itemBuilder: (context) {
                                            return _userOptions.map((option) {
                                              return PopupMenuItem(
                                                  value: option['value'],
                                                  child: Text(option['label']));
                                            }).toList();
                                          },
                                          onSelected: (value) async {
                                            if (value != null) {
                                              switch (value) {
                                                case 0:
                                                  if (connectivityState is! ConnectedState) {
                                                    showAppSnackbar(
                                                        context, 'Not connected to server',
                                                        isError: true);
                                                    return;
                                                  }
                                                  Navigator.push(context,
                                                      MaterialPageRoute(builder: (newContext) {
                                                    return BlocProvider.value(
                                                      value: BlocProvider.of<UsersCubit>(context),
                                                      child: UserAdminEditForm(user: users[index]),
                                                    );
                                                  }));
                                                  break;
                                                case 1:
                                                  if (connectivityState is! ConnectedState) {
                                                    showAppSnackbar(
                                                        context, 'Not connected to server',
                                                        isError: true);
                                                    return;
                                                  }
                                                  //TODO: Delete User
                                                  print('Delete this user');
                                              }
                                            }
                                          });
                                    })),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserView(
                                                user: users[index],
                                                currentUser: currentUser,
                                              )));
                                }));
                      }),
                ),
              )
            ]),
          );
        }));
  }
}
