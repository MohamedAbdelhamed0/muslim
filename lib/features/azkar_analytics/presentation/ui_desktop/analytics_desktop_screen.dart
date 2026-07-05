import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../controllers/analytics_provider.dart';
import '../widgets/analytics_chart_widget.dart';

class AnalyticsDesktopScreen extends ConsumerWidget {
  const AnalyticsDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsNotifierProvider);
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 2,
            onDestinationSelected: (index) {
              if (index == 0) {
                context.go('/');
              } else if (index == 1) {
                context.go('/azkar');
              }
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Icon(Icons.mosque, size: 40, color: theme.colorScheme.primary),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: Text(loc.desktopDashboard),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.auto_awesome_outlined),
                selectedIcon: const Icon(Icons.auto_awesome),
                label: Text(loc.azkar),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: Text(loc.analytics),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: analyticsState.summary.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
              data: (summary) {
                final periodData = AnalyticsDataMapper.getPeriodData(
                  analyticsState.period,
                  summary.logs,
                );

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Desktop Header Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                loc.analytics,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.refresh),
                                tooltip: loc.refresh,
                                onPressed: () {
                                  ref
                                      .read(analyticsNotifierProvider.notifier)
                                      .loadSummary();
                                },
                              ),
                            ],
                          ),
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
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Desktop Metric Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              title: loc.totalTapsAllTime,
                              value: '${summary.totalTapsAllTime}',
                              icon: Icons.touch_app,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              title: loc.totalSessions,
                              value: '${summary.totalSessionsAllTime}',
                              icon: Icons.task_alt,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              title: loc.activeStreak,
                              value: '${summary.currentStreakDays} ${loc.days}',
                              icon: Icons.local_fire_department,
                              color: Colors.orangeAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              title: loc.mostRecited,
                              value: summary.topZikrName,
                              icon: Icons.star,
                              color: Colors.amber,
                              isSmallText: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Wide Desktop Chart Widget
                      Expanded(
                        child: AnalyticsChartWidget(
                          title: '${loc.tasbeehProgress} (${_getPeriodLabel(analyticsState.period, loc)})',
                          data: periodData,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: isSmallText
                  ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    )
                  : theme.textTheme.headlineMedium?.copyWith(
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
