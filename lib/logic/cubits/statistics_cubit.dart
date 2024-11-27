import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/models/statistics%20model/statistics_object.dart';
import 'package:lm_teams_app/presentation/dialogs/interaction_dialog.dart';
import 'package:lm_teams_app/services/statistics_service.dart';
import '../../data/models/statistics model/statistics_filter.dart';

class StatisticsState extends Equatable {
  StatisticsState(
      {required this.dateRangeContext,
      required this.isPersonal,
      required this.statisticsObjects,
      required this.isLoading});
  final StatisticsDateRangeContext dateRangeContext;
  final List<bool> isPersonal;
  final List<StatisticsObject> statisticsObjects;
  final bool isLoading;

  final StatisticsService _statisticsService = StatisticsService();

  get dateRangeText {
    switch (dateRangeContext) {
      case StatisticsDateRangeContext.day:
        return 'Today';
      case StatisticsDateRangeContext.month:
        return 'This month';
      case StatisticsDateRangeContext.week:
        return 'This week';
      case StatisticsDateRangeContext.year:
        return 'This year';
    }
  }

  List<StatisticsObject> get objectList {
    try {
      if (!_statisticsService.hasPresentStatisticsObject(statisticsObjects, dateRangeContext) ||
          statisticsObjects.isEmpty) {
        return [StatisticsObject.presentObj];
      } else {
        statisticsObjects.sort((a, b) => b.date.compareTo(a.date));
        return statisticsObjects;
      }
    } catch (e) {
      return [StatisticsObject.presentObj];
    }
  }

  @override
  List<Object?> get props => [dateRangeContext, isPersonal, statisticsObjects, isLoading];

  StatisticsState copyWith(
      {StatisticsDateRangeContext? dateRangeContext,
      List<bool>? isPersonal,
      List<StatisticsObject>? statisticsObjects,
      bool? isLoading}) {
    return StatisticsState(
        dateRangeContext: dateRangeContext ?? this.dateRangeContext,
        isPersonal: isPersonal ?? this.isPersonal,
        statisticsObjects: statisticsObjects ?? this.statisticsObjects,
        isLoading: isLoading ?? this.isLoading);
  }

  Map<String, dynamic> toJson() => {
        'dateRangeContext': dateRangeContext.name,
        'isPersonal': isPersonal,
        'statisticsObjects': statisticsObjects,
        'isLoadingStatisticsPage': isLoading
      };

  StatisticsState.fromJson(Map<String, dynamic> json)
      : dateRangeContext = stringToEnum<StatisticsDateRangeContext>(
            StatisticsDateRangeContext.values, json['dateRangeContext']),
        isPersonal = json['isPersonal'],
        statisticsObjects = List.from(json['statisticsObjects'])
            .map((object) => StatisticsObject.fromJson(object))
            .toList(),
        isLoading = json['isLoadingStatisticsPage'];
}

class StatisticsCubit extends Cubit<StatisticsState> with HydratedMixin {
  StatisticsCubit()
      : super(StatisticsState(
            dateRangeContext: StatisticsDateRangeContext.week,
            isPersonal: const [true, false],
            statisticsObjects: const [],
            isLoading: false));

  final _statisticsService = StatisticsService();

  void changeDateRangeFilter(StatisticsDateRangeContext context) {
    emit(state.copyWith(dateRangeContext: context));
  }

  void changeIsPersonal(int index) {
    switch (index) {
      case 0:
        emit(state.copyWith(isPersonal: [true, false]));
        break;
      case 1:
        emit(state.copyWith(isPersonal: [false, true]));
        break;
    }
  }

  getStatisticsObjects(StatisticsFilter filter) async {
    emit(state.copyWith(isLoading: true));
    var statisticObjects = await _statisticsService.getStatistics(filter);
    if (state.dateRangeContext != StatisticsDateRangeContext.day) {
      var _updatedStatisticsObjects = _statisticsService.mergeStatisticsObjectsByDateRange(
          statisticObjects, state.dateRangeContext);
      emit(state.copyWith(statisticsObjects: _updatedStatisticsObjects));
    } else {
      emit(state.copyWith(statisticsObjects: statisticObjects));
    }
    emit(state.copyWith(isLoading: false));
  }

  @override
  StatisticsState? fromJson(Map<String, dynamic> json) {
    return StatisticsState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(StatisticsState state) {
    return state.toJson();
  }
}
