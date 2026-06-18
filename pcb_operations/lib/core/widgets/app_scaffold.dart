import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';

class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
    this.actions,
    this.leading,
    this.showBack = false,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        leading: leading ??
            (showBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null),
        bottom: bottom,
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final double? trend;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (color ?? AppColors.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color ?? AppColors.primary, size: 20),
                  ),
                  const Spacer(),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (trend! >= 0 ? AppColors.success : AppColors.error)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trend! >= 0 ? Icons.trending_up : Icons.trending_down,
                            size: 12,
                            color: trend! >= 0 ? AppColors.success : AppColors.error,
                          ),
                          const Gap(2),
                          Text(
                            '${trend!.abs().toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: trend! >= 0 ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Gap(12),
              Text(
                value,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Gap(4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingShimmer extends StatelessWidget {
  final int itemCount;

  const LoadingShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Card(
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 14,
                          width: 150,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Gap(8),
                        Container(
                          height: 10,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            const Gap(16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const Gap(24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
