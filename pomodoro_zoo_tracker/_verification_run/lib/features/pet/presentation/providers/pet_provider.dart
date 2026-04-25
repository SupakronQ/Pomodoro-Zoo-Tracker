import 'package:flutter/material.dart';

import '../../domain/entities/pet_detail.dart';
import '../../domain/entities/pet_food_inventory.dart';
import '../../domain/entities/pet_summary.dart';
import '../../domain/repositories/pet_repository.dart';

class PetProvider extends ChangeNotifier {
  final PetRepository repository;

  PetProvider({required this.repository});

  String? _currentUserId;
  String? _currentPetId;
  List<PetSummary> _pets = [];
  PetDetail? _currentPet;
  String? _selectedFoodId;
  String? _errorMessage;
  bool _isZooLoading = false;
  bool _isDetailLoading = false;
  bool _isFeeding = false;

  String? get currentUserId => _currentUserId;
  String? get currentPetId => _currentPetId;
  List<PetSummary> get pets => _pets;
  PetDetail? get currentPet => _currentPet;
  String? get selectedFoodId => _selectedFoodId;
  String? get errorMessage => _errorMessage;
  bool get isZooLoading => _isZooLoading;
  bool get isDetailLoading => _isDetailLoading;
  bool get isFeeding => _isFeeding;

  PetFoodInventory? get selectedFood {
    final pet = _currentPet;
    final selectedFoodId = _selectedFoodId;
    if (pet == null || selectedFoodId == null) {
      return null;
    }
    return pet.foodById(selectedFoodId);
  }

  bool get canFeed {
    final pet = _currentPet;
    final food = selectedFood;
    return !_isFeeding &&
        pet != null &&
        food != null &&
        food.quantity > 0 &&
        !pet.isFull;
  }

  Future<void> loadZoo(String userId) async {
    _currentUserId = userId;
    _isZooLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.ensureStarterData(userId);
      _pets = await repository.getOwnedPets(userId);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isZooLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadZoo() async {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }
    await loadZoo(userId);
  }

  Future<void> loadPetDetail(String userAnimalId) async {
    final userId = _currentUserId;
    if (userId == null) {
      _errorMessage = 'No active user found.';
      notifyListeners();
      return;
    }

    if (_currentPetId != userAnimalId) {
      _currentPet = null;
      _selectedFoodId = null;
    }

    _currentPetId = userAnimalId;
    _isDetailLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPet = await repository.getPetDetail(userId, userAnimalId);
      final selectedFoodId = _selectedFoodId;
      if (selectedFoodId != null &&
          (_currentPet?.foodById(selectedFoodId)?.quantity ?? 0) <= 0) {
        _selectedFoodId = null;
      }
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadCurrentPet() async {
    final petId = _currentPetId;
    if (petId == null) {
      return;
    }
    await loadPetDetail(petId);
  }

  void selectFood(String userFoodId) {
    if (_selectedFoodId == userFoodId) {
      _selectedFoodId = null;
    } else {
      _selectedFoodId = userFoodId;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> feedSelectedFood() async {
    final userId = _currentUserId;
    final petId = _currentPetId;
    final foodId = _selectedFoodId;

    if (userId == null || petId == null || foodId == null) {
      return false;
    }

    _isFeeding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.feedPet(userId, petId, foodId);
      _pets = await repository.getOwnedPets(userId);
      _currentPet = await repository.getPetDetail(userId, petId);
      if ((_currentPet?.foodById(foodId)?.quantity ?? 0) <= 0) {
        _selectedFoodId = null;
      }
      return true;
    } catch (error) {
      _errorMessage = _formatError(error);
      return false;
    } finally {
      _isFeeding = false;
      notifyListeners();
    }
  }

  String _formatError(Object error) {
    if (error is StateError) {
      return error.message.toString();
    }
    return 'Something went wrong.';
  }
}
