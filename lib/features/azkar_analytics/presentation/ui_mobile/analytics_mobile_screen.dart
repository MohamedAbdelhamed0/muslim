import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../controllers/analytics_provider.dart';
import '../widgets/analytics_chart_widget.dart';

class AnalyticsMobileScreen extends ConsumerWidget {
  const AnalyticsMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsNotifierProvider);
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.analytics),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(analyticsNotifierProvider.notifier).loadSummary();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 1) {
            context.go('/azkar');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.mosque),
            label: loc.appTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: loc.azkar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: loc.analytics,
          ),
        ],
      ),
      body: SafeArea(
        child: analyticsState.summary.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error: $err')),
          data: (summary) {
            final periodData = AnalyticsDataMapper.getPeriodData(
              analyticsState.period,
              summary.logs,
            );

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Period Selector (Day, Week, Month, Year)
                SegmentedButton<AnalyticsPeriod>(
                  segments: [
                    ButtonSegment(
                      value: AnalyticsPeriod.day,
                      label: Text(loc.day),
                    ),
                    ButtonSegment(
                      value: AnalyticsPeriod.week,
                      label: Text(loc.week),
                    ),
                    ButtonSegment(
                      value: AnalyticsPeriod.month,
                      label: Text(loc.month),
                    ),
                    ButtonSegment(
                      value: AnalyticsPeriod.year,
                      label: Text(loc.year),
                    ),
                  ],
                  selected: {analyticsState.period},
                  onSelectionChanged: (Set<AnalyticsPeriod> selection) {
                    ref
                        .read(analyticsNotifierProvider.notifier)
                        .setPeriod(selection.first);
                  },
                ),
                const SizedBox(height: 16),

                // Top Metric Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildMetricCard(
                      context,
                      title: loc.totalTapsAllTime,
                      value: '${summary.totalTapsAllTime}',
                      icon: Icons.touch_app,
                      color: const Color(0xFFD4AF37),
                    ),
                    _buildMetricCard(
                      context,
                      title: loc.totalSessions,
                      value: '${summary.totalSessionsAllTime}',
                      icon: Icons.task_alt,
                      color: theme.colorScheme.primary,
                    ),
                    _buildMetricCard(
                      context,
                      title: loc.activeStreak,
                      value: '${summary.currentStreakDays} ${loc.days}',
                      icon: Icons.local_fire_department,
                      color: Colors.orangeAccent,
                    ),
                    _buildMetricCard(
                      context,
                      title: loc.mostRecited,
                      value: summary.topZikrName,
                      icon: Icons.star,
                      color: Colors.amber,
                      isSmallText: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Real Data Chart Widget
                AnalyticsChartWidget(
                  title: '${loc.tasbeehProgress} (${_getPeriodLabel(analyticsState.period, loc)})',
                  data: periodData,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isSmallText = false,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: isSmallText
                  ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    )
                  : theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodLabel(AnalyticsPeriod period, AppLocalizations loc) {
    switch (period) {
      case AnalyticsPeriod.day:
        return loc.day;
      case AnalyticsPeriod.week:
        return loc.week;
      case AnalyticsPeriod.month:
        return loc.month;
      case AnalyticsPeriod.year:
        return loc.year;
    }
  }
}
