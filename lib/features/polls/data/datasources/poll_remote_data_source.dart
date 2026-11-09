import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/poll_type.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../models/poll_model.dart';
import '../models/poll_option_model.dart';

abstract class PollRemoteDataSource {
  Future<List<PollModel>> getPolls({String? matchId, bool? activeOnly});

  Future<PollModel> getPollById(String pollId);

  Future<PollModel> createPoll(PollModel poll);

  Future<PollModel> vote({
    required String pollId,
    required String optionId,
    required String userId,
  });

  Future<PollModel> closePoll(String pollId);
}

class FirebasePollRemoteDataSource implements PollRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebasePollRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _pollsCollection =>
      _firestore.collection('polls');

  @override
  Future<List<PollModel>> getPolls({String? matchId, bool? activeOnly}) async {
    try {
      Query<Map<String, dynamic>> query = _pollsCollection.orderBy(
        'createdAt',
        descending: true,
      );

      if (matchId != null) {
        query = query.where('matchId', isEqualTo: matchId);
      }
      if (activeOnly == true) {
        query = query.where('isClosed', isEqualTo: false);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => PollModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PollModel> getPollById(String pollId) async {
    try {
      final doc = await _pollsCollection.doc(pollId).get();
      if (!doc.exists) {
        throw NotFoundException('الاستطلاع غير موجود');
      }
      return PollModel.fromFirestore(doc);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PollModel> createPoll(PollModel poll) async {
    try {
      final docRef = _pollsCollection.doc(poll.id.isEmpty ? null : poll.id);
      final modelToSave = PollModel(
        id: docRef.id,
        matchId: poll.matchId,
        title: poll.title,
        description: poll.description,
        type: poll.type,
        options: poll.options,
        creatorId: poll.creatorId,
        allowMultipleVotes: poll.allowMultipleVotes,
        closesAt: poll.closesAt,
        isClosed: poll.isClosed,
        createdAt: poll.createdAt,
      );
      await docRef.set(modelToSave.toJson());
      return modelToSave;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PollModel> vote({
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final docRef = _pollsCollection.doc(pollId);
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw NotFoundException('الاستطلاع غير موجود');
        }

        final poll = PollModel.fromFirestore(snapshot);
        if (!poll.isActive) {
          throw ValidationException('انتهت فترة التصويت لهذا الاستطلاع');
        }

        final updatedOptions = poll.options.map((option) {
          final voters = List<String>.from(option.voterUserIds);

          if (option.id == optionId) {
            if (!voters.contains(userId)) {
              voters.add(userId);
            }
          } else if (!poll.allowMultipleVotes) {
            // Remove from other options in single-vote polls
            voters.remove(userId);
          }

          return PollOptionModel(
            id: option.id,
            text: option.text,
            subtitle: option.subtitle,
            voterUserIds: voters,
            metadata: option.metadata,
          );
        }).toList();

        final updatedPoll = PollModel(
          id: poll.id,
          matchId: poll.matchId,
          title: poll.title,
          description: poll.description,
          type: poll.type,
          options: updatedOptions,
          creatorId: poll.creatorId,
          allowMultipleVotes: poll.allowMultipleVotes,
          closesAt: poll.closesAt,
          isClosed: poll.isClosed,
          createdAt: poll.createdAt,
        );

        transaction.set(docRef, updatedPoll.toJson());
        return updatedPoll;
      });
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PollModel> closePoll(String pollId) async {
    try {
      final docRef = _pollsCollection.doc(pollId);
      await docRef.update({'isClosed': true});
      final updated = await docRef.get();
      return PollModel.fromFirestore(updated);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

/// In-memory mock data source pre-seeded with real-world football polls.
class MockPollRemoteDataSource implements PollRemoteDataSource {
  final Map<String, PollModel> _polls = {};
  final Duration delay;

  MockPollRemoteDataSource({this.delay = Duration.zero}) {
    _seedInitialPolls();
  }

  void _seedInitialPolls() {
    // 1. Match Scheduling Poll
    final schedulingPoll = PollModel(
      id: 'poll_schedule_1',
      title: 'تصويت موعد ومكان كلاسيكو الجمعة القادم ⚽',
      description:
          'حدد الموعد والمكان الأنسب لمشاركتك لاعتماد حجز الصالة رسمياً.',
      type: PollType.matchScheduling,
      creatorId: 'admin_1',
      allowMultipleVotes: false,
      closesAt: DateTime.now().add(const Duration(days: 2)),
      isClosed: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      options: const [
        PollOptionModel(
          id: 'opt_1',
          text: 'الجمعة 08:00 مساءً - صالة النخبة المغطاة',
          subtitle: 'عشب صناعي متطور • مكيف بالكامل',
          voterUserIds: ['user_1', 'user_2', 'user_3', 'user_4', 'user_5'],
        ),
        PollOptionModel(
          id: 'opt_2',
          text: 'السبت 07:30 مساءً - صالة أرينا المغطاة',
          subtitle: 'ملعب سداسي فسيح • مواقف مجانية',
          voterUserIds: [
            'user_6',
            'user_7',
            'user_8',
            'user_9',
            'user_10',
            'user_11',
            'user_12',
            'user_13',
          ],
        ),
        PollOptionModel(
          id: 'opt_3',
          text: 'الخميس 09:00 مساءً - ملعب حديقة العشب الخارجي',
          subtitle: 'أجواء ليلية مفتوحة • كشافات قوية',
          voterUserIds: ['user_14', 'user_15'],
        ),
      ],
    );

    // 2. MOTM Poll
    final motmPoll = PollModel(
      id: 'poll_motm_1',
      matchId: 'match_1',
      title: 'تصويت رجل المباراة (MOTM) - الكلاسيكو الأخير ⭐',
      description: 'صوت لأفضل لاعب قدم أداءً حاسماً في مباراة الأسبوع.',
      type: PollType.manOfTheMatch,
      creatorId: 'admin_1',
      allowMultipleVotes: false,
      closesAt: DateTime.now().add(const Duration(hours: 24)),
      isClosed: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      options: const [
        PollOptionModel(
          id: 'opt_motm_1',
          text: 'كابتن سفيان',
          subtitle: 'مهاجم • هاتريك (3 أهداف) وصناعة هدف حاسم',
          voterUserIds: [
            'user_1',
            'user_2',
            'user_3',
            'user_4',
            'user_5',
            'user_6',
            'user_7',
          ],
        ),
        PollOptionModel(
          id: 'opt_motm_2',
          text: 'فهد الدوسري',
          subtitle: 'حارس مرمى • 6 تصديات إعجازية والتصدي لركلة جزاء',
          voterUserIds: [
            'user_8',
            'user_9',
            'user_10',
            'user_11',
            'user_12',
            'user_13',
            'user_14',
            'user_15',
            'admin_1',
          ],
        ),
        PollOptionModel(
          id: 'opt_motm_3',
          text: 'عمر الشهري',
          subtitle: 'قلب دفاع • افتكاك الكرة 8 مرات وتمريرات دقيقة 94%',
          voterUserIds: ['user_16', 'user_17', 'user_18'],
        ),
      ],
    );

    _polls[schedulingPoll.id] = schedulingPoll;
    _polls[motmPoll.id] = motmPoll;
  }

  @override
  Future<List<PollModel>> getPolls({String? matchId, bool? activeOnly}) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    var list = _polls.values.toList();
    if (matchId != null) {
      list = list.where((p) => p.matchId == matchId).toList();
    }
    if (activeOnly == true) {
      list = list.where((p) => p.isActive).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<PollModel> getPollById(String pollId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final poll = _polls[pollId];
    if (poll == null) throw NotFoundException('الاستطلاع غير موجود');
    return poll;
  }

  @override
  Future<PollModel> createPoll(PollModel poll) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final id = poll.id.isNotEmpty
        ? poll.id
        : 'poll_${DateTime.now().millisecondsSinceEpoch}';
    final saved = PollModel(
      id: id,
      matchId: poll.matchId,
      title: poll.title,
      description: poll.description,
      type: poll.type,
      options: poll.options,
      creatorId: poll.creatorId,
      allowMultipleVotes: poll.allowMultipleVotes,
      closesAt: poll.closesAt,
      isClosed: poll.isClosed,
      createdAt: poll.createdAt,
    );
    _polls[id] = saved;
    return saved;
  }

  @override
  Future<PollModel> vote({
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final poll = _polls[pollId];
    if (poll == null) throw NotFoundException('الاستطلاع غير موجود');

    if (!poll.isActive) {
      throw ValidationException('انتهت فترة التصويت لهذا الاستطلاع');
    }

    final updatedOptions = poll.options.map((option) {
      final voters = List<String>.from(option.voterUserIds);

      if (option.id == optionId) {
        if (!voters.contains(userId)) {
          voters.add(userId);
        }
      } else if (!poll.allowMultipleVotes) {
        // Single choice: remove user's vote from other options
        voters.remove(userId);
      }

      return PollOptionModel(
        id: option.id,
        text: option.text,
        subtitle: option.subtitle,
        voterUserIds: voters,
        metadata: option.metadata,
      );
    }).toList();

    final updated = PollModel(
      id: poll.id,
      matchId: poll.matchId,
      title: poll.title,
      description: poll.description,
      type: poll.type,
      options: updatedOptions,
      creatorId: poll.creatorId,
      allowMultipleVotes: poll.allowMultipleVotes,
      closesAt: poll.closesAt,
      isClosed: poll.isClosed,
      createdAt: poll.createdAt,
    );

    _polls[pollId] = updated;
    return updated;
  }

  @override
  Future<PollModel> closePoll(String pollId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final poll = _polls[pollId];
    if (poll == null) throw NotFoundException('الاستطلاع غير موجود');

    final updated = poll.copyWith(isClosed: true);
    final model = PollModel.fromEntity(updated);
    _polls[pollId] = model;
    return model;
  }
}
