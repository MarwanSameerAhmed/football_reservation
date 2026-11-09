/// Football tactical playing positions.
enum PlayerPosition {
  goalkeeper, // GK
  defender, // DEF
  midfielder, // MID
  forward; // FWD

  String get acronym => switch (this) {
    PlayerPosition.goalkeeper => 'GK',
    PlayerPosition.defender => 'DEF',
    PlayerPosition.midfielder => 'MID',
    PlayerPosition.forward => 'FWD',
  };

  String get labelArabic => switch (this) {
    PlayerPosition.goalkeeper => 'حارس مرمى',
    PlayerPosition.defender => 'مدافع',
    PlayerPosition.midfielder => 'لاعب وسط',
    PlayerPosition.forward => 'مهاجم',
  };

  String get labelEnglish => switch (this) {
    PlayerPosition.goalkeeper => 'Goalkeeper',
    PlayerPosition.defender => 'Defender',
    PlayerPosition.midfielder => 'Midfielder',
    PlayerPosition.forward => 'Forward',
  };
}
