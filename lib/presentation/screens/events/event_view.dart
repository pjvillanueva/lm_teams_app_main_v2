import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/cubits/statistics_tab_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/image_options.dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/rename_dialog.dart';
import 'package:lm_teams_app/presentation/screens/events/event_members_tab_view.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/event_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import '../../../data/constants/constants.dart';
import '../../../data/models/event model/event.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import '../../../data/models/member model/member.dart';
import '../../../data/models/user model/user.dart';
import '../../../logic/blocs/account_bloc.dart';
import '../../../logic/blocs/user_bloc.dart';
import '../../../logic/cubits/events_cubit.dart';
import '../../../services/uploader_service.dart';
import '../../dialogs/confirmation_dialog.dart';
import '../../widgets/frames.dart';
import 'event_inventory_tab_view.dart';
import 'event_statistics_tab_view.dart';

class EventView extends StatefulWidget {
  const EventView({Key? key, required this.event}) : super(key: key);
  final Event event;
  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final int currentDateTimeRange = 2;
  final List<Map<String, dynamic>> _dropDownItems = [
    {'value': 1, 'label': 'Rename Event', 'enabled': true},
    {'value': 2, 'label': 'Delete Event', 'enabled': true}
  ];

  final _utils = UtilsService();
  final _eventService = EventService();
  final _uploaderService = UploaderService();
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    final AccountRole _accountMemberRole = context.read<AccountBloc>().state.role;
    final User _currentUser = context.read<UserBloc>().state.user;
    return BlocProvider(
        create: (context) => StatisticsTabCubit(),
        child: AppFrame(
            title: 'My Event',
            padding: 0,
            actions: [
              BlocBuilder<StatisticsTabCubit, StatisticsTabState>(builder: (context, state) {
                return Visibility(
                    visible: _isAdminOrLeader(_currentUser, _accountMemberRole, state.members),
                    child: PopupMenuButton(
                        icon: Icon(Icons.more_vert, size: 24.0.spMin, color: Colors.white),
                        itemBuilder: (context) {
                          return _dropDownItems
                              .map((item) => PopupMenuItem(
                                  value: item['value'],
                                  enabled: isOptionEnabled(_currentUser, _accountMemberRole,
                                      item['value'], state.members),
                                  child: Text(item['label'])))
                              .toList();
                        },
                        onSelected: (value) async {
                          if (value != null) {
                            switch (value) {
                              case 1:
                                //rename event
                                var newName = await showRenameDialog(
                                    context, 'Rename Event', widget.event.name);
                                if (newName == null || newName == widget.event.name) {
                                  showAppSnackbar(context, 'No changes made', isError: true);
                                  return;
                                }
                                var _updates = {'id': widget.event.id, 'name': newName};
                                _eventService.updateEvent(_updates);

                                setState(() {
                                  widget.event.name = newName;
                                });
                                break;
                              case 2:
                                // delete event
                                try {
                                  var proceedDelete = await showDeleteConfirmation(
                                      context,
                                      'Delete Event',
                                      'Are you sure you want to delete this event?');
                                  if (proceedDelete) {
                                    await context.read<EventsCubit>().deleteEvent(widget.event);
                                    showAppSnackbar(context, 'Event deleted');
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  print(e);
                                  showAppSnackbar(context, 'Failed to delete event', isError: true);
                                }
                                break;
                              default:
                            }
                          }
                        }));
              })
            ],
            content: SizedBox(
                height: MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top,
                child: Column(children: [
                  Container(
                      height: 100.spMin,
                      padding: EdgeInsets.all(10.0.spMin),
                      child: Row(children: [
                        Avatar(
                            placeholder: Icon(Icons.event, size: 30.spMin),
                            size: Size(80.spMin, 100.spMin),
                            image: widget.event.image,
                            imageFile: imageFile,
                            onTapPicture: () async {
                              File? _imageFile = imageFile ??
                                  (widget.event.image != null
                                      ? await _utils.urlToFile(widget.event.image!.url)
                                      : null);
                              File? newFile =
                                  await showImageOptionsDialog(context, imageFile: _imageFile);
                              if (newFile != null) {
                                showLoaderDialog(context);
                                var imageObj = await _uploaderService.uploadAndGetImageObj(newFile);

                                var _updates = {'id': widget.event.id, 'image': imageObj};

                                _eventService.updateEvent(_updates);
                                Navigator.pop(context);
                                setState(() {
                                  imageFile = newFile;
                                });
                              }
                            }),
                        SizedBox(width: 10.0.spMin),
                        Flexible(
                            flex: 1,
                            child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Column(children: [
                                  Text(widget.event.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 22.spMin)),
                                  Text(
                                      '${widget.event.eventStartDate?.simplified} - ${widget.event.eventEndDate?.simplified}',
                                      style: TextStyle(fontSize: 16.spMin))
                                ])))
                      ])),
                  Flexible(
                      flex: 1,
                      child: DefaultTabController(
                          length: 3,
                          child: Column(children: [
                            TabBar(
                                tabAlignment: TabAlignment.start,
                                isScrollable: true,
                                indicator: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    shape: BoxShape.rectangle),
                                labelColor: Theme.of(context).colorScheme.onSurface,
                                indicatorWeight: 2.0,
                                padding: EdgeInsets.zero,
                                indicatorPadding: EdgeInsets.zero,
                                labelPadding: EdgeInsets.zero,
                                tabs: [
                                  SizedBox(width: 100.spMin, child: const Tab(text: 'Statistics')),
                                  SizedBox(width: 100.spMin, child: const Tab(text: 'Members')),
                                  SizedBox(width: 100.spMin, child: const Tab(text: 'Inventory')),
                                ]),
                            Expanded(
                                child: TabBarView(children: [
                              EventStatisticsTabView(event: widget.event),
                              EventMembersTabView(event: widget.event),
                              EventInventoryTabView(event: widget.event)
                            ]))
                          ])))
                ]))));
  }
}

bool _isAdminOrLeader(User user, AccountRole role, List<Member> members) {
  if (role == AccountRole.admin || role == AccountRole.owner) return true;
  if (members.isEmpty) return false;

  var index = members.indexWhere((member) => member.user?.id == user.id);
  if (index != -1) {
    return members[index].isLeader;
  }
  return false;
}

bool isOptionEnabled(User user, AccountRole role, int value, List<Member> members) {
  if (value == 1) return true;
  return _isAdminOrLeader(user, role, members);
}
