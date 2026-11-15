import 'package:flutter/material.dart';

import '../theme/router_theme.dart';
import '../widgets/app_feedback.dart';
import 'main_shell_screen.dart';

/// 2. Gateway Login Screen (from Stitch 9Router Mobile UI Kit).
/// Uses Form + TextFormField validation and visible error feedback.
class GatewayLoginScreen extends StatefulWidget {
  const GatewayLoginScreen({super.key});

  @override
  State<GatewayLoginScreen> createState() => _GatewayLoginScreenState();
}

class _GatewayLoginScreenState extends State<GatewayLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: '123');
  bool _obscurePassword = true;
  bool _hasSubmitted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    setState(() {
      _hasSubmitted = true;
      _errorMessage = null;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    try {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } catch (e) {
      final msg = 'Tidak dapat membuka gateway: $e';
      setState(() => _errorMessage = msg);
      AppFeedback.showError(context, title: 'Kesalahan Sistem', message: msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RouterColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
                    decoration: BoxDecoration(
                      color: RouterColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: RouterColors.surfaceContainerHighest,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _hasSubmitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.account_circle,
                                size: 34,
                                color: RouterColors.primary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: RouterColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: RouterColors.surfaceContainerHighest,
                          ),
                          const SizedBox(height: 20),
                          InlineErrorBanner(
                            title: 'Autentikasi Diperlukan',
                            message: _errorMessage,
                            onDismiss: () =>
                                setState(() => _errorMessage = null),
                          ),
                          const Text(
                            'USERNAME',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: RouterColors.outline,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _usernameController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Username tidak boleh kosong'
                                : null,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: RouterColors.onSurface,
                            ),
                            decoration: _fieldDecoration(
                              defaultBorderColor:
                                  RouterColors.loginFocusBorder,
                              focusBorderColor: RouterColors.tertiary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'PASSWORD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: RouterColors.outline,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Password tidak boleh kosong'
                                : null,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: RouterColors.onSurface,
                            ),
                            decoration: _fieldDecoration(
                              defaultBorderColor: RouterColors.outlineVariant,
                              focusBorderColor: RouterColors.loginFocusBorder,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 18,
                                  color: RouterColors.outline,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RouterColors.loginAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              icon: const Icon(Icons.login, size: 18),
                              label: const Text('LOGIN'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 14,
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Secured with TLS 1.3 · AES-256 Vault',
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required Color defaultBorderColor,
    required Color focusBorderColor,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: RouterColors.surface,
      errorStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: RouterColors.error,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: defaultBorderColor, width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: focusBorderColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: RouterColors.error, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: RouterColors.error, width: 1.6),
      ),
    );
  }
}
