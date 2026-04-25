import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/zoo_header.dart';
import '../../../coin/presentation/providers/coin_provider.dart';
import '../../domain/entities/pet_detail.dart';
import '../../domain/entities/pet_food_inventory.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_artwork.dart';

class PetDetailPage extends StatefulWidget {
  final String userAnimalId;

  const PetDetailPage({super.key, required this.userAnimalId});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<PetProvider>().loadPetDetail(widget.userAnimalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 1),
        child: Consumer<CoinProvider>(
          builder: (context, coinProvider, child) {
            return ZooHeader(
              title: 'Animal Care',
              showBackButton: true,
              coins: coinProvider.balance,
            );
          },
        ),
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          if (petProvider.isDetailLoading && petProvider.currentPet == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final pet = petProvider.currentPet;
          if (pet == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  petProvider.errorMessage ?? 'This pet could not be found.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: petProvider.reloadCurrentPet,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _buildHero(pet),
                const SizedBox(height: 20),
                _buildHungerCard(pet),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildGrowthCard(pet)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMoodCard(pet)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTreatHeader(pet),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: pet.foods
                      .map(
                        (food) => _FoodCard(
                          food: food,
                          isSelected:
                              petProvider.selectedFoodId == food.userFoodId,
                          onTap: food.isAvailable
                              ? () => petProvider.selectFood(food.userFoodId)
                              : null,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                if (petProvider.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      petProvider.errorMessage!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA75A14),
                      ),
                    ),
                  ),
                if (petProvider.errorMessage != null) const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: petProvider.canFeed
                        ? () => _handleFeed(context, petProvider, pet)
                        : null,
                    child: Text(_feedLabel(petProvider, pet)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleFeed(
    BuildContext context,
    PetProvider petProvider,
    PetDetail pet,
  ) async {
    final selectedFood = petProvider.selectedFood;
    if (selectedFood == null) {
      return;
    }

    final success = await petProvider.feedSelectedFood();
    if (!mounted) {
      return;
    }

    final message = success
        ? '${pet.name} enjoyed ${selectedFood.name}.'
        : (petProvider.errorMessage ?? 'Unable to feed your pet.');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _feedLabel(PetProvider petProvider, PetDetail pet) {
    if (petProvider.isFeeding) {
      return 'Feeding...';
    }
    if (pet.isFull) {
      return '${pet.name} Is Full';
    }
    if (petProvider.selectedFood == null) {
      return 'Select a Treat';
    }
    return 'Feed ${pet.name}';
  }

  Widget _buildHero(PetDetail pet) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          PetArtwork(name: pet.name, spriteUrl: pet.spriteUrl, size: 200),
          const SizedBox(height: 18),
          Text(
            pet.name,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  pet.rarityName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Stage ${pet.stage}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHungerCard(PetDetail pet) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HUNGER LEVEL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                '${pet.hungerLevel}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pet.hungerProgress,
              minHeight: 12,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard(PetDetail pet) {
    return _StatCard(
      eyebrow: 'GROWTH',
      title: 'Lv. ${pet.level}',
      subtitle: '${pet.experiencePoints}/${pet.experienceToNextLevel} EXP',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pet.growthProgress,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Progress ${(pet.growthProgress * 100).round()}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(PetDetail pet) {
    return _StatCard(
      eyebrow: 'MOOD',
      title: pet.moodTitle,
      subtitle: pet.moodSubtitle,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          pet.hungerLevel >= 80
              ? Icons.sentiment_satisfied_alt
              : pet.hungerLevel >= 50
              ? Icons.sentiment_neutral
              : Icons.sentiment_dissatisfied,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTreatHeader(PetDetail pet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Treats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Pick one food from your bag.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        Text(
          'Inventory ${pet.totalInventoryCount}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  const _StatCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final PetFoodInventory food;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FoodCard({
    required this.food,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !food.isAvailable;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 152,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryContainer
              : Colors.white.withValues(alpha: isDisabled ? 0.7 : 1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.6),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  'x${food.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDisabled ? const Color(0xFF9DA89D) : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              food.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDisabled ? const Color(0xFF98A298) : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+${food.benefitValue} hunger',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDisabled ? const Color(0xFF98A298) : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
