import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/data/models/statistics%20model/statistics_filter.dart';
import 'package:lm_teams_app/data/models/statistics%20model/statistics_object.dart';
import 'package:lm_teams_app/services/response-handlers/response-handlers.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

class StatisticsService {
  final _socket = WebSocketService();

  Future<List<StatisticsObject>> getStatistics(StatisticsFilter filter) async {
    if (!_socket.isConnected) return [];
    var response = await HandleStatisticsObjects(
            await _socket.sendAndWait(Message('GetStatistics', data: filter)))
        .run();

    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  List<StatisticsObject> mergeStatisticsObjectsByDateRange(
      List<StatisticsObject> statisticObjects, StatisticsDateRangeContext dateRangeFilter) {
    List<StatisticsObject> _newStatisticsObjects = [];

    for (var obj in statisticObjects) {
      var index = objIndex(dateRangeFilter, _newStatisticsObjects, obj);

      if (index != -1) {
        var _updatedObject = mergeObjects(_newStatisticsObjects[index], obj);
        _newStatisticsObjects[index] = _updatedObject;
      } else {
        _newStatisticsObjects.add(obj);
      }
    }
    return _newStatisticsObjects;
  }

  List<StatisticsObject> mergeStatisticsObjectByOwner(List<StatisticsObject> statisticsObjects) {
    List<StatisticsObject> _newStatisticsObjects = [];
    for (var obj in statisticsObjects) {
      var index = _newStatisticsObjects.indexWhere((object) => object.ownerId == obj.ownerId);
      if (index != -1) {
        var _updatedObject = mergeObjects(_newStatisticsObjects[index], obj);
        _newStatisticsObjects[index] = _updatedObject;
      } else {
        _newStatisticsObjects.add(obj);
      }
    }
    return _newStatisticsObjects;
  }

  int objIndex(StatisticsDateRangeContext rangeFilter, List<StatisticsObject> newStatisticsObjects,
      StatisticsObject obj) {
    switch (rangeFilter) {
      case StatisticsDateRangeContext.week:
        return newStatisticsObjects
            .indexWhere((object) => object.date.weekNumber == obj.date.weekNumber);
      case StatisticsDateRangeContext.month:
        return newStatisticsObjects.indexWhere((object) => object.date.month == obj.date.month);
      case StatisticsDateRangeContext.year:
        return newStatisticsObjects.indexWhere((object) => object.date.year == obj.date.year);
      default:
        return -1;
    }
  }

  StatisticsObject mergeObjects(StatisticsObject existing, StatisticsObject toMerge) {
    return StatisticsObject(
        ownerId: existing.ownerId,
        date: existing.date,
        notes: existing.notes + toMerge.notes,
        card: existing.card + toMerge.card,
        coins: existing.coins + toMerge.coins,
        books: existing.books + toMerge.books,
        prayers: existing.prayers + toMerge.prayers,
        contacts: existing.contacts + toMerge.contacts);
  }

  bool hasPresentStatisticsObject(
      List<StatisticsObject> statisticsObjects, StatisticsDateRangeContext rangeFilter) {
    var now = DateTime.now();
    switch (rangeFilter) {
      case StatisticsDateRangeContext.day:
        return statisticsObjects.indexWhere((object) => object.date.day == now.day) != -1;
      case StatisticsDateRangeContext.month:
        return statisticsObjects.indexWhere((object) => object.date.month == now.month) != -1;
      case StatisticsDateRangeContext.week:
        return statisticsObjects.indexWhere((object) => object.date.weekNumber == now.weekNumber) !=
            -1;
      case StatisticsDateRangeContext.year:
        return statisticsObjects.indexWhere((object) => object.date.year == now.year) != -1;
      default:
        return false;
    }
  }
}
