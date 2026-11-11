/// Categories used for sorting and displaying football group leaderboards.
enum StatisticsCategory {
  goals,
  assists,
  cleanSheets,
  motm;

  String get labelArabic => switch (this) {
    StatisticsCategory.goals => 'الهدافون',
    StatisticsCategory.assists => 'صناع اللعب',
    StatisticsCategory.cleanSheets => 'نظافة الشباك',
    StatisticsCategory.motm => 'رجل المباراة',
  };

  String get labelEnglish => switch (this) {
    StatisticsCategory.goals => 'Top Scorers',
    StatisticsCategory.assists => 'Top Assists',
    StatisticsCategory.cleanSheets => 'Clean Sheets',
    StatisticsCategory.motm => 'MOTM Awards',
  };

  String get metricUnitArabic => switch (this) {
    StatisticsCategory.goals => 'أهداف',
    StatisticsCategory.assists => 'تمريرات حاسمة',
    StatisticsCategory.cleanSheets => 'مباريات شباك نظيفة',
    StatisticsCategory.motm => 'جوائز MOTM',
  };
}
