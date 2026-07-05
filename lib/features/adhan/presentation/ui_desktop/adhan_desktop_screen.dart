import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/adhan_provider.dart';
import '../controllers/adhan_timer_provider.dart';

class AdhanDesktopScreen extends ConsumerStatefulWidget {
  const AdhanDesktopScreen({super.key});

  @override
  ConsumerState<AdhanDesktopScreen> createState() => _AdhanDesktopScreenState();
}

class _AdhanDesktopScreenState extends ConsumerState<AdhanDesktopScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adhanState = ref.watch(adhanNotifierProvider);
    final nextPrayer = ref.watch(adhanTimerNotifierProvider);
    final activeAlert = ref.watch(activeAdhanAlertNotifierProvider);
    final currentTimeAsync = ref.watch(currentTimeStreamProvider);
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar Navigation Rail
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
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
                ],
              ),

              const VerticalDivider(thickness: 1, width: 1),

              // Main Desktop Content Dashboard
              Expanded(
                child: adhanState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(loc.errorLoading, style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text(err.toString()),
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
                  data: (prayerTimes) {
                    final currentTime = currentTimeAsync.value ?? DateTime.now();
                    final formattedClock = DateFormat('hh:mm:ss a').format(currentTime);

                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Desktop Header Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.desktopDashboard,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${prayerTimes.city}, ${prayerTimes.country} (${prayerTimes.dateReadable})',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
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
                                      label: const Text('Test Adhan Alert'),
                                      onPressed: () {
                                        ref
                                            .read(activeAdhanAlertNotifierProvider.notifier)
                                            .triggerAlert('Fajr (Test)', DateTime.now());
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      formattedClock,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton.filledTonal(
                                    icon: const Icon(Icons.refresh),
                                    tooltip: loc.refresh,
                                    onPressed: () {
                                      ref
                                          .read(adhanNotifierProvider.notifier)
                                          .fetchPrayerTimes();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Next Prayer Hero Banner
                          if (nextPrayer != null) ...[
                            Card(
                              elevation: 4,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(32.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            loc.nextPrayer.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              letterSpacing: 2.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            nextPrayer.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 42,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'At ${DateFormat('hh:mm a').format(nextPrayer.time)}',
                                            style: const TextStyle(
                                                color: Colors.white70, fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          nextPrayer.formattedRemaining,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 48,
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          loc.timeRemaining,
                                          style: const TextStyle(
                                              color: Colors.white70, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),
                          Text(
                            loc.todayTimings,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Desktop Grid Cards Layout for 6 Prayer Times
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.2,
                              children: prayerTimes.toMap().entries.map((entry) {
                                final isNext = nextPrayer?.name == entry.key;
                                final formattedTime =
                                    DateFormat('hh:mm a').format(entry.value);

                                return Card(
                                  elevation: isNext ? 6 : 2,
                                  color: isNext
                                      ? theme.colorScheme.secondaryContainer
                                      : theme.cardTheme.color,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor: isNext
                                              ? theme.colorScheme.secondary
                                              : theme.colorScheme.primary
                                                  .withValues(alpha: 0.15),
                                          child: Icon(
                                            _getPrayerIcon(entry.key),
                                            size: 28,
                                            color: isNext
                                                ? Colors.white
                                                : theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                entry.key,
                                                style: theme.textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: isNext
                                                      ? FontWeight.bold
                                                      : FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                formattedTime,
                                                style: theme.textTheme.titleLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isNext
                                                      ? theme.colorScheme.primary
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
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

          // 5-MINUTE FULLSCREEN ADHAN ALERT OVERLAY
          if (activeAlert != null)
            Positioned.fill(
              child: Container(
                color: const Color(0xFA0F5132), // High opacity Islamic Emerald
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.volume_up_rounded,
                      size: 100,
                      color: Color(0xFFD4AF37), // Gold accent
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'حان الآن موعد أذان صلاة ${activeAlert.prayerName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'It is now time for ${activeAlert.prayerName} prayer',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                      ),
                      child: Text(
                        'Full screen auto-minimize in: ${_formatSeconds(activeAlert.remainingAlertSeconds)}',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 22,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        ref
                            .read(activeAdhanAlertNotifierProvider.notifier)
                            .dismissAlert();
                      },
                      icon: const Icon(Icons.stop_circle_outlined, size: 28),
                      label: const Text(
                        'Stop Sound & Minimize App',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
