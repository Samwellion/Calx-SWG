import 'package:drift/drift.dart';
import 'database_connection.dart';
part 'app_database.g.dart';

@DataClassName('Organization')
class Organizations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().named('Org_Name')();
}

@DataClassName('Plant')
class Plants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get organizationId => integer().references(Organizations, #id)();
  TextColumn get name => text().named('Plant_Name')();
  TextColumn get street =>
      text().named('Street').withLength(min: 1, max: 255)();
  TextColumn get city => text().named('City').withLength(min: 1, max: 255)();
  TextColumn get state => text().named('State').withLength(min: 1, max: 255)();
  TextColumn get zip => text().named('Zip').withLength(min: 1, max: 20)();
}

@DataClassName('ValueStream')
class ValueStreams extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer().references(Plants, #id)();
  TextColumn get name => text().named('VS_Name')();
}

@DriftDatabase(tables: [Organizations, Plants, ValueStreams])
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.e);

  static Future<AppDatabase> open() async {
    final executor = await openConnection();
    return AppDatabase._(executor);
  }

  @override
  int get schemaVersion => 1;

  // CRUD methods can be added here

  // Insert or get an organization by name and return its id
  Future<int> upsertOrganization(String name) async {
    final existing = await (select(organizations)
          ..where((o) => o.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(organizations)
        .insert(OrganizationsCompanion(name: Value(name)));
  }

  // Insert or get a plant by orgId+name and return its id
  Future<int> upsertPlant({
    required int organizationId,
    required String name,
    required String street,
    required String city,
    required String state,
    required String zip,
  }) async {
    final existing = await (select(plants)
          ..where((p) =>
              p.organizationId.equals(organizationId) & p.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(plants).insert(PlantsCompanion(
      organizationId: Value(organizationId),
      name: Value(name),
      street: Value(street),
      city: Value(city),
      state: Value(state),
      zip: Value(zip),
    ));
  }

  // Insert or get a value stream by plantId+name and return its id
  Future<int> upsertValueStream(
      {required int plantId, required String name}) async {
    final existing = await (select(valueStreams)
          ..where((vs) => vs.plantId.equals(plantId) & vs.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(valueStreams).insert(ValueStreamsCompanion(
      plantId: Value(plantId),
      name: Value(name),
    ));
  }
}
