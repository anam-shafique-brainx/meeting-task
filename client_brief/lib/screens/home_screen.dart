import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/brief_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/api_key_dialog.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _briefController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _loadedFileName;

  @override
  void dispose() {
    _briefController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md', 'txt'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      final content = String.fromCharCodes(result.files.single.bytes!);
      setState(() {
        _briefController.text = content;
        _loadedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _analyze() async {
    if (_briefController.text.trim().isEmpty) {
      _showError(AppConstants.errBriefRequired);
      return;
    }

    final provider = context.read<BriefProvider>();

    if (!provider.hasApiKey) {
      await showDialog(context: context, builder: (_) => const ApiKeyDialog());
      if (!mounted) return;
      if (!context.read<BriefProvider>().hasApiKey) return;
    }

    await provider.analyzeBrief(_briefController.text);

    if (!mounted) return;

    if (provider.state == AnalysisState.success) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
    } else if (provider.state == AnalysisState.error) {
      _showError(provider.errorMessage);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.priorityHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearContent() {
    setState(() {
      _briefController.clear();
      _loadedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<BriefProvider>().state == AnalysisState.loading;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text(AppConstants.appTitle),
          ],
        ),
        actions: [
          Selector<BriefProvider, bool>(
            selector: (_, p) => p.hasApiKey,
            builder: (_, hasKey, __) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  hasKey ? Icons.key_rounded : Icons.key_off_rounded,
                  color: hasKey ? AppTheme.priorityLow : AppTheme.priorityHigh,
                ),
                tooltip: hasKey
                    ? AppConstants.tooltipApiKeySet
                    : AppConstants.tooltipApiKeyMissing,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const ApiKeyDialog(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeroHeader(),
                  const SizedBox(height: 24),
                  _InputCard(
                    controller: _briefController,
                    focusNode: _focusNode,
                    loadedFileName: _loadedFileName,
                    onPickFile: _pickFile,
                    onClear: _clearContent,
                  ),
                  const SizedBox(height: 16),
                  _ExampleBanner(controller: _briefController),
                ],
              ),
            ),
          ),
          _AnalyzeButton(isLoading: isLoading, onPressed: _analyze),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.homeHeadline,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            height: 1.25,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          AppConstants.homeSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? loadedFileName;
  final VoidCallback onPickFile;
  final VoidCallback onClear;

  const _InputCard({
    required this.controller,
    required this.focusNode,
    required this.loadedFileName,
    required this.onPickFile,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 16, color: AppTheme.textMuted),
                const SizedBox(width: 8),
                const Text(
                  AppConstants.inputCardLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (loadedFileName != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      loadedFileName!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          TextField(
            controller: controller,
            focusNode: focusNode,
            minLines: 12,
            maxLines: 20,
            decoration: const InputDecoration(
              hintText: AppConstants.inputHintText,
              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.7),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              filled: false,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.6,
              fontFamily: 'monospace',
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onPickFile,
                  icon: const Icon(Icons.upload_file_outlined, size: 15),
                  label: const Text(AppConstants.loadFileButton),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (_, value, __) {
                    final count = value.text.trim().isEmpty
                        ? 0
                        : value.text.trim().split(RegExp(r'\s+')).length;
                    return Text(
                      '$count ${AppConstants.wordCountSuffix}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleBanner extends StatelessWidget {
  final TextEditingController controller;

  const _ExampleBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.primary, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              AppConstants.exampleBannerText,
              style: TextStyle(fontSize: 13, color: AppTheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => controller.text = AppConstants.exampleBrief,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              AppConstants.useExampleButton,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _AnalyzeButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        border: const Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
          ),
          child: isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text(AppConstants.analyzingButton, style: TextStyle(fontSize: 15)),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 18),
                    SizedBox(width: 8),
                    Text(AppConstants.analyzeButton, style: TextStyle(fontSize: 15)),
                  ],
                ),
        ),
      ),
    );
  }
}
