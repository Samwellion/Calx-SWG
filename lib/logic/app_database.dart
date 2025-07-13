import 'package:drift/drift.dart';
part 'app_database.g.dart';

class ValueStreams extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer()();
  TextColumn get name => text()();
}

class SetupElements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get processPartId => integer().references(ProcessParts, #id)();
  TextColumn get setupName => text()();
  DateTimeColumn get setupDateTime => dateTime()();
  TextColumn get elementName => text()();
  TextColumn get time => text()(); // Format: HH:MM:SS
}

@DriftDatabase(tables: [
  ProcessParts,
  Processes,
  Parts,
  Organizations,
  Plants,
  ValueStreams,
  SetupElements
])
class AppDatabase extends _$AppDatabase {
  // Insert or get an organization by name and return its id
  Future<int> upsertOrganization(String name) async {
    final existing = await (select(organizations)
          ..where((o) => o.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(organizations)
        .insert(OrganizationsCompanion(name: Value(name)));
  }

  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  Future<int> insertPart(PartsCompanion part) => into(parts).insert(part);
  Future<int> upsertValueStream(ValueStreamsCompanion entry) async {
    return into(valueStreams).insertOnConflictUpdate(entry);
  }

  // Add the method here:
  Future<void> upsertPlant({
    required int organizationId,
    required String name,
    required String street,
    required String city,
    required String state,
    required String zip,
  }) async {
    final existing = await (select(plants)
          ..where((tbl) =>
              tbl.organizationId.equals(organizationId) &
              tbl.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) {
      await (update(plants)..where((tbl) => tbl.id.equals(existing.id))).write(
        PlantsCompanion(
          street: Value(street),
          city: Value(city),
          state: Value(state),
          zip: Value(zip),
        ),
      );
    } else {
      await into(plants).insert(
        PlantsCompanion.insert(
          organizationId: organizationId,
          name: name,
          street: street,
          city: city,
          state: state,
          zip: zip,
        ),
      );
    }
  }
}

// ProcessPart table: associates a part number with a process
class ProcessParts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get partNumber => text()();
  IntColumn get processId => integer().references(Processes, #id)();
}

// Process table: associates a process with a value stream
class Processes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get valueStreamId => integer().references(ValueStreams, #id)();
  TextColumn get processName => text().named('process_name')();
  TextColumn get processDescription =>
      text().named('process_description').nullable()();
}

// Part table: associates a part with a value stream
class Parts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get valueStreamId => integer().references(ValueStreams, #id)();
  TextColumn get partNumber => text()();
  TextColumn get partDescription => text().nullable()();
}

@DataClassName('Organization')
class Organizations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().named('Org_Name')();
}

// Removed duplicate Plants table definition to resolve naming conflict.

@DataClassName('PlantData')
class Plants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get organizationId => integer()();
  TextColumn get name => text()();
  TextColumn get street => text()();
  TextColumn get city => text()();
  TextColumn get state => text()();
  TextColumn get zip => text()();
}
