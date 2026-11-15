import 'dart:async';

import 'package:flutter/material.dart';

import '../models/ai_route.dart';
import '../theme/router_theme.dart';
import '../widgets/app_feedback.dart';

/// 6. Configure AI Route Form (from Stitch 9Router Mobile UI Kit).
/// Includes per-field Form validation, dynamic error banner, and exception handling.
class ConfigureRouteScreen extends StatefulWidget {
  final AiRoute? initialRoute;

  const ConfigureRouteScreen({super.key, this.initialRoute});

  @override
  State<ConfigureRouteScreen> createState() => _ConfigureRouteScreenState();
}

class _ConfigureRouteScreenState extends State<ConfigureRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _providerController;
  late final TextEditingController _aliasController;
  late final TextEditingController _endpointController;
  late final TextEditingController _apiKeyController;

  bool get _isEditMode => widget.initialRoute != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRoute;
    _providerController = TextEditingController(
      text: initial?.name ?? 'Google Gemini 2.5 Pro',
    );
    _aliasController = TextEditingController(
      text: initial?.alias ?? '/v1/gemini-fast',
    );
    _endpointController = TextEditingController(
      text: initial?.endpointUrl ?? 'https://generativelanguage.googleapis.com/v1',
    );
    _apiKeyController = TextEditingController(
      text: initial?.fullApiKey ?? 'AIzaSyDG-9X3109kLM02910488219',
    );
  }

  bool _obscureKey = true;
  bool _isSaving = false;
  bool _hasSubmittedOnce = false;
  String? _bannerTitle;
  String? _bannerMessage;
  IconData _bannerIcon = Icons.error_outline;

  @override
  void dispose() {
    _providerController.dispose();
    _aliasController.dispose();
    _endpointController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  String? _validateProvider(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Provider Name wajib diisi';
    if (v.length < 2) return 'Provider Name minimal 2 karakter';
    return null;
  }

  String? _validateAlias(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Route Alias wajib diisi';
    if (!v.startsWith('/')) return 'Route Alias harus diawali tanda "/"';
    if (v.contains(' ')) return 'Route Alias tidak boleh mengandung spasi';
    return null;
  }

  String? _validateEndpoint(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Endpoint URL wajib diisi';
    final uri = Uri.tryParse(v);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Format URL tidak valid (contoh: https://api.openai.com/v1)';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'URL harus menggunakan protokol http:// atau https://';
    }
    return null;
  }

  String? _validateApiKey(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'API Secret Key wajib diisi';
    if (v.length < 6) return 'API Secret Key minimal 6 karakter';
    return null;
  }

  Future<void> _verifyAndBuildRoute() async {
    final endpoint = _endpointController.text.trim();
    final uri = Uri.parse(endpoint);

    await Future.delayed(const Duration(milliseconds: 550));

    // Safe guard against unreachable/offline hosts in simulation or network failure
    if (uri.host.contains('offline') || uri.host.contains('unreachable')) {
      throw TimeoutException(
        'Koneksi ke ${uri.host} terputus atau melewati batas waktu.',
      );
    }
  }

  Future<void> _saveRoute() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _hasSubmittedOnce = true;
      _bannerTitle = null;
      _bannerMessage = null;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _verifyAndBuildRoute();
      if (!mounted) return;

      final name = _providerController.text.trim();
      final alias = _aliasController.text.trim();
      final endpoint = _endpointController.text.trim();
      final key = _apiKeyController.text.trim();

      final lowerName = name.toLowerCase();
      final badgeKind = lowerName.contains('openai')
          ? ProviderBadgeKind.openai
          : lowerName.contains('claude') || lowerName.contains('anthropic')
              ? ProviderBadgeKind.anthropic
              : lowerName.contains('gemini') || lowerName.contains('google')
                  ? ProviderBadgeKind.gemini
                  : lowerName.contains('ollama') || lowerName.contains('local')
                      ? ProviderBadgeKind.ollama
                      : lowerName.contains('mistral')
                          ? ProviderBadgeKind.mistral
                          : ProviderBadgeKind.custom;

      final existing = widget.initialRoute;
      final resultRoute = existing != null
          ? existing.copyWith(
              name: name,
              alias: alias,
              endpointUrl: endpoint,
              fullApiKey: key,
            )
          : AiRoute(
              id: 'rt_${DateTime.now().millisecondsSinceEpoch}',
              routeCode:
                  'rt_custom_${DateTime.now().second.toString().padLeft(2, '0')}',
              sla: '99.95% SLA',
              name: name,
              subtitle: 'Custom Edge Route · $alias',
              model: alias.replaceFirst('/v1/', ''),
              alias: alias,
              endpointUrl: endpoint,
              fullApiKey: key,
              usedTokens: 12000,
              quotaTokens: 500000,
              promptTokens: 8500,
              completionTokens: 3500,
              spentUsd: 0.42,
              status: AiRouteStatus.active,
              badgeKind: badgeKind,
              traces: const [
                ExecutionTrace(
                  statusLabel: '200 OK',
                  detailLabel: 'Healthcheck Passed',
                  isSuccess: true,
                ),
              ],
            );

      Navigator.of(context).pop(resultRoute);
    } on TimeoutException catch (e) {
      if (!mounted) return;
      final msg =
          e.message ?? 'Koneksi internet terputus saat menghubungi gateway.';
      setState(() {
        _bannerTitle = 'Koneksi Terputus';
        _bannerMessage = msg;
        _bannerIcon = Icons.wifi_off;
      });
      AppFeedback.showError(
        context,
        title: 'Koneksi Terputus',
        message: msg,
        icon: Icons.wifi_off,
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      final msg = 'Format data endpoint tidak valid: ${e.message}';
      setState(() {
        _bannerTitle = 'Format Tidak Valid';
        _bannerMessage = msg;
        _bannerIcon = Icons.error_outline;
      });
      AppFeedback.showError(
        context,
        title: 'Format Tidak Valid',
        message: msg,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = 'Gagal menyimpan rute AI: $e';
      setState(() {
        _bannerTitle = 'Terjadi Kesalahan';
        _bannerMessage = msg;
        _bannerIcon = Icons.error_outline;
      });
      AppFeedback.showError(
        context,
        title: 'Terjadi Kesalahan',
        message: msg,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RouterColors.surface,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit AI Route' : 'Configure AI Route',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                autovalidateMode: _hasSubmittedOnce
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InlineErrorBanner(
                      title: _bannerTitle,
                      message: _bannerMessage,
                      icon: _bannerIcon,
                      onDismiss: () {
                        setState(() {
                          _bannerTitle = null;
                          _bannerMessage = null;
                        });
                      },
                      onRetry: _bannerIcon == Icons.wifi_off ? _saveRoute : null,
                    ),
                    _FormFieldGroup(
                      label: 'Provider Name',
                      child: TextFormField(
                        controller: _providerController,
                        validator: _validateProvider,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          fontSize: 14,
                          color: RouterColors.onSurface,
                        ),
                        decoration: _inputDecoration(
                          hintText: 'e.g. Google Gemini 2.5 Pro',
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FormFieldGroup(
                      label: 'Route Alias',
                      child: TextFormField(
                        controller: _aliasController,
                        validator: _validateAlias,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: RouterColors.primary,
                        ),
                        decoration: _inputDecoration(
                          hintText: '/v1/gemini-fast',
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FormFieldGroup(
                      label: 'Endpoint URL',
                      child: TextFormField(
                        controller: _endpointController,
                        validator: _validateEndpoint,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: RouterColors.onSurface,
                        ),
                        decoration: _inputDecoration(
                          hintText:
                              'https://generativelanguage.googleapis.com/v1',
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FormFieldGroup(
                      label: 'API Secret Key',
                      child: TextFormField(
                        controller: _apiKeyController,
                        validator: _validateApiKey,
                        obscureText: _obscureKey,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _saveRoute(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          letterSpacing: 1.5,
                          color: RouterColors.onSurface,
                        ),
                        decoration: _inputDecoration(hintText: 'AIzaSy...')
                            .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureKey
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 18,
                                  color: RouterColors.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() => _obscureKey = !_obscureKey);
                                },
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveRoute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RouterColors.primaryContainer,
                          foregroundColor: const Color(0xFF001552),
                          disabledBackgroundColor:
                              RouterColors.surfaceContainerHigh,
                          disabledForegroundColor:
                              RouterColors.onSurfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check, size: 18),
                        label: Text(
                          _isSaving
                              ? (_isEditMode ? 'Updating...' : 'Deploying...')
                              : (_isEditMode ? 'Update Route' : 'Save Route'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: RouterColors.onSurfaceVariant.withValues(alpha: 0.4),
      ),
      errorStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: RouterColors.error,
      ),
      filled: true,
      fillColor: RouterColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: RouterColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: RouterColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: RouterColors.error, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: RouterColors.error, width: 1.6),
      ),
    );
  }
}

class _FormFieldGroup extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormFieldGroup({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: RouterColors.onSurfaceVariant,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
