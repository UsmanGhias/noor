import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noor_ul_haya/core/theme/app_colors.dart';

/// Digital tasbih counter.
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _count = 0;
  int _target = 33;
  String _dhikr = 'SubhanAllah';

  static const _phrases = [
  'SubhanAllah',
  'Alhamdulillah',
  'Allahu Akbar',
  'La ilaha illallah',
  ];

  void _tap() {
    setState(() => _count++);
    HapticFeedback.lightImpact();
    if (_count % _target == 0) {
      HapticFeedback.mediumImpact();
    }
  }

  void _reset() {
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    final round = _count == 0 ? 0 : ((_count - 1) ~/ _target) + 1;
    final inRound = _count == 0 ? 0 : ((_count - 1) % _target) + 1;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text('Tasbih'),
        actions: [
          IconButton(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: _phrases.map((phrase) {
                final selected = phrase == _dhikr;
                return ChoiceChip(
                  label: Text(phrase),
                  selected: selected,
                  onSelected: (_) => setState(() => _dhikr = phrase),
                );
              }).toList(),
            ),
            const Spacer(),
            Text(
              _dhikr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentGreen,
                  ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _tap,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.accentGreen,
                    width: 4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_count',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$inRound / $_target',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Round $round'),
            const Spacer(),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 33, label: Text('33')),
                ButtonSegment(value: 99, label: Text('99')),
                ButtonSegment(value: 100, label: Text('100')),
              ],
              selected: {_target},
              onSelectionChanged: (value) {
                setState(() => _target = value.first);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap the circle to count',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
