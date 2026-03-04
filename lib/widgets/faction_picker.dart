import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class FactionPicker extends StatelessWidget {
  final String myFaction;
  final String enemyFaction;
  final Function(String, String) onFactionChanged;

  const FactionPicker({
    super.key,
    required this.myFaction,
    required this.enemyFaction,
    required this.onFactionChanged,
  });

  static const factions = [
    {'key': 'P', 'name': '神族', 'color': AppTheme.sc2Gold},
    {'key': 'T', 'name': '人族', 'color': AppTheme.sc2Terran},
    {'key': 'Z', 'name': '虫族', 'color': AppTheme.sc2Zerg},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sc2BgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.sc2AccentSecondary, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 300) {
            // 小屏幕：垂直布局
            return Column(
              children: [
                _buildFactionSelector('我方', myFaction, true),
                const SizedBox(height: 16),
                Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.sc2AccentPrimary,
                    shadows: [
                      Shadow(
                        color: AppTheme.sc2AccentPrimary.withOpacity(0.6),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildFactionSelector('敌方', enemyFaction, false),
              ],
            );
          } else {
            // 大屏幕：水平布局
            return Row(
              children: [
                Expanded(child: _buildFactionSelector('我方', myFaction, true)),
                const SizedBox(width: 20),
                Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.sc2AccentPrimary,
                    shadows: [
                      Shadow(
                        color: AppTheme.sc2AccentPrimary.withOpacity(0.6),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(child: _buildFactionSelector('敌方', enemyFaction, false)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildFactionSelector(String label, String currentFaction, bool isMyFaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.uniTextColorGrey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          width: 100,
          decoration: BoxDecoration(
            color: AppTheme.sc2BgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.sc2AccentSecondary, width: 2),
          ),
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: factions.length,
            controller: PageController(
              initialPage: factions.indexWhere((f) => f['key'] == currentFaction),
              viewportFraction: 0.6,
            ),
            onPageChanged: (index) {
              final faction = factions[index];
              if (isMyFaction) {
                onFactionChanged(faction['key'] as String, enemyFaction);
              } else {
                onFactionChanged(myFaction, faction['key'] as String);
              }
            },
            itemBuilder: (context, index) {
              final faction = factions[index];
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      faction['key'] as String,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: faction['color'] as Color,
                        shadows: [
                          Shadow(
                            color: (faction['color'] as Color).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      faction['name'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.uniTextColorGrey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
