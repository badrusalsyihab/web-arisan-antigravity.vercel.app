import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DashboardSkeletonScreen extends StatefulWidget {
  const DashboardSkeletonScreen({super.key});

  @override
  State<DashboardSkeletonScreen> createState() => _DashboardSkeletonScreenState();
}

class _DashboardSkeletonScreenState extends State<DashboardSkeletonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildShimmerBox({required double width, required double height, double borderRadius = 12}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1).withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Header Skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBox(width: 140, height: 36, borderRadius: 16),
                  _buildShimmerBox(width: 40, height: 40, borderRadius: 20),
                ],
              ),
              const SizedBox(height: 20),

              // Main Banner Card Skeleton
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildShimmerBox(width: 120, height: 20, borderRadius: 8),
                        _buildShimmerBox(width: 80, height: 24, borderRadius: 12),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildShimmerBox(width: 220, height: 38, borderRadius: 10),
                    const SizedBox(height: 12),
                    _buildShimmerBox(width: 160, height: 16, borderRadius: 6),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildShimmerBox(width: double.infinity, height: 44, borderRadius: 14)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildShimmerBox(width: double.infinity, height: 44, borderRadius: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons Row Skeleton
              Row(
                children: [
                  Expanded(child: _buildShimmerBox(width: double.infinity, height: 42, borderRadius: 14)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildShimmerBox(width: double.infinity, height: 42, borderRadius: 14)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildShimmerBox(width: double.infinity, height: 42, borderRadius: 14)),
                ],
              ),
              const SizedBox(height: 20),

              // Stat Summary Cards Grid Skeleton
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(width: 90, height: 14, borderRadius: 6),
                          const SizedBox(height: 10),
                          _buildShimmerBox(width: 110, height: 22, borderRadius: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(width: 90, height: 14, borderRadius: 6),
                          const SizedBox(height: 10),
                          _buildShimmerBox(width: 110, height: 22, borderRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Title Skeleton
              _buildShimmerBox(width: 180, height: 20, borderRadius: 8),
              const SizedBox(height: 14),

              // Member List Items Skeleton
              for (int i = 0; i < 3; i++) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      _buildShimmerBox(width: 44, height: 44, borderRadius: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerBox(width: 130, height: 16, borderRadius: 6),
                            const SizedBox(height: 6),
                            _buildShimmerBox(width: 90, height: 12, borderRadius: 4),
                          ],
                        ),
                      ),
                      _buildShimmerBox(width: 70, height: 26, borderRadius: 12),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
