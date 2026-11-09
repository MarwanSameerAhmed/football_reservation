/// Defines user permissions within the Kickoff application.
enum UserRole {
  player, // Regular group player (can RSVP, vote, view stats)
  admin; // Group manager (can manage ratings, generate teams, edit matches, manage polls & results)

  bool get isAdmin => this == UserRole.admin;
  bool get isPlayer => this == UserRole.player;

  String get labelArabic => this == UserRole.admin ? 'مسؤول المجموعة' : 'لاعب';
  String get labelEnglish => this == UserRole.admin ? 'Admin' : 'Player';
}
