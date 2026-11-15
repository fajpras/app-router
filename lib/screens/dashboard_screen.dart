import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/ai_route.dart';
import '../theme/router_theme.dart';

/// 3. Dashboard Screen (from Stitch 9Router Mobile UI Kit).
class DashboardScreen extends StatelessWidget {
  final List<AiRoute> routes;

  const DashboardScreen({super.key, required this.routes});

  @override
  Widget build(BuildContext context) {
    final activeCount = routes.where((r) => r.isEnabled).length;
    final totalUsed = routes.fold<int>(0, (sum, r) => sum + r.usedTokens);
    const totalQuota = 2000000;
    final usedRatio = (totalUsed / totalQuota).clamp(0.0, 1.0);
    final usedPercent = (usedRatio * 100).toStringAsFixed(1);
    final remaining = math.max(0, totalQuota - totalUsed);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Tokens Used Card
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOKENS USED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: RouterColors.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: RouterColors.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Resets in 8d',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: RouterColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    AiRoute.formatTokens(totalUsed),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '/ 2.0M',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: RouterColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: usedRatio,
                  minHeight: 6,
                  backgroundColor: RouterColors.surfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    RouterColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$usedPercent% consumed',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: RouterColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${AiRoute.formatTokens(remaining)} remaining',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: RouterColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 2-column KPI grid
        Row(
          children: [
            Expanded(
              child: _DashboardCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active APIs',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: RouterColors.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: RouterColors.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$activeCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Online',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: RouterColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DashboardCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Avg Latency',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: RouterColors.onSurfaceVariant,
                          ),
                        ),
                        Icon(
                          Icons.bolt,
                          size: 16,
                          color: RouterColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: const [
                        Text(
                          '240',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'ms (P95)',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: RouterColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 7-Day Consumption & Quota Card
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '7-Day Consumption & Quota',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '284k peak',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: RouterColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _ConsumptionSparklinePainter(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _DayLabel('M'),
                            _DayLabel('T'),
                            _DayLabel('W'),
                            _DayLabel('T'),
                            _DayLabel('F', highlighted: true),
                            _DayLabel('S'),
                            _DayLabel('S'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CustomPaint(
                      painter: _QuotaRingPainter(progress: 0.75, strokeWidth: 3),
                      child: const Center(
                        child: Text(
                          '75%',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Live Traffic Card
        _DashboardCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: RouterColors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: RouterColors.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Live Traffic',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: RouterColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '120 req/s',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: RouterColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const _TrafficRow(
                status: '200',
                target: 'openai:gpt-4o',
                latency: '182ms',
              ),
              const _TrafficRow(
                status: '200',
                target: 'anthropic:claude-3.5',
                latency: '310ms',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: RouterColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RouterColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: child,
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String text;
  final bool highlighted;

  const _DayLabel(this.text, {this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 9,
        fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
        color: highlighted
            ? RouterColors.primary
            : RouterColors.onSurfaceVariant,
      ),
    );
  }
}

class _TrafficRow extends StatelessWidget {
  final String status;
  final String target;
  final String latency;

  const _TrafficRow({
    required this.status,
    required this.target,
    required this.latency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                status,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: RouterColors.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                target,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            latency,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: RouterColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsumptionSparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 240.0;
    final sy = size.height / 60.0;
    final path = Path()
      ..moveTo(0, 48 * sy)
      ..cubicTo(35 * sx, 46 * sy, 50 * sx, 40 * sy, 80 * sx, 38 * sy)
      ..cubicTo(110 * sx, 36 * sy, 125 * sx, 44 * sy, 150 * sx, 18 * sy)
      ..cubicTo(175 * sx, 4 * sy, 195 * sx, 26 * sy, 215 * sx, 22 * sy)
      ..cubicTo(225 * sx, 20 * sy, 235 * sx, 16 * sy, 240 * sx, 14 * sy);

    final linePaint = Paint()
      ..color = RouterColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;

    canvas.drawPath(path, linePaint);
    canvas.drawCircle(
      Offset(150 * sx, 18 * sy),
      3.0,
      Paint()..color = RouterColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuotaRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  const _QuotaRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = RouterColors.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final activePaint = Paint()
      ..color = RouterColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _QuotaRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
