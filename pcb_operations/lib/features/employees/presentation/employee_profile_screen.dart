import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/employee.dart';

class EmployeeProfileScreen extends ConsumerWidget {
  final Employee employee;

  const EmployeeProfileScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _AppBar(employee: employee),
          SliverToBoxAdapter(child: _HeaderSection(employee: employee)),
          SliverToBoxAdapter(child: _InfoSection(employee: employee)),
          SliverToBoxAdapter(child: _ContactSection(employee: employee)),
          SliverToBoxAdapter(child: _AttendanceSection(employee: employee)),
          const SliverToBoxAdapter(child: Gap(32)),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final Employee employee;
  const _AppBar({required this.employee});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Employee employee;
  const _HeaderSection({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  backgroundImage: employee.photoUrl != null
                      ? NetworkImage(employee.photoUrl!)
                      : null,
                  child: employee.photoUrl == null
                      ? Text(
                          employee.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const Gap(12),
                Text(
                  employee.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Gap(4),
                Text(
                  employee.designation,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ID: ${employee.employeeId}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Employee employee;
  const _InfoSection({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Department & Role', style: Theme.of(context).textTheme.titleLarge),
              const Gap(16),
              _InfoRow(icon: Icons.business_rounded, label: 'Department', value: employee.department),
              const Divider(height: 24),
              _InfoRow(icon: Icons.badge_outlined, label: 'Designation', value: employee.designation),
              const Divider(height: 24),
              _InfoRow(icon: Icons.shield_outlined, label: 'Role', value: employee.roleLabel),
              const Divider(height: 24),
              _InfoRow(icon: Icons.store_outlined, label: 'Branch', value: employee.branchName),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  final Employee employee;
  const _ContactSection({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact', style: Theme.of(context).textTheme.titleLarge),
              const Gap(16),
              _InfoRow(icon: Icons.email_outlined, label: 'Email', value: employee.email),
              const Divider(height: 24),
              _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: employee.phone),
              if (employee.emergencyContact != null) ...[
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.emergency_outlined,
                  label: 'Emergency Contact (${employee.emergencyName ?? ''})',
                  value: employee.emergencyContact!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceSection extends StatelessWidget {
  final Employee employee;
  const _AttendanceSection({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Attendance', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (employee.isCheckedIn
                              ? AppColors.attendancePresent
                              : AppColors.textSecondary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          employee.isCheckedIn
                              ? Icons.check_circle_rounded
                              : Icons.cancel_outlined,
                          size: 16,
                          color: employee.isCheckedIn
                              ? AppColors.attendancePresent
                              : AppColors.textSecondary,
                        ),
                        const Gap(4),
                        Text(
                          employee.isCheckedIn ? 'Checked In' : 'Not Checked In',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: employee.isCheckedIn
                                ? AppColors.attendancePresent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),
              if (employee.lastCheckIn != null)
                _InfoRow(
                  icon: Icons.login_rounded,
                  label: 'Last Check-In',
                  value: employee.lastCheckIn!.formattedDateTime,
                ),
              if (employee.lastCheckIn != null && employee.lastCheckOut != null)
                const Divider(height: 24),
              if (employee.lastCheckOut != null)
                _InfoRow(
                  icon: Icons.logout_rounded,
                  label: 'Last Check-Out',
                  value: employee.lastCheckOut!.formattedDateTime,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                    ),
              ),
              const Gap(2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
