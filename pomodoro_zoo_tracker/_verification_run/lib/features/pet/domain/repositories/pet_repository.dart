import '../entities/pet_detail.dart';
import '../entities/pet_summary.dart';

abstract class PetRepository {
  Future<void> ensureStarterData(String userId);
  Future<List<PetSummary>> getOwnedPets(String userId);
  Future<PetDetail?> getPetDetail(String userId, String userAnimalId);
  Future<void> feedPet(String userId, String userAnimalId, String userFoodId);
}
