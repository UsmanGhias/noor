import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noor_ul_haya/core/providers/prayer_providers.dart';
import 'package:noor_ul_haya/core/services/prayer_location_service.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';
import 'package:noor_ul_haya/core/utils/prayer_utils.dart';

/// Qibla compass screen.
class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(prayerScheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        child: scheduleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Unable to load Qibla')),
          data: (schedule) {
            final qiblaBearing =
                qiblaDirection(schedule.location.coordinates);

            return StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                final heading = snapshot.data?.heading;
                final normalized = normalizeHeading(heading);
                final relative = qiblaRelativeAngle(qiblaBearing, heading);
                final instruction = turnInstruction(qiblaBearing, heading);
                final dialRotation = -normalized * math.pi / 180;
                final isAligned = relative <= 12 || relative >= 348;

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _InfoBadge(
                            icon: Icons.location_on_outlined,
                            label: schedule.location.label,
                          ),
                          const Spacer(),
                          _InfoBadge(
                            icon: Icons.explore_outlined,
                            label: heading == null || heading.isNaN
                                ? 'Calibrating'
                                : '${normalized.round()}°',
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: dialRotation,
                              child: CustomPaint(
                                size: const Size(300, 300),
                                painter: _CompassRosePainter(
                                  qiblaBearing: qiblaBearing,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.navigation,
                              size: 52,
                              color: isAligned
                                  ? AppColors.accentGreen
                                  : AppColors.primary,
                            ),
                            Positioned(
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                  ),
                                ),
                                child: const Text(
                                  'Face this way',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        instruction,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isAligned
                                      ? AppColors.accentGreen
                                      : AppColors.textPrimary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Qibla ${qiblaBearing.toStringAsFixed(0)}° • ${schedule.location.label}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hold phone flat and turn slowly',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accentGreen),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  _CompassRosePainter({required this.qiblaBearing});

  final double qiblaBearing;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.cardBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    const labels = ['N', 'E', 'S', 'W'];
    for (var i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * math.pi / 180;
      final offset = Offset(
        center.dx + (radius - 28) * math.cos(angle),
        center.dy + (radius - 28) * math.sin(angle),
      );
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: labels[i] == 'N' ? 18 : 14,
            color: labels[i] == 'N'
                ? AppColors.accentGreen
                : AppColors.textPrimary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        offset - Offset(painter.width / 2, painter.height / 2),
      );
    }

    final qiblaAngle = (qiblaBearing - 90) * math.pi / 180;
    final qiblaEnd = Offset(
      center.dx + (radius - 36) * math.cos(qiblaAngle),
      center.dy + (radius - 36) * math.sin(qiblaAngle),
    );

    canvas.drawLine(
      center,
      qiblaEnd,
      Paint()
        ..color = AppColors.accentGreen
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      qiblaEnd,
      10,
      Paint()..color = AppColors.accentGreen,
    );
    canvas.drawCircle(
      qiblaEnd,
      5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _CompassRosePainter oldDelegate) {
    return oldDelegate.qiblaBearing != qiblaBearing;
  }
}
