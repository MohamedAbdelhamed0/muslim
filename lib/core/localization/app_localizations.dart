import 'package:flutter/material.dart';
import 'l10n_ar.dart';
import 'l10n_en.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late final Map<String, String> _localizedStrings =
      locale.languageCode == 'ar' ? arTranslations : enTranslations;

  String translate(String key, {Map<String, String>? args}) {
    String text = _localizedStrings[key] ?? key;
    if (args != null) {
      args.forEach((argKey, value) {
        text = text.replaceAll('{$argKey}', value);
      });
    }
    return text;
  }

  String get appTitle => translate('appTitle');
  String get fajr => translate('fajr');
  String get sunrise => translate('sunrise');
  String get dhuhr => translate('dhuhr');
  String get asr => translate('asr');
  String get maghrib => translate('maghrib');
  String get isha => translate('isha');
  String get nextPrayer => translate('nextPrayer');
  String get timeRemaining => translate('timeRemaining');
  String get todayTimings => translate('todayTimings');
  String get refresh => translate('refresh');
  String get retry => translate('retry');
  String get cairoEgypt => translate('cairoEgypt');
  String get desktopDashboard => translate('desktopDashboard');
  String get errorLoading => translate('errorLoading');
  String get settings => translate('settings');
  String get azkar => translate('azkar');
  String get azkarReminder => translate('azkarReminder');
  String get addZikr => translate('addZikr');
  String get editZikr => translate('editZikr');
  String get zikrText => translate('zikrText');
  String get targetCount => translate('targetCount');
  String get intervalMinutes => translate('intervalMinutes');
  String get minutes => translate('minutes');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get tapToCount => translate('tapToCount');
  String get completedToday => translate('completedToday');
  String get totalTapsToday => translate('totalTapsToday');
  String get tapsToday => translate('tapsToday');
  String get testZikrAlert => translate('testZikrAlert');
  String get wellDone => translate('wellDone');
  String get dailyGoal => translate('dailyGoal');
  String get edit => translate('edit');
  String get analytics => translate('analytics');
  String get day => translate('day');
  String get week => translate('week');
  String get month => translate('month');
  String get year => translate('year');
  String get totalTapsAllTime => translate('totalTapsAllTime');
  String get totalSessions => translate('totalSessions');
  String get activeStreak => translate('activeStreak');
  String get days => translate('days');
  String get mostRecited => translate('mostRecited');
  String get tasbeehProgress => translate('tasbeehProgress');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
