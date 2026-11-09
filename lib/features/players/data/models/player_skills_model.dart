import '../../domain/entities/player_skills.dart';

class PlayerSkillsModel extends PlayerSkills {
  const PlayerSkillsModel({
    required super.pace,
    required super.shooting,
    required super.passing,
    required super.defending,
    required super.physical,
    super.goalkeeping,
  });

  factory PlayerSkillsModel.fromJson(Map<String, dynamic> json) {
    return PlayerSkillsModel(
      pace: (json['pace'] as num?)?.toInt() ?? 70,
      shooting: (json['shooting'] as num?)?.toInt() ?? 65,
      passing: (json['passing'] as num?)?.toInt() ?? 70,
      defending: (json['defending'] as num?)?.toInt() ?? 65,
      physical: (json['physical'] as num?)?.toInt() ?? 70,
      goalkeeping: (json['goalkeeping'] as num?)?.toInt() ?? 50,
    );
  }

  factory PlayerSkillsModel.fromEntity(PlayerSkills skills) {
    return PlayerSkillsModel(
      pace: skills.pace,
      shooting: skills.shooting,
      passing: skills.passing,
      defending: skills.defending,
      physical: skills.physical,
      goalkeeping: skills.goalkeeping,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pace': pace,
      'shooting': shooting,
      'passing': passing,
      'defending': defending,
      'physical': physical,
      'goalkeeping': goalkeeping,
    };
  }
}
