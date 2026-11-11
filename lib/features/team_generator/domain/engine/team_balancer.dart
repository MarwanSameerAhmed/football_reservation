import 'dart:math';
import '../../../../core/enums/player_position.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../entities/generated_team_entity.dart';
import '../entities/team_lineup_entity.dart';

/// Intelligent, deterministic football team balancing algorithm.
///
/// Supports 2-team matches (e.g. 14 players, 7v7) and 3-team tournaments
/// (e.g. 18 players, 3 teams of 6 with rotating goalkeeping).
class TeamBalancer {
  TeamBalancer._();

  /// Thoughtfully selects the team captain based on objective leadership metrics:
  /// - Matches played (seniority, loyalty, commitment): 2.5 pts per match
  /// - Man of the Match awards (peer respect & performance): 6.0 pts per MOTM
  /// - Technical skill rating: 0.15 pts per overall score
  /// - Goal and assist contributions: 1.0 pt per assist + 0.5 pt per goal
  static String? selectCaptain(List<PlayerEntity> roster) {
    if (roster.isEmpty) return null;

    PlayerEntity? bestCandidate;
    double highestScore = -1.0;

    for (final player in roster) {
      final leadershipScore =
          (player.matchesPlayed * 2.5) +
          (player.motmCount * 6.0) +
          (player.skills.overallScore * 0.15) +
          (player.assists * 1.0) +
          (player.goals * 0.5);

      if (leadershipScore > highestScore) {
        highestScore = leadershipScore;
        bestCandidate = player;
      } else if (leadershipScore == highestScore && bestCandidate != null) {
        // Deterministic tie-breaker: matches played > overall score > earlier creation
        if (player.matchesPlayed > bestCandidate.matchesPlayed) {
          bestCandidate = player;
        } else if (player.skills.overallScore >
            bestCandidate.skills.overallScore) {
          bestCandidate = player;
        } else if (player.createdAt.isBefore(bestCandidate.createdAt)) {
          bestCandidate = player;
        }
      }
    }

    return bestCandidate?.id;
  }

  /// Generates a randomized rotation order for goalkeeping across all team players.
  /// In friendly amateur football, all players take turns guarding the net ("الكل راح يحرس").
  static List<String> generateGoalkeeperRotation(
    List<PlayerEntity> roster, [
    Random? random,
  ]) {
    if (roster.isEmpty) return const [];
    final rng = random ?? Random();
    final shuffled = List<PlayerEntity>.from(roster)..shuffle(rng);
    return shuffled.map((p) => p.id).toList();
  }

  static TeamLineupEntity balance({
    required List<PlayerEntity> players,
    required String matchId,
    int? numberOfTeams,
    Random? random,
  }) {
    if (players.length < 2) {
      throw ArgumentError(
        'يجب أن تحتوي قائمة اللاعبين على لاعبين على الأقل لتوليد الفرق',
      );
    }

    final int numTeams = numberOfTeams ?? (players.length >= 15 ? 3 : 2);
    final targetSize = (players.length / numTeams).ceil();

    final teamPlayers = List.generate(numTeams, (_) => <PlayerEntity>[]);

    int score(int t) =>
        teamPlayers[t].fold(0, (sum, p) => sum + p.skills.overallScore);

    int currentSpread() {
      final scores = List.generate(numTeams, (i) => score(i));
      return scores.reduce(max) - scores.reduce(min);
    }

    void assignPlayer(PlayerEntity player) {
      // Find team with room that has the minimum current score
      int bestTeam = -1;
      int minScore = 999999;
      int minLength = 999999;

      for (int t = 0; t < numTeams; t++) {
        if (teamPlayers[t].length < targetSize) {
          final s = score(t);
          final l = teamPlayers[t].length;
          if (s < minScore || (s == minScore && l < minLength)) {
            minScore = s;
            minLength = l;
            bestTeam = t;
          }
        }
      }

      if (bestTeam != -1) {
        teamPlayers[bestTeam].add(player);
      } else {
        // Fallback to least loaded team
        int leastLoaded = 0;
        for (int t = 1; t < numTeams; t++) {
          if (teamPlayers[t].length < teamPlayers[leastLoaded].length) {
            leastLoaded = t;
          }
        }
        teamPlayers[leastLoaded].add(player);
      }
    }

    // Partition players by tactical positions
    final gks =
        players
            .where((p) => p.primaryPosition == PlayerPosition.goalkeeper)
            .toList()
          ..sort(
            (a, b) => b.skills.overallScore.compareTo(a.skills.overallScore),
          );

    final defs =
        players
            .where((p) => p.primaryPosition == PlayerPosition.defender)
            .toList()
          ..sort(
            (a, b) => b.skills.overallScore.compareTo(a.skills.overallScore),
          );

    final mids =
        players
            .where((p) => p.primaryPosition == PlayerPosition.midfielder)
            .toList()
          ..sort(
            (a, b) => b.skills.overallScore.compareTo(a.skills.overallScore),
          );

    final fwds =
        players
            .where((p) => p.primaryPosition == PlayerPosition.forward)
            .toList()
          ..sort(
            (a, b) => b.skills.overallScore.compareTo(a.skills.overallScore),
          );

    if (numTeams == 2) {
      // For standard 2 teams, anchor goalkeepers first if available
      for (int i = 0; i < gks.length; i++) {
        if (i % 2 == 0) {
          score(0) <= score(1)
              ? teamPlayers[0].add(gks[i])
              : teamPlayers[1].add(gks[i]);
        } else {
          if (teamPlayers[0].length < teamPlayers[1].length) {
            teamPlayers[0].add(gks[i]);
          } else if (teamPlayers[1].length < teamPlayers[0].length) {
            teamPlayers[1].add(gks[i]);
          } else {
            score(0) <= score(1)
                ? teamPlayers[0].add(gks[i])
                : teamPlayers[1].add(gks[i]);
          }
        }
      }
      for (final p in defs) {
        assignPlayer(p);
      }
      for (final p in mids) {
        assignPlayer(p);
      }
      for (final p in fwds) {
        assignPlayer(p);
      }
    } else {
      // For 3 teams: Rotating goalkeepers ("الفريق كامل يحرس")
      // Distribute by tactical lines so each team has balanced positions
      for (final p in defs) {
        assignPlayer(p);
      }
      for (final p in mids) {
        assignPlayer(p);
      }
      for (final p in fwds) {
        assignPlayer(p);
      }
      for (final p in gks) {
        assignPlayer(p);
      }
    }

    // Local Optimization Pass (Greedy Swaps across team pairs)
    bool improved = true;
    int maxIterations = 20;
    while (improved && maxIterations-- > 0) {
      improved = false;
      final currentDiff = currentSpread();
      if (currentDiff == 0) break;

      for (int tA = 0; tA < numTeams; tA++) {
        for (int tB = tA + 1; tB < numTeams; tB++) {
          for (int i = 0; i < teamPlayers[tA].length; i++) {
            for (int j = 0; j < teamPlayers[tB].length; j++) {
              final pA = teamPlayers[tA][i];
              final pB = teamPlayers[tB][j];

              // Swap players of the same tactical position to maintain balance
              if (pA.primaryPosition == pB.primaryPosition) {
                final oldScoreA = score(tA);
                final oldScoreB = score(tB);
                final newScoreA =
                    oldScoreA - pA.skills.overallScore + pB.skills.overallScore;
                final newScoreB =
                    oldScoreB - pB.skills.overallScore + pA.skills.overallScore;

                final hypScores = List<int>.generate(numTeams, (idx) {
                  if (idx == tA) return newScoreA;
                  if (idx == tB) return newScoreB;
                  return score(idx);
                });
                final newDiff = hypScores.reduce(max) - hypScores.reduce(min);

                if (newDiff < currentDiff) {
                  teamPlayers[tA][i] = pB;
                  teamPlayers[tB][j] = pA;
                  improved = true;
                  break;
                }
              }
            }
            if (improved) break;
          }
          if (improved) break;
        }
        if (improved) break;
      }
    }

    // Build GeneratedTeamEntity instances with thoughtful captain & randomized GK rotation
    final List<GeneratedTeamEntity> generatedTeams = [];
    if (numTeams == 3) {
      final teamDefs = [
        ('team_1', 'الفريق الأول (الأخضر)', 'الأخضر العشبي'),
        ('team_2', 'الفريق الثاني (الأبيض)', 'الأبيض الناصع'),
        ('team_3', 'الفريق الثالث (الأسود)', 'الأسود الداكن'),
      ];
      for (int i = 0; i < 3; i++) {
        final def = teamDefs[i];
        final squad = teamPlayers[i];
        generatedTeams.add(
          GeneratedTeamEntity(
            id: def.$1,
            name: def.$2,
            bibColor: def.$3,
            players: squad,
            captainPlayerId: selectCaptain(squad),
            goalkeeperRotation: generateGoalkeeperRotation(squad, random),
          ),
        );
      }
    } else {
      final teamDefs = [
        ('team_a', 'الفريق (أ)', 'الأخضر العشبي'),
        ('team_b', 'الفريق (ب)', 'الفحم الداكن'),
      ];
      for (int i = 0; i < 2; i++) {
        final def = teamDefs[i];
        final squad = teamPlayers[i];
        generatedTeams.add(
          GeneratedTeamEntity(
            id: def.$1,
            name: def.$2,
            bibColor: def.$3,
            players: squad,
            captainPlayerId: selectCaptain(squad),
            goalkeeperRotation: generateGoalkeeperRotation(squad, random),
          ),
        );
      }
    }

    return TeamLineupEntity(
      id: 'lineup_${DateTime.now().millisecondsSinceEpoch}',
      matchId: matchId,
      teams: generatedTeams,
      generatedAt: DateTime.now(),
      isFinalized: false,
    );
  }

  /// Manually swap two players between any teams (Admin customization).
  /// Preserves the goalkeeper rotation slot seamlessly and recalculates team captains.
  static TeamLineupEntity swap({
    required TeamLineupEntity lineup,
    required String playerAId,
    required String playerBId,
  }) {
    final updatedTeams = lineup.teams
        .map((t) => List<PlayerEntity>.from(t.players))
        .toList();

    int teamIndexA = -1;
    int playerIndexA = -1;
    int teamIndexB = -1;
    int playerIndexB = -1;

    for (int t = 0; t < updatedTeams.length; t++) {
      final pIndex = updatedTeams[t].indexWhere((p) => p.id == playerAId);
      if (pIndex != -1) {
        teamIndexA = t;
        playerIndexA = pIndex;
        break;
      }
    }

    for (int t = 0; t < updatedTeams.length; t++) {
      final pIndex = updatedTeams[t].indexWhere((p) => p.id == playerBId);
      if (pIndex != -1) {
        teamIndexB = t;
        playerIndexB = pIndex;
        break;
      }
    }

    if (teamIndexA != -1 && teamIndexB != -1 && teamIndexA != teamIndexB) {
      final pA = updatedTeams[teamIndexA][playerIndexA];
      final pB = updatedTeams[teamIndexB][playerIndexB];
      updatedTeams[teamIndexA][playerIndexA] = pB;
      updatedTeams[teamIndexB][playerIndexB] = pA;

      final newGeneratedTeams = <GeneratedTeamEntity>[];
      for (int i = 0; i < lineup.teams.length; i++) {
        final currentTeam = lineup.teams[i];
        final currentRoster = updatedTeams[i];

        if (i == teamIndexA) {
          final newRotation = List<String>.from(currentTeam.goalkeeperRotation);
          final rotIdx = newRotation.indexOf(playerAId);
          if (rotIdx != -1) {
            newRotation[rotIdx] = playerBId;
          } else {
            newRotation.add(playerBId);
          }
          newGeneratedTeams.add(
            currentTeam.copyWith(
              players: currentRoster,
              captainPlayerId: selectCaptain(currentRoster),
              goalkeeperRotation: newRotation,
            ),
          );
        } else if (i == teamIndexB) {
          final newRotation = List<String>.from(currentTeam.goalkeeperRotation);
          final rotIdx = newRotation.indexOf(playerBId);
          if (rotIdx != -1) {
            newRotation[rotIdx] = playerAId;
          } else {
            newRotation.add(playerAId);
          }
          newGeneratedTeams.add(
            currentTeam.copyWith(
              players: currentRoster,
              captainPlayerId: selectCaptain(currentRoster),
              goalkeeperRotation: newRotation,
            ),
          );
        } else {
          newGeneratedTeams.add(currentTeam);
        }
      }

      return lineup.copyWith(teams: newGeneratedTeams);
    }

    return lineup;
  }
}
