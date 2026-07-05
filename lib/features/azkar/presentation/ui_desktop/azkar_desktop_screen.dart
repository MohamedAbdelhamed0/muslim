import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/zikr_entity.dart';
import '../controllers/azkar_provider.dart';
import '../controllers/azkar_settings_provider.dart';
import '../controllers/azkar_timer_provider.dart';
import 'zikr_popup_desktop.dart';

class AzkarDesktopScreen extends ConsumerWidget {
  const AzkarDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final azkarState = ref.watch(azkarNotifierProvider);
    final settingsState = ref.watch(azkarSettingsNotifierProvider);
    final activeAlert = ref.watch(activeZikrAlertNotifierProvider);
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              NavigationRail(
                selectedIndex: 1,
                onDestinationSelected: (index) {
                  if (index == 0) {
                    context.go('/');
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
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.azkarReminder,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              if (kDebugMode) ...[
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.black,
                                  ),
                                  icon: const Icon(Icons.bug_report),
                                  label: Text(loc.testZikrAlert),
                                  onPressed: () {
                                    ref
                                        .read(activeZikrAlertNotifierProvider.notifier)
                                        .triggerAlert();
                                  },
                                ),
                                const SizedBox(width: 12),
                              ],
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: Text(loc.addZikr),
                                onPressed: () => _showAddZikrDialog(context, ref, loc),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Settings & Stats Header Bar
                      settingsState.when(
                        loading: () => const SizedBox.shrink(),
                        error: (e, s) => const SizedBox.shrink(),
                        data: (settings) {
                          final progress = settings.dailyGoal > 0
                              ? (settings.completedToday / settings.dailyGoal)
                                  .clamp(0.0, 1.0)
                              : 0.0;

                          return Card(
                            color: theme.colorScheme.primaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '🎯 ${loc.completedToday}: ${settings.completedToday} / ${settings.dailyGoal}',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '🌟 ${loc.totalTapsToday}: ${settings.totalTapsToday}',
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.white24,
                                          color: theme.colorScheme.primary,
                                          minHeight: 12,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Row(
                                    children: [
                                      Text(
                                        '${loc.intervalMinutes}: ',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      DropdownButton<int>(
                                        value: [5, 10, 15, 30, 60, 120]
                                                .contains(settings.intervalMinutes)
                                            ? settings.intervalMinutes
                                            : 30,
                                        items: [5, 10, 15, 30, 60, 120]
                                            .map((int value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text('$value ${loc.minutes}'),
                                          );
                                        }).toList(),
                                        onChanged: (int? newValue) {
                                          if (newValue != null) {
                                            ref
                                                .read(azkarSettingsNotifierProvider
                                                    .notifier)
                                                .updateSettings(
                                                    intervalMinutes: newValue);
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 24),
                                      Switch(
                                        value: settings.isEnabled,
                                        onChanged: (val) {
                                          ref
                                              .read(azkarSettingsNotifierProvider
                                                  .notifier)
                                              .updateSettings(isEnabled: val);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Azkar Grid Cards with Target Edit Button
                      Expanded(
                        child: azkarState.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, st) => Text('Error: $err'),
                          data: (azkarList) {
                            return GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.8,
                              children: azkarList.map((zikr) {
                                return Card(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      ref
                                          .read(
                                              activeZikrAlertNotifierProvider.notifier)
                                          .triggerAlert(zikr);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: theme.colorScheme.primary
                                                .withValues(alpha: 0.15),
                                            child: Text(
                                              '${zikr.defaultTargetCount}x',
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  zikr.textAr,
                                                  style: theme.textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme
                                                            .surfaceContainerHighest,
                                                        borderRadius:
                                                            BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        '${loc.tapsToday}: ${zikr.todayTapCount}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color:
                                                              theme.colorScheme.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined,
                                                color: Color(0xFFD4AF37)),
                                            tooltip: loc.editZikr,
                                            onPressed: () {
                                              _showEditZikrDialog(
                                                  context, ref, loc, zikr);
                                            },
                                          ),
                                          if (zikr.isCustom)
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline,
                                                  color: Colors.redAccent),
                                              onPressed: () {
                                                ref
                                                    .read(
                                                        azkarNotifierProvider.notifier)
                                                    .deleteZikr(zikr.id);
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Fullscreen Interactive Popup Overlay
          if (activeAlert != null) const Positioned.fill(child: ZikrPopupDesktop()),
        ],
      ),
    );
  }

  void _showAddZikrDialog(
      BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final textController = TextEditingController();
    final countController = TextEditingController(text: '3');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.addZikr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: loc.zikrText,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.targetCount,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final text = textController.text.trim();
                final count = int.tryParse(countController.text) ?? 3;
                if (text.isNotEmpty) {
                  ref
                      .read(azkarNotifierProvider.notifier)
                      .addZikr(textAr: text, defaultTargetCount: count);
                  Navigator.pop(context);
                }
              },
              child: Text(loc.save),
            ),
          ],
        );
      },
    );
  }

  void _showEditZikrDialog(
      BuildContext context, WidgetRef ref, AppLocalizations loc, ZikrEntity zikr) {
    final textController = TextEditingController(text: zikr.textAr);
    final countController =
        TextEditingController(text: zikr.defaultTargetCount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.editZikr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: loc.zikrText,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.targetCount,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final text = textController.text.trim();
                final count = int.tryParse(countController.text) ?? 3;
                if (text.isNotEmpty) {
                  final updated = zikr.copyWith(
                    textAr: text,
                    defaultTargetCount: count,
                  );
                  ref
                      .read(azkarNotifierProvider.notifier)
                      .updateZikr(updated);
                  Navigator.pop(context);
                }
              },
              child: Text(loc.save),
            ),
          ],
        );
      },
    );
  }
}
