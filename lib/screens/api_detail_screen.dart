import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/ai_route.dart';
import '../theme/router_theme.dart';
import '../widgets/app_feedback.dart';
import 'configure_route_screen.dart';

class ApiDetailResult {
  final AiRoute? updatedRoute;
  final String? deletedRouteId;

  const ApiDetailResult.updated(this.updatedRoute) : deletedRouteId = null;
  const ApiDetailResult.deleted(this.deletedRouteId) : updatedRoute = null;

  bool get isDeleted => deletedRouteId != null;
}

/// 5. API Detail Screen (from Stitch 9Router Mobile UI Kit).
class ApiDetailScreen extends StatefulWidget {
  final AiRoute route;

  const ApiDetailScreen({super.key, required this.route});

  @override
  State<ApiDetailScreen> createState() => _ApiDetailScreenState();
}

class _ApiDetailScreenState extends State<ApiDetailScreen> {
  late AiRoute _route;
  bool _revealKey = false;
  bool _copiedEndpoint = false;
  bool _copiedKey = false;

  @override
  void initState() {
    super.initState();
    _route = widget.route;
  }

  Future<void> _copyText(String text, {required bool isEndpoint}) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      setState(() {
        if (isEndpoint) {
          _copiedEndpoint = true;
        } else {
          _copiedKey = true;
        }
      });
      AppFeedback.showSuccess(
        context,
        message: isEndpoint
            ? 'Endpoint URL berhasil disalin ke clipboard'
            : 'API Key berhasil disalin ke clipboard',
      );
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          if (isEndpoint) {
            _copiedEndpoint = false;
          } else {
            _copiedKey = false;
          }
        });
      });
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(
        context,
        title: 'Gagal Menyalin',
        message: 'Tidak dapat mengakses clipboard: $e',
      );
    }
  }

  Future<void> _editRoute() async {
    final updated = await Navigator.of(context).push<AiRoute>(
      MaterialPageRoute(
        builder: (_) => ConfigureRouteScreen(initialRoute: _route),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _route = updated);
      AppFeedback.showSuccess(
        context,
        title: 'Rute Diperbarui',
        message: 'Perubahan pada "${updated.name}" telah disimpan.',
      );
    }
  }

  Future<void> _confirmDeleteRoute() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RouterColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: RouterColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        title: const Text(
          'Hapus Rute?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: RouterColors.onSurface,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${_route.name}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(
            fontSize: 13,
            color: RouterColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: RouterColors.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: RouterColors.errorSurface,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(ApiDetailResult.deleted(_route.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final traces = _route.traces.isNotEmpty
        ? _route.traces
        : const [
            ExecutionTrace(
              statusLabel: '200 OK',
              detailLabel: '1.2k tok',
              isSuccess: true,
            ),
          ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(ApiDetailResult.updated(_route));
        }
      },
      child: Scaffold(
        backgroundColor: RouterColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.of(context).pop(ApiDetailResult.updated(_route)),
          ),
          title: Text(
            _route.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              tooltip: 'Edit Route',
              icon: const Icon(Icons.edit_outlined, color: RouterColors.primary),
              onPressed: _editRoute,
            ),
            IconButton(
              tooltip: 'Delete Route',
              icon: const Icon(Icons.delete_outline, color: RouterColors.error),
              onPressed: _confirmDeleteRoute,
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // Route code + SLA badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _route.isEnabled
                              ? RouterColors.tertiary
                              : RouterColors.outline,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _route.routeCode,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: RouterColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: RouterColors.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Text(
                      _route.sla,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: RouterColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Summary + Endpoint + API Key card
              _DetailCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: RouterColors.outlineVariant.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_route.name} Route',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: RouterColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _route.subtitle,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: RouterColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _route.isEnabled,
                            activeThumbColor: RouterColors.surface,
                            activeTrackColor: RouterColors.primary,
                            inactiveThumbColor: RouterColors.surface,
                            inactiveTrackColor:
                                RouterColors.surfaceContainerHighest,
                            onChanged: (val) {
                              setState(() {
                                _route = _route.copyWith(isEnabled: val);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ENDPOINT URL',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        letterSpacing: 0.8,
                        color: RouterColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _CopyableCodeBox(
                      text: _route.endpointUrl,
                      copied: _copiedEndpoint,
                      onCopy: () =>
                          _copyText(_route.endpointUrl, isEndpoint: true),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'API KEY',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            letterSpacing: 0.8,
                            color: RouterColors.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _revealKey = !_revealKey),
                          child: Text(
                            _revealKey ? 'Hide' : 'Reveal',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: RouterColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _CopyableCodeBox(
                      text: _revealKey
                          ? _route.fullApiKey
                          : _route.maskedApiKey,
                      copied: _copiedKey,
                      onCopy: () =>
                          _copyText(_route.fullApiKey, isEndpoint: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Token Utilization Card
              _DetailCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Token Utilization',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: RouterColors.onSurface,
                          ),
                        ),
                        Text(
                          'Monthly Quota',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: RouterColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CustomPaint(
                            painter: _UtilizationRingPainter(
                              progress: _route.utilizationRatio,
                              color: _route.accentColor,
                            ),
                            child: Center(
                              child: Text(
                                '${_route.utilizationPercent}%',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: RouterColors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              _TokenRow(
                                dotColor: RouterColors.primary,
                                label: 'Prompt',
                                value:
                                    '${AiRoute.formatTokens(_route.promptTokens)} tok',
                              ),
                              const SizedBox(height: 8),
                              _TokenRow(
                                dotColor: RouterColors.secondary,
                                label: 'Completion',
                                value:
                                    '${AiRoute.formatTokens(_route.completionTokens)} tok',
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: RouterColors.outlineVariant
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _route.isUnlimited
                                          ? 'Total: ${AiRoute.formatTokens(_route.usedTokens)}'
                                          : 'Total: ${AiRoute.formatTokens(_route.usedTokens)} / ${AiRoute.formatTokens(_route.quotaTokens)}',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: RouterColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '\$${_route.spentUsd.toStringAsFixed(2)} spent',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: RouterColors.tertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Execution Trace Card
              _DetailCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Execution Trace',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: RouterColors.onSurface,
                          ),
                        ),
                        Text(
                          'Recent',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: RouterColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: RouterColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: RouterColors.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < traces.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                color: RouterColors.outlineVariant.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: traces[i].isSuccess
                                              ? RouterColors.tertiary
                                              : RouterColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        traces[i].statusLabel,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          color: RouterColors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    traces[i].detailLabel,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: RouterColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _editRoute,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RouterColors.primary,
                        side: BorderSide(
                          color: RouterColors.primary.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Route'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _confirmDeleteRoute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RouterColors.errorSurface,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete Route'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RouterColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: RouterColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: child,
    );
  }
}

class _CopyableCodeBox extends StatelessWidget {
  final String text;
  final bool copied;
  final VoidCallback onCopy;

  const _CopyableCodeBox({
    required this.text,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: RouterColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: RouterColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: RouterColors.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: onCopy,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(
              copied ? Icons.check : Icons.content_copy,
              size: 16,
              color: copied
                  ? RouterColors.tertiary
                  : RouterColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String value;

  const _TokenRow({
    required this.dotColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: RouterColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: RouterColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _UtilizationRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _UtilizationRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 5.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = RouterColors.surfaceContainerHighest
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _UtilizationRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
