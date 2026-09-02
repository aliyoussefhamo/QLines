import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../data/api_auth_repository.dart';
import '../domain/auth_session.dart';

enum _AuthMode { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.repository,
    required this.onAuthenticated,
    super.key,
  });

  final ApiAuthRepository repository;
  final void Function(BuildContext context, AuthSession session)
  onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  _AuthMode _mode = _AuthMode.login;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  bool get _isRegistering => _mode == _AuthMode.register;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changeMode(_AuthMode mode) {
    if (_mode == mode || _isLoading) return;
    setState(() {
      _mode = mode;
      _error = null;
      _confirmPasswordController.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final session = _isRegistering
          ? await widget.repository.register(
              fullName: _fullNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
            )
          : await widget.repository.login(
              email: _emailController.text,
              password: _passwordController.text,
            );
      if (mounted) widget.onAuthenticated(context, session);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = _messageFor(error));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = _isRegistering
              ? 'تعذر إنشاء الحساب'
              : 'تعذر تسجيل الدخول',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _messageFor(ApiException error) {
    if (error.statusCode == 409) return 'البريد الإلكتروني مسجل مسبقاً';
    if (error.statusCode == 401) {
      return 'البريد الإلكتروني أو كلمة المرور خاطئة';
    }
    return error.message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.queue, size: 72),
                  const SizedBox(height: 16),
                  Text(
                    'QLines',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegistering
                        ? 'أنشئ حسابك وابدأ بحجز دورك'
                        : 'سجّل دخولك لحجز دورك ومتابعته',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<_AuthMode>(
                    segments: const [
                      ButtonSegment(
                        value: _AuthMode.login,
                        label: Text('تسجيل الدخول'),
                        icon: Icon(Icons.login),
                      ),
                      ButtonSegment(
                        value: _AuthMode.register,
                        label: Text('إنشاء حساب'),
                        icon: Icon(Icons.person_add_outlined),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (selection) =>
                        _changeMode(selection.first),
                  ),
                  const SizedBox(height: 24),
                  if (_isRegistering) ...[
                    TextFormField(
                      controller: _fullNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 2
                          ? 'أدخل الاسم الكامل'
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) => value == null || !value.contains('@')
                        ? 'أدخل بريداً إلكترونياً صحيحاً'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: _isRegistering
                        ? TextInputAction.next
                        : TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.length < 8
                        ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'
                        : null,
                    onFieldSubmitted: (_) {
                      if (!_isRegistering) _submit();
                    },
                  ),
                  if (_isRegistering) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? 'كلمتا المرور غير متطابقتين'
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isRegistering
                                ? Icons.person_add_outlined
                                : Icons.login,
                          ),
                    label: Text(
                      _isLoading
                          ? 'يرجى الانتظار...'
                          : _isRegistering
                          ? 'إنشاء الحساب'
                          : 'تسجيل الدخول',
                    ),
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
