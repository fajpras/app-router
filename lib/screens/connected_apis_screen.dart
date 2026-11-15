import 'package:flutter/material.dart';

import '../models/ai_route.dart';
import '../theme/router_theme.dart';
import '../widgets/provider_badge.dart';
import 'api_detail_screen.dart';
import 'configure_route_screen.dart';

enum _RouteFilter { all, active, limited }

/// 4. Connected AI APIs List (from Stitch 9Router Mobile UI Kit).
class ConnectedApisScreen extends StatefulWidget {
  final List<AiRoute> routes;
  final ValueChanged<AiRoute> onRouteAdded;
  final ValueChanged<AiRoute> onRouteUpdated;
  final ValueChanged<String> onRouteDeleted;

  const ConnectedApisScreen({
    super.key,
    required this.routes,
    required this.onRouteAdded,
    required this.onRouteUpdated,
    required this.onRouteDeleted,
  });

  @override
  State<ConnectedApisScreen> createState() => _ConnectedApisScreenState();
}

class _ConnectedApisScreenState extends State<ConnectedApisScreen> {
  final _searchController = TextEditingController();
  _RouteFilter _filter = _RouteFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AiRoute> get _filteredRoutes {
    return widget.routes.where((route) {
      final matchesQuery =
          _query.isEmpty ||
          route.name.toLowerCase().contains(_query) ||
          route.model.toLowerCase().contains(_query);
      if (!matchesQuery) return false;
      switch (_filter) {
        case _RouteFilter.all:
          return true;
        case _RouteFilter.active:
          return route.isEnabled &&
              (route.status == AiRouteStatus.active ||
                  route.status == AiRouteStatus.local);
        case _RouteFilter.limited:
          return route.status == AiRouteStatus.limited;
      }
    }).toList();
  }

  Future<void> _openAddRoute() async {
    final newRoute = await Navigator.of(context).push<AiRoute>(
      MaterialPageRoute(builder: (_) => const ConfigureRouteScreen()),
    );
    if (newRoute != null) {
      widget.onRouteAdded(newRoute);
    }
  }

  Future<void> _openDetail(AiRoute route) async {
    final result = await Navigator.of(context).push<ApiDetailResult>(
      MaterialPageRoute(builder: (_) => ApiDetailScreen(route: route)),
    );
    if (result == null) return;
    if (result.isDeleted && result.deletedRouteId != null) {
      widget.onRouteDeleted(result.deletedRouteId!);
    } else if (result.updatedRoute != null) {
      widget.onRouteUpdated(result.updatedRoute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allCount = widget.routes.length;
    final activeCount = widget.routes
        .where(
          (r) =>
              r.isEnabled &&
              (r.status == AiRouteStatus.active ||
                  r.status == AiRouteStatus.local),
        )
        .length;
    final limitedCount = widget.routes
        .where((r) => r.status == AiRouteStatus.limited)
        .length;
    final filtered = _filteredRoutes;

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _query = value.trim().toLowerCase();
                      });
                    },
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: RouterColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Filter routes or models...',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: RouterColors.outlineVariant.withValues(
                          alpha: 0.9,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: RouterColors.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              color: RouterColors.onSurfaceVariant,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: RouterColors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: RouterColors.outlineVariant.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: RouterColors.outlineVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _FilterChipButton(
                        label: 'All ($allCount)',
                        selected: _filter == _RouteFilter.all,
                        onTap: () => setState(() => _filter = _RouteFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterChipButton(
                        label: 'Active ($activeCount)',
                        dotColor: RouterColors.tertiary,
                        selected: _filter == _RouteFilter.active,
                        onTap: () =>
                            setState(() => _filter = _RouteFilter.active),
                      ),
                      const SizedBox(width: 8),
                      _FilterChipButton(
                        label: 'Limited ($limitedCount)',
                        dotColor: RouterColors.warning,
                        selected: _filter == _RouteFilter.limited,
                        onTap: () =>
                            setState(() => _filter = _RouteFilter.limited),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 40,
                              color: RouterColors.outline,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tidak ada rute AI yang cocok.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: RouterColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _query = '';
                                  _filter = _RouteFilter.all;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: RouterColors.primary,
                                side: BorderSide(
                                  color: RouterColors.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Reset Filter'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final route = filtered[index];
                        return _RouteCard(
                          route: route,
                          onTap: () => _openDetail(route),
                        );
                      },
                    ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 16,
          child: Material(
            color: RouterColors.surfaceContainerHigh,
            shape: CircleBorder(
              side: BorderSide(
                color: RouterColors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            elevation: 3,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _openAddRoute,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: RouterColors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    this.dotColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? RouterColors.surfaceContainerHigh
              : RouterColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: RouterColors.outlineVariant.withValues(
              alpha: selected ? 0.5 : 0.25,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected
                    ? RouterColors.onSurface
                    : RouterColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final AiRoute route;
  final VoidCallback onTap;

  const _RouteCard({required this.route, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLimited = route.status == AiRouteStatus.limited;
    final isLocal = route.status == AiRouteStatus.local;
    final dotColor = !route.isEnabled
        ? RouterColors.outline
        : (isLimited ? RouterColors.warning : RouterColors.tertiary);
    final barColor = !route.isEnabled
        ? RouterColors.outlineVariant
        : route.accentColor;

    final leftLabel = isLocal
        ? '${AiRoute.formatTokens(route.usedTokens)} (Unlimited)'
        : '${AiRoute.formatTokens(route.usedTokens)} / ${AiRoute.formatTokens(route.quotaTokens)}';
    final rightLabel = isLocal ? 'Local' : '${route.utilizationPercent}%';

    return Material(
      color: RouterColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: RouterColors.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProviderBadge(kind: route.badgeKind),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: RouterColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            route.model,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: RouterColors.onSurfaceVariant.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    leftLabel,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: isLimited
                          ? RouterColors.warning
                          : RouterColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    rightLabel,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isLocal
                          ? RouterColors.tertiary
                          : (isLimited
                                ? RouterColors.warning
                                : RouterColors.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: route.utilizationRatio,
                  minHeight: 4,
                  backgroundColor: RouterColors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
