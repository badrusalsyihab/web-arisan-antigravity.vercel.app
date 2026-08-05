import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  FirebaseFirestore? get _db {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Save User Profile to Cloud Firestore
  Future<void> saveUserProfile(UserModel user) async {
    try {
      final db = _db;
      if (db == null) return;

      final docId = user.email.isNotEmpty
          ? user.email.replaceAll('.', '_').replaceAll('@', '_at_')
          : 'user_${DateTime.now().millisecondsSinceEpoch}';

      await db.collection('users').doc(docId).set({
        'name': user.name,
        'email': user.email,
        'photoUrl': user.photoUrl ?? '',
        'phone': user.phone ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint("✅ Firestore User Profile $docId saved successfully!");
    } catch (e) {
      debugPrint("❌ Firestore User Profile save error: $e");
    }
  }

  // Stream Group Data in Real-time from Cloud Firestore
  Stream<GroupModel?> streamGroup(String groupId) {
    final db = _db;
    if (db == null) return const Stream.empty();

    return db.collection('groups').doc(groupId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      final data = snapshot.data()!;
      
      // Parse members sub-collection or array
      List<MemberModel> membersList = [];
      if (data['members'] != null && data['members'] is List) {
        membersList = (data['members'] as List).map((m) {
          final map = Map<String, dynamic>.from(m as Map);
          final rawStatuses = map['paymentStatuses'] as Map<String, dynamic>? ?? {};
          final Map<int, String> parsedStatuses = {};
          rawStatuses.forEach((key, val) {
            parsedStatuses[int.tryParse(key.toString()) ?? 1] = val.toString();
          });

          final rawKasStatuses = map['kasPaymentStatuses'] as Map<String, dynamic>? ?? {};
          final Map<int, String> parsedKasStatuses = {};
          rawKasStatuses.forEach((key, val) {
            parsedKasStatuses[int.tryParse(key.toString()) ?? 1] = val.toString();
          });

          return MemberModel(
            id: map['id'] ?? '',
            name: map['name'] ?? '',
            waNumber: map['waNumber'] ?? '',
            role: map['role'] ?? 'Member',
            isWinner: map['isWinner'] ?? false,
            winPeriodLabel: map['winPeriodLabel'] ?? '',
            paymentStatuses: parsedStatuses,
            kasPaymentStatuses: parsedKasStatuses,
            userId: map['userId'],
          );
        }).toList();
      }

      // Parse winner schedule
      final Map<int, String> parsedWinners = {};
      if (data['winnerSchedule'] != null && data['winnerSchedule'] is Map) {
        (data['winnerSchedule'] as Map).forEach((k, v) {
          parsedWinners[int.tryParse(k.toString()) ?? 1] = v.toString();
        });
      }

      return GroupModel(
        id: snapshot.id,
        name: data['name'] ?? '',
        potAmount: (data['potAmount'] ?? 1000000).toDouble(),
        hasKas: data['hasKas'] ?? true,
        kasAmount: (data['kasAmount'] ?? 20000).toDouble(),
        periodType: data['periodType'] ?? 'bulanan',
        activePeriodIndex: data['activePeriodIndex'] ?? 3,
        winnerSchedule: parsedWinners,
        members: membersList,
        joinCode: data['joinCode'] ?? '',
        memberUserIds: List<String>.from(data['memberUserIds'] ?? []),
        startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : null,
      );
    });
  }

  // Get Group Model by ID once
  Future<GroupModel?> getGroup(String groupId) async {
    try {
      final db = _db;
      if (db == null) return null;

      final doc = await db.collection('groups').doc(groupId).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      List<MemberModel> membersList = [];
      if (data['members'] != null && data['members'] is List) {
        membersList = (data['members'] as List).map((m) {
          final map = Map<String, dynamic>.from(m as Map);
          final rawStatuses = map['paymentStatuses'] as Map<String, dynamic>? ?? {};
          final Map<int, String> parsedStatuses = {};
          rawStatuses.forEach((key, val) {
            parsedStatuses[int.tryParse(key.toString()) ?? 1] = val.toString();
          });

          final rawKasStatuses = map['kasPaymentStatuses'] as Map<String, dynamic>? ?? {};
          final Map<int, String> parsedKasStatuses = {};
          rawKasStatuses.forEach((key, val) {
            parsedKasStatuses[int.tryParse(key.toString()) ?? 1] = val.toString();
          });

          return MemberModel(
            id: map['id'] ?? '',
            name: map['name'] ?? '',
            waNumber: map['waNumber'] ?? '',
            role: map['role'] ?? 'Member',
            isWinner: map['isWinner'] ?? false,
            winPeriodLabel: map['winPeriodLabel'] ?? '',
            paymentStatuses: parsedStatuses,
            kasPaymentStatuses: parsedKasStatuses,
            userId: map['userId'],
          );
        }).toList();
      }

      final Map<int, String> parsedWinners = {};
      if (data['winnerSchedule'] != null && data['winnerSchedule'] is Map) {
        (data['winnerSchedule'] as Map).forEach((k, v) {
          parsedWinners[int.tryParse(k.toString()) ?? 1] = v.toString();
        });
      }

      return GroupModel(
        id: doc.id,
        name: data['name'] ?? '',
        potAmount: (data['potAmount'] ?? 500000).toDouble(),
        hasKas: data['hasKas'] ?? true,
        kasAmount: (data['kasAmount'] ?? 20000).toDouble(),
        periodType: data['periodType'] ?? 'bulanan',
        activePeriodIndex: data['activePeriodIndex'] ?? 1,
        winnerSchedule: parsedWinners,
        members: membersList,
        joinCode: data['joinCode'] ?? '',
        memberUserIds: List<String>.from(data['memberUserIds'] ?? []),
        startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : null,
      );
    } catch (e) {
      debugPrint("getGroup error: $e");
      return null;
    }
  }

  // Fetch Latest Group created by user or available in Firestore
  Future<GroupModel?> fetchLatestGroup(String userId) async {
    try {
      final db = _db;
      if (db == null) return null;

      final snap = await db.collection('groups').where('memberUserIds', arrayContains: userId).get();
      if (snap.docs.isEmpty) return null;

      final docs = snap.docs.toList();
      docs.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>?;
        final dataB = b.data() as Map<String, dynamic>?;
        final dateA = dataA != null && dataA['startDate'] != null ? (dataA['startDate'] as dynamic).toDate() : DateTime.now();
        final dateB = dataB != null && dataB['startDate'] != null ? (dataB['startDate'] as dynamic).toDate() : DateTime.now();
        return dateB.compareTo(dateA);
      });

      return getGroup(docs.first.id);
    } catch (e) {
      return null;
    }
  }

  // Save / Sync Group Model to Cloud Firestore
  Future<void> syncGroup(GroupModel group) async {
    try {
      final db = _db;
      if (db == null) return;

      final membersData = group.members.map((m) {
        final Map<String, String> statusesStr = {};
        m.paymentStatuses.forEach((periodIndex, status) {
          statusesStr[periodIndex.toString()] = status;
        });

        final Map<String, String> kasStatusesStr = {};
        m.kasPaymentStatuses.forEach((periodIndex, status) {
          kasStatusesStr[periodIndex.toString()] = status;
        });

        return {
          'id': m.id,
          'name': m.name,
          'waNumber': m.waNumber,
          'role': m.role,
          'isWinner': m.isWinner,
          'winPeriodLabel': m.winPeriodLabel,
          'paymentStatuses': statusesStr,
          'kasPaymentStatuses': kasStatusesStr,
          if (m.userId != null) 'userId': m.userId,
        };
      }).toList();

      final Map<String, String> winnersStr = {};
      group.winnerSchedule.forEach((p, w) {
        winnersStr[p.toString()] = w;
      });

      await db.collection('groups').doc(group.id).set({
        'name': group.name,
        'potAmount': group.potAmount,
        'hasKas': group.hasKas,
        'kasAmount': group.kasAmount,
        'periodType': group.periodType,
        'activePeriodIndex': group.activePeriodIndex,
        'winnerSchedule': winnersStr,
        'members': membersData,
        'joinCode': group.joinCode,
        'memberUserIds': group.memberUserIds,
        if (group.startDate != null) 'startDate': Timestamp.fromDate(group.startDate!),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint("✅ Firestore Group synced successfully!");
    } catch (e) {
      debugPrint("❌ Firestore Group sync error: $e");
    }
  }

  // Add Kas Expense to Firestore Sub-collection
  Future<void> addKasExpense(String groupId, Map<String, dynamic> expense) async {
    try {
      final db = _db;
      if (db == null) return;

      await db.collection('groups').doc(groupId).collection('expenses').add({
        'title': expense['title'],
        'amount': expense['amount'],
        'date': expense['date'],
        'period': expense['period'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently handle
    }
  }

  // Stream Kas Expenses List
  Stream<List<Map<String, dynamic>>> streamExpenses(String groupId) {
    final db = _db;
    if (db == null) return const Stream.empty();

    return db
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // Add Photo Item to Firestore Sub-collection
  Future<void> addGalleryPhoto(String groupId, Map<String, String> photoItem) async {
    try {
      final db = _db;
      if (db == null) return;

      await db.collection('groups').doc(groupId).collection('gallery').add({
        'title': photoItem['title'],
        'emoji': photoItem['emoji'] ?? '📸',
        'driveUrl': photoItem['driveUrl'] ?? '',
        'url': photoItem['url'] ?? '',
        'uploadedBy': photoItem['uploadedBy'] ?? '',
        'date': photoItem['date'] ?? 'Hari Ini',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently handle
    }
  }

  // Stream Gallery Photos List (Max 4 for Dashboard)
  Stream<List<Map<String, dynamic>>> streamGallery(String groupId) {
    final db = _db;
    if (db == null) return const Stream.empty();

    return db
        .collection('groups')
        .doc(groupId)
        .collection('gallery')
        .orderBy('createdAt', descending: true)
        .limit(4)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // Get Gallery Photos Paginated
  Future<Map<String, dynamic>> getGalleryPaginated(String groupId, {DocumentSnapshot? lastDocument, int limit = 10}) async {
    try {
      final db = _db;
      if (db == null) return {'items': [], 'lastDoc': null};

      var query = db
          .collection('groups')
          .doc(groupId)
          .collection('gallery')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final items = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id, 'doc': doc}).toList();
      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return {'items': items, 'lastDoc': lastDoc};
    } catch (e) {
      return {'items': [], 'lastDoc': null};
    }
  }
  // Stream User's Groups
  Stream<List<GroupModel>> streamUserGroups(String userId) {
    final db = _db;
    if (db == null) return const Stream.empty();

    return db.collection('groups').where('memberUserIds', arrayContains: userId).snapshots().map((snap) {
      final groups = snap.docs.map((doc) {
        final data = doc.data();
        List<MemberModel> membersList = [];
        if (data['members'] != null && data['members'] is List) {
          membersList = (data['members'] as List).map((m) {
            final map = Map<String, dynamic>.from(m as Map);
            final rawStatuses = map['paymentStatuses'] as Map<String, dynamic>? ?? {};
            final Map<int, String> parsedStatuses = {};
            rawStatuses.forEach((key, val) {
              parsedStatuses[int.tryParse(key.toString()) ?? 1] = val.toString();
            });

            final rawKasStatuses = map['kasPaymentStatuses'] as Map<String, dynamic>? ?? {};
            final Map<int, String> parsedKasStatuses = {};
            rawKasStatuses.forEach((key, val) {
              parsedKasStatuses[int.tryParse(key.toString()) ?? 1] = val.toString();
            });

            return MemberModel(
              id: map['id'] ?? '',
              name: map['name'] ?? '',
              waNumber: map['waNumber'] ?? '',
              role: map['role'] ?? 'Member',
              isWinner: map['isWinner'] ?? false,
              winPeriodLabel: map['winPeriodLabel'] ?? '',
              paymentStatuses: parsedStatuses,
              kasPaymentStatuses: parsedKasStatuses,
              userId: map['userId'],
            );
          }).toList();
        }

        final Map<int, String> parsedWinners = {};
        if (data['winnerSchedule'] != null && data['winnerSchedule'] is Map) {
          (data['winnerSchedule'] as Map).forEach((k, v) {
            parsedWinners[int.tryParse(k.toString()) ?? 1] = v.toString();
          });
        }

          return GroupModel(
            id: doc.id,
            name: data['name'] ?? '',
            potAmount: (data['potAmount'] ?? 500000).toDouble(),
            hasKas: data['hasKas'] ?? true,
            kasAmount: (data['kasAmount'] ?? 20000).toDouble(),
            periodType: data['periodType'] ?? 'bulanan',
            activePeriodIndex: data['activePeriodIndex'] ?? 1,
            winnerSchedule: parsedWinners,
            members: membersList,
            joinCode: data['joinCode'] ?? '',
            memberUserIds: List<String>.from(data['memberUserIds'] ?? []),
            startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : null,
          );
      }).toList();
      groups.sort((a, b) => (b.startDate ?? DateTime.now()).compareTo(a.startDate ?? DateTime.now()));
      return groups;
    });
  }

  // Get Group by Join Code
  Future<GroupModel?> getGroupByJoinCode(String joinCode) async {
    try {
      final db = _db;
      if (db == null) return null;

      final snap = await db.collection('groups').where('joinCode', isEqualTo: joinCode.toUpperCase()).limit(1).get();
      if (snap.docs.isEmpty) return null;

      return getGroup(snap.docs.first.id);
    } catch (e) {
      debugPrint("getGroupByJoinCode error: $e");
      return null;
    }
  }

  // Join Group: Map a user account to a specific member
  Future<bool> joinGroup(String groupId, String memberId, String userId) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) return false;

      final updatedMembers = group.members.map((m) {
        if (m.id == memberId) {
          return m.copyWith(userId: userId);
        }
        return m;
      }).toList();

      final updatedMemberUserIds = List<String>.from(group.memberUserIds);
      if (!updatedMemberUserIds.contains(userId)) {
        updatedMemberUserIds.add(userId);
      }

      final updatedGroup = group.copyWith(
        members: updatedMembers,
        memberUserIds: updatedMemberUserIds,
      );

      await syncGroup(updatedGroup);
      return true;
    } catch (e) {
      debugPrint("joinGroup error: $e");
      return false;
    }
  }

  // Join Group as a completely new member
  Future<bool> joinGroupAsNewMember(String groupId, String userId, String userName) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) return false;

      // Check if already a member
      if (group.memberUserIds.contains(userId)) return true;

      final newMember = MemberModel(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        name: userName,
        waNumber: '0812-0000-0000',
        role: 'Member',
        isWinner: false,
        winPeriodLabel: 'Belum Menang',
        userId: userId,
        paymentStatuses: {
          for (int i = 1; i <= (group.members.length + 1); i++) i: 'BELUM LUNAS'
        },
        kasPaymentStatuses: {
          for (int i = 1; i <= (group.members.length + 1); i++) i: 'BELUM LUNAS'
        },
      );

      final updatedMembers = List<MemberModel>.from(group.members)..add(newMember);
      final updatedMemberUserIds = List<String>.from(group.memberUserIds)..add(userId);

      final updatedGroup = group.copyWith(
        members: updatedMembers,
        memberUserIds: updatedMemberUserIds,
      );

      await syncGroup(updatedGroup);
      return true;
    } catch (e) {
      debugPrint("joinGroupAsNewMember error: $e");
      return false;
    }
  }

  // Delete Group
  Future<bool> deleteGroup(String groupId) async {
    try {
      final db = _db;
      if (db == null) return false;

      await db.collection('groups').doc(groupId).delete();
      debugPrint("✅ Firestore Group $groupId deleted successfully!");
      return true;
    } catch (e) {
      debugPrint("❌ Firestore Group delete error: $e");
      return false;
    }
  }
}
