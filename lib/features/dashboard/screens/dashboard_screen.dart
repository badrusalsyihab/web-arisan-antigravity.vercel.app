import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/imgbb_service.dart';
import '../../../core/models/group_model.dart';
import '../../../core/models/member_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../group/widgets/winner_order_modal.dart';
import 'package:app_arisan_antigravity/features/group/screens/gallery_detail_screen.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/firebase_service.dart';
import '../widgets/kas_expenses_modal.dart';
import 'package:app_arisan_antigravity/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  final GroupModel group;
  final UserModel currentUser;
  final Function(GroupModel) onGroupUpdated;
  final Function(int) onNavigateToTab;

  const DashboardScreen({
    super.key,
    required this.group,
    required this.currentUser,
    required this.onGroupUpdated,
    required this.onNavigateToTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int selectedPeriodIndex;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    selectedPeriodIndex = widget.group.activePeriodIndex;
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.id != widget.group.id) {
      setState(() {
        selectedPeriodIndex = widget.group.activePeriodIndex;
      });
    }
  }

  void _togglePaymentStatus(MemberModel member) {
    if (!widget.group.isAdmin(widget.currentUser.email)) return;

    final currentStatus =
        member.paymentStatuses[selectedPeriodIndex] ?? 'BELUM LUNAS';
    final newStatus = currentStatus == 'LUNAS' ? 'BELUM LUNAS' : 'LUNAS';

    final updatedMembers = widget.group.members.map((m) {
      if (m.id == member.id) {
        final newStatuses = Map<int, String>.from(m.paymentStatuses);
        newStatuses[selectedPeriodIndex] = newStatus;
        return m.copyWith(paymentStatuses: newStatuses);
      }
      return m;
    }).toList();

    final updatedGroup = widget.group.copyWith(
      members: updatedMembers,
    );

    widget.onGroupUpdated(updatedGroup);
  }

  void _toggleKasPaymentStatus(MemberModel member) {
    if (!widget.group.isAdmin(widget.currentUser.email)) return;

    final currentStatus =
        member.kasPaymentStatuses[selectedPeriodIndex] ?? 'BELUM LUNAS';
    final newStatus = currentStatus == 'LUNAS' ? 'BELUM LUNAS' : 'LUNAS';

    final updatedMembers = widget.group.members.map((m) {
      if (m.id == member.id) {
        final newKasStatuses = Map<int, String>.from(m.kasPaymentStatuses);
        newKasStatuses[selectedPeriodIndex] = newStatus;
        return m.copyWith(kasPaymentStatuses: newKasStatuses);
      }
      return m;
    }).toList();

    final updatedGroup = widget.group.copyWith(
      members: updatedMembers,
    );

    widget.onGroupUpdated(updatedGroup);
  }

  Future<bool?> _confirmDelete(MemberModel member) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.dashConfirmDeleteTitle),
        content: Text(
          AppLocalizations.of(context)!.dashConfirmDeleteBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.dashBtnCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.dashBtnDelete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _performDelete(MemberModel member) {
    final updatedMembers = widget.group.members
        .where((m) => m.id != member.id)
        .toList();
    final updatedUserIds = widget.group.memberUserIds
        .where((id) => id != member.userId)
        .toList();

    final updatedGroup = widget.group.copyWith(
      members: updatedMembers,
      memberUserIds: updatedUserIds,
    );

    widget.onGroupUpdated(updatedGroup);

    /* ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anggota ${member.name} berhasil dihapus!'),
        backgroundColor: AppTheme.accent,
      ),
    ); */
  }

  void _startNewCycle() {
    // Generate new members with reset statuses
    final newMembers = widget.group.members.map((m) {
      final initialPaymentStatuses = {
        for (int i = 1; i <= widget.group.members.length; i++) i: 'BELUM LUNAS',
      };
      final initialKasPaymentStatuses = {
        for (int i = 1; i <= widget.group.members.length; i++) i: 'BELUM LUNAS',
      };

      return MemberModel(
        id: m.id,
        name: m.name,
        waNumber: m.waNumber,
        role: m.role,
        isWinner: false,
        winPeriodLabel: 'Belum Menang',
        paymentStatuses: initialPaymentStatuses,
        kasPaymentStatuses: initialKasPaymentStatuses,
        userId: m.userId,
      );
    }).toList();

    final newGroup = GroupModel(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      name: '${widget.group.name} (Siklus Baru)',
      potAmount: widget.group.potAmount,
      hasKas: widget.group.hasKas,
      kasAmount: widget.group.kasAmount,
      periodType: widget.group.periodType,
      activePeriodIndex: 1,
      members: newMembers,
      winnerSchedule: {},
      startDate: DateTime.now(),
      joinCode: widget
          .group
          .joinCode, // Keep the same join code so members stay connected
      memberUserIds: widget.group.memberUserIds,
    );

    widget.onGroupUpdated(newGroup);
    /* ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berhasil memulai siklus arisan baru!'),
        backgroundColor: AppTheme.primary,
      ),
    ); */
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Validasi tipe file (sederhana)
        final ext = image.name.split('.').last.toLowerCase();
        final validExts = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
        if (!validExts.contains(ext)) {
          return;
        }

        final bytes = await image.readAsBytes();

        // Validasi ukuran maksimal 15MB
        final sizeInBytes = bytes.lengthInBytes;
        final sizeInMB = sizeInBytes / (1024 * 1024);
        if (sizeInMB > 15) {
          return;
        }

        if (mounted) {
          setState(() {
            _isUploadingImage = true;
          });
        }

        final imgbbService = ImgbbService();
        final result = await imgbbService.uploadImage(
          photoTitle: image.name,
          emoji: '🖼️',
          bytes: bytes.toList(),
          uploadedBy: widget.currentUser.email,
        );

        if (result != null) {
          await FirebaseService().addGalleryPhoto(widget.group.id, result);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maaf gagal upload gambar, silahkan coba lagi'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maaf gagal upload gambar, silahkan coba lagi'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _showImageDetailModal(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: item.containsKey('url')
                      ? Image.network(
                          item['url']!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 200,
                          color: const Color(0xFFF8FAFC),
                          child: Center(
                            child: Text(
                              item['emoji']!,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['date']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          if (item.containsKey('uploadedBy')) ...[
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.person,
                              size: 14,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['uploadedBy']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Tutup'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textMain,
                                side: const BorderSide(
                                  color: AppTheme.cardBorder,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (item.containsKey('url')) {
                                  Share.share(
                                    'Lihat dokumentasi Arisan: ${item['title']} - ${item['url']}',
                                  );
                                } else {
                                  /* ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Hanya foto asli yang dapat dibagikan.')),
                                  ); */
                                }
                              },
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Bagikan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddMemberDialog() {
    final nameCtrl = TextEditingController();
    final waCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '➕ Tambah Anggota Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Anggota',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: waCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor WhatsApp (Opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 4),
                const Text(
                  'Buat Akun Login (Opsional)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              else ...[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final email = emailCtrl.text.trim();
                    final pass = passCtrl.text.trim();
                    if (name.isEmpty) return;

                    setStateDialog(() => isLoading = true);

                    String? authUserId;
                    String newMemberId =
                        'm_${DateTime.now().millisecondsSinceEpoch}';

                    // Try to create Firebase Auth user if email & password are provided
                    if (email.isNotEmpty && pass.isNotEmpty) {
                      try {
                        // Create a secondary app to not sign out current admin
                        FirebaseApp tempApp = await Firebase.initializeApp(
                          name:
                              'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
                          options: Firebase.app().options,
                        );
                        UserCredential userCredential =
                            await FirebaseAuth.instanceFor(
                              app: tempApp,
                            ).createUserWithEmailAndPassword(
                              email: email,
                              password: pass,
                            );
                        authUserId = userCredential.user!.uid;
                        newMemberId = authUserId; // Use UID as member ID

                        // Create user document
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(authUserId)
                            .set({
                              'name': name,
                              'email': email,
                              'role': 'Member',
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                        await tempApp.delete();
                      } catch (e) {
                        setStateDialog(() => isLoading = false);
                        if (context.mounted) {
                          /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat akun: $e'), backgroundColor: AppTheme.warning)); */
                        }
                        return; // Stop if failed to create user
                      }
                    }

                    final newMember = MemberModel(
                      id: newMemberId,
                      name: name,
                      waNumber: waCtrl.text.trim().isNotEmpty
                          ? waCtrl.text.trim()
                          : '0812-0000-0000',
                      role: 'Member',
                      isWinner: false,
                      winPeriodLabel: 'Belum Menang',
                      userId: authUserId,
                      paymentStatuses: {
                        for (
                          int i = 1;
                          i <= (widget.group.members.length + 1);
                          i++
                        )
                          i: 'BELUM LUNAS',
                      },
                    );

                    final updatedMembers = List<MemberModel>.from(
                      widget.group.members,
                    )..add(newMember);
                    final updatedGroup = widget.group.copyWith(
                      members: updatedMembers,
                    );

                    await widget.onGroupUpdated(updatedGroup);
                    if (context.mounted) {
                      Navigator.pop(context);
                      /* ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Anggota $name berhasil ditambahkan!'),
                        backgroundColor: AppTheme.accent,
                      ),
                    ); */
                    }
                  },
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final periodLabel = group.getPeriodLabel(selectedPeriodIndex);

    final paidCount = group.members
        .where((m) => m.paymentStatuses[selectedPeriodIndex] == 'LUNAS')
        .length;
    final kasPaidCount = group.members
        .where((m) => m.kasPaymentStatuses[selectedPeriodIndex] == 'LUNAS')
        .length;
    final totalCount = group.members.length;

    // Normalize user email to match how it's stored in userId/memberUserIds
    final isAdmin = group.isAdmin(widget.currentUser.email);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Header Banner (Deep Dark Teal with Gradient Accent & Banner Badge)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background Decorative Circle Banner Graphic
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            color: AppTheme.limeAccent,
                            size: 18,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.limeAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$paidCount/$totalCount ${AppLocalizations.of(context)!.dashTotalPaid}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (group.joinCode.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.tag,
                                  color: AppTheme.limeAccent,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  group.joinCode,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.limeAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        GestureDetector(
                          onTap: () {
                            final inviteUrl = group.joinCode.isNotEmpty
                                ? 'https://web-arisan-antigravity.vercel.app/?joinCode=${group.joinCode}'
                                : 'https://web-arisan-antigravity.vercel.app/';
                            Share.share(
                              'Ayo bergabung dengan grup arisan "${group.name}"! Klik link ini untuk masuk:\n$inviteUrl\n\nAtau gunakan kode: ${group.joinCode.isNotEmpty ? group.joinCode : "-"}',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.share_rounded,
                              size: 14,
                              color: AppTheme.limeAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context)!.dashPotWinner}: ${CurrencyFormatter.formatRupiah(group.potAmount)} / ${group.periodType == 'bulanan' ? AppLocalizations.of(context)!.dashPerMonth : AppLocalizations.of(context)!.dashPerWeek}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stat Cards (Pastel Lavender & Warm Cream like image)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.pastelPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.dashTotalCollected,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatRupiah(
                          paidCount * group.potAmount,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (group.hasKas) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: FirebaseService().streamExpenses(group.id),
                    builder: (context, snapshot) {
                      final expenses = snapshot.data ?? [];
                      final totalExpenses = expenses.fold(
                        0.0,
                        (sum, exp) => sum + (exp['amount'] ?? 0),
                      );

                      // Calculate overall Kas for the modal (Saldo Kas Keseluruhan)
                      int totalKasLunas = 0;
                      for (var m in group.members) {
                        for (var status in m.kasPaymentStatuses.values) {
                          if (status == 'LUNAS') totalKasLunas++;
                        }
                      }
                      final trueTotalKasIn =
                          totalKasLunas * group.kasAmount.toDouble();

                      // Calculate Kas collected for THIS period to show on the card
                      final kasCollectedPeriod =
                          kasPaidCount * group.kasAmount.toDouble();

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.pastelCream,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.savings_outlined,
                                    color: AppTheme.warning,
                                    size: 20,
                                  ),
                                ),
                                // Arrow icon removed
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.dashKasCollected,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.formatRupiah(
                                kasCollectedPeriod,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textMain,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons Grid
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.textMain,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.cardBorder),
                    ),
                  ),
                  onPressed: () {
                    final textToShare = group.joinCode.isNotEmpty
                        ? 'Ayo gabung kelompok arisan ${group.name} di Aplikasi Arisan Digital!\n\nKode Kelompok: *${group.joinCode}*\n\nBuka via Web:\nhttps://web-arisan-antigravity.vercel.app/?joinCode=${group.joinCode}'
                        : 'Ayo gabung kelompok arisan ${group.name} di Aplikasi Arisan Digital!\n\nBuka via Web:\nhttps://web-arisan-antigravity.vercel.app/';
                    SharePlus.instance.share(ShareParams(text: textToShare));
                  },
                  icon: const Icon(
                    Icons.chat,
                    color: Color(0xFF25D366),
                    size: 18,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.dashBtnInviteWA,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Completed Banner and New Cycle Button
          if (group.isCompleted) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF15803D),
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.dashArisanCompleted,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isAdmin ? _startNewCycle : null,
                    icon: const Icon(
                      Icons.restart_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.dashBtnNewCycle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Join Code Section
          if (group.joinCode.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.pastelPurple.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dashJoinCodeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        group.joinCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: group.joinCode));
                      /* ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode kelompok disalin!'), backgroundColor: AppTheme.primary),
                      ); */
                    },
                    icon: const Icon(Icons.copy, color: AppTheme.primary),
                    tooltip: 'Salin Kode',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Admin Winner Schedule Button
          if (isAdmin) ...[
            Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textMain,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onPressed: group.isCompleted
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) => WinnerOrderModal(
                            group: group,
                            onSave: (newSchedule) {
                              final updatedGroup = group.copyWith(
                                winnerSchedule: newSchedule,
                              );
                              widget.onGroupUpdated(updatedGroup);
                            },
                          ),
                        );
                      },
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
                label: Text(
                  AppLocalizations.of(context)!.dashBtnSetWinnerOrder,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Member List Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dashboardPaymentStatus,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          periodLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Period Selector Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(group.totalPeriods, (index) {
                      final periodIndex = index + 1;
                      final isSelected = selectedPeriodIndex == periodIndex;
                      final periodTabTitle = group.periodType == 'bulanan'
                          ? '${AppLocalizations.of(context)!.dashMonth} $periodIndex'
                          : '${AppLocalizations.of(context)!.dashWeek} $periodIndex';

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          checkmarkColor: Colors.white,
                          label: Text(
                            periodIndex == group.activePeriodIndex
                                ? '$periodTabTitle ${AppLocalizations.of(context)!.dashActive}'
                                : periodTabTitle,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textMuted,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.primary,
                          backgroundColor: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedPeriodIndex = periodIndex;
                              });
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 14),

                // Member List
                ...group.members.map((member) {
                  final payStatus =
                      member.paymentStatuses[selectedPeriodIndex] ??
                      'BELUM LUNAS';
                  final isPaid = payStatus == 'LUNAS';

                  final kasPayStatus =
                      member.kasPaymentStatuses[selectedPeriodIndex] ??
                      'BELUM LUNAS';
                  final isKasPaid = kasPayStatus == 'LUNAS';

                  final winnerForPeriod =
                      group.winnerSchedule[selectedPeriodIndex];
                  final isWinner = (winnerForPeriod == member.name);
                  final canDelete =
                      isAdmin &&
                      member.role != 'Admin' &&
                      !group.isCompleted &&
                      !member.isWinner;

                  Widget memberRow = Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isWinner
                          ? AppTheme.pastelPurple.withValues(alpha: 0.6)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isWinner
                            ? AppTheme.secondary.withValues(alpha: 0.3)
                            : AppTheme.cardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isWinner
                                  ? AppTheme.secondary
                                  : AppTheme.primary,
                              child: Text(
                                member.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  isWinner ? AppLocalizations.of(context)!.dashWinnerLabel : member.role,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isWinner
                                        ? AppTheme.secondary
                                        : AppTheme.textMuted,
                                    fontWeight: isWinner
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Two Payment Status Flags (Arisan & Kas)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Flag 1: Iuran Arisan
                            InkWell(
                              onTap: (group.isCompleted || !isAdmin)
                                  ? null
                                  : () => _togglePaymentStatus(member),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isPaid
                                        ? const Color(0xFF86EFAC)
                                        : const Color(0xFFFCA5A5),
                                  ),
                                ),
                                child: Text(
                                  isPaid
                                      ? '🟢 Arisan: ${AppLocalizations.of(context)!.paid}'
                                      : '🔴 Arisan: ${AppLocalizations.of(context)!.unpaid}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isPaid
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ),

                            if (group.hasKas) ...[
                              const SizedBox(height: 6),
                              // Flag 2: Iuran Kas
                              InkWell(
                                onTap: (group.isCompleted || !isAdmin)
                                    ? null
                                    : () => _toggleKasPaymentStatus(member),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isKasPaid
                                        ? const Color(0xFFE0F2FE)
                                        : const Color(0xFFFFEDD5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isKasPaid
                                          ? const Color(0xFF7DD3FC)
                                          : const Color(0xFFFDBA74),
                                    ),
                                  ),
                                  child: Text(
                                    isKasPaid
                                        ? '🟢 Kas: ${AppLocalizations.of(context)!.paid}'
                                        : '🟠 Kas: ${AppLocalizations.of(context)!.unpaid}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isKasPaid
                                          ? const Color(0xFF0369A1)
                                          : const Color(0xFFC2410C),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );

                  if (canDelete) {
                    return Dismissible(
                      key: Key(member.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) => _confirmDelete(member),
                      onDismissed: (direction) => _performDelete(member),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.warning,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: memberRow,
                    );
                  }

                  return memberRow;
                }),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 📸 GALERI & DOKUMENTASI KEGIATAN (PHOTO GRID SECTION)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2x2 Photo Grid with Title
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirebaseService().streamGallery(widget.group.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final items = snapshot.data ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.dashGalleryTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textMain,
                              ),
                            ),
                            if (items.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GalleryDetailScreen(
                                        group: widget.group,
                                        currentUser: widget.currentUser,
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.dashBtnGalleryDetail,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (_isUploadingImage) ...[
                          const SizedBox(height: 14),
                          const LinearProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        ],
                        const SizedBox(height: 14),
                        if (items.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.photo_library_outlined,
                                  size: 48,
                                  color: Colors.black26,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppLocalizations.of(context)!.dashGalleryEmpty,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.25,
                                ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return GestureDetector(
                                onTap: () => _showImageDetailModal(
                                  item.cast<String, String>(),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: AppTheme.cardBorder,
                                    ),
                                    image:
                                        item.containsKey('url') &&
                                            item['url'].toString().isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(item['url']),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (item.containsKey('url') &&
                                          item['url'].toString().isNotEmpty)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              gradient: const LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black87,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (!item.containsKey('url') ||
                                                item['url']
                                                    .toString()
                                                    .isEmpty) ...[
                                              Center(
                                                child: Text(
                                                  item['emoji'] ?? '📸',
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                            ],
                                            Text(
                                              item['title'] ?? '',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    item.containsKey('url') &&
                                                        item['url']
                                                            .toString()
                                                            .isNotEmpty
                                                    ? Colors.white
                                                    : AppTheme.textMain,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item['date'] ?? '',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color:
                                                    item.containsKey('url') &&
                                                        item['url']
                                                            .toString()
                                                            .isNotEmpty
                                                    ? Colors.white70
                                                    : AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                            ),
                            onPressed: _pickImage,
                            icon: const Icon(
                              Icons.add_a_photo_outlined,
                              size: 16,
                              color: AppTheme.limeAccent,
                            ),
                            label: Text(
                              AppLocalizations.of(context)!.dashBtnUploadPhoto,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
