import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../data/api_profile_repository.dart';
import '../domain/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.repository,
    required this.onProfileUpdated,
    required this.onLogout,
    super.key,
  });

  final ApiProfileRepository repository;
  final Future<void> Function(UserProfile profile) onProfileUpdated;
  final Future<void> Function() onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await widget.repository.getProfile();
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر تحميل بيانات الحساب');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _profile!.fullName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الاسم'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'الاسم الكامل'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.length < 2 || name == _profile!.fullName) return;

    try {
      final updated = await widget.repository.updateFullName(name);
      await widget.onProfileUpdated(updated);
      if (mounted) {
        setState(() => _profile = updated);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تم تحديث الاسم')));
      }
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    }
  }

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final values = await showDialog<List<String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, [
              currentController.text,
              newController.text,
              confirmController.text,
            ]),
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    if (values == null) return;
    if (values[1].length < 8) {
      _showError('كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل');
      return;
    }
    if (values[1] != values[2]) {
      _showError('كلمتا المرور غير متطابقتين');
      return;
    }
    try {
      await widget.repository.changePassword(
        currentPassword: values[0],
        newPassword: values[1],
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم تغيير كلمة المرور')));
      }
    } on ApiException catch (error) {
      if (mounted) {
        _showError(
          error.statusCode == 403
              ? 'كلمة المرور الحالية غير صحيحة'
              : error.message,
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: FilledButton(
                onPressed: _load,
                child: const Text('إعادة المحاولة'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const CircleAvatar(
                  radius: 44,
                  child: Icon(Icons.person_outline, size: 48),
                ),
                const SizedBox(height: 18),
                Text(
                  _profile!.fullName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(_profile!.email, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_outlined),
                        title: const Text('تعديل الاسم'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: _editName,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_reset_outlined),
                        title: const Text('تغيير كلمة المرور'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: _changePassword,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await widget.onLogout();
                    navigator.popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                ),
              ],
            ),
    );
  }
}
