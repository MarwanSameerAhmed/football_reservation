/// Current operational status of a scheduled football match.
enum MatchStatus {
  upcoming, // Open for registration
  full, // Confirmed squad is full, registration goes to waiting list
  inProgress, // Match is currently active on the pitch
  completed, // Match finished, scores and results recorded
  cancelled; // Match cancelled

  String get labelArabic => switch (this) {
    MatchStatus.upcoming => 'التسجيل متاح',
    MatchStatus.full => 'التشكيلة مكتملة (انتظار)',
    MatchStatus.inProgress => 'المباراة جارية',
    MatchStatus.completed => 'منتهية',
    MatchStatus.cancelled => 'ملغاة',
  };

  String get labelEnglish => switch (this) {
    MatchStatus.upcoming => 'Open',
    MatchStatus.full => 'Squad Full',
    MatchStatus.inProgress => 'In Progress',
    MatchStatus.completed => 'Completed',
    MatchStatus.cancelled => 'Cancelled',
  };
}
