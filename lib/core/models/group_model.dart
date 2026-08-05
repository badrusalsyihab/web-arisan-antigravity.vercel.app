import 'member_model.dart';
import 'kas_expense_model.dart';

class GroupModel {
  final String id;
  final String name;
  final double potAmount;
  final bool hasKas;
  final double kasAmount;
  final String periodType; // 'bulanan' | 'mingguan' | '2mingguan'
  final int activePeriodIndex;
  final List<MemberModel> members;
  final Map<int, String> winnerSchedule; // periodIndex -> memberName

  final String joinCode;
  final List<String> memberUserIds;
  final DateTime? startDate;
  final List<KasExpenseModel> kasExpenses;

  GroupModel({
    required this.id,
    required this.name,
    required this.potAmount,
    required this.hasKas,
    required this.kasAmount,
    required this.periodType,
    required this.activePeriodIndex,
    required this.members,
    required this.winnerSchedule,
    this.joinCode = '',
    this.memberUserIds = const [],
    this.startDate,
    this.kasExpenses = const [],
  });

  // Total period count dynamically equals total members count
  int get totalPeriods => members.isNotEmpty ? members.length : 1;

  // Group is completed when all periods have winners
  bool get isCompleted => winnerSchedule.length >= totalPeriods;

  // Check if a user is an Admin of this group
  bool isAdmin(String? userId) {
    if (userId == null || members.isEmpty) return false;
    // Format email to userId if it's an email format
    final formattedUserId = userId.replaceAll('.', '_').replaceAll('@', '_at_');
    try {
      final member = members.firstWhere((m) => m.userId == formattedUserId);
      return member.role == 'Admin';
    } catch (e) {
      return false;
    }
  }

  String getPeriodLabel(int index) {
    if (periodType == 'bulanan') {
      final start = startDate ?? DateTime(2026, 8, 1);
      final periodDate = DateTime(start.year, start.month + index - 1, 1);
      final monthNames = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final monthName = monthNames[periodDate.month - 1];
      return 'Bulan $index ($monthName ${periodDate.year})';
    } else if (periodType == 'mingguan') {
      return 'Minggu $index (Mg-$index)';
    } else {
      return 'Periode $index';
    }
  }
}
