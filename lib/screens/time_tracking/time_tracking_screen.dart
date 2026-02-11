import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/service_log.dart';
import '../../services/service_log_repository.dart';

/// Global notifier to track if add entry sheet is open
/// Used to hide AI FAB when the sheet is displayed
final ValueNotifier<bool> isAddEntrySheetOpen = ValueNotifier(false);

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  final _repo = ServiceLogRepository();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Hours')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history_toggle_off, size: 56),
                const SizedBox(height: 12),
                Text(
                  'Sign in to track service hours',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hour logs are account-based so your entries stay private and saved to your profile.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Service Hours')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showAddLogSheet(context, uid, _selectedDay ?? DateTime.now()),
        icon: const Icon(Icons.add),
        label: const Text('Log Hours'),
      ),
      body: StreamBuilder<List<ServiceLog>>(
        stream: _repo.serviceLogs(uid),
        builder: (context, logsSnap) {
          final allLogs = logsSnap.data ?? [];
          final logsByDay = _groupLogsByDay(allLogs);
          final totalHours = allLogs.fold<double>(
            0,
            (sum, log) => sum + log.hours,
          );

          final displayLogs = _selectedDay != null
              ? allLogs
                    .where((log) => isSameDay(log.date, _selectedDay))
                    .toList()
              : allLogs;

          return Column(
            children: [
              _buildSummaryCard(scheme, totalHours, allLogs.length),
              _buildCalendar(scheme, logsByDay),
              const Divider(height: 1),
              Expanded(child: _buildLogsList(uid, displayLogs, scheme)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    ColorScheme scheme,
    double totalHours,
    int entryCount,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                totalHours.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              Text(
                'Total Hours',
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.onPrimaryContainer.withAlpha(51),
          ),
          Column(
            children: [
              Text(
                '$entryCount',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              Text(
                'Entries',
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    ColorScheme scheme,
    Map<DateTime, List<ServiceLog>> logsByDay,
  ) {
    return TableCalendar<ServiceLog>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) => logsByDay[_normalizeDate(day)] ?? [],
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: scheme.primary.withAlpha(77),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: scheme.tertiary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerSize: 6,
        markerMargin: const EdgeInsets.symmetric(horizontal: 1),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildLogsList(String uid, List<ServiceLog> logs, ColorScheme scheme) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism_outlined,
              size: 64,
              color: scheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedDay != null
                  ? 'No entries for this date'
                  : 'No service hours logged yet',
              style: TextStyle(color: scheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to log hours',
              style: TextStyle(color: scheme.outline, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Dismissible(
          key: Key(log.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: scheme.error,
            child: Icon(Icons.delete, color: scheme.onError),
          ),
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) =>
              _repo.deleteLog(userId: uid, logId: log.id, hours: log.hours),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: scheme.secondaryContainer,
              child: Text(
                log.hours.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
            title: Text(log.description),
            subtitle: Text(DateFormat.yMMMd().format(log.date)),
            trailing: Text(
              '${log.hours.toStringAsFixed(1)} hrs',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Map<DateTime, List<ServiceLog>> _groupLogsByDay(List<ServiceLog> logs) {
    final Map<DateTime, List<ServiceLog>> result = {};
    for (final log in logs) {
      final normalizedDate = _normalizeDate(log.date);
      result.putIfAbsent(normalizedDate, () => []).add(log);
    }
    return result;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this service log entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showAddLogSheet(
    BuildContext context,
    String uid,
    DateTime? preselectedDate,
  ) {
    isAddEntrySheetOpen.value = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddServiceLogSheet(
        userId: uid,
        preselectedDate: preselectedDate,
        repository: _repo,
      ),
    ).then((_) {
      isAddEntrySheetOpen.value = false;
    });
  }
}

class AddServiceLogSheet extends StatefulWidget {
  final String userId;
  final DateTime? preselectedDate;
  final ServiceLogRepository repository;

  const AddServiceLogSheet({
    super.key,
    required this.userId,
    this.preselectedDate,
    required this.repository,
  });

  @override
  State<AddServiceLogSheet> createState() => _AddServiceLogSheetState();
}

class _AddServiceLogSheetState extends State<AddServiceLogSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController();
  late DateTime _selectedDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.preselectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outline.withAlpha(77),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Log Service Hours',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat.yMMMd().format(_selectedDate)),
              subtitle: const Text('Date'),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: scheme.outline.withAlpha(51)),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hoursController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Hours',
                prefixIcon: Icon(Icons.access_time),
                hintText: 'e.g., 2.5',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter hours';
                }
                final hours = double.tryParse(value);
                if (hours == null || hours <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                hintText: 'What did you do?',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Entry'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.repository.addLog(
        userId: widget.userId,
        date: _selectedDate,
        hours: double.parse(_hoursController.text),
        description: _descriptionController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
