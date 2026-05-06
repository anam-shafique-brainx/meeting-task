import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/brief_provider.dart';
import '../theme/app_theme.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  late TextEditingController _controller;
  bool _obscured = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<BriefProvider>().apiKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<BriefProvider>().saveApiKey(_controller.text);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.key_rounded, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  AppConstants.apiKeyDialogTitle,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              AppConstants.apiKeyDialogBody,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              obscureText: _obscured,
              decoration: InputDecoration(
                hintText: AppConstants.apiKeyHint,
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                ),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppConstants.apiKeyGetSnackbar),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
              child: const Text(
                AppConstants.apiKeyGetLink,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(AppConstants.dialogCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(AppConstants.dialogSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
