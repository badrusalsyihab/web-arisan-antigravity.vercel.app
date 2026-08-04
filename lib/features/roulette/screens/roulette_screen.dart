import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/group_model.dart';

class RouletteScreen extends StatefulWidget {
  final GroupModel group;
  final Function(String winnerName) onWinnerSelected;

  const RouletteScreen({
    super.key,
    required this.group,
    required this.onWinnerSelected,
  });

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isSpinning = false;
  double targetAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (isSpinning) return;

    final candidates = widget.group.members.where((m) => !m.isWinner).toList();
    if (candidates.isEmpty) {
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seluruh anggota sudah pernah menang pada siklus ini!')),
      ); */
      return;
    }

    setState(() {
      isSpinning = true;
    });

    final candidateList = candidates.map((m) => m.name).toList();
    final preDefinedWinner = widget.group.winnerSchedule[widget.group.activePeriodIndex];
    
    int winnerIndex = 0;
    if (preDefinedWinner != null) {
      winnerIndex = candidateList.indexOf(preDefinedWinner);
      if (winnerIndex == -1) winnerIndex = 0;
    } else {
      winnerIndex = Random().nextInt(candidateList.length);
    }
    
    final selectedWinner = candidateList[winnerIndex];

    final arcAngle = (2 * pi) / candidateList.length;
    final winnerMiddleAngle = winnerIndex * arcAngle + (arcAngle / 2);
    
    final randomSpins = 5 + Random().nextInt(3);
    final currentBase = _animation.value - (_animation.value % (2 * pi));
    targetAngle = currentBase + (2 * pi * randomSpins) + ((3 * pi) / 2) - winnerMiddleAngle;

    _animation = Tween<double>(begin: _animation.value, end: targetAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward(from: 0).then((_) {
      setState(() {
        isSpinning = false;
      });
      _showWinnerDialog(selectedWinner);
    });
  }

  void _showWinnerDialog(String winnerName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎊🏆🎊', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 10),
              const Text('Selamat Kepada Pemenang!', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              Text(
                winnerName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.accent),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.secondary),
                ),
                child: Text(
                  '🏆 PEMENANG ${widget.group.getPeriodLabel(widget.group.activePeriodIndex).toUpperCase()}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  widget.onWinnerSelected(winnerName);
                  Navigator.pop(context);
                },
                child: const Text('Tutup & Simpan Hasil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final candidates = widget.group.members.where((m) => !m.isWinner).map((m) => m.name).toList();
    final candidateList = candidates.isEmpty ? ['Semua', 'Sudah', 'Menang'] : candidates;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text('Kocokan Roulette Arisan 🎯', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Hanya anggota yang BELUM MENANG yang masuk dalam Roda Roulette.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Wheel Pointer & Canvas
          Stack(
            alignment: Alignment.topCenter,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value,
                    child: CustomPaint(
                      size: const Size(260, 260),
                      painter: WheelPainter(items: candidateList),
                    ),
                  );
                },
              ),
              Positioned(
                top: -5,
                child: CustomPaint(
                  size: const Size(24, 24),
                  painter: PointerPainter(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Spin Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: isSpinning ? null : _spinWheel,
            child: isSpinning
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('MEMUTAR ROULETTE...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  )
                : const Text(
                    'PUTAR ROULETTE (AKSES KETUA)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> items;
  WheelPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final arcAngle = (2 * pi) / items.length;

    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.accent,
      AppTheme.warning,
      const Color(0xFFE11D48),
      const Color(0xFF0284C7),
    ];

    for (int i = 0; i < items.length; i++) {
      final startAngle = i * arcAngle;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcAngle,
        true,
        borderPaint,
      );

      // Text rendering
      final textAngle = startAngle + arcAngle / 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i],
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(radius * 0.45, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
