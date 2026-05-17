import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../data/providers.dart';
import 'widgets/upgrade_card.dart';

enum _UpgradeFilter { all, active, archived }

class UpgradesScreen extends ConsumerStatefulWidget {
  const UpgradesScreen({super.key});

  @override
  ConsumerState<UpgradesScreen> createState() => _UpgradesScreenState();
}

class _UpgradesScreenState extends ConsumerState<UpgradesScreen> with AutomaticKeepAliveClientMixin {
  _UpgradeFilter _filter = _UpgradeFilter.active;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final upgradesAsync = ref.watch(upgradesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrades'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/upgrades/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.newUpgrade),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _UpgradeFilter.values.map((f) {
                final label = switch (f) {
                  _UpgradeFilter.all => 'All',
                  _UpgradeFilter.active => 'Active',
                  _UpgradeFilter.archived => 'Archived',
                };
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: AsyncValueWidget(
              value: upgradesAsync,
              data: (upgrades) {
                final filtered = switch (_filter) {
                  _UpgradeFilter.all => upgrades,
                  _UpgradeFilter.active => upgrades.where((u) => !u.archived).toList(),
                  _UpgradeFilter.archived => upgrades.where((u) => u.archived).toList(),
                };

                final visible = filtered..sort((a, b) {
                  const order = {'active': 0, 'completed': 1, 'failed': 2};
                  final cmp = (order[a.status] ?? 3).compareTo(order[b.status] ?? 3);
                  if (cmp != 0) return cmp;
                  return b.createdAt.compareTo(a.createdAt);
                });

                if (visible.isEmpty) {
                  final (icon, title, subtitle) = switch (_filter) {
                    _UpgradeFilter.all => (null, AppStrings.noUpgradesTitle, AppStrings.noUpgradesSubtitle),
                    _UpgradeFilter.active => (Icons.rocket_launch_rounded, 'No active upgrades', 'You don\'t have any active upgrades right now.'),
                    _UpgradeFilter.archived => (Icons.archive_outlined, 'No archived upgrades', 'Your archived upgrades will appear here.'),
                  };
                  return AppEmptyState(
                    useAppLogo: icon == null,
                    icon: icon,
                    title: title,
                    subtitle: subtitle,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final upgrade = visible[index];
                    final score = ref.watch(liveUpgradeScoreProvider(upgrade.id));
                    final memberships = ref.watch(upgradeHabitsForUpgradeProvider(upgrade.id));
                    final activeCount = memberships.where((m) => m.leftDate == null).length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: UpgradeCard(
                        upgrade: upgrade,
                        habitCount: activeCount,
                        liveScore: score,
                        onTap: () => context.go('/upgrades/${upgrade.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
