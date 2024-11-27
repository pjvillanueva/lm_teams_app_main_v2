import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_data_model.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_model.dart';
import 'package:lm_teams_app/logic/cubits/contacts_cubit.dart';
import 'package:lm_teams_app/logic/cubits/entry_history_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/book_entry_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/contact_entry_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/money_entry_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/notes_entry_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/entry%20dialogs/prayer_entry_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/user model/user.dart';
import '../../../logic/blocs/user_bloc.dart';
import '../../../services/entry_service.dart';
import '../../dialogs/confirmation_dialog.dart';

class EntryHistoryScreen extends StatefulWidget {
  const EntryHistoryScreen({
    Key? key,
    required this.filter,
  }) : super(key: key);

  final EntryFilter filter;
  @override
  State<EntryHistoryScreen> createState() => _EntryHistoryScreenState();
}

class _EntryHistoryScreenState extends State<EntryHistoryScreen> {
  final utils = UtilsService();

  final List<Map<String, dynamic>> _entryOptions = [
    {'value': 0, 'label': 'Edit Entry'},
    {'value': 1, 'label': 'Delete Entry'}
  ];

  @override
  void initState() {
    context.read<EntryHistoryCubit>().getEntries(widget.filter);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    User _user = context.read<UserBloc>().state.user;

    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: BlocBuilder<EntryHistoryCubit, EntryHistoryState>(builder: (context, state) {
          if (state.historyObjects.isNotEmpty) {
            var entries = state.historyObjects[state.dateIndex].entries;
            return Column(children: [
              const Divider(),
              Expanded(
                  child: Scrollbar(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            return Card(
                                color: Theme.of(context).colorScheme.surface,
                                child: ListTile(
                                    leading: _getLeading(entries[index], screenWidth),
                                    title: _getTitle(entries[index]),
                                    subtitle: Text(entries[index].time.timeAgo),
                                    onTap: () {
                                      switch (entries[index].type) {
                                        case EntryType.money:
                                          showMoneyEntryDialog(context, EntryDialogMode.view,
                                              entry: entries[index],
                                              historyObjectIndex: state.dateIndex,
                                              locationEvent: entries[index].locationEvent);
                                          break;
                                        case EntryType.notes:
                                          showNoteEntryDialog(context, EntryDialogMode.view,
                                              entry: entries[index],
                                              historyObjectIndex: state.dateIndex,
                                              locationEvent: entries[index].locationEvent);
                                          break;
                                        case EntryType.prayer:
                                          showPrayerEntryDialog(context, EntryDialogMode.view,
                                              entry: entries[index],
                                              historyObjectIndex: state.dateIndex,
                                              locationEvent: entries[index].locationEvent);
                                          break;
                                        case EntryType.contact:
                                          showContactEntryDialog(context, EntryDialogMode.view,
                                              entry: entries[index],
                                              historyObjectIndex: state.dateIndex,
                                              locationEvent: entries[index].locationEvent);
                                          break;
                                        case EntryType.book:
                                          showBookEntryDialog(context, EntryDialogMode.view,
                                              entry: entries[index],
                                              historyObjectIndex: state.dateIndex,
                                              locationEvent: entries[index].locationEvent);
                                          break;
                                        default:
                                      }
                                    },
                                    trailing: PopupMenuButton(
                                        icon: Icon(Icons.more_vert, size: 24.0.spMin),
                                        itemBuilder: (context) {
                                          return _entryOptions.map((option) {
                                            return PopupMenuItem(
                                                value: option['value'],
                                                child: Text(option['label']));
                                          }).toList();
                                        },
                                        onSelected: (value) async {
                                          if (value != null) {
                                            switch (value) {
                                              case 0:
                                                switch (entries[index].type) {
                                                  case EntryType.book:
                                                    showBookEntryDialog(
                                                        context, EntryDialogMode.edit,
                                                        entry: entries[index],
                                                        historyObjectIndex: state.dateIndex,
                                                        locationEvent:
                                                            entries[index].locationEvent);
                                                    break;
                                                  case EntryType.contact:
                                                    showContactEntryDialog(
                                                        context, EntryDialogMode.edit,
                                                        entry: entries[index],
                                                        historyObjectIndex: state.dateIndex,
                                                        locationEvent:
                                                            entries[index].locationEvent);
                                                    break;
                                                  case EntryType.money:
                                                    showMoneyEntryDialog(
                                                        context, EntryDialogMode.edit,
                                                        entry: entries[index],
                                                        historyObjectIndex: state.dateIndex,
                                                        locationEvent:
                                                            entries[index].locationEvent);
                                                    break;
                                                  case EntryType.notes:
                                                    showNoteEntryDialog(
                                                        context, EntryDialogMode.edit,
                                                        entry: entries[index],
                                                        historyObjectIndex: state.dateIndex,
                                                        locationEvent:
                                                            entries[index].locationEvent);
                                                    break;
                                                  case EntryType.prayer:
                                                    showPrayerEntryDialog(
                                                        context, EntryDialogMode.edit,
                                                        entry: entries[index],
                                                        historyObjectIndex: state.dateIndex,
                                                        locationEvent:
                                                            entries[index].locationEvent);
                                                    break;
                                                }
                                                break;
                                              case 1:
                                                var proceedDelete = await showDeleteConfirmation(
                                                    context,
                                                    'Delete Entry',
                                                    'Are you sure you want to delete this entry?');
                                                if (proceedDelete) {
                                                  try {
                                                    //delete contact entry
                                                    BlocProvider.of<EntryHistoryCubit>(context)
                                                        .deleteEntry(
                                                            entries[index].id, state.dateIndex);

                                                    if (entries[index].type == EntryType.contact) {
                                                      var contact = entries[index].data as Contact;
                                                      context
                                                          .read<ContactsCubit>()
                                                          .deleteContact(contact, _user.id);
                                                    }

                                                    showAppSnackbar(context, 'Entry Deleted');
                                                  } catch (e) {
                                                    showAppSnackbar(
                                                        context, 'Failed: ${e.toString()}');
                                                  }
                                                }
                                                break;
                                            }
                                          }
                                        })));
                          })))
            ]);
          } else {
            return Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Image.asset('assets/logo/error.png', width: 150.spMin, height: 150.spMin),
                  Text("No Entry", style: TextStyle(fontSize: 16.spMin))
                ]));
          }
        }));
  }

  Widget _getLeading(Entry entry, double screenWidth) {
    String assetName = '';

    if (entry.type == EntryType.book) {
      BookEntryData data = entry.data as BookEntryData;

      if (data.item?.image != null) {
        return Avatar(
            image: data.item?.image!,
            size: Size(screenWidth / 9.spMin, 80.spMin),
            placeholder: Icon(Icons.book, size: 30.0.spMin));
      } else {
        return Icon(Icons.book, size: 30.0.spMin);
      }
    }

    switch (entry.type) {
      case EntryType.contact:
        assetName = 'contacts.svg';
        break;
      case EntryType.money:
        assetName = 'money.svg';
        break;
      case EntryType.notes:
        assetName = 'notes.svg';
        break;
      case EntryType.prayer:
        assetName = 'pray.svg';
        break;
      default:
    }

    return SvgPicture.asset('assets/svgIcons/' + assetName,
        width: 30.0,
        height: 30.0,
        allowDrawingOutsideViewBox: false,
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn));
  }

  Widget _getTitle(Entry entry) {
    String title = "";

    switch (entry.type) {
      case EntryType.book:
        var data = entry.data as BookEntryData;
        title = '${data.item?.name} (${data.quantity})';
        break;
      case EntryType.contact:
        Contact data = entry.data as Contact;
        title = data.name;
        break;
      case EntryType.money:
        var data = entry.data as MoneyEntryData;
        title = "Card: ${data.card}, Notes: ${data.notes}, Coins: ${data.coins}";
        break;
      case EntryType.notes:
        title = entry.data;
        break;
      case EntryType.prayer:
        title = entry.data;
        break;
      default:
    }

    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold));
  }
}
