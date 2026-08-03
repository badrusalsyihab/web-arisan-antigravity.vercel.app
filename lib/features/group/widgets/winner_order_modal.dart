import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/group_model.dart';

class WinnerOrderModal extends StatefulWidget {
  final GroupModel group;
  final Function(Map<int, String>) onSave;

  const WinnerOrderModal({
    Key? key,
    required this.group,
    required this.onSave,
  }) : super(key: key);

  @override
  State<WinnerOrderModal> createState() => _WinnerOrderModalState();
}

class _WinnerOrderModalState extends State<WinnerOrderModal> {
  late Map<int, String> schedule;

  @override
  void initState() {
    super.initState();
    schedule = Map.from(widget.group.winnerSchedule);
  }

  @override
  Widget build(BuildContext context) {
    final candidateNames = widget.group.members.map((m) => m.name).toList();
    
    // Collect past winners so they can be excluded from future selections
    final pastWinners = schedule.entries
        .where((e) => e.key < widget.group.activePeriodIndex)
        .map((e) => e.value)
        .toSet();

    return Dialog(
      backgroundColor: AppTheme.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.settings, color: AppTheme.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Atur Urutan Pemenang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Jenis Periode: ${widget.group.periodType.toUpperCase()}',
                style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...List.generate(widget.group.members.length, (index) {
                final periodIndex = index + 1;
                final periodLabel = widget.group.getPeriodLabel(periodIndex);
                final isPast = periodIndex < widget.group.activePeriodIndex;
                final isCurrent = periodIndex == widget.group.activePeriodIndex;

                final currentWinner = schedule[periodIndex] ?? candidateNames[index % candidateNames.length];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppTheme.primary.withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent ? AppTheme.primary : AppTheme.cardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          periodLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isPast)
                        Text(
                          '$currentWinner (Menang)',
                          style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.bold),
                        )
                      else
                        Builder(
                          builder: (context) {
                            // Filter out past winners for the dropdown options
                            final availableOptions = candidateNames
                                .where((name) => !pastWinners.contains(name))
                                .toList();
                                
                            // Fallback if availableOptions is somehow empty
                            if (availableOptions.isEmpty) {
                              availableOptions.add(currentWinner);
                            }

                            final safeValue = availableOptions.contains(currentWinner) 
                                ? currentWinner 
                                : availableOptions.first;

                            return DropdownButton<String>(
                              value: safeValue,
                              dropdownColor: AppTheme.cardBg,
                              underline: const SizedBox(),
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMain, fontWeight: FontWeight.bold),
                              items: availableOptions.map((String name) {
                                return DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    schedule[periodIndex] = newValue;
                                  });
                                }
                              },
                            );
                          },
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  widget.onSave(schedule);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Urutan pemenang berhasil disimpan!')),
                  );
                },
                child: const Text('💾 Simpan Urutan Pemenang', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(color: AppTheme.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
