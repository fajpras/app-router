import 'package:flutter/material.dart';

import '../theme/router_theme.dart';

enum AiRouteStatus { active, limited, local }

enum ProviderBadgeKind { openai, anthropic, gemini, ollama, mistral, custom }

class ExecutionTrace {
  final String statusLabel;
  final String detailLabel;
  final bool isSuccess;

  const ExecutionTrace({
    required this.statusLabel,
    required this.detailLabel,
    required this.isSuccess,
  });
}

class AiRoute {
  final String id;
  final String routeCode;
  final String sla;
  final String name;
  final String subtitle;
  final String model;
  final String alias;
  final String endpointUrl;
  final String fullApiKey;
  final int usedTokens;
  final int quotaTokens;
  final bool isUnlimited;
  final int promptTokens;
  final int completionTokens;
  final double spentUsd;
  final AiRouteStatus status;
  final ProviderBadgeKind badgeKind;
  final bool isEnabled;
  final List<ExecutionTrace> traces;

  const AiRoute({
    required this.id,
    required this.routeCode,
    required this.sla,
    required this.name,
    required this.subtitle,
    required this.model,
    required this.alias,
    required this.endpointUrl,
    required this.fullApiKey,
    required this.usedTokens,
    required this.quotaTokens,
    this.isUnlimited = false,
    required this.promptTokens,
    required this.completionTokens,
    required this.spentUsd,
    required this.status,
    required this.badgeKind,
    this.isEnabled = true,
    this.traces = const [],
  });

  double get utilizationRatio {
    if (isUnlimited || quotaTokens <= 0) return 1.0;
    return (usedTokens / quotaTokens).clamp(0.0, 1.0);
  }

  int get utilizationPercent {
    if (isUnlimited || quotaTokens <= 0) return 100;
    return ((usedTokens / quotaTokens) * 100).round().clamp(0, 100);
  }

  String get maskedApiKey {
    if (fullApiKey.length <= 12) return '••••••••';
    final prefix = fullApiKey.substring(0, 8);
    final suffix = fullApiKey.substring(fullApiKey.length - 4);
    return '$prefix••••$suffix';
  }

  Color get accentColor {
    switch (status) {
      case AiRouteStatus.limited:
        return RouterColors.warning;
      case AiRouteStatus.local:
        return RouterColors.tertiary;
      case AiRouteStatus.active:
        switch (badgeKind) {
          case ProviderBadgeKind.anthropic:
            return RouterColors.secondary;
          case ProviderBadgeKind.gemini:
            return RouterColors.warning;
          case ProviderBadgeKind.ollama:
            return RouterColors.tertiary;
          default:
            return RouterColors.primary;
        }
    }
  }

  AiRoute copyWith({
    bool? isEnabled,
    String? name,
    String? alias,
    String? endpointUrl,
    String? fullApiKey,
  }) {
    return AiRoute(
      id: id,
      routeCode: routeCode,
      sla: sla,
      name: name ?? this.name,
      subtitle: subtitle,
      model: model,
      alias: alias ?? this.alias,
      endpointUrl: endpointUrl ?? this.endpointUrl,
      fullApiKey: fullApiKey ?? this.fullApiKey,
      usedTokens: usedTokens,
      quotaTokens: quotaTokens,
      isUnlimited: isUnlimited,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      spentUsd: spentUsd,
      status: status,
      badgeKind: badgeKind,
      isEnabled: isEnabled ?? this.isEnabled,
      traces: traces,
    );
  }

  static String formatTokens(int count) {
    if (count >= 1000000) {
      final m = count / 1000000;
      return '${m.toStringAsFixed(m == m.roundToDouble() ? 1 : 2)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).round()}k';
    }
    return count.toString();
  }
}

List<AiRoute> initialAiRoutes() {
  return const [
    AiRoute(
      id: 'openai-primary',
      routeCode: 'rt_oai_prod_01',
      sla: '99.98% SLA',
      name: 'OpenAI Primary',
      subtitle: 'Production Gateway · Tier-1 Pool',
      model: 'gpt-4o',
      alias: '/v1/openai',
      endpointUrl: 'https://api.airouter.local/v1/openai',
      fullApiKey: 'sk-airtr-992389aB',
      usedTokens: 680000,
      quotaTokens: 1000000,
      promptTokens: 495000,
      completionTokens: 185000,
      spentUsd: 34.12,
      status: AiRouteStatus.active,
      badgeKind: ProviderBadgeKind.openai,
      traces: [
        ExecutionTrace(
          statusLabel: '200 OK',
          detailLabel: '1.2k tok',
          isSuccess: true,
        ),
        ExecutionTrace(
          statusLabel: '429 Rate Limit',
          detailLabel: 'Claude Fallback',
          isSuccess: false,
        ),
        ExecutionTrace(
          statusLabel: '200 OK',
          detailLabel: '640 tok',
          isSuccess: true,
        ),
      ],
    ),
    AiRoute(
      id: 'claude-analysis',
      routeCode: 'rt_ant_prod_02',
      sla: '99.95% SLA',
      name: 'Claude Analysis',
      subtitle: 'Reasoning & Code Review Pool',
      model: 'claude-3-5-sonnet',
      alias: '/v1/claude',
      endpointUrl: 'https://api.airouter.local/v1/claude',
      fullApiKey: 'sk-ant-774102cD',
      usedTokens: 420000,
      quotaTokens: 800000,
      promptTokens: 290000,
      completionTokens: 130000,
      spentUsd: 21.80,
      status: AiRouteStatus.active,
      badgeKind: ProviderBadgeKind.anthropic,
      traces: [
        ExecutionTrace(
          statusLabel: '200 OK',
          detailLabel: '2.1k tok',
          isSuccess: true,
        ),
        ExecutionTrace(
          statusLabel: '200 OK',
          detailLabel: '890 tok',
          isSuccess: true,
        ),
      ],
    ),
    AiRoute(
      id: 'gemini-multimodal',
      routeCode: 'rt_gem_edge_03',
      sla: '99.90% SLA',
      name: 'Gemini Multimodal',
      subtitle: 'Vision & Long-Context Mesh',
      model: 'gemini-2.5-pro',
      alias: '/v1/gemini',
      endpointUrl: 'https://api.airouter.local/v1/gemini',
      fullApiKey: 'AIzaSyDG-9X3109kLM',
      usedTokens: 380000,
      quotaTokens: 400000,
      promptTokens: 305000,
      completionTokens: 75000,
      spentUsd: 14.50,
      status: AiRouteStatus.limited,
      badgeKind: ProviderBadgeKind.gemini,
      traces: [
        ExecutionTrace(
          statusLabel: '429 Quota Near',
          detailLabel: '95% used',
          isSuccess: false,
        ),
        ExecutionTrace(
          statusLabel: '200 OK',
          detailLabel: '1.8k tok',
          isSuccess: true,
        ),
      ],
    ),
    AiRoute(
      id: 'ollama-fallback',
      routeCode: 'rt_loc_node_04',
      sla: '100% Local',
      name: 'On-Prem Fallback',
      subtitle: 'Private GPU Cluster · Localhost',
      model: 'qwen2.5-coder-32b',
      alias: '/v1/local-qwen',
      endpointUrl: 'http://127.0.0.1:11434/v1',
      fullApiKey: 'local-no-key-required',
      usedTokens: 110000,
      quotaTokens: 0,
      isUnlimited: true,
      promptTokens: 82000,
      completionTokens: 28000,
      spentUsd: 0.00,
      status: AiRouteStatus.local,
      badgeKind: ProviderBadgeKind.ollama,
      traces: [
        ExecutionTrace(
          statusLabel: '200 OK',
          detailLabel: '510 tok',
          isSuccess: true,
        ),
      ],
    ),
    AiRoute(
      id: 'mistral-compliant',
      routeCode: 'rt_mis_eu_05',
      sla: '99.92% SLA',
      name: 'Mistral Compliant',
      subtitle: 'EU Sovereign Data Residency',
      model: 'mistral-large-2407',
      alias: '/v1/mistral',
      endpointUrl: 'https://api.airouter.local/v1/mistral',
      fullApiKey: 'mis-live-441092eF',
      usedTokens: 95000,
      quotaTokens: 300000,
      promptTokens: 64000,
      completionTokens: 31000,
      spentUsd: 6.40,
      status: AiRouteStatus.active,
      badgeKind: ProviderBadgeKind.mistral,
      traces: [
        ExecutionTrace(
          statusLabel: '200 OK',
          detailLabel: '430 tok',
          isSuccess: true,
        ),
      ],
    ),
  ];
}
