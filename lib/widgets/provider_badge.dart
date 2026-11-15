import 'package:flutter/material.dart';

import '../models/ai_route.dart';
import '../theme/router_theme.dart';

class ProviderBadge extends StatelessWidget {
  final ProviderBadgeKind kind;

  const ProviderBadge({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: RouterColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: _buildIcon(),
    );
  }

  Widget _buildIcon() {
    switch (kind) {
      case ProviderBadgeKind.openai:
        return const Icon(
          Icons.hub_outlined,
          size: 18,
          color: RouterColors.primary,
        );
      case ProviderBadgeKind.anthropic:
        return const Text(
          'A',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: RouterColors.secondary,
          ),
        );
      case ProviderBadgeKind.gemini:
        return const Icon(
          Icons.auto_awesome,
          size: 17,
          color: RouterColors.warning,
        );
      case ProviderBadgeKind.ollama:
        return const Icon(
          Icons.terminal,
          size: 17,
          color: RouterColors.tertiary,
        );
      case ProviderBadgeKind.mistral:
        return const Text(
          'M//',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: RouterColors.primary,
          ),
        );
      case ProviderBadgeKind.custom:
        return const Icon(
          Icons.alt_route,
          size: 17,
          color: RouterColors.primary,
        );
    }
  }
}
