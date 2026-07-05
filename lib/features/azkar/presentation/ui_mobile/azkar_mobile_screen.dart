import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/zikr_entity.dart';
import '../controllers/azkar_provider.dart';
import '../controllers/azkar_settings_provider.dart';
import '../controllers/azkar_timer_provider.dart';
import 'zikr_popup_mobile.dart';

class AzkarMobileScreen extends ConsumerWidget {
  const AzkarMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final azkarState = ref.watch(azkarNotifierProvider);
    final settingsState = ref.watch(azkarSettingsNotifierProvider);
    final activeAlert = ref.watch(activeZikrAlertNotifierProvider);
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.azkar),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report, color: Color(0xFFD4AF37)),
              tooltip: loc.testZikrAlert,
              onPressed: () {
                ref
                    .read(activeZikrAlertNotifierProvider.notifier)
                    .triggerAlert();
              },
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            context.go('/');
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddZikrDialog(context, ref, loc),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Stats & Progress Header Banner
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.dailyGoal,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
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
                                Switch(
                                  value: settings.isEnabled,
                                  onChanged: (val) {
                                    ref
                                        .read(
                                            azkarSettingsNotifierProvider.notifier)
                                        .updateSettings(isEnabled: val);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white24,
                              color: theme.colorScheme.primary,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🎯 ${loc.completedToday}: ${settings.completedToday} / ${settings.dailyGoal}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // List of Azkar with Target Edit Button & Today Tap Badge
                azkarState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Text('Error: $err'),
                  data: (azkarList) {
                    return Column(
                      children: azkarList.map((zikr) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primary.withValues(alpha: 0.15),
                              child: Text(
                                '${zikr.defaultTargetCount}x',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              zikr.textAr,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${loc.tapsToday}: ${zikr.todayTapCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                if (zikr.textEn.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      zikr.textEn,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: Color(0xFFD4AF37)),
                                  tooltip: loc.editZikr,
                                  onPressed: () {
                                    _showEditZikrDialog(context, ref, loc, zikr);
                                  },
                                ),
                                if (zikr.isCustom)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      ref
                                          .read(azkarNotifierProvider.notifier)
                                          .deleteZikr(zikr.id);
                                    },
                                  ),
                              ],
                            ),
                            onTap: () {
                              ref
                                  .read(
                                      activeZikrAlertNotifierProvider.notifier)
                                  .triggerAlert(zikr);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          // Fullscreen Interactive Popup Overlay
          if (activeAlert != null) const Positioned.fill(child: ZikrPopupMobile()),
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
