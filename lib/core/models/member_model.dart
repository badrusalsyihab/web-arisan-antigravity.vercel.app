class MemberModel {
  final String id;
  final String name;
  final String waNumber;
  final String role; // 'Admin' or 'Member'
  final bool isWinner;
  final String winPeriodLabel;
  final Map<int, String> paymentStatuses; // periodIndex -> 'LUNAS' | 'BELUM LUNAS'
  final Map<int, String> kasPaymentStatuses; // periodIndex -> 'LUNAS' | 'BELUM LUNAS'
  final String? userId; // ID of the registered user if claimed

  MemberModel({
    required this.id,
    required this.name,
    required this.waNumber,
    required this.role,
    this.isWinner = false,
    this.winPeriodLabel = '',
    required this.paymentStatuses,
    Map<int, String>? kasPaymentStatuses,
    this.userId,
  }) : kasPaymentStatuses = kasPaymentStatuses ?? {};

  MemberModel copyWith({
    String? id,
    String? name,
    String? waNumber,
    String? role,
    bool? isWinner,
    String? winPeriodLabel,
    Map<int, String>? paymentStatuses,
    Map<int, String>? kasPaymentStatuses,
    String? userId,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      waNumber: waNumber ?? this.waNumber,
      role: role ?? this.role,
      isWinner: isWinner ?? this.isWinner,
      winPeriodLabel: winPeriodLabel ?? this.winPeriodLabel,
      paymentStatuses: paymentStatuses ?? Map.from(this.paymentStatuses),
      kasPaymentStatuses: kasPaymentStatuses ?? Map.from(this.kasPaymentStatuses),
      userId: userId ?? this.userId,
    );
  }
}
