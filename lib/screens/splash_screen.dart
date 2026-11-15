import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/router_theme.dart';
import 'login_screen.dart';

/// 1. Splash Screen (from Stitch 9Router Mobile UI Kit).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const List<String> _states = [
    'Connecting nodes...',
    'Syncing rate limit cache...',
    'Warming edge routes...',
    'Gateway active',
  ];

  int _step = 0;
  double _progress = 0.45;
  Timer? _timer;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 550), (timer) {
      if (!mounted) return;
      setState(() {
        _step = (_step + 1).clamp(0, _states.length - 1);
        if (_step == 1) _progress = 0.78;
        if (_step == 2) _progress = 0.94;
        if (_step >= 3) {
          _progress = 1.0;
          timer.cancel();
        }
      });
    });

    _navTimer = Timer(const Duration(milliseconds: 2200), _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GatewayLoginScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RouterColors.surface,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _goToLogin,
          child: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: RouterColors.splashIconBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: RouterColors.splashIconBorder,
                          ),
                        ),
                        child: Center(
                          child: CustomPaint(
                            size: const Size(56, 56),
                            painter: _AiRouterLogoPainter(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'AI Router',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: Color(0xFFF4F6FB),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _states[_step],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: RouterColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 192,
                        height: 4,
                        decoration: BoxDecoration(
                          color: RouterColors.splashIconBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          alignment: Alignment.centerLeft,
                          widthFactor: _progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: RouterColors.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiRouterLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 64.0;
    final sy = size.height / 64.0;
    Offset pt(double x, double y) => Offset(x * sx, y * sy);

    final trianglePath = Path()
      ..moveTo(32 * sx, 12 * sy)
      ..lineTo(52 * sx, 48 * sy)
      ..lineTo(12 * sx, 48 * sy)
      ..close();

    final fillPaint = Paint()
      ..color = RouterColors.primaryContainer.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(trianglePath, fillPaint);

    final strokePaint = Paint()
      ..color = RouterColors.primaryContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * sx
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(trianglePath, strokePaint);

    final dashedPaint = Paint()
      ..color = RouterColors.primaryContainer.withValues(alpha: 0.6)
      ..strokeWidth = 1.5 * sx;
    canvas.drawLine(pt(32, 16), pt(32, 31), dashedPaint);
    canvas.drawLine(pt(15, 46), pt(28, 38), dashedPaint);
    canvas.drawLine(pt(49, 46), pt(36, 38), dashedPaint);

    canvas.drawCircle(
      pt(32, 12),
      3.5 * sx,
      Paint()..color = const Color(0xFFF4F6FB),
    );
    canvas.drawCircle(
      pt(52, 48),
      3.5 * sx,
      Paint()..color = RouterColors.primaryContainer,
    );
    canvas.drawCircle(
      pt(12, 48),
      3.5 * sx,
      Paint()..color = RouterColors.primaryContainer,
    );
    canvas.drawCircle(
      pt(32, 36),
      4.5 * sx,
      Paint()..color = RouterColors.primaryContainer,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
