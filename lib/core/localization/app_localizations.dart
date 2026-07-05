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
