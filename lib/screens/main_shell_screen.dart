import 'package:flutter/material.dart';

import '../models/ai_route.dart';
import '../theme/router_theme.dart';
import '../widgets/app_feedback.dart';
import 'connected_apis_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  late List<AiRoute> _routes;

  @override
  void initState() {
    super.initState();
    _routes = initialAiRoutes();
  }

  void _addRoute(AiRoute route) {
    setState(() {
      _routes = [route, ..._routes];
    });
    AppFeedback.showSuccess(
      context,
      title: 'Rute Terpasang',
      message: 'Rute "${route.name}" (${route.alias}) berhasil diaktifkan.',
    );
  }

  void _updateRoute(AiRoute updated) {
    setState(() {
      _routes = _routes
          .map((r) => r.id == updated.id ? updated : r)
          .toList();
    });
  }

  void _deleteRoute(String routeId) {
    final deleted = _routes.where((r) => r.id == routeId).firstOrNull;
    setState(() {
      _routes = _routes.where((r) => r.id != routeId).toList();
    });
    if (deleted != null) {
      AppFeedback.showSuccess(
        context,
        title: 'Rute Dihapus',
        message: 'Rute "${deleted.name}" telah dihapus.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['AI Router', 'Connected AI APIs', 'Gateway Settings'];

    return Scaffold(
      backgroundColor: RouterColors.surface,
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: RouterColors.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: RouterColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(routes: _routes),
          ConnectedApisScreen(
            routes: _routes,
            onRouteAdded: _addRoute,
            onRouteUpdated: _updateRoute,
            onRouteDeleted: _deleteRoute,
          ),
          _SettingsTab(
            routeCount: _routes.length,
            onLogout: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const GatewayLoginScreen()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: RouterColors.surface.withValues(alpha: 0.92),
          border: Border(
            top: BorderSide(
              color: RouterColors.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  selected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.alt_route,
                  label: 'Routers',
                  selected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  selected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 28,
              decoration: BoxDecoration(
                color: selected
                    ? RouterColors.surfaceContainerHighest
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                size: 19,
                color: selected
                    ? RouterColors.primary
                    : RouterColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? Colors.white
                    : RouterColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  final int routeCount;
  final VoidCallback onLogout;

  const _SettingsTab({required this.routeCount, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RouterColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: RouterColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '9Router Gateway',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: RouterColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TLS 1.3 · AES-256 Vault · $routeCount configured routes',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: RouterColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onLogout,
          style: OutlinedButton.styleFrom(
            foregroundColor: RouterColors.error,
            side: BorderSide(color: RouterColors.error.withValues(alpha: 0.4)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Lock Gateway & Sign Out'),
        ),
      ],
    );
  }
}
