import 'package:flutter/material.dart';
import 'package:pomodoro_zoo_tracker/features/category/domain/entities/category_entity.dart';
import 'package:pomodoro_zoo_tracker/features/category/presentation/providers/category_provider.dart';
import 'package:pomodoro_zoo_tracker/features/goal/domain/entities/goal_entity.dart';
import 'package:pomodoro_zoo_tracker/features/goal/presentation/providers/goal_provider.dart';
import 'package:pomodoro_zoo_tracker/presentation/main_page.dart';
import '../providers/timer_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/timer_circle.dart';
import '../widgets/timer_controls.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  String? _selectedCategoryId;
  String? _selectedGoalId;

  bool _canStartTimer(List<GoalEntity> goals) {
    if (_selectedCategoryId == null) return true;
    if (goals.length <= 1) return true;
    return _selectedGoalId != null;
  }

  void _handleStart(TimerProvider provider, List<GoalEntity> goals) {
    if (!_canStartTimer(goals)) {
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Current session skipped.')));
  }

  Future<void> _openCategoryManager() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MainPage(initialIndex: 1)));
  }

  Future<void> _openCategoryManagerForTitle(String title) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MainPage(initialIndex: 1, categoryTitleToEdit: title),
      ),
    );
  }

  void _selectCategory(String id, List<GoalEntity> goals) {
    if (_selectedCategoryId == id) {
      setState(() {
        _selectedCategoryId = null;
        _selectedGoalId = null;
      });
      return;
    }
    setState(() {
      _selectedCategoryId = id;
      _selectedGoalId = null;
      if (goals.length == 1) {
        _selectedGoalId = goals.first.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimerProvider>();
    final categories = context.watch<CategoryProvider>().categories;
    final goalProvider = context.watch<GoalProvider>();

    final selectedGoals = _selectedCategoryId != null
        ? goalProvider.getGoalsForCategory(_selectedCategoryId!)
        : <GoalEntity>[];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 40,
              ),
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
                    canStart: _canStartTimer(selectedGoals),
                    onStart: () => _handleStart(provider, selectedGoals),
                    onPause: provider.pause,
                    onReset: provider.reset,
                  ),
                  if (!_canStartTimer(selectedGoals)) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Selected category has multiple goals. Please select one goal to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6F8B71),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Free Focus card
                        _buildCategoryCard(
                          title: 'Free Focus',
                          category: null,
                          selected: _selectedCategoryId == null,
                          goals: const [],
                          selectedGoalId: _selectedGoalId,
                          goalSelectionRequired: false,
                          onEdit: null,
                          onSelectGoal: (goalId) =>
                              setState(() => _selectedGoalId = goalId),
                          onTap: () => setState(() {
                            _selectedCategoryId = null;
                            _selectedGoalId = null;
                          }),
                        ),
                        // Real categories from provider
                        ...categories.map((cat) {
                          final catGoals = goalProvider.getGoalsForCategory(
                            cat.id,
                          );
                          return _buildCategoryCard(
                            title: cat.name,
                            category: cat,
                            selected: _selectedCategoryId == cat.id,
                            goals: catGoals,
                            selectedGoalId: _selectedGoalId,
                            goalSelectionRequired:
                                _selectedCategoryId == cat.id &&
                                catGoals.length > 1,
                            onEdit: () =>
                                _openCategoryManagerForTitle(cat.name),
                            onSelectGoal: (goalId) =>
                                setState(() => _selectedGoalId = goalId),
                            onTap: () => _selectCategory(cat.id, catGoals),
                          );
                        }),
                      ],
                    ),
                  ),
                  if (provider.isCompleted) ...[
                    const SizedBox(height: 32),
                    const Text(
                      '🎉 Pomodoro Complete! 🐾',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildCategoryCard({
    required String title,
    required CategoryEntity? category,
    required bool selected,
    required List<GoalEntity> goals,
    required String? selectedGoalId,
    required bool goalSelectionRequired,
    required VoidCallback? onEdit,
    required ValueChanged<String> onSelectGoal,
    required VoidCallback onTap,
  }) {
    final Color accentColor = category != null
        ? _parseHexColor(category.colorHex)
        : const Color(0xFF4B9E58);
    final IconData catIcon = category != null
        ? IconData(category.iconCodePoint, fontFamily: 'MaterialIcons')
        : Icons.all_inclusive;
    final double totalGoalHours = goals.fold(0.0, (s, g) => s + g.targetHours);

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
              color: const Color(
                0xFF2E5D34,
              ).withValues(alpha: selected ? 0.14 : 0.06),
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
                  catIcon,
                  size: 18,
                  color: selected ? accentColor : const Color(0xFF8BA18D),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? accentColor : const Color(0xFF2E3C2E),
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    splashRadius: 18,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    padding: EdgeInsets.zero,
                    color: selected ? accentColor : const Color(0xFF5E7F62),
                    tooltip: 'Edit category',
                  ),
              ],
            ),
            // Goals progress bar
            if (totalGoalHours > 0) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    goals.length > 1 ? 'Goal Checklist' : 'Goal Progress',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5E7F62),
                    ),
                  ),
                  Text(
                    '${goals.length} goal${goals.length > 1 ? 's' : ''}  •  ${_formatHours(totalGoalHours)}h total',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2F7A3D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: 0,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE4EDE5),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ],
            // Goal chip selector when expanded
            if (selected && goals.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                goalSelectionRequired
                    ? 'Choose Your Goal (required)'
                    : 'Choose Your Goal',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
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
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD8E7DA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(goals.length, (index) {
                    final goal = goals[index];
                    final isSelectedGoal = selectedGoalId == goal.id;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == goals.length - 1 ? 0 : 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.pending_outlined,
                            size: 16,
                            color: accentColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelectedGoal
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: const Color(0xFF2E3C2E),
                              ),
                            ),
                          ),
                          Text(
                            '${_formatHours(goal.targetHours)}h',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9A6A1A),
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

  static Color _parseHexColor(String hex) {
    final h = hex.replaceAll('#', '');
    final full = h.length == 6 ? 'ff$h' : h;
    return Color(int.parse(full, radix: 16));
  }

  String _formatHours(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}
