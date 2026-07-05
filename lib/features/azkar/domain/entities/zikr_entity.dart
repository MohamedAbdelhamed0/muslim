import 'package:flutter/foundation.dart';

@immutable
class ZikrEntity {
  final String id;
  final String textAr;
  final String textEn;
  final int defaultTargetCount;
  final String category;
  final bool isCustom;
  final int todayTapCount;

  const ZikrEntity({
    required this.id,
    required this.textAr,
    this.textEn = '',
    this.defaultTargetCount = 3,
    this.category = 'General',
    this.isCustom = false,
    this.todayTapCount = 0,
  });

  ZikrEntity copyWith({
    String? id,
    String? textAr,
    String? textEn,
    int? defaultTargetCount,
    String? category,
    bool? isCustom,
    int? todayTapCount,
  }) {
    return ZikrEntity(
      id: id ?? this.id,
      textAr: textAr ?? this.textAr,
      textEn: textEn ?? this.textEn,
      defaultTargetCount: defaultTargetCount ?? this.defaultTargetCount,
      category: category ?? this.category,
      isCustom: isCustom ?? this.isCustom,
      todayTapCount: todayTapCount ?? this.todayTapCount,
    );
  }
}
