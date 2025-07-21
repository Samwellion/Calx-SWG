import 'app_database.dart';
import '../models/organization_data.dart' as org_data;
import 'package:drift/drift.dart' as drift;

//import '../screens/home_screen.dart';

class PlantRepository {
  final AppDatabase _db;

  PlantRepository(this._db);

  Future<void> savePlantDetails(
      org_data.PlantData plant, List<String> valueStreamNames) async {
    const orgId = 1; // Assuming a static orgId for now.

    await _db.upsertPlant(
      organizationId: orgId,
      name: plant.name,
      street: plant.street,
      city: plant.city,
      state: plant.state,
      zip: plant.zip,
    );

    final dbPlant = await (_db.select(_db.plants)
          ..where((tbl) =>
              tbl.organizationId.equals(orgId) & tbl.name.equals(plant.name)))
        .getSingleOrNull();
    final plantId = dbPlant?.id ?? -1;

    if (plantId == -1) {
      return; // Don't save value streams if plant wasn't saved
    }

    // First, delete existing value streams for this plant to handle removals
    await (_db.delete(_db.valueStreams)
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .go();

    // Then, insert the current ones
    for (final vsName in valueStreamNames) {
      await _db.upsertValueStream(
        ValueStreamsCompanion(
          plantId: drift.Value(plantId),
          name: drift.Value(vsName),
        ),
      );
    }
  }

  Future<PlantData?> getPlant(String plantName) async {
    return await (_db.select(_db.plants)
          ..where((tbl) => tbl.name.equals(plantName)))
        .getSingleOrNull();
  }

  Future<List<org_data.PlantData>> getAllPlants() async {
    final plants = await _db.select(_db.plants).get();
    return plants
        .map((dbPlant) => org_data.PlantData(
              name: dbPlant.name,
              street: dbPlant.street,
              city: dbPlant.city,
              state: dbPlant.state,
              zip: dbPlant.zip,
            ))
        .toList();
  }

  Future<List<String>> getValueStreams(int plantId) async {
    final valueStreams = await (_db.select(_db.valueStreams)
          ..where((tbl) => tbl.plantId.equals(plantId)))
        .get();
    return valueStreams.map((vs) => vs.name).toList();
  }
}
