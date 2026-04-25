import '../../domain/entities/pet_detail.dart';
import '../../domain/entities/pet_summary.dart';
import '../../domain/repositories/pet_repository.dart';
import '../datasources/pet_local_datasource.dart';

class PetRepositoryImpl implements PetRepository {
  final PetLocalDataSource dataSource;

  PetRepositoryImpl(this.dataSource);

  @override
  Future<void> ensureStarterData(String userId) async {
    await dataSource.ensureStarterData(userId);
  }

  @override
  Future<List<PetSummary>> getOwnedPets(String userId) async {
    return dataSource.getOwnedPets(userId);
  }

  @override
  Future<PetDetail?> getPetDetail(String userId, String userAnimalId) async {
    return dataSource.getPetDetail(userId, userAnimalId);
  }

  @override
  Future<void> feedPet(String userId, String userAnimalId, String userFoodId) async {
    await dataSource.feedPet(userId, userAnimalId, userFoodId);
  }
}
