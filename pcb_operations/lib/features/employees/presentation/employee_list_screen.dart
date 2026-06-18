import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../data/models/employee.dart';
import '../data/employee_repository.dart';
import 'employee_profile_screen.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedDepartmentProvider = StateProvider<String?>((ref) => null);

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesStreamProvider(null));
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedDept = ref.watch(selectedDepartmentProvider);

    return AppScaffold(
      title: 'Employee Directory',
      body: Column(
        children: [
          _SearchBar(
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
          ),
          _DepartmentFilter(
            selected: selectedDept,
            onSelected: (dept) =>
                ref.read(selectedDepartmentProvider.notifier).state = dept,
          ),
          Expanded(
            child: employeesAsync.when(
              loading: () => const _ShimmerList(),
              error: (e, _) => _ErrorState(message: e.toString()),
              data: (employees) {
                var filtered = employees.where((e) {
                  if (searchQuery.isEmpty && selectedDept == null) return true;
                  final matchesSearch = searchQuery.isEmpty ||
                      e.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      e.employeeId.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      e.designation.toLowerCase().contains(searchQuery.toLowerCase());
                  final matchesDept = selectedDept == null || e.department == selectedDept;
                  return matchesSearch && matchesDept;
                }).toList();

                if (filtered.isEmpty) {
                  return _EmptyState(
                    hasFilters: searchQuery.isNotEmpty || selectedDept != null,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _EmployeeCard(employee: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search by name, ID, designation...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: Consumer(
            builder: (context, ref, _) {
              final query = ref.watch(searchQueryProvider);
              if (query.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DepartmentFilter extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _DepartmentFilter({required this.selected, required this.onSelected});

  static const _departments = [
    'Fabrication',
    'Welding',
    'Sheet Metal',
    'Painting',
    'Electrical',
    'Interior',
    'Testing',
    'Quality',
    'Administration',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: 'All',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          const Gap(8),
          ..._departments.map((dept) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: dept,
                  selected: selected == dept,
                  onTap: () => onSelected(selected == dept ? null : dept),
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _EmployeeCard extends ConsumerWidget {
  final Employee employee;
  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EmployeeProfileScreen(employee: employee),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _Avatar(employee: employee),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _RoleBadge(role: employee.role),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      employee.designation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary.withValues(alpha: 0.7),
                          ),
                    ),
                    const Gap(6),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.business_rounded,
                          label: employee.department,
                        ),
                        const Gap(8),
                        _InfoChip(
                          icon: Icons.badge_outlined,
                          label: employee.employeeId,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Employee employee;
  const _Avatar({required this.employee});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      backgroundImage: employee.photoUrl != null
          ? NetworkImage(employee.photoUrl!)
          : null,
      child: employee.photoUrl == null
          ? Text(
              employee.name.isNotEmpty
                  ? employee.name[0].toUpperCase()
                  : '?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            )
          : null,
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (role) {
      'admin' => (AppColors.error.withValues(alpha: 0.1), AppColors.error, 'Admin'),
      'supervisor' => (AppColors.accent.withValues(alpha: 0.1), AppColors.accentDark, 'Supervisor'),
      _ => (AppColors.primary.withValues(alpha: 0.1), AppColors.primary, 'Employee'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const Gap(4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.card,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 88,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const Gap(16),
            Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge),
            const Gap(8),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  const _EmptyState({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters ? Icons.search_off_rounded : Icons.people_outline_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const Gap(16),
            Text(
              hasFilters ? 'No employees found' : 'No employees yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(8),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Employees will appear here once added',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
