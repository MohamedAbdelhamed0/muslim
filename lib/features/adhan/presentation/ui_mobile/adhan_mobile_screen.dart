import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/adhan_provider.dart';
import '../controllers/adhan_timer_provider.dart';

class AdhanMobileScreen extends ConsumerWidget {
  const AdhanMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhanState = ref.watch(adhanNotifierProvider);
    final nextPrayer = ref.watch(adhanTimerNotifierProvider);
    final currentTimeAsync = ref.watch(currentTimeStreamProvider);
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: loc.refresh,
            onPressed: () {
              ref.read(adhanNotifierProvider.notifier).fetchPrayerTimes();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: adhanState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(loc.errorLoading, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(err.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(adhanNotifierProvider.notifier).fetchPrayerTimes();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.retry),
                  ),
                ],
              ),
            ),
          ),
          data: (prayerTimes) {
            final currentTime = currentTimeAsync.value ?? DateTime.now();
            final formattedClock = DateFormat('hh:mm:ss a').format(currentTime);

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(adhanNotifierProvider.notifier).fetchPrayerTimes();
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Location & Current Time Banner
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 18, color: theme.colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${prayerTimes.city}, ${prayerTimes.country}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prayerTimes.dateReadable,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Text(
                            formattedClock,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hero Next Prayer Countdown Card
                  if (nextPrayer != null) ...[
                    Card(
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              loc.nextPrayer.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nextPrayer.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              nextPrayer.formattedRemaining,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${loc.timeRemaining} (${DateFormat('hh:mm a').format(nextPrayer.time)})',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Text(
                    loc.todayTimings,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Daily Prayer Times Stack List
                  ...prayerTimes.toMap().entries.map((entry) {
                    final isNext = nextPrayer?.name == entry.key;
                    final formattedTime = DateFormat('hh:mm a').format(entry.value);

                    return Card(
                      color: isNext
                          ? theme.colorScheme.secondaryContainer
                          : theme.cardTheme.color,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isNext
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(
                            _getPrayerIcon(entry.key),
                            color: isNext ? Colors.white : theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                            color: isNext ? theme.colorScheme.primary : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'sunrise':
        return Icons.wb_sunny_outlined;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.sunny_snowing;
      case 'maghrib':
        return Icons.nights_stay_outlined;
      case 'isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}
