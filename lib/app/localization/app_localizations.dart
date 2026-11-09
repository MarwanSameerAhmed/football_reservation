import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized localization for Kickoff.
/// Arabic is the primary language, English is supported as fallback.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ar'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];

  bool get isArabic => locale.languageCode == 'ar';

  // ── Localized Strings ─────────────────────────────────────────────────────

  // General & Navigation
  String get appName => isArabic ? 'Kickoff' : 'Kickoff';
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get matches => isArabic ? 'المباريات' : 'Matches';
  String get teamGenerator => isArabic ? 'توليد الفرق' : 'Team Generator';
  String get stats => isArabic ? 'الإحصائيات' : 'Statistics';
  String get profile => isArabic ? 'الملف الشخصي' : 'Profile';
  String get seeAll => isArabic ? 'عرض الكل' : 'See All';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get searchPlaceholder => isArabic
      ? 'ابحث عن لاعب، ملعب، أو مباراة...'
      : 'Search player, arena, or match...';

  // UI States
  String get loading => isArabic ? 'جاري التحميل...' : 'Loading...';
  String get emptyTitle =>
      isArabic ? 'لا توجد بيانات متاحة' : 'No Data Available';
  String get emptyDescription => isArabic
      ? 'لم يتم إضافة أي عناصر حتى الآن.'
      : 'No items have been added yet.';
  String get errorTitle =>
      isArabic ? 'حدث خطأ غير متوقع' : 'An Unexpected Error Occurred';
  String get errorDescription => isArabic
      ? 'يرجى التحقق من اتصال الإنترنت والمحاولة مجدداً.'
      : 'Please check your connection and try again.';
  String get offlineMessage =>
      isArabic ? 'أنت غير متصل بالإنترنت حالياً' : 'You are currently offline.';

  // Match & Booking Strings
  String get reserveYourCourt =>
      isArabic ? 'تفاصيل المباراة الأسبوعية' : 'Reserve Your Court';
  String get chooseSlot =>
      isArabic ? 'اختر الفترة أو التشكيلة' : 'Choose a Slot';
  String get chooseDate => isArabic ? 'اختر التاريخ' : 'Choose Date';
  String get chooseTime => isArabic ? 'اختر التوقيت' : 'Choose a time';
  String get noOfPlayers => isArabic ? 'عدد اللاعبين' : 'No. of Players';
  String get bookNow => isArabic ? 'تسجيل الحضور الآن' : 'Book now';
  String get confirmBooking =>
      isArabic ? 'تأكيد تسجيل الحضور' : 'Confirm Booking';
  String get spotsAvailable => isArabic ? 'أماكن شاغرة' : 'slots free';
  String get confirmedList =>
      isArabic ? 'التشكيلة الأساسية' : 'Confirmed Squad';
  String get waitingList => isArabic ? 'قائمة الانتظار' : 'Waiting List';
  String get fullSquad => isArabic ? 'اكتمل العدد' : 'Squad Full';

  // Player & Team Generator
  String get positionGK => isArabic ? 'حارس' : 'GK';
  String get positionDEF => isArabic ? 'دفاع' : 'DEF';
  String get positionMID => isArabic ? 'وسط' : 'MID';
  String get positionFWD => isArabic ? 'هجوم' : 'FWD';
  String get generateTeams =>
      isArabic ? 'توليد الفرق المتوازنة' : 'Generate Balanced Teams';
  String get teamA => isArabic ? 'الفريق (أ)' : 'Team A';
  String get teamB => isArabic ? 'الفريق (ب)' : 'Team B';
  String get skillRating => isArabic ? 'التقييم الفني' : 'Skill Rating';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
