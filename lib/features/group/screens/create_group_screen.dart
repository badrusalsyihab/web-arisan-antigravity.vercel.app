import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/group_model.dart';
import '../../../core/models/member_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:app_arisan_antigravity/l10n/app_localizations.dart';

import 'dart:math';

class CreateGroupScreen extends StatefulWidget {
  final UserModel currentUser;
  final Function(GroupModel) onGroupCreated;

  const CreateGroupScreen({
    super.key,
    required this.currentUser,
    required this.onGroupCreated,
  });

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _potController = TextEditingController(text: '500.000');
  final _kasController = TextEditingController(text: '20.000');
  bool _hasKas = true;
  String _periodType = 'bulanan';

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      6,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _potController.dispose();
    _kasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createGroupTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.createGroupAdminNotice,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.createGroupNameLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.createGroupNameHint,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(AppLocalizations.of(context)!.createGroupPotLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _potController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RupiahInputFormatter()],
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      hintText: '500.000',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(AppLocalizations.of(context)!.createGroupPeriodLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _periodType,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                    ),
                    items: [
                      DropdownMenuItem(value: 'bulanan', child: Text(AppLocalizations.of(context)!.createGroupPeriodMonthly)),
                      DropdownMenuItem(value: 'mingguan', child: Text(AppLocalizations.of(context)!.createGroupPeriodWeekly)),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _periodType = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Toggle Kas
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppLocalizations.of(context)!.createGroupKasActive, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(AppLocalizations.of(context)!.createGroupKasDesc, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    value: _hasKas,
                    activeThumbColor: AppTheme.accent,
                    onChanged: (val) => setState(() => _hasKas = val),
                  ),

                  if (_hasKas) ...[
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.createGroupKasAmountLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _kasController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [RupiahInputFormatter()],
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '20.000',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      final groupName = _nameController.text.trim();
                      if (groupName.isEmpty) {
                        /* ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nama kelompok arisan wajib diisi')),
                        ); */
                        return;
                      }

                      final potCleaned = _potController.text.replaceAll('.', '').replaceAll('Rp', '').trim();
                      final kasCleaned = _kasController.text.replaceAll('.', '').replaceAll('Rp', '').trim();

                      final String newJoinCode = _generateJoinCode();
                      final userId = widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_'); // Assuming same as FirebaseService user id

                      final newGroup = GroupModel(
                        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
                        name: groupName,
                        potAmount: double.tryParse(potCleaned) ?? 500000,
                        hasKas: _hasKas,
                        kasAmount: double.tryParse(kasCleaned) ?? 20000,
                        periodType: _periodType,
                        activePeriodIndex: 1,
                        joinCode: newJoinCode,
                        startDate: DateTime.now(),
                        memberUserIds: [userId],
                        members: [
                          MemberModel(
                            id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                            name: widget.currentUser.name,
                            waNumber: widget.currentUser.phone ?? widget.currentUser.email,
                            role: AppLocalizations.of(context)!.createGroupRoleAdmin,
                            isWinner: false,
                            winPeriodLabel: AppLocalizations.of(context)!.createGroupWinnerPending,
                            paymentStatuses: {1: 'BELUM LUNAS'},
                            userId: userId,
                          ),
                        ],
                        winnerSchedule: {},
                      );
                      widget.onGroupCreated(newGroup);
                      Navigator.pop(context);
                    },
                    child: Text('💾 ${AppLocalizations.of(context)!.createGroupBtnSave}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
