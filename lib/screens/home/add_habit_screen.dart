import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design_system.dart';
import '../../models/habit.dart';
import '../../services/services.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? habit;
  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // Default all days
  Color _selectedColor = AppColors.habitIndigo;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _selectedColor = Color(widget.habit!.colorValue);
      _selectedTime = widget.habit!.reminderTime;
      _selectedDays = _parseFrequency(widget.habit!.frequency);
    } else {
      final settings = context.read<SettingsService>();
      _selectedTime = settings.defaultReminderTime;
    }
  }

  Set<int> _parseFrequency(List<String> freq) {
    return freq.map((s) {
      switch (s) {
        case 'Mon': return 1;
        case 'Tue': return 2;
        case 'Wed': return 3;
        case 'Thu': return 4;
        case 'Fri': return 5;
        case 'Sat': return 6;
        case 'Sun': return 7;
        default: return 1;
      }
    }).toSet();
  }


  final List<Map<String, dynamic>> _days = [
    {'label': 'Mon', 'value': 1},
    {'label': 'Tue', 'value': 2},
    {'label': 'Wed', 'value': 3},
    {'label': 'Thu', 'value': 4},
    {'label': 'Fri', 'value': 5},
    {'label': 'Sat', 'value': 6},
    {'label': 'Sun', 'value': 7},
  ];

  final List<Color> _colors = [
    AppColors.habitIndigo,
    AppColors.habitBlue,
    AppColors.habitCoral,
    AppColors.habitLavender,
    AppColors.habitMint,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleDay(int dayValue) {
    setState(() {
      if (_selectedDays.contains(dayValue)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(dayValue);
        }
      } else {
        _selectedDays.add(dayValue);
      }
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final habitService = context.read<HabitService>();
      final premiumService = context.read<PremiumService>();
      final settingsService = context.read<SettingsService>();
      try {
        List<String> frequencyStrings = _selectedDays.map((val) {
          return _days.firstWhere((d) => d['value'] == val)['label'] as String;
        }).toList();

        if (widget.habit != null) {
          // Update existing
          await habitService.updateHabit(
            id: widget.habit!.id,
            name: _nameController.text.trim(),
            colorValue: _selectedColor.value,
            frequency: frequencyStrings,
            reminderHour: _selectedTime.hour,
            reminderMinute: _selectedTime.minute,
            sound: settingsService.notificationSound,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Habit updated!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          // Create new
          await habitService.addHabit(
            name: _nameController.text.trim(),
            category: 'Personal',
            colorValue: _selectedColor.value,
            frequency: frequencyStrings,
            isPremium: premiumService.isPremium,
            reminderHour: _selectedTime.hour,
            reminderMinute: _selectedTime.minute,
            sound: settingsService.notificationSound,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Habit created! 🎉'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.habitCoral,
              behavior: SnackBarBehavior.floating,
              action: e.toString().contains('Limit reached') ? SnackBarAction(
                label: 'Upgrade',
                textColor: Colors.white,
                onPressed: () {
                  // TODO: Navigate to settings or show upgrade prompt
                },
              ) : null,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Text(
                    widget.habit != null ? 'Edit Habit' : 'New Habit',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(width: 48), // Spacer for balance
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Habit Name Section ─────────────────────────────────
              _Section(
                icon: Icons.auto_awesome_rounded,
                title: 'What is your habit?',
                subtitle: 'E.g. Morning Yoga, Read 10 pages',
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Habit name...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a habit name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Frequency Section ──────────────────────────────────
              _Section(
                icon: Icons.calendar_month_rounded,
                title: 'Frequency',
                subtitle: 'Select days to track this habit',
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _days.map((day) {
                    final isSelected = _selectedDays.contains(day['value']);
                    return GestureDetector(
                      onTap: () => _toggleDay(day['value']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          day['label'],
                          style: AppTypography.chip.copyWith(
                            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Color Identity Section ─────────────────────────────
              _Section(
                icon: Icons.palette_outlined,
                title: 'Color Identity',
                subtitle: 'Used for charts and indicators',
                child: Row(
                  children: _colors.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(right: AppSpacing.md),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Daily Reminder Section ─────────────────────────────
              _Section(
                icon: Icons.notifications_active_outlined,
                title: 'Daily Reminder',
                subtitle: "We'll nudge you to stay on track",
                child: GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.cardBorder,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _selectedTime.format(context),
                      style: AppTypography.titleMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Bottom Buttons ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveHabit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.habit != null ? 'Save Changes' : 'Create Habit'),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: AppRadius.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}
