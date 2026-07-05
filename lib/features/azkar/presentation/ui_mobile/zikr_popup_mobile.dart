import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/azkar_timer_provider.dart';

class ZikrPopupMobile extends ConsumerWidget {
  const ZikrPopupMobile({super.key});

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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.star_outline, color: Color(0xFFD4AF37)),
                  Text(
                    loc.azkarReminder,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () {
                      ref
                          .read(activeZikrAlertNotifierProvider.notifier)
                          .dismissAlert();
                    },
                  ),
                ],
              ),
              const Spacer(),

              // Zikr Text Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      zikr.textAr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '🌟 ${loc.tapsToday}: ${zikr.todayTapCount}',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 14,
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.white24,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    Container(
                      width: 140,
                      height: 140,
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
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.tapToCount,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
