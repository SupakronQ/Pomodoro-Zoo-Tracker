import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';
import 'package:pomodoro_zoo_tracker/features/category/presentation/widgets/category_card.dart';

class CategoryManagementPage extends StatefulWidget {
  final String? categoryTitleToEdit;

  const CategoryManagementPage({super.key, this.categoryTitleToEdit});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final List<_CategoryItemData> _categories = [
    _CategoryItemData(
      title: 'Deep Work',
      icon: Icons.work,
      trackedHours: 3,
      hasGoal: true,
      goals: [
        _CategoryGoalData(name: 'Finish sprint tasks', hours: 2, deadline: DateTime(2026, 4, 15)),
        _CategoryGoalData(name: 'Focus block review', hours: 2, deadline: DateTime(2026, 4, 20)),
      ],
    ),
    _CategoryItemData(
      title: 'Learning',
      icon: Icons.menu_book,
      trackedHours: 1.8,
      hasGoal: true,
      goals: [
        _CategoryGoalData(name: 'Read chapter 1', hours: 1, deadline: DateTime(2026, 4, 13)),
        _CategoryGoalData(name: 'Practice exercises', hours: 1, deadline: DateTime(2026, 4, 30)),
      ],
    ),
    _CategoryItemData(
      title: 'Restoration',
      icon: Icons.spa,
      trackedHours: 0.2,
      hasGoal: false,
      goals: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoryTitleToEdit != null && widget.categoryTitleToEdit!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _showCategoryModalByTitle(widget.categoryTitleToEdit!.trim());
      });
    }
  }
  
  // ฟังก์ชันสำหรับเปิด Modal
  void _showCategoryModal({int? editIndex}) {
    final bool isNew = editIndex == null;
    final _CategoryItemData? editingItem = isNew ? null : _categories[editIndex];
    final TextEditingController titleController = TextEditingController(text: editingItem?.title ?? '');
    bool hasGoal = editingItem?.hasGoal ?? true;
    List<_GoalDraft> goals = _createGoalDrafts(editingItem);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // สำคัญ: เพื่อให้ขยายตามคีย์บอร์ด
      backgroundColor: Colors.transparent, // เพื่อให้เห็นขอบโค้งของ Container
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // ดันขึ้นเมื่อคีย์บอร์ดมา
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => _buildModalContent(
            isNew: isNew,
            titleController: titleController,
            hasGoal: hasGoal,
            goals: goals,
            onHasGoalChanged: (value) {
              setModalState(() {
                hasGoal = value;
                if (hasGoal && goals.isEmpty) {
                  goals = [_createDefaultGoal()];
                }
              });
            },
            onAddGoal: () {
              setModalState(() {
                goals = [...goals, _createDefaultGoal()];
              });
            },
            onRemoveGoal: (index) {
              setModalState(() {
                goals = List<_GoalDraft>.from(goals)..removeAt(index);
              });
            },
            onGoalHoursChanged: (index, value) {
              setModalState(() {
                goals[index].hours = value;
              });
            },
            onGoalDeadlineChanged: (index, value) {
              setModalState(() {
                goals[index].deadline = value;
              });
            },
            onSave: () {
              final String title = titleController.text.trim();
              if (title.isEmpty) {
                return;
              }

              if (hasGoal && goals.isEmpty) {
                return;
              }

              if (hasGoal && !_syncGoalHoursFromInputs(goals)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid hours for every goal.')),
                );
                return;
              }

              if (hasGoal && !_syncGoalNamesFromInputs(goals)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name for every goal.')),
                );
                return;
              }

              final savedGoals = goals
                  .map((goal) => _CategoryGoalData(name: goal.name, hours: goal.hours, deadline: goal.deadline))
                  .toList();

              setState(() {
                if (isNew) {
                  _categories.add(
                    _CategoryItemData(
                      title: title,
                      icon: Icons.pets,
                      trackedHours: 0,
                      hasGoal: hasGoal,
                      goals: hasGoal ? savedGoals : [],
                    ),
                  );
                } else {
                  final current = _categories[editIndex];
                  _categories[editIndex] = current.copyWith(
                    title: title,
                    hasGoal: hasGoal,
                    goals: hasGoal ? savedGoals : [],
                  );
                }
              });

              Navigator.pop(context);
            },
            onDelete: isNew
                ? null
                : () {
                    setState(() {
                      _categories.removeAt(editIndex);
                    });
                    Navigator.pop(context);
                  },
          ),
        ),
      ),
    ).whenComplete(() {
      titleController.dispose();
      for (final goal in goals) {
        goal.nameController.dispose();
        goal.hoursController.dispose();
      }
    });
  }

  void _showCategoryModalByTitle(String title) {
    final index = _categories.indexWhere((item) => item.title == title);
    if (index >= 0) {
      _showCategoryModal(editIndex: index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & Add Button
            _buildPageHeader(),
            const SizedBox(height: 32),
            
            const Text(
              "EXISTING ECOSYSTEM",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),

            // รายการ Category
            ...List.generate(
              _categories.length,
              (index) => _buildCategoryItem(index),
            ),
            
            const SizedBox(height: 100), // เผื่อพื้นที่ให้ Bottom Nav
          ],
        ),
      ),
    );
  }

  // ส่วนประกอบของ Modal
  Widget _buildModalContent({
    required bool isNew,
    required TextEditingController titleController,
    required bool hasGoal,
    required List<_GoalDraft> goals,
    required ValueChanged<bool> onHasGoalChanged,
    required VoidCallback onAddGoal,
    required ValueChanged<int> onRemoveGoal,
    required void Function(int index, double value) onGoalHoursChanged,
    required void Function(int index, DateTime value) onGoalDeadlineChanged,
    required VoidCallback onSave,
    required VoidCallback? onDelete,
  }) {
    final mediaQuery = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.88,
        ),
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLow, // สีเขียวอ่อน f8fbf8
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)), // โค้งมนสูง
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isNew ? "New Category" : "Edit Category",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (!isNew)
                    TextButton(
                      onPressed: onDelete,
                      child: const Text("DELETE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    )
                  else
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 32),
              
              _buildLabel("IDENTITY"),
              _buildTextField(titleController),
              const SizedBox(height: 24),

              _buildLabel("GOAL SETTING"),
              _buildGoalToggle(hasGoal: hasGoal, onChanged: onHasGoalChanged),
              const SizedBox(height: 24),
              
              if (hasGoal) ...[
                _buildLabel("GOALS & DEADLINES"),
                _buildGoalsEditor(
                  goals: goals,
                  onAddGoal: onAddGoal,
                  onRemoveGoal: onRemoveGoal,
                  onGoalHoursChanged: onGoalHoursChanged,
                  onGoalDeadlineChanged: onGoalDeadlineChanged,
                ),
                const SizedBox(height: 40),
              ] else ...[
                _buildAccumulationNote(),
                const SizedBox(height: 40),
              ],
              
              _buildSaveButton(isNew ? "Create Category" : "Save Changes", onPressed: onSave),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Manage Categories", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
            Text("WORKSPACE", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
        GestureDetector(
          onTap: () => _showCategoryModal(), // เปิด Modal แบบสร้างใหม่
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(int index) {
    final item = _categories[index];
    final double totalGoalHours = item.totalGoalHours;
    final double progressValue = item.hasGoal && totalGoalHours > 0
      ? (item.trackedHours / totalGoalHours).clamp(0.0, 1.0)
        : 0;
    final String stats = item.hasGoal
      ? '${_formatHours(item.trackedHours)} / ${_formatHours(totalGoalHours)}h (${item.goalItems.length} goals)'
        : 'สะสม ${_formatHours(item.trackedHours)}h';

    return GestureDetector(
      onTap: () => _showCategoryModal(editIndex: index), // เปิด Modal แบบแก้ไข
      child: CategoryCard(
        title: item.title,
        icon: item.icon,
        progress: progressValue,
        stats: stats,
        showProgress: item.hasGoal,
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 1.5)),
  );

  Widget _buildTextField(TextEditingController controller) => TextField(
    controller: controller,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: "Category Name",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    ),
  );

  Widget _buildGoalToggle({required bool hasGoal, required ValueChanged<bool> onChanged}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.outlineVariant),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Enable daily goal',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Switch(
          value: hasGoal,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    ),
  );

  Widget _buildGoalsEditor({
    required List<_GoalDraft> goals,
    required VoidCallback onAddGoal,
    required ValueChanged<int> onRemoveGoal,
    required void Function(int index, double value) onGoalHoursChanged,
    required void Function(int index, DateTime value) onGoalDeadlineChanged,
  }) {
    return Column(
      children: [
        ...List.generate(goals.length, (index) {
          final goal = goals[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      goal.name.trim().isEmpty ? 'Goal ${index + 1}' : goal.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: goals.length > 1 ? () => onRemoveGoal(index) : null,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: goal.nameController,
                  onChanged: (value) {
                    goal.name = value;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    hintText: 'Goal name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hours'),
                    const Text(
                      'Hours target',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: goal.hoursController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                  ],
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      onGoalHoursChanged(index, parsed);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    hintText: 'e.g. 1.5',
                    suffixText: 'h',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: goal.deadline,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        onGoalDeadlineChanged(index, picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: Text('Deadline: ${_formatDate(goal.deadline)}'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddGoal,
            icon: const Icon(Icons.add),
            label: const Text('Add another goal'),
          ),
        ),
      ],
    );
  }

  Widget _buildAccumulationNote() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.outlineVariant),
    ),
    child: const Text(
      'No goal selected: this category will accumulate continuously.',
      style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
    ),
  );

  String _formatHours(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  _GoalDraft _createDefaultGoal() {
    return _GoalDraft(
      name: '',
      hours: 1,
      deadline: DateTime.now().add(const Duration(days: 7)),
    );
  }

  List<_GoalDraft> _createGoalDrafts(_CategoryItemData? item) {
    if (item == null || item.goalItems.isEmpty) {
      return [_createDefaultGoal()];
    }

    return item.goalItems
      .map((goal) => _GoalDraft(name: goal.name, hours: goal.hours, deadline: goal.deadline))
        .toList();
  }

  bool _syncGoalHoursFromInputs(List<_GoalDraft> goals) {
    for (final goal in goals) {
      final parsed = double.tryParse(goal.hoursController.text.trim());
      if (parsed == null || parsed <= 0) {
        return false;
      }
      goal.hours = parsed;
    }

    return true;
  }

  bool _syncGoalNamesFromInputs(List<_GoalDraft> goals) {
    for (final goal in goals) {
      final name = goal.nameController.text.trim();
      if (name.isEmpty) {
        return false;
      }
      goal.name = name;
    }

    return true;
  }

  Widget _buildSaveButton(String label, {required VoidCallback onPressed}) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: const StadiumBorder(),
        elevation: 10,
        shadowColor: AppColors.primary.withOpacity(0.3),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}

class _CategoryItemData {
  final String title;
  final IconData icon;
  final double trackedHours;
  final bool hasGoal;
  final List<_CategoryGoalData>? goals;

  const _CategoryItemData({
    required this.title,
    required this.icon,
    required this.trackedHours,
    required this.hasGoal,
    this.goals,
  });

  List<_CategoryGoalData> get goalItems {
    return goals ?? const [];
  }

  double get totalGoalHours {
    return goalItems.fold(0, (sum, item) => sum + item.hours);
  }

  _CategoryItemData copyWith({
    String? title,
    IconData? icon,
    double? trackedHours,
    bool? hasGoal,
    List<_CategoryGoalData>? goals,
  }) {
    return _CategoryItemData(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      trackedHours: trackedHours ?? this.trackedHours,
      hasGoal: hasGoal ?? this.hasGoal,
      goals: goals ?? this.goals ?? const [],
    );
  }
}

class _CategoryGoalData {
  final String name;
  final double hours;
  final DateTime deadline;

  const _CategoryGoalData({
    required this.name,
    required this.hours,
    required this.deadline,
  });
}

class _GoalDraft {
  String name;
  double hours;
  DateTime deadline;
  final TextEditingController nameController;
  final TextEditingController hoursController;

  _GoalDraft({
    required this.name,
    required this.hours,
    required this.deadline,
  }) : nameController = TextEditingController(text: name),
        hoursController = TextEditingController(
          text: hours % 1 == 0 ? hours.toStringAsFixed(0) : hours.toStringAsFixed(1),
        );
}