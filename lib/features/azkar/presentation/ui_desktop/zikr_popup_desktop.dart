import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/azkar_timer_provider.dart';

class ZikrPopupDesktop extends ConsumerWidget {
  const ZikrPopupDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAlert = ref.watch(activeZikrAlertNotifierProvider);
    if (activeAlert == null) return const SizedBox.shrink();

    final zikr = activeAlert.zikr;
    final current = activeAlert.currentTapCount;
    final target = zikr.defaultTargetCount;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final loc = AppLocalizations.of(context);

    return Material(
      color: const Color(0xFA0F5132), // Emerald dark background
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Color(0xFFD4AF37), size: 32),
                  const SizedBox(width: 12),
                  Text(
                    loc.azkarReminder,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Zikr Text Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      zikr.textAr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '🌟 ${loc.tapsToday}: ${zikr.todayTapCount}',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Interactive Counter Button with Progress Ring
              GestureDetector(
                onTap: () {
                  ref
                      .read(activeZikrAlertNotifierProvider.notifier)
                      .incrementTap();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Colors.white24,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                      Container(
                        width: 176,
                        height: 176,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFD4AF37),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$current / $target',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              loc.tapToCount,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              TextButton.icon(
                onPressed: () {
                  ref
                      .read(activeZikrAlertNotifierProvider.notifier)
                      .dismissAlert();
                },
                icon: const Icon(Icons.close, color: Colors.white70),
                label: Text(
                  loc.cancel,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
