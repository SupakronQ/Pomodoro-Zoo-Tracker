import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:pomodoro_zoo_tracker/core/theme/app_colors.dart';
import 'package:pomodoro_zoo_tracker/features/category/domain/entities/category_entity.dart';
import 'package:pomodoro_zoo_tracker/features/category/presentation/providers/category_provider.dart';
import 'package:pomodoro_zoo_tracker/features/category/presentation/widgets/category_card.dart';
import 'package:pomodoro_zoo_tracker/features/goal/domain/entities/goal_entity.dart';
import 'package:pomodoro_zoo_tracker/features/goal/presentation/providers/goal_provider.dart';

class CategoryManagementPage extends StatefulWidget {
  final String? categoryTitleToEdit;

  const CategoryManagementPage({super.key, this.categoryTitleToEdit});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  static const _uuid = Uuid();

  static const List<IconData> _kIconOptions = [
    Icons.work_outline,
    Icons.menu_book,
    Icons.spa,
    Icons.fitness_center,
    Icons.music_note,
    Icons.code,
    Icons.palette,
    Icons.restaurant,
    Icons.flight,
    Icons.home_outlined,
    Icons.favorite_border,
    Icons.school,
    Icons.sports_soccer,
    Icons.local_hospital,
    Icons.directions_run,
    Icons.label_outlined,
  ];

  static const List<Color> _kColorOptions = [
    Color(0xFF356939),
    Color(0xFF2196F3),
    Color(0xFFFF5722),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
    Color(0xFF00BCD4),
    Color(0xFFE91E63),
    Color(0xFF607D8B),
    Color(0xFFF44336),
    Color(0xFF4CAF50),
    Color(0xFF795548),
    Color(0xFF3F51B5),
  ];

  static Color _parseHexColor(String hex) {
    final h = hex.replaceAll('#', '');
    final full = h.length == 6 ? 'ff$h' : h;
    return Color(int.parse(full, radix: 16));
  }

  static String _colorToHex(Color color) {
    final r = (color.r * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0');
    final g = (color.g * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0');
    final b = (color.b * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0');
    return '#$r$g$b';
  }

  @override
  void initState() {
    super.initState();
    if (widget.categoryTitleToEdit != null &&
        widget.categoryTitleToEdit!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showCategoryModalByName(widget.categoryTitleToEdit!.trim());
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Modal
  // ---------------------------------------------------------------------------

  void _showCategoryModal({CategoryEntity? category}) {
    final categoryProvider = context.read<CategoryProvider>();
    final goalProvider = context.read<GoalProvider>();

    final bool isNew = category == null;
    final List<GoalEntity> existingGoals = isNew
        ? []
        : goalProvider.getGoalsForCategory(category.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryModalSheet(
        isNew: isNew,
        existingCategory: category,
        existingGoals: existingGoals,
        iconOptions: _kIconOptions,
        colorOptions: _kColorOptions,
        parseHexColor: _parseHexColor,
        colorToHex: _colorToHex,
        hoursToIntervals: _hoursToIntervals,
        onSave:
            (
              capturedName,
              capturedHasGoal,
              capturedIconCodePoint,
              capturedColorHex,
              capturedDrafts,
            ) {
              _doSave(
                existingCategory: category,
                categoryName: capturedName,
                iconCodePoint: capturedIconCodePoint,
                colorHex: capturedColorHex,
                hasGoal: capturedHasGoal,
                drafts: capturedDrafts,
                categoryProvider: categoryProvider,
                goalProvider: goalProvider,
              );
            },
        onDelete: isNew
            ? null
            : () => _doDelete(
                category: category,
                categoryProvider: categoryProvider,
                goalProvider: goalProvider,
              ),
      ),
    );
  }

  void _showCategoryModalByName(String name) {
    final categories = context.read<CategoryProvider>().categories;
    final idx = categories.indexWhere((c) => c.name == name);
    if (idx >= 0) _showCategoryModal(category: categories[idx]);
  }

  // ---------------------------------------------------------------------------
  // Async DB operations (called after modal is dismissed)
  // ---------------------------------------------------------------------------

  Future<void> _doSave({
    required CategoryEntity? existingCategory,
    required String categoryName,
    required int iconCodePoint,
    required String colorHex,
    required bool hasGoal,
    required List<_GoalSave> drafts,
    required CategoryProvider categoryProvider,
    required GoalProvider goalProvider,
  }) async {
    final String categoryId;

    if (existingCategory == null) {
      final newId = _uuid.v4();
      await categoryProvider.createCategory(
        CategoryEntity(
          id: newId,
          name: categoryName,
          userId: categoryProvider.currentUserId,
          colorHex: colorHex,
          iconCodePoint: iconCodePoint,
        ),
      );
      categoryId = newId;
    } else {
      await categoryProvider.updateCategory(
        CategoryEntity(
          id: existingCategory.id,
          name: categoryName,
          userId: existingCategory.userId,
          colorHex: colorHex,
          iconCodePoint: iconCodePoint,
        ),
      );
      categoryId = existingCategory.id;
    }

    final goalEntities = hasGoal
        ? drafts
              .map(
                (d) => GoalEntity(
                  id: '',
                  name: d.name,
                  categoryId: categoryId,
                  targetIntervals: _hoursToIntervals(d.hours),
                  deadline: d.deadline,
                  createdAt: DateTime.now(),
                ),
              )
              .toList()
        : <GoalEntity>[];

    await goalProvider.replaceGoalsForCategory(categoryId, goalEntities);
  }

  Future<void> _doDelete({
    required CategoryEntity? category,
    required CategoryProvider categoryProvider,
    required GoalProvider goalProvider,
  }) async {
    if (category == null) return;
    await goalProvider.deleteGoalsForCategory(category.id);
    await categoryProvider.deleteCategory(
      category.id,
      currentUserId: category.userId,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<CategoryProvider, GoalProvider>(
        builder: (context, categoryProvider, goalProvider, _) {
          final categories = categoryProvider.categories;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 32),
                const Text(
                  "EXISTING ECOSYSTEM",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (categoryProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ...categories.map((cat) {
                    final goals = goalProvider.getGoalsForCategory(cat.id);
                    return _buildCategoryItem(cat, goals);
                  }),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(CategoryEntity category, List<GoalEntity> goals) {
    final double totalGoalHours = goals.fold(
      0.0,
      (sum, g) => sum + g.targetHours,
    );
    const double trackedHours = 0; // TODO: derive from pomodoro_sessions
    final double progressValue = goals.isNotEmpty && totalGoalHours > 0
        ? (trackedHours / totalGoalHours).clamp(0.0, 1.0)
        : 0;
    final String stats = goals.isNotEmpty
        ? '${_formatHours(trackedHours)} / ${_formatHours(totalGoalHours)}h (${goals.length} goals)'
        : 'สะสม ${_formatHours(trackedHours)}h';

    final Color catColor = _parseHexColor(category.colorHex);
    final IconData catIcon = IconData(
      category.iconCodePoint,
      fontFamily: 'MaterialIcons',
    );

    return GestureDetector(
      onTap: () => _showCategoryModal(category: category),
      child: CategoryCard(
        title: category.name,
        icon: catIcon,
        color: catColor,
        progress: progressValue,
        stats: stats,
        showProgress: goals.isNotEmpty,
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage Categories",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              "WORKSPACE",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showCategoryModal(),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  String _formatHours(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  /// Converts hours (double) → Pomodoro intervals (25 min each).
  static int _hoursToIntervals(double hours) =>
      (hours * 60 / 25).round().clamp(1, 9999);
}

// ---------------------------------------------------------------------------
// Modal sheet — proper StatefulWidget so setState never conflicts with route
// ---------------------------------------------------------------------------

class _CategoryModalSheet extends StatefulWidget {
  final bool isNew;
  final CategoryEntity? existingCategory;
  final List<GoalEntity> existingGoals;
  final List<IconData> iconOptions;
  final List<Color> colorOptions;
  final Color Function(String) parseHexColor;
  final String Function(Color) colorToHex;
  final int Function(double) hoursToIntervals;
  final void Function(
    String name,
    bool hasGoal,
    int iconCodePoint,
    String colorHex,
    List<_GoalSave> drafts,
  )
  onSave;
  final VoidCallback? onDelete;

  const _CategoryModalSheet({
    required this.isNew,
    required this.existingCategory,
    required this.existingGoals,
    required this.iconOptions,
    required this.colorOptions,
    required this.parseHexColor,
    required this.colorToHex,
    required this.hoursToIntervals,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_CategoryModalSheet> createState() => _CategoryModalSheetState();
}

class _CategoryModalSheetState extends State<_CategoryModalSheet> {
  late final TextEditingController _titleController;
  late bool _hasGoal;
  late List<_GoalDraft> _goals;
  late IconData _selectedIcon;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingCategory?.name ?? '',
    );
    _hasGoal = widget.isNew ? true : widget.existingGoals.isNotEmpty;
    _goals = _createGoalDrafts();
    _selectedColor = widget.existingCategory != null
        ? widget.parseHexColor(widget.existingCategory!.colorHex)
        : widget.colorOptions.first;
    _selectedIcon = widget.existingCategory != null
        ? widget.iconOptions.firstWhere(
            (i) => i.codePoint == widget.existingCategory!.iconCodePoint,
            orElse: () => widget.iconOptions.first,
          )
        : widget.iconOptions.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final g in _goals) {
      g.nameController.dispose();
      g.hoursController.dispose();
    }
    super.dispose();
  }

  List<_GoalDraft> _createGoalDrafts() {
    if (widget.isNew || widget.existingGoals.isEmpty) {
      return [_defaultGoal()];
    }
    return widget.existingGoals
        .map(
          (e) => _GoalDraft(
            name: e.name,
            hours: e.targetHours,
            deadline: e.deadline,
          ),
        )
        .toList();
  }

  _GoalDraft _defaultGoal() => _GoalDraft(
    name: '',
    hours: 1,
    deadline: DateTime.now().add(const Duration(days: 7)),
  );

  bool _syncHours() {
    for (final g in _goals) {
      final v = double.tryParse(g.hoursController.text.trim());
      if (v == null || v <= 0) return false;
      g.hours = v;
    }
    return true;
  }

  bool _syncNames() {
    for (final g in _goals) {
      final n = g.nameController.text.trim();
      if (n.isEmpty) return false;
      g.name = n;
    }
    return true;
  }

  void _handleSave() {
    final catName = _titleController.text.trim();
    if (catName.isEmpty) return;
    if (_hasGoal && _goals.isEmpty) return;
    if (_hasGoal && !_syncHours()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid hours for every goal.'),
        ),
      );
      return;
    }
    if (_hasGoal && !_syncNames()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for every goal.')),
      );
      return;
    }

    final drafts = _goals
        .map(
          (g) => _GoalSave(name: g.name, hours: g.hours, deadline: g.deadline),
        )
        .toList();

    Navigator.pop(context);
    widget.onSave(
      catName,
      _hasGoal,
      _selectedIcon.codePoint,
      widget.colorToHex(_selectedColor),
      drafts,
    );
  }

  void _handleDelete() {
    Navigator.pop(context);
    widget.onDelete?.call();
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isNew ? "New Category" : "Edit Category",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!widget.isNew)
                      TextButton(
                        onPressed: _handleDelete,
                        child: const Text(
                          "DELETE",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                _label("IDENTITY"),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Category Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _label("APPEARANCE"),
                _buildIconPicker(),
                const SizedBox(height: 12),
                _buildColorPicker(),
                const SizedBox(height: 24),
                _label("GOAL SETTING"),
                _buildGoalToggle(),
                const SizedBox(height: 24),
                if (_hasGoal) ...[
                  _label("GOALS & DEADLINES"),
                  _buildGoalsEditor(),
                  const SizedBox(height: 40),
                ] else ...[
                  _buildAccumulationNote(),
                  const SizedBox(height: 40),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: const StadiumBorder(),
                      elevation: 10,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      widget.isNew ? "Create Category" : "Save Changes",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.secondary,
        letterSpacing: 1.5,
      ),
    ),
  );

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.iconOptions.map((iconData) {
        final isSelected = iconData.codePoint == _selectedIcon.codePoint;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = iconData),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? _selectedColor.withValues(alpha: 0.15)
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? _selectedColor : AppColors.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              iconData,
              color: isSelected ? _selectedColor : AppColors.secondary,
              size: 22,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.colorOptions.map((color) {
        final isSelected = color.toARGB32() == _selectedColor.toARGB32();
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalToggle() {
    return Container(
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
            value: _hasGoal,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() {
                _hasGoal = v;
                if (_hasGoal && _goals.isEmpty) _goals = [_defaultGoal()];
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsEditor() {
    return Column(
      children: [
        ...List.generate(_goals.length, (index) {
          final goal = _goals[index];
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
                      goal.name.trim().isEmpty
                          ? 'Goal ${index + 1}'
                          : goal.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: _goals.length > 1
                          ? () => setState(() => _goals.removeAt(index))
                          : null,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: goal.nameController,
                  onChanged: (v) => goal.name = v,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    hintText: 'Goal name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hours'),
                    Text(
                      'Hours target',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: goal.hoursController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,1}'),
                    ),
                  ],
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed != null && parsed > 0) goal.hours = parsed;
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 1),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (picked != null) {
                        setState(() => goal.deadline = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: Text('Deadline: ${_formatDate(goal.deadline)}'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
            onPressed: () => setState(() => _goals.add(_defaultGoal())),
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
}

// ---------------------------------------------------------------------------
// Private data classes
// ---------------------------------------------------------------------------

class _GoalSave {
  final String name;
  final double hours;
  final DateTime deadline;

  const _GoalSave({
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

  _GoalDraft({required this.name, required this.hours, required this.deadline})
    : nameController = TextEditingController(text: name),
      hoursController = TextEditingController(
        text: hours % 1 == 0
            ? hours.toStringAsFixed(0)
            : hours.toStringAsFixed(1),
      );
}
