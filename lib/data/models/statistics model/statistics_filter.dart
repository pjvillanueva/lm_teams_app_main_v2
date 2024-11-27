class StatisticsFilter {
  StatisticsFilter({
    this.teamId,
    this.eventId,
    this.userId,
    this.accountId,
    this.memberIds,
    this.getChildTeams,
    this.dateRangeStart,
    this.dateRangeEnd,
  });

  String? teamId;
  String? eventId;
  String? userId;
  String? accountId;
  List<String>? memberIds;
  bool? getChildTeams;
  DateTime? dateRangeStart;
  DateTime? dateRangeEnd;

  Map<String, dynamic> toJson() => {
        'teamId': teamId,
        'eventId': eventId,
        'userId': userId,
        'accountId': accountId,
        'memberIds': memberIds,
        'getChildTeams': getChildTeams,
        'dateRangeStart': dateRangeStart?.toIso8601String(),
        'dateRangeEnd': dateRangeEnd?.toIso8601String(),
      };

  @override
  String toString() =>
      'StatisticsFilter: teamId: $teamId, eventId: $eventId, userId: $userId, accountId: $accountId, memberIds: $memberIds, getChildTeams: $getChildTeams, dateRangeStart: $dateRangeStart, dateRangeEnd: $dateRangeEnd';
}
