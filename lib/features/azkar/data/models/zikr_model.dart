import 'package:intl/intl.dart';
import '../../domain/entities/zikr_entity.dart';

class ZikrModel {
  final String id;
  final String textAr;
  final String textEn;
  final int defaultTargetCount;
  final String category;
  final bool isCustom;
  final int todayTapCount;
  final String lastTapDate;

  ZikrModel({
    required this.id,
    required this.textAr,
    this.textEn = '',
    this.defaultTargetCount = 3,
    this.category = 'General',
    this.isCustom = false,
    this.todayTapCount = 0,
    this.lastTapDate = '',
  });

  factory ZikrModel.fromJson(Map<String, dynamic> json) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedDate = json['lastTapDate'] as String? ?? '';
    final count = (savedDate == todayStr) ? (json['todayTapCount'] as int? ?? 0) : 0;

    return ZikrModel(
      id: json['id'] as String,
      textAr: json['textAr'] as String,
      textEn: json['textEn'] as String? ?? '',
      defaultTargetCount: json['defaultTargetCount'] as int? ?? 3,
      category: json['category'] as String? ?? 'General',
      isCustom: json['isCustom'] as bool? ?? false,
      todayTapCount: count,
      lastTapDate: savedDate == todayStr ? savedDate : todayStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'textAr': textAr,
      'textEn': textEn,
      'defaultTargetCount': defaultTargetCount,
      'category': category,
      'isCustom': isCustom,
      'todayTapCount': todayTapCount,
      'lastTapDate': lastTapDate,
    };
  }

  ZikrEntity toEntity() {
    return ZikrEntity(
      id: id,
      textAr: textAr,
      textEn: textEn,
      defaultTargetCount: defaultTargetCount,
      category: category,
      isCustom: isCustom,
      todayTapCount: todayTapCount,
    );
  }

  factory ZikrModel.fromEntity(ZikrEntity entity) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return ZikrModel(
      id: entity.id,
      textAr: entity.textAr,
      textEn: entity.textEn,
      defaultTargetCount: entity.defaultTargetCount,
      category: entity.category,
      isCustom: entity.isCustom,
      todayTapCount: entity.todayTapCount,
      lastTapDate: todayStr,
    );
  }
}
