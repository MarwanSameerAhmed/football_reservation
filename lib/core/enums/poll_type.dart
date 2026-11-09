/// Types of polls supported in Kickoff football group management.
enum PollType {
  matchScheduling,
  manOfTheMatch,
  general;

  String get labelArabic => switch (this) {
    PollType.matchScheduling => 'موعد ومكان المباراة',
    PollType.manOfTheMatch => 'رجل المباراة (MOTM)',
    PollType.general => 'استطلاع عام',
  };

  String get labelEnglish => switch (this) {
    PollType.matchScheduling => 'Match Scheduling',
    PollType.manOfTheMatch => 'Man of the Match',
    PollType.general => 'General Poll',
  };
}
