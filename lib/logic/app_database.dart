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
  AppDatabase._(QueryExecutor e) : super(e);

  static Future<AppDatabase> open() async {
    final executor = await openConnection();
    return AppDatabase._(executor);
  }

  @override
  int get schemaVersion => 1;

  // CRUD methods can be added here
  // Insert an organization and return its id
  Future<int> insertOrganization(String name) {
    return into(organizations)
        .insert(OrganizationsCompanion(name: Value(name)));
  }

  // Insert a plant and return its id
  Future<int> insertPlant({required int organizationId, required String name}) {
    return into(plants).insert(PlantsCompanion(
      organizationId: Value(organizationId),
      name: Value(name),
    ));
  }

  // Insert a value stream and return its id
  Future<int> insertValueStream({required int plantId, required String name}) {
    return into(valueStreams).insert(ValueStreamsCompanion(
      plantId: Value(plantId),
      name: Value(name),
    ));
  }
}
