import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/services/firebase_service.dart';
import 'package:app_arisan_antigravity/l10n/app_localizations.dart';

class KasExpensesModal extends StatefulWidget {
  final String groupId;
  final double totalKasIn;
  final bool isAdmin;

  const KasExpensesModal({
    Key? key,
    required this.groupId,
    required this.totalKasIn,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<KasExpensesModal> createState() => _KasExpensesModalState();
}

class _KasExpensesModalState extends State<KasExpensesModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final amountStr = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountStr) ?? 0;

    if (amount <= 0) {
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal pengeluaran harus lebih dari 0')),
      ); */
      return;
    }

    setState(() => _isAdding = true);

    try {
      await FirebaseService().addKasExpense(widget.groupId, {
        'title': _titleController.text.trim(),
        'amount': amount,
        'date': Timestamp.now(),
        'period': 0, // General kas expense
      });

      _titleController.clear();
      _amountController.clear();
      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengeluaran berhasil dicatat')),
        ); */
      }
    } catch (e) {
      if (mounted) {
        /* ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencatat pengeluaran: $e')),
        ); */
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseService().streamExpenses(widget.groupId),
        builder: (context, snapshot) {
          final expenses = snapshot.data ?? [];
          final totalExpenses = expenses.fold(0.0, (sum, exp) => sum + (exp['amount'] ?? 0));
          final currentBalance = widget.totalKasIn - totalExpenses;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.kasDetailsTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
              const SizedBox(height: 16),

              // Summary Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.pastelCream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.kasTotalIn, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          Text(CurrencyFormatter.formatRupiah(widget.totalKasIn), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                          const SizedBox(height: 8),
                          Text(AppLocalizations.of(context)!.kasTotalOut, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          Text(CurrencyFormatter.formatRupiah(totalExpenses), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.warning)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(AppLocalizations.of(context)!.kasRemaining, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          Text(CurrencyFormatter.formatRupiah(currentBalance), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: currentBalance >= 0 ? AppTheme.primary : AppTheme.warning)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // List of Expenses
              Expanded(
                child: expenses.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.kasEmpty, style: const TextStyle(color: AppTheme.textMuted)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: expenses.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final exp = expenses[index];
                          DateTime date = DateTime.now();
                          final rawDate = exp['date'];
                          if (rawDate is Timestamp) {
                            date = rawDate.toDate();
                          } else if (rawDate is String) {
                            try {
                              final parts = rawDate.split('/');
                              if (parts.length == 3) {
                                date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                              }
                            } catch (_) {}
                          }
                          
                          final amount = (exp['amount'] ?? 0).toDouble();

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.arrow_downward, color: AppTheme.warning, size: 20),
                            ),
                            title: Text(exp['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(date), style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            trailing: Text('- ${CurrencyFormatter.formatRupiah(amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warning)),
                          );
                        },
                      ),
              ),

              // Add Expense Form (Admin Only)
              if (widget.isAdmin) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.kasAddExpenseTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.kasDescHint,
                                  filled: true,
                                  fillColor: AppTheme.cardBg,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Wajib' : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.kasAmountHint,
                                  filled: true,
                                  fillColor: AppTheme.cardBg,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Wajib' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warning,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isAdding ? null : _submitExpense,
                            child: _isAdding 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(AppLocalizations.of(context)!.kasBtnSave, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
