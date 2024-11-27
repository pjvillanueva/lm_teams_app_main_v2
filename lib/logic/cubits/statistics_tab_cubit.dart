import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/member%20model/member.dart';
import 'package:lm_teams_app/data/models/statistics%20model/statistics_object.dart';
import 'package:lm_teams_app/data/models/user%20model/team_invitee.dart';
import 'package:lm_teams_app/services/statistics_service.dart';
import 'package:collection/collection.dart';
import '../../data/models/statistics model/dispensed_book_model.dart';
import '../../data/models/statistics model/statistics_filter.dart';
import '../../services/event_service.dart';
import '../../services/team_service.dart';

class TableData {
  TableData(
      {required this.selectedMembers, required this.dispensedBooks, required this.quantityList});
  final List<Member> selectedMembers;
  final List<DispensedBook> dispensedBooks;
  final List<List<int>> quantityList;

  @override
  String toString() =>
      'TableData (selectedMembers: $selectedMembers, dispensedBooks: $dispensedBooks, quantityList: $quantityList)';

  static TableData empty = TableData(selectedMembers: [
    Member.empty
  ], dispensedBooks: [
    DispensedBook.empty
  ], quantityList: [
    [0]
  ]);
}

class StatisticsTabState {
  StatisticsTabState(
      {required this.dateTimeRange,
      required this.members,
      required this.invitees,
      required this.selectedMembers,
      required this.statisticsObjects});

  DateTimeRange dateTimeRange;
  List<Member> members;
  List<TeamInvitee> invitees;
  List<Member> selectedMembers;
  List<StatisticsObject> statisticsObjects;

  StatisticsTabState copyWith({
    DateTimeRange? dateTimeRange,
    List<Member>? members,
    List<TeamInvitee>? invitees,
    List<Member>? selectedMembers,
    List<StatisticsObject>? statisticsObjects,
  }) {
    return StatisticsTabState(
        dateTimeRange: dateTimeRange ?? this.dateTimeRange,
        members: members ?? this.members,
        invitees: invitees ?? this.invitees,
        selectedMembers: selectedMembers ?? this.selectedMembers,
        statisticsObjects: statisticsObjects ?? this.statisticsObjects);
  }

  Member getMember(String userID) {
    try {
      return selectedMembers.where((member) => member.userId == userID).first;
    } catch (e) {
      return Member.empty;
    }
  }

  String getMemberName(String userID) => getMember(userID).name;
  String getMemberInitials(String userID) => getMember(userID).initials;

  TableData get tableData {
    Map<String, DispensedBook> _dispensedBookMap = {};
    List<List<int>> _quantityList = [];

    final _validMemberStatisticsObject = selectedMembers
        .map((member) =>
            statisticsObjects.firstWhereOrNull((object) => object.ownerId == member.userId))
        .whereNotNull()
        .toList();

    for (var object in _validMemberStatisticsObject) {
      for (var book in object.books) {
        if (_dispensedBookMap.containsKey(book.code)) {
          _dispensedBookMap[book.code]!.quantity += book.quantity;
        } else {
          _dispensedBookMap[book.code] = book;
        }
      }
    }

    _quantityList = _dispensedBookMap.values
        .toList()
        .map((item) => selectedMembers.map((member) {
              final object = _validMemberStatisticsObject
                  .firstWhereOrNull((object) => object.ownerId == member.userId);
              return object != null
                  ? object.books.firstWhereOrNull((book) => book.code == item.code)?.quantity ?? 0
                  : 0;
            }).toList())
        .toList();

    return TableData(
        dispensedBooks: _dispensedBookMap.values.toList(),
        selectedMembers: selectedMembers,
        quantityList: _quantityList);
  }
}

class StatisticsTabCubit extends Cubit<StatisticsTabState> {
  StatisticsTabCubit()
      : super(StatisticsTabState(
            dateTimeRange: kMemberStatisticsDefaultDateRange,
            members: [],
            invitees: [],
            selectedMembers: [],
            statisticsObjects: []));

  final _statisticsService = StatisticsService();
  final _teamService = TeamService();
  final _eventService = EventService();

  initialEvent(bool isTeam, StatisticsFilter statisticsFilter) async {
    if (!isClosed) {
      //get members
      List<Member> _members = [];
      List<TeamInvitee>? _invitees;
      if (isTeam) {
        _members = await _teamService.getTeamMembers(statisticsFilter.teamId ?? '');
        _invitees = await _teamService.getTeamInvitees(statisticsFilter.teamId ?? '');
      } else {
        _members = await _eventService.getEventMembers(statisticsFilter.eventId ?? '');
      }
      emit(state.copyWith(members: _members, invitees: _invitees, selectedMembers: _members));

      //fetch event/team members statistics
      await getMemberStatistics(statisticsFilter);
    }
  }

  List<String> get memberIds {
    return state.selectedMembers.map((member) => member.userId).toList();
  }

  Future<void> getMemberStatistics(StatisticsFilter statisticsFilter) async {
    statisticsFilter.memberIds = memberIds;
    statisticsFilter.dateRangeStart = state.dateTimeRange.start;
    statisticsFilter.dateRangeEnd = state.dateTimeRange.end;

    var statisticsObjects = await _statisticsService.getStatistics(statisticsFilter);

    var _updatedStatisticsObjects =
        _statisticsService.mergeStatisticsObjectByOwner(statisticsObjects);

    if (!isClosed) {
      emit(state.copyWith(statisticsObjects: _updatedStatisticsObjects));
    }
  }

  Future<void> updateDateTimeRange(
      DateTimeRange dateTimeRange, StatisticsFilter statisticsFilter) async {
    if (!isClosed) {
      emit(state.copyWith(dateTimeRange: dateTimeRange));
    }

    statisticsFilter.memberIds = memberIds;
    statisticsFilter.dateRangeStart = dateTimeRange.start;
    statisticsFilter.dateRangeEnd = dateTimeRange.end;

    await getMemberStatistics(statisticsFilter);
  }

  Future<void> updateSelectedMembers(
      List<Member> selectedTeamMembers, StatisticsFilter statisticsFilter) async {
    if (!isClosed) {
      emit(state.copyWith(selectedMembers: selectedTeamMembers));
    }
    statisticsFilter.memberIds = memberIds;
    statisticsFilter.dateRangeStart = state.dateTimeRange.start;
    statisticsFilter.dateRangeEnd = state.dateTimeRange.end;
    await getMemberStatistics(statisticsFilter);
  }
}
