import 'package:equatable/equatable.dart';

enum BibleStudyType { none, personal, diy, dvd }

enum StudyGuideType { none, amazing, search, other }

class BibleStudyData extends Equatable {
  const BibleStudyData({required this.studyType, required this.studyGuide});

  final BibleStudyType? studyType;
  final StudyGuideType? studyGuide;

  @override
  List<Object?> get props => [studyType, studyGuide];

  BibleStudyData.fromJson(Map<String, dynamic> json)
      : studyType = getBibleStudyType(json['studyType']),
        studyGuide = getStudyGuideType(json['studyGuide']);

  Map<String, dynamic> toJson() => {
        'studyType': studyType?.name,
        'studyGuide': studyGuide?.name,
      };
}

BibleStudyType? getBibleStudyType(dynamic jsonType) {
  if (jsonType != null) {
    return BibleStudyType.values.where((e) => e.name == jsonType).first;
  }
  return null;
}

StudyGuideType? getStudyGuideType(dynamic jsonType) {
  if (jsonType != null) {
    return StudyGuideType.values.where((e) => e.name == jsonType).first;
  }
  return null;
}

class VisitData extends Equatable {
  const VisitData({required this.wasHome});
  final bool wasHome;

  @override
  List<Object?> get props => [wasHome];

  VisitData.fromJson(Map<String, dynamic> json) : wasHome = json['wasHome'];

  Map<String, dynamic> toJson() => {'wasHome': wasHome};
}
