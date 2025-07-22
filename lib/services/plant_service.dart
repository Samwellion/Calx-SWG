import '../models/plant.dart';
import '../logic/app_database.dart' as db;
import 'package:drift/drift.dart' as drift;

/// Service class for managing Plant operations
/// Provides CRUD operations and business logic for Plant entities
class PlantService {
  final db.AppDatabase _db;

  PlantService(this._db);

  /// Create a new plant
  Future<Plant> createPlant(Plant plant) async {
    // Validate the plant before saving
    final validation = plant.validate();
    if (!validation.isValid) {
      throw PlantValidationException(validation.errors);
    }

    // If this is marked as primary, ensure no other plant is primary for this organization
    if (plant.isPrimary) {
      await _clearPrimaryStatusForOrganization(plant.organizationId);
    }

    final plantId = await _db.into(_db.plants).insert(
          db.PlantsCompanion(
            organizationId: drift.Value(plant.organizationId),
            name: drift.Value(plant.name),
            street: drift.Value(plant.street),
            city: drift.Value(plant.city),
            state: drift.Value(plant.state),
            zip: drift.Value(plant.zip),
          ),
        );

    // Save value streams if any
    if (plant.valueStreams.isNotEmpty) {
      await _saveValueStreams(plantId, plant.valueStreams);
    }

    // Return the created plant with the assigned ID
    return plant.copyWith(id: plantId);
  }

  /// Update an existing plant
  Future<Plant> updatePlant(Plant plant) async {
    if (plant.id == null) {
      throw ArgumentError('Plant ID is required for update');
    }

    // Validate the plant before saving
    final validation = plant.validate();
    if (!validation.isValid) {
      throw PlantValidationException(validation.errors);
    }

    // If this is marked as primary, ensure no other plant is primary for this organization
    if (plant.isPrimary) {
      await _clearPrimaryStatusForOrganization(plant.organizationId,
          excludePlantId: plant.id);
    }

    await (_db.update(_db.plants)..where((tbl) => tbl.id.equals(plant.id!)))
        .write(
      db.PlantsCompanion(
        organizationId: drift.Value(plant.organizationId),
        name: drift.Value(plant.name),
        street: drift.Value(plant.street),
        city: drift.Value(plant.city),
        state: drift.Value(plant.state),
        zip: drift.Value(plant.zip),
      ),
    );

    // Update value streams
    await _saveValueStreams(plant.id!, plant.valueStreams);

    return plant.copyWith(updatedAt: DateTime.now());
  }

  /// Get plant by ID
  Future<Plant?> getPlantById(int plantId) async {
    final dbPlant = await (_db.select(_db.plants)
          ..where((tbl) => tbl.id.equals(plantId)))
        .getSingleOrNull();

    if (dbPlant == null) return null;

    final valueStreams = await _getValueStreamsForPlant(plantId);

    return _mapDbPlantToModel(dbPlant, valueStreams);
  }

  /// Get plant by name and organization
  Future<Plant?> getPlantByName(String name, int organizationId) async {
    final dbPlant = await (_db.select(_db.plants)
          ..where((tbl) =>
              tbl.name.equals(name) &
              tbl.organizationId.equals(organizationId)))
        .getSingleOrNull();

    if (dbPlant == null) return null;

    final valueStreams = await _getValueStreamsForPlant(dbPlant.id);

    return _mapDbPlantToModel(dbPlant, valueStreams);
  }

  /// Get all plants for an organization
  Future<List<Plant>> getPlantsForOrganization(int organizationId) async {
    final dbPlants = await (_db.select(_db.plants)
          ..where((tbl) => tbl.organizationId.equals(organizationId)))
        .get();

    final plants = <Plant>[];
    for (final dbPlant in dbPlants) {
      final valueStreams = await _getValueStreamsForPlant(dbPlant.id);
      plants.add(_mapDbPlantToModel(dbPlant, valueStreams));
    }

    return plants;
  }

  /// Get all plants (across all organizations)
  Future<List<Plant>> getAllPlants() async {
    final dbPlants = await _db.select(_db.plants).get();

    final plants = <Plant>[];
    for (final dbPlant in dbPlants) {
      final valueStreams = await _getValueStreamsForPlant(dbPlant.id);
      plants.add(_mapDbPlantToModel(dbPlant, valueStreams));
    }

    return plants;
  }

  /// Get the primary plant for an organization
  Future<Plant?> getPrimaryPlantForOrganization(int organizationId) async {
    // For now, we'll return the first plant as primary since the current schema
    // doesn't have an isPrimary field. This can be updated when the schema is extended.
    final plants = await getPlantsForOrganization(organizationId);
    return plants.isNotEmpty ? plants.first : null;
  }

  /// Delete a plant
  Future<void> deletePlant(int plantId) async {
    // Delete associated value streams first
    await (_db.delete(_db.valueStreams)
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .go();

    // Delete the plant
    await (_db.delete(_db.plants)..where((tbl) => tbl.id.equals(plantId))).go();
  }

  /// Search plants by criteria
  Future<List<Plant>> searchPlants({
    String? nameFilter,
    String? cityFilter,
    String? stateFilter,
    PlantStatus? statusFilter,
    PlantType? typeFilter,
    int? organizationId,
  }) async {
    var query = _db.select(_db.plants);

    // Apply filters
    if (organizationId != null) {
      query = query..where((tbl) => tbl.organizationId.equals(organizationId));
    }
    if (nameFilter != null && nameFilter.isNotEmpty) {
      query = query..where((tbl) => tbl.name.contains(nameFilter));
    }
    if (cityFilter != null && cityFilter.isNotEmpty) {
      query = query..where((tbl) => tbl.city.contains(cityFilter));
    }
    if (stateFilter != null && stateFilter.isNotEmpty) {
      query = query..where((tbl) => tbl.state.contains(stateFilter));
    }

    final dbPlants = await query.get();

    final plants = <Plant>[];
    for (final dbPlant in dbPlants) {
      final valueStreams = await _getValueStreamsForPlant(dbPlant.id);
      final plant = _mapDbPlantToModel(dbPlant, valueStreams);

      // Apply additional filters that can't be done at DB level
      if (statusFilter != null && plant.status != statusFilter) continue;
      if (typeFilter != null && plant.plantType != typeFilter) continue;

      plants.add(plant);
    }

    return plants;
  }

  /// Add a value stream to a plant
  Future<void> addValueStreamToPlant(
      int plantId, String valueStreamName) async {
    await _db.upsertValueStream(
      db.ValueStreamsCompanion(
        plantId: drift.Value(plantId),
        name: drift.Value(valueStreamName),
      ),
    );
  }

  /// Remove a value stream from a plant
  Future<void> removeValueStreamFromPlant(
      int plantId, String valueStreamName) async {
    await (_db.delete(_db.valueStreams)
          ..where((tbl) =>
              tbl.plantId.equals(plantId) & tbl.name.equals(valueStreamName)))
        .go();
  }

  /// Get statistics for plants
  Future<PlantStatistics> getPlantStatistics({int? organizationId}) async {
    var query = _db.select(_db.plants);

    if (organizationId != null) {
      query = query..where((tbl) => tbl.organizationId.equals(organizationId));
    }

    final dbPlants = await query.get();

    return PlantStatistics(
      totalPlants: dbPlants.length,
      plantsByState: _groupPlantsByState(dbPlants),
      averagePlantsPerOrganization:
          organizationId != null ? dbPlants.length.toDouble() : 0.0,
    );
  }

  /// Private helper methods

  Future<void> _saveValueStreams(
      int plantId, List<String> valueStreamNames) async {
    // Delete existing value streams for this plant
    await (_db.delete(_db.valueStreams)
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .go();

    // Insert new value streams
    for (final vsName in valueStreamNames) {
      await _db.upsertValueStream(
        db.ValueStreamsCompanion(
          plantId: drift.Value(plantId),
          name: drift.Value(vsName),
        ),
      );
    }
  }

  Future<List<String>> _getValueStreamsForPlant(int plantId) async {
    final valueStreams = await (_db.select(_db.valueStreams)
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .get();
    return valueStreams.map((vs) => vs.name).toList();
  }

  Future<void> _clearPrimaryStatusForOrganization(int organizationId,
      {int? excludePlantId}) async {
    // This would be implemented when the database schema includes an isPrimary field
    // For now, this is a placeholder for future functionality
  }

  Plant _mapDbPlantToModel(db.PlantData dbPlant, List<String> valueStreams) {
    return Plant(
      id: dbPlant.id,
      organizationId: dbPlant.organizationId,
      name: dbPlant.name,
      street: dbPlant.street,
      city: dbPlant.city,
      state: dbPlant.state,
      zip: dbPlant.zip,
      valueStreams: valueStreams,
      // Default values for fields not in current schema
      plantType: PlantType.manufacturing,
      status: PlantStatus.active,
      createdAt: DateTime.now(), // Would come from DB when schema is updated
      updatedAt: DateTime.now(), // Would come from DB when schema is updated
    );
  }

  Map<String, int> _groupPlantsByState(List<db.PlantData> dbPlants) {
    final stateGroups = <String, int>{};
    for (final plant in dbPlants) {
      stateGroups[plant.state] = (stateGroups[plant.state] ?? 0) + 1;
    }
    return stateGroups;
  }
}

/// Exception thrown when plant validation fails
class PlantValidationException implements Exception {
  final List<String> errors;

  PlantValidationException(this.errors);

  @override
  String toString() {
    return 'PlantValidationException: ${errors.join(', ')}';
  }
}

/// Statistics about plants
class PlantStatistics {
  final int totalPlants;
  final Map<String, int> plantsByState;
  final double averagePlantsPerOrganization;

  PlantStatistics({
    required this.totalPlants,
    required this.plantsByState,
    required this.averagePlantsPerOrganization,
  });

  @override
  String toString() {
    return 'PlantStatistics(total: $totalPlants, states: ${plantsByState.length})';
  }
}
