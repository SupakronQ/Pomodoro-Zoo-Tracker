import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/presentation/main_page.dart';
import '../providers/timer_provider.dart';
import 'package:provider/provider.dart';
import '../../../coin/presentation/providers/coin_provider.dart';
import '../../../coin/domain/usecases/calculate_coins.dart';
import '../widgets/timer_circle.dart';
import '../widgets/timer_controls.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final List<_TimerCategoryOption> _categoryOptions = [
    _TimerCategoryOption(
      id: 'deep-work',
      title: 'Deep Work',
      trackedHours: 3,
      goals: [
        _TimerGoalOption(id: 'deep-work-goal-1', name: 'Finish sprint tasks', hours: 2),
        _TimerGoalOption(id: 'deep-work-goal-2', name: 'Focus block review', hours: 2),
      ],
    ),
    _TimerCategoryOption(
      id: 'learning',
      title: 'Learning',
      trackedHours: 1.8,
      goals: [
        _TimerGoalOption(id: 'learning-goal-1', name: 'Read chapter 1', hours: 1),
        _TimerGoalOption(id: 'learning-goal-2', name: 'Practice exercises', hours: 1),
      ],
    ),
    _TimerCategoryOption(
      id: 'restoration',
      title: 'Restoration',
      trackedHours: 0.2,
      goals: [],
    ),
  ];

  String? _selectedCategoryId;
  String? _selectedGoalId;

  _TimerCategoryOption? get _selectedCategory {
    if (_selectedCategoryId == null) {
      return null;
    }
    for (final category in _categoryOptions) {
      if (category.id == _selectedCategoryId) {
        return category;
      }
    }
    return null;
  }

  bool get _requiresGoalSelection {
    final category = _selectedCategory;
    if (category == null) {
      return false;
    }
    return category.goals.length > 1;
  }

  bool get _canStartTimer {
    final category = _selectedCategory;
    if (category == null) {
      return true;
    }

    if (category.goals.length <= 1) {
      return true;
    }

    return _selectedGoalId != null;
  }

  void _handleStart(TimerProvider provider) {
    if (!_canStartTimer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a goal before starting.')),
      );
      return;
    }
    provider.start();
  }

  Future<void> _handleSkip(TimerProvider provider) async {
    await provider.reset();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Current session skipped.')),
    );
  }

  Future<void> _openCategoryManager() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MainPage(initialIndex: 1)),
    );
  }

  Future<void> _openCategoryManagerForTitle(String title) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MainPage(initialIndex: 1, categoryTitleToEdit: title),
      ),
    );
  }

  void _selectCategory(String id) {
    if (_selectedCategoryId == id) {
      setState(() {
        _selectedCategoryId = null;
        _selectedGoalId = null;
      });
      return;
    }

    final category = _categoryOptions
        .where((item) => item.id == id)
        .cast<_TimerCategoryOption?>()
        .firstWhere((item) => item != null, orElse: () => null);

    setState(() {
      _selectedCategoryId = id;
      _selectedGoalId = null;
      if (category != null && category.goals.length == 1) {
        _selectedGoalId = category.goals.first.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimerProvider>();
    final coinProvider = context.watch<CoinProvider>();

    return Scaffold(
      // backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ZooTimerDisplay(
                    progress: provider.progress,
                    formattedTime: provider.formattedTime,
                    isCompleted: provider.isCompleted,
                    phaseLabel: provider.phaseLabel,
                    currentRound: provider.currentRound,
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: provider.isRunning || provider.progress > 0
                        ? () => _handleSkip(provider)
                        : null,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('SKIP SESSION'),
                  ),
                  const SizedBox(height: 40),
                  TimerControls(
                    isRunning: provider.isRunning,
                    isCompleted: provider.isCompleted,
                    canStart: _canStartTimer,
                    onStart: () => _handleStart(provider),
                    onPause: provider.pause,
                    onReset: provider.reset,
                  ),
                  const SizedBox(height: 16),

                  // -- Coin Progress Indicator --
                  _buildCoinProgress(coinProvider),
                  const SizedBox(height: 8),

                  // -- Debug: Skip to 5s before 1 hour --
                  _buildSkipTestButton(provider, coinProvider),

                  if (!_canStartTimer) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Selected category has multiple goals. Please select one goal to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pick Your Focus Lane',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _openCategoryManager,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('ADD'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 34),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Choose a category to track your momentum.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6F8B71), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        _buildCategoryCard(
                          title: 'Free Focus',
                          selected: _selectedCategoryId == null,
                          trackedHours: null,
                          goalTotalHours: null,
                          completedGoals: null,
                          goals: const [],
                          selectedGoalId: _selectedGoalId,
                          goalSelectionRequired: false,
                          onEdit: null,
                          onSelectGoal: (goalId) {
                            setState(() {
                              _selectedGoalId = goalId;
                            });
                          },
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = null;
                              _selectedGoalId = null;
                            });
                          },
                        ),
                        ..._categoryOptions.map(
                          (category) => _buildCategoryCard(
                            title: category.title,
                            selected: _selectedCategoryId == category.id,
                            trackedHours: category.trackedHours,
                            goalTotalHours: category.totalGoalHours,
                            completedGoals: _completedGoalCount(category),
                            goals: category.goals,
                            selectedGoalId: _selectedGoalId,
                            goalSelectionRequired: _selectedCategoryId == category.id && category.goals.length > 1,
                            onEdit: () => _openCategoryManagerForTitle(category.title),
                            onSelectGoal: (goalId) {
                              setState(() {
                                _selectedGoalId = goalId;
                              });
                            },
                            onTap: () => _selectCategory(category.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (provider.isCompleted) ...[
                    const SizedBox(height: 32),
                    const Text(
                      '🎉 Pomodoro Complete! 🐾',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinProgress(CoinProvider coinProvider) {
    final focusMinutes = coinProvider.totalFocusSeconds ~/ 60;
    final focusSecs = coinProvider.totalFocusSeconds % 60;
    final untilNext = coinProvider.secondsUntilNextCoin;
    final untilMin = untilNext ~/ 60;
    final untilSec = untilNext % 60;
    final progressToNextCoin = 1.0 -
        (untilNext / CalculateCoins.secondsPerHour).clamp(0.0, 1.0);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7F1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDE6DE)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, size: 16, color: Color(0xFF7FB77E)),
                    const SizedBox(width: 6),
                    Text(
                      '${coinProvider.coinBalance} Coins',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF356939),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Focus: ${focusMinutes.toString().padLeft(2, '0')}:${focusSecs.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6F8B71),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progressToNextCoin,
                minHeight: 6,
                backgroundColor: const Color(0xFFE4EDE5),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4B9E58)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Next coin in ${untilMin.toString().padLeft(2, '0')}:${untilSec.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8BA18D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipTestButton(TimerProvider timerProvider, CoinProvider coinProvider) {
    return TextButton.icon(
      onPressed: () async {
        coinProvider.skipToBeforeOneHour();
        if (timerProvider.phase != PomodoroPhase.focus || !timerProvider.isRunning) {
          await timerProvider.reset();
          await timerProvider.start();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⏩ Skipped to 5s before coin award! (Focus: ${coinProvider.formatSeconds(coinProvider.totalFocusSeconds)})',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      icon: const Icon(Icons.fast_forward, size: 16),
      label: const Text(
        '⏩ SKIP TO 5s BEFORE 1HR (TEST)',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFB67B1F),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: const Color(0xFFFFF8E8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE8D5A8)),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required bool selected,
    required double? trackedHours,
    required double? goalTotalHours,
    required int? completedGoals,
    required List<_TimerGoalOption> goals,
    required String? selectedGoalId,
    required bool goalSelectionRequired,
    required VoidCallback? onEdit,
    required ValueChanged<String> onSelectGoal,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFDFF3E2), Color(0xFFCBE8D0)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFF7FBF7)],
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF4B9E58) : const Color(0xFFDDE6DE),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E5D34).withOpacity(selected ? 0.14 : 0.06),
              blurRadius: selected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                  color: selected ? const Color(0xFF2F7A3D) : const Color(0xFF8BA18D),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? const Color(0xFF2F7A3D) : const Color(0xFF2E3C2E),
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    splashRadius: 18,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    padding: EdgeInsets.zero,
                    color: selected ? const Color(0xFF2F7A3D) : const Color(0xFF5E7F62),
                    tooltip: 'Edit category',
                  ),
              ],
            ),
            if (goals.isEmpty && trackedHours != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Focus',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF5E7F62)),
                  ),
                  Text(
                    '${_formatHours(trackedHours)}h all-time',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2F7A3D)),
                  ),
                ],
              ),
            ],
            if (goalTotalHours != null && goalTotalHours > 0) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    goals.length > 1 ? 'Goal Checklist' : 'Goal Progress',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF5E7F62)),
                  ),
                  Text(
                    goals.length > 1
                        ? '${completedGoals ?? 0}/${goals.length} completed'
                        : '${_formatHours(trackedHours ?? 0)} / ${_formatHours(goalTotalHours)}h',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2F7A3D)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ((trackedHours ?? 0) / goalTotalHours).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE4EDE5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4B9E58)),
                ),
              ),
            ],
            if (selected && goals.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                goalSelectionRequired ? 'Choose Your Goal (required)' : 'Choose Your Goal',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: goals
                    .map(
                      (goal) => ChoiceChip(
                        label: Text(goal.name),
                        selected: selectedGoalId == goal.id,
                        onSelected: (_) => onSelectGoal(goal.id),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD8E7DA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(goals.length, (index) {
                    final goal = goals[index];
                    final remaining = _goalRemainingHours(
                      trackedHours: trackedHours ?? 0,
                      goals: goals,
                      index: index,
                    );
                    final completed = remaining <= 1e-9;
                    final isSelectedGoal = selectedGoalId == goal.id;

                    return Padding(
                      padding: EdgeInsets.only(bottom: index == goals.length - 1 ? 0 : 8),
                      child: Row(
                        children: [
                          Icon(
                            completed ? Icons.check_circle : Icons.pending_outlined,
                            size: 16,
                            color: completed ? const Color(0xFF2F7A3D) : const Color(0xFFB67B1F),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelectedGoal ? FontWeight.w700 : FontWeight.w600,
                                color: const Color(0xFF2E3C2E),
                              ),
                            ),
                          ),
                          Text(
                            completed ? 'Complete' : 'Remind ${_formatHours(remaining)}h',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: completed ? const Color(0xFF2F7A3D) : const Color(0xFF9A6A1A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatHours(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  int _completedGoalCount(_TimerCategoryOption category) {
    if (category.goals.isEmpty) {
      return 0;
    }

    double cumulative = 0;
    int completed = 0;
    for (final goal in category.goals) {
      cumulative += goal.hours;
      if (category.trackedHours + 1e-9 >= cumulative) {
        completed += 1;
      } else {
        break;
      }
    }

    return completed;
  }

  double _goalRemainingHours({
    required double trackedHours,
    required List<_TimerGoalOption> goals,
    required int index,
  }) {
    double previousGoalsTotal = 0;
    for (int i = 0; i < index; i++) {
      previousGoalsTotal += goals[i].hours;
    }

    final currentGoalHours = goals[index].hours;
    final doneOnThisGoal = (trackedHours - previousGoalsTotal).clamp(0.0, currentGoalHours);
    final remaining = currentGoalHours - doneOnThisGoal;
    return remaining < 0 ? 0 : remaining;
  }
}

class _TimerCategoryOption {
  final String id;
  final String title;
  final double trackedHours;
  final List<_TimerGoalOption> goals;

  const _TimerCategoryOption({
    required this.id,
    required this.title,
    required this.trackedHours,
    required this.goals,
  });

  double get totalGoalHours {
    return goals.fold(0, (sum, goal) => sum + goal.hours);
  }

  _TimerCategoryOption copyWith({
    String? id,
    String? title,
    double? trackedHours,
    List<_TimerGoalOption>? goals,
  }) {
    return _TimerCategoryOption(
      id: id ?? this.id,
      title: title ?? this.title,
      trackedHours: trackedHours ?? this.trackedHours,
      goals: goals ?? this.goals,
    );
  }
}

class _TimerGoalOption {
  final String id;
  final String name;
  final double hours;

  const _TimerGoalOption({
    required this.id,
    required this.name,
    required this.hours,
  });
}
