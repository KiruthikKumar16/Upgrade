import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../domain/entities/upgrade_group.dart';

class UpgradeCard extends StatelessWidget {
  final UpgradeGroup upgrade;
  final int habitCount;
  final double liveScore;
  final VoidCallback onTap;

  const UpgradeCard({
    super.key,
    required this.upgrade,
    required this.habitCount,
    required this.liveScore,
    required this.onTap,
  });

  Color get _statusColor {
    switch (upgrade.status) {
      case 'completed':
        return AppColors.green;
      case 'failed':
        return AppColors.red;
      default:
        return AppColors.blue;
    }
  }

  String get _statusLabel {
    switch (upgrade.status) {
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return 'Active';
    }
  }

  @override
  Widget build(BuildContext context) {
    final upgradeColor = Color(upgrade.color);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final displayScore =
        upgrade.status != 'active' && upgrade.completionScore != null
            ? upgrade.completionScore!
            : liveScore;

    return CardShell(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: upgradeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: upgradeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            IconData(upgrade.iconCodePoint, fontFamily: 'MaterialIcons'),
                            color: upgradeColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      upgrade.name,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _StatusBadge(label: _statusLabel, color: _statusColor),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _IconInfo(
                                    icon: Icons.check_circle_outline_rounded,
                                    label: '$habitCount habits',
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                  const SizedBox(width: 12),
                                  _IconInfo(
                                    icon: Icons.analytics_outlined,
                                    label: '${(displayScore * 100).toStringAsFixed(0)}%',
                                    color: _statusColor,
                                  ),
                                  const SizedBox(width: 12),
                                  _IconInfo(
                                    icon: Icons.calendar_today_rounded,
                                    label: '${upgrade.startDate.month}/${upgrade.startDate.day} - ${upgrade.endDate.month}/${upgrade.endDate.day}',
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FlatProgressBar(
                      score: displayScore,
                      cutoff: upgrade.cutoffPercentage,
                      color: upgradeColor,
                      trackColor: trackColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlatProgressBar extends StatelessWidget {
  final double score;
  final double cutoff;
  final Color color;
  final Color trackColor;

  const _FlatProgressBar({
    required this.score,
    required this.cutoff,
    required this.color,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: score.clamp(0.0, 1.0),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IconInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _IconInfo({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
      ),
    );
  }
}


