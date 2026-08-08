import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/group_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:app_arisan_antigravity/l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  final GroupModel group;

  const HistoryScreen({super.key, required this.group});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  void _showAddExpenseModal() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.histAddExpenseTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Keterangan Pengeluaran
                  Text(AppLocalizations.of(context)!.histExpenseDesc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.histExpenseDescHint,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.cardBorder),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.histRequiredField : null,
                  ),
                  const SizedBox(height: 14),

                  // Jumlah Nominal
                  Text(AppLocalizations.of(context)!.histExpenseAmount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RupiahInputFormatter()],
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.histExpenseAmountHint,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.cardBorder),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.histRequiredAmount;
                      final cleanV = v.replaceAll('.', '');
                      if (double.tryParse(cleanV) == null) return AppLocalizations.of(context)!.histInvalidAmount;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final cleanAmount = amountController.text.trim().replaceAll('.', '');
                          final amount = double.parse(cleanAmount);
                          
                          // Save to Firestore using FirebaseService
                          await FirebaseService().addKasExpense(widget.group.id, {
                            'title': titleController.text.trim(),
                            'amount': amount,
                            'date': Timestamp.now(), // Store as Firestore Timestamp
                            'period': widget.group.getPeriodLabel(widget.group.activePeriodIndex),
                          });

                          if (context.mounted) {
                            Navigator.pop(context);
                            /* ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Catatan pengeluaran kas berhasil disimpan!')),
                            ); */
                          }
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      label: Text(AppLocalizations.of(context)!.histBtnSaveExpense, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    
    // Calculate totalKasIn dynamically
    int lunasCount = 0;
    for (var member in group.members) {
      member.kasPaymentStatuses.forEach((periodIndex, status) {
        if (status == 'LUNAS') {
          lunasCount++;
        }
      });
    }
    final double totalKasIn = (group.kasAmount * lunasCount).toDouble();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService().streamExpenses(group.id),
      builder: (context, snapshot) {
        final kasExpenses = snapshot.data ?? [];
        
        // Calculate totals
        final double totalExpenses = kasExpenses.fold(0.0, (sum, item) => sum + ((item['amount'] ?? 0) as num).toDouble());
        final double netKasBalance = totalKasIn - totalExpenses;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Professional Accent Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.histMainTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Elegant & Professional + Keluar Kas Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _showAddExpenseModal,
                    icon: const Icon(Icons.remove_circle_outline, size: 16, color: AppTheme.limeAccent),
                    label: Text(
                      AppLocalizations.of(context)!.histBtnSpend,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kas Summary Box (Full Width)
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
                    Text(
                      AppLocalizations.of(context)!.histSummaryTitle,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.histTotalIn, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                        Text(
                          '+ ${CurrencyFormatter.formatRupiah(totalKasIn)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.histTotalOut, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                        Text(
                          '- ${CurrencyFormatter.formatRupiah(totalExpenses)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.danger),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(height: 1, color: AppTheme.cardBorder),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.histBalance, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                        Text(
                          CurrencyFormatter.formatRupiah(netKasBalance),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Audit History Per Periode (FULL PAGE WIDTH)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.histAuditTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        Text(AppLocalizations.of(context)!.histAuditSub, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    ...List.generate(group.totalPeriods, (index) {
                      final pIndex = group.totalPeriods - index; // count backwards from highest period to 1
                      final pLabel = group.getPeriodLabel(pIndex);
                      final isCurrent = pIndex == group.activePeriodIndex;
                      final winner = group.winnerSchedule[pIndex] ?? AppLocalizations.of(context)!.histWaitingRoulette;

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppTheme.pastelPurple.withValues(alpha: 0.5)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent ? AppTheme.secondary.withValues(alpha: 0.3) : AppTheme.cardBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  pLabel,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isCurrent ? AppTheme.primary : AppTheme.textMain,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isCurrent ? AppTheme.primary : (pIndex > group.activePeriodIndex ? Colors.grey.shade200 : Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: pIndex > group.activePeriodIndex ? Colors.transparent : AppTheme.cardBorder),
                                  ),
                                  child: Text(
                                    isCurrent ? AppLocalizations.of(context)!.histActivePeriod : (pIndex > group.activePeriodIndex ? AppLocalizations.of(context)!.histNotStarted : AppLocalizations.of(context)!.histDone),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isCurrent ? Colors.white : (pIndex > group.activePeriodIndex ? AppTheme.textMuted : AppTheme.textMain),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${AppLocalizations.of(context)!.histPot} Rp ${group.potAmount.toStringAsFixed(0)} • ${AppLocalizations.of(context)!.histKas} Rp ${group.kasAmount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.histPerMember}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.emoji_events_outlined, size: 16, color: AppTheme.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${AppLocalizations.of(context)!.histWinner} $winner',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Daftar Catatan Pengeluaran Kas (Recent Transactions)
              if (kasExpenses.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.histTransactionsTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      ...kasExpenses.map((expense) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(expense['title'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                                  Builder(
                                    builder: (context) {
                                      String dateStr = '';
                                      if (expense['date'] is Timestamp) {
                                        dateStr = DateFormat('dd MMM yyyy, HH:mm').format((expense['date'] as Timestamp).toDate());
                                      } else {
                                        dateStr = expense['date'].toString();
                                      }
                                      return Text('${expense['period']} • $dateStr', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted));
                                    }
                                  ),
                                ],
                              ),
                              Text(
                                '- Rp ${((expense['amount'] ?? 0) as num).toDouble().toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.danger),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
