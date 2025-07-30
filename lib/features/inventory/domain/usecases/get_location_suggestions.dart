import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/inventory_repository.dart';

@LazySingleton()
class GetLocationSuggestions implements UseCase<List<String>, NoParams> {
  final InventoryRepository repository;

  GetLocationSuggestions(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    final result = await repository.getInventoryItems();
    
    return result.fold(
      (failure) => Left(failure),
      (existingItems) {
        final locations = existingItems.map((item) => item.location).toSet().toList();
        locations.sort();
        
        // Agregar algunas sugerencias comunes si no existen
        const commonLocations = [
          'Almacén Principal',
          'Bodega A',
          'Bodega B',
          'Área de Cuarentena',
          'Refrigerador',
          'Laboratorio',
          'Vehículo 1',
          'Vehículo 2',
        ];
        
        for (final location in commonLocations) {
          if (!locations.contains(location)) {
            locations.add(location);
          }
        }
        
        return Right(locations);
      },
    );
  }
}