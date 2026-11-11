import 'package:equatable/equatable.dart';

/// Technical attributes representing a player's football abilities.
class PlayerSkills extends Equatable {
  final int pace; // السرعة والتحرك
  final int shooting; // دقة وقوة التسديد
  final int passing; // دقة التمرير وصناعة اللعب
  final int defending; // التمركز الدفاعي وافتكاك الكرة
  final int physical; // القوة البدنية واللياقة
  final int goalkeeping; // مهارات حراسة المرمى والتصديات

  const PlayerSkills({
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.defending,
    required this.physical,
    this.goalkeeping = 50,
  });

  /// Standard default baseline skills for a new player.
  const PlayerSkills.baseline()
    : pace = 70,
      shooting = 65,
      passing = 70,
      defending = 65,
      physical = 70,
      goalkeeping = 50;

  /// Overall score on a scale from 1 to 100.
  int get overallScore {
    final sum = pace + shooting + passing + defending + physical;
    return (sum / 5).round().clamp(1, 100);
  }

  /// Alias for overall score matching EA Sports / FUT ratings.
  int get overallRating => overallScore;

  /// Star rating on a scale from 1.0 to 5.0 stars (e.g. 4.2 / 5.0).
  double get starsRating {
    final stars = overallScore / 20.0;
    return (stars * 10).round() / 10;
  }

  PlayerSkills copyWith({
    int? pace,
    int? shooting,
    int? passing,
    int? defending,
    int? physical,
    int? goalkeeping,
  }) {
    return PlayerSkills(
      pace: pace ?? this.pace,
      shooting: shooting ?? this.shooting,
      passing: passing ?? this.passing,
      defending: defending ?? this.defending,
      physical: physical ?? this.physical,
      goalkeeping: goalkeeping ?? this.goalkeeping,
    );
  }

  @override
  List<Object?> get props => [
    pace,
    shooting,
    passing,
    defending,
    physical,
    goalkeeping,
  ];
}
