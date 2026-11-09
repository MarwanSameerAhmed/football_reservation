/// Player preferred kicking foot.
enum PreferredFoot {
  right,
  left,
  both;

  String get labelArabic => switch (this) {
    PreferredFoot.right => 'اليمنى',
    PreferredFoot.left => 'اليسرى',
    PreferredFoot.both => 'كلتا القدمين',
  };

  String get labelEnglish => switch (this) {
    PreferredFoot.right => 'Right',
    PreferredFoot.left => 'Left',
    PreferredFoot.both => 'Both',
  };
}
