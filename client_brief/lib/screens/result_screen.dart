import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/brief_analysis.dart';
import '../providers/brief_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/requirement_card.dart';
import '../widgets/section_header.dart';
import '../widgets/ticket_card.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<BriefProvider>().analysis;

    if (analysis == null) {
      return const Scaffold(
        body: Center(child: Text(AppConstants.noResults)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.resultsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppConstants.tooltipAnalyzeAgain,
            onPressed: () {
              context.read<BriefProvider>().reset();
              Navigator.pop(context);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: [
              const Tab(text: AppConstants.tabSummary),
              Tab(text: '${AppConstants.tabRequirements}  ${analysis.requirements.length}'),
              Tab(text: '${AppConstants.tabTickets}  ${analysis.tickets.length}'),
              Tab(text: '${AppConstants.tabClarifications}  ${analysis.clarifications.length}'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SummaryTab(analysis: analysis),
          _RequirementsTab(analysis: analysis),
          _TicketsTab(analysis: analysis),
          _ClarificationsTab(analysis: analysis),
        ],
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final BriefAnalysis analysis;

  const _SummaryTab({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: AppConstants.summaryTitle,
            subtitle: AppConstants.summarySubtitle,
            icon: Icons.summarize_outlined,
            accentColor: AppTheme.summaryAccent,
            accentBgColor: AppTheme.summaryAccentBg,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              analysis.summary,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _StatsRow(analysis: analysis),
          const SizedBox(height: 24),
          _CategoryBreakdown(requirements: analysis.requirements),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final BriefAnalysis analysis;

  const _StatsRow({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          value: '${analysis.requirements.length}',
          label: AppConstants.statRequirements,
          color: AppTheme.requirementAccent,
          bgColor: AppTheme.requirementAccentBg,
          icon: Icons.checklist_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: '${analysis.tickets.length}',
          label: AppConstants.statTickets,
          color: AppTheme.ticketAccent,
          bgColor: AppTheme.ticketAccentBg,
          icon: Icons.confirmation_number_outlined,
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: '${analysis.clarifications.length}',
          label: AppConstants.statClarifications,
          color: AppTheme.clarificationAccent,
          bgColor: AppTheme.clarificationAccentBg,
          icon: Icons.help_outline_rounded,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<Requirement> requirements;

  const _CategoryBreakdown({required this.requirements});

  Map<String, int> get _categoryCounts {
    final counts = <String, int>{};
    for (final req in requirements) {
      counts[req.category] = (counts[req.category] ?? 0) + 1;
    }
    return Map.fromEntries(
      counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoryCounts;
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppConstants.categoriesLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.requirementAccentBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.requirementAccent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RequirementsTab extends StatelessWidget {
  final BriefAnalysis analysis;

  const _RequirementsTab({required this.analysis});

  @override
  Widget build(BuildContext context) {
    if (analysis.requirements.isEmpty) {
      return const _EmptyState(
        icon: Icons.checklist_rounded,
        message: AppConstants.emptyRequirements,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionHeader(
          title: AppConstants.requirementsTitle,
          subtitle: AppConstants.requirementsSubtitle,
          icon: Icons.checklist_rounded,
          accentColor: AppTheme.requirementAccent,
          accentBgColor: AppTheme.requirementAccentBg,
          count: analysis.requirements.length,
        ),
        const SizedBox(height: 16),
        ...analysis.requirements.map(
          (req) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RequirementCard(requirement: req),
          ),
        ),
      ],
    );
  }
}

class _TicketsTab extends StatelessWidget {
  final BriefAnalysis analysis;

  const _TicketsTab({required this.analysis});

  @override
  Widget build(BuildContext context) {
    if (analysis.tickets.isEmpty) {
      return const _EmptyState(
        icon: Icons.confirmation_number_outlined,
        message: AppConstants.emptyTickets,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionHeader(
          title: AppConstants.ticketsTitle,
          subtitle: AppConstants.ticketsSubtitle,
          icon: Icons.confirmation_number_outlined,
          accentColor: AppTheme.ticketAccent,
          accentBgColor: AppTheme.ticketAccentBg,
          count: analysis.tickets.length,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.touch_app_outlined, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              const Text(
                AppConstants.ticketsHint,
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _copyAll(context, analysis.tickets),
                child: const Row(
                  children: [
                    Icon(Icons.copy_outlined, size: 13, color: AppTheme.primary),
                    SizedBox(width: 4),
                    Text(
                      AppConstants.ticketsCopyAll,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...analysis.tickets.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TicketCard(ticket: entry.value, index: entry.key),
          ),
        ),
      ],
    );
  }

  void _copyAll(BuildContext context, List<DeveloperTicket> tickets) {
    final buffer = StringBuffer();
    for (final ticket in tickets) {
      buffer.writeln('## ${ticket.id}: ${ticket.title}');
      buffer.writeln('**Priority:** ${ticket.priority}');
      buffer.writeln('**Category:** ${ticket.category}');
      buffer.writeln();
      buffer.writeln('**Description:**');
      buffer.writeln(ticket.description);
      buffer.writeln();
      if (ticket.acceptanceCriteria.isNotEmpty) {
        buffer.writeln('**Acceptance Criteria:**');
        for (final c in ticket.acceptanceCriteria) {
          buffer.writeln('- $c');
        }
      }
      buffer.writeln('---');
      buffer.writeln();
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tickets.length} ${AppConstants.ticketsCopied}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ClarificationsTab extends StatelessWidget {
  final BriefAnalysis analysis;

  const _ClarificationsTab({required this.analysis});

  @override
  Widget build(BuildContext context) {
    if (analysis.clarifications.isEmpty) {
      return const _EmptyState(
        icon: Icons.check_circle_outline_rounded,
        message: AppConstants.emptyClarifications,
        isPositive: true,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionHeader(
          title: AppConstants.clarificationsTitle,
          subtitle: AppConstants.clarificationsSubtitle,
          icon: Icons.help_outline_rounded,
          accentColor: AppTheme.clarificationAccent,
          accentBgColor: AppTheme.clarificationAccentBg,
          count: analysis.clarifications.length,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.clarificationAccentBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.clarificationAccent.withValues(alpha: 0.25),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 15, color: AppTheme.clarificationAccent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppConstants.clarificationsInfo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.clarificationAccent,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...analysis.clarifications.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ClarificationItem(index: entry.key + 1, text: entry.value),
          ),
        ),
      ],
    );
  }
}

class _ClarificationItem extends StatelessWidget {
  final int index;
  final String text;

  const _ClarificationItem({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppTheme.clarificationAccentBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.clarificationAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.clarificationAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isPositive;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppTheme.summaryAccent : AppTheme.textMuted;
    final bgColor = isPositive ? AppTheme.summaryAccentBg : AppTheme.border;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
