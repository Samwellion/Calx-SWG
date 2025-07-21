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
  IntColumn get setupId => integer().references(Setups, #id)();
  DateTimeColumn get setupDateTime => dateTime()();
  TextColumn get elementName => text()();
  TextColumn get time => text()(); // Format: HH:MM:SS
}

class Setups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get processPartId => integer().references(ProcessParts, #id)();
  TextColumn get setupName => text()();
}

class Study extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get setupId => integer().references(Setups, #id)();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get time => dateTime()();
  TextColumn get observerName => text()();
}

class TimeStudy extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studyId => integer().references(Study, #id)();
  IntColumn get setupElementId => integer().references(SetupElements, #id)();
  TextColumn get time => text()(); // Format: HH:MM:SS
}

@DriftDatabase(tables: [
  ProcessParts,
  Processes,
  Parts,
  Organizations,
  Plants,
  ValueStreams,
  SetupElements,
  Setups,
  Study,
  TimeStudy
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
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1 && to == 2) {
            await m.createTable(setups);
          }
          if (from == 2 && to == 3) {
            await m.createTable(study);
          }
          if (from == 3 && to == 4) {
            await m.createTable(timeStudy);
          }
          if (from == 4 && to == 5) {
            // Migration to replace setupName with setupId in SetupElements
            // This is a breaking change - existing data will be lost
            // In production, you would need to migrate data first
            await m.deleteTable('setup_elements');
            await m.createTable(setupElements);
          }
          if (from == 5 && to == 6) {
            // Force recreate setup_elements table to ensure setupId column exists
            await m.deleteTable('setup_elements');
            await m.createTable(setupElements);
          }
          if (from == 1 && to == 3) {
            await m.createTable(setups);
            await m.createTable(study);
          }
          if (from == 1 && to == 4) {
            await m.createTable(setups);
            await m.createTable(study);
            await m.createTable(timeStudy);
          }
          if (from == 1 && to == 5) {
            await m.createTable(setups);
            await m.createTable(study);
            await m.createTable(timeStudy);
            await m.deleteTable('setup_elements');
            await m.createTable(setupElements);
          }
          if (from == 1 && to == 6) {
            await m.createTable(setups);
            await m.createTable(study);
            await m.createTable(timeStudy);
            await m.deleteTable('setup_elements');
            await m.createTable(setupElements);
          }
          if (from == 2 && to == 4) {
            await m.createTable(study);
            await m.createTable(timeStudy);
          }
          if (from == 2 && to == 5) {
            await m.createTable(study);
            await m.createTable(timeStudy);
            await m.deleteTable('setup_elements');
            await m.createTable(setupElements);
          }
          if (from == 2 && to == 6) {
            await m.createTable(study);
            await m.createTable(timeStudy);
            await m.deleteTable('setup_elements');
            await m.createTable(setupElements);
          }
          if (from == 3 && to == 5) {
            await m.createTable(timeStudy);
            await m.deleteTable('setup_elements');
            await m.createTable(setupElements);
          }
          if (from == 3 && to == 6) {
            await m.createTable(timeStudy);
            await m.deleteTable('setup_elements');
            await m.createTable(setupElements);
          }
          if (from == 4 && to == 6) {
            await m.deleteTable('setup_elements');
            await m.createTable(setupElements);
          }
        },
      );

  Future<int> insertPart(PartsCompanion part) => into(parts).insert(part);
  Future<int> upsertValueStream(ValueStreamsCompanion entry) async {
    return into(valueStreams).insertOnConflictUpdate(entry);
  }

  // Setup management methods
  Future<int> insertSetup(SetupsCompanion setup) => into(setups).insert(setup);

  Future<List<Setup>> getSetupsForProcessPart(int processPartId) {
    return (select(setups)..where((s) => s.processPartId.equals(processPartId)))
        .get();
  }

  Future<Setup?> getSetupById(int setupId) {
    return (select(setups)..where((s) => s.id.equals(setupId)))
        .getSingleOrNull();
  }

  // Study management methods
  Future<int> insertStudy(StudyCompanion study) =>
      into(this.study).insert(study);

  Future<List<StudyData>> getStudiesForSetup(int setupId) {
    return (select(study)..where((s) => s.setupId.equals(setupId))).get();
  }

  Future<StudyData?> getStudyById(int studyId) {
    return (select(study)..where((s) => s.id.equals(studyId)))
        .getSingleOrNull();
  }

  Future<List<StudyData>> getStudiesByObserver(String observerName) {
    return (select(study)..where((s) => s.observerName.equals(observerName)))
        .get();
  }

  // TimeStudy management methods
  Future<int> insertTimeStudy(TimeStudyCompanion timeStudy) =>
      into(this.timeStudy).insert(timeStudy);

  Future<List<TimeStudyData>> getTimeStudiesForStudy(int studyId) {
    return (select(timeStudy)..where((ts) => ts.studyId.equals(studyId))).get();
  }

  Future<List<TimeStudyData>> getTimeStudiesForSetupElement(
      int setupElementId) {
    return (select(timeStudy)
          ..where((ts) => ts.setupElementId.equals(setupElementId)))
        .get();
  }

  Future<TimeStudyData?> getTimeStudyById(int timeStudyId) {
    return (select(timeStudy)..where((ts) => ts.id.equals(timeStudyId)))
        .getSingleOrNull();
  }

  // SetupElements management methods
  Future<int> insertSetupElement(SetupElementsCompanion setupElement) =>
      into(setupElements).insert(setupElement);

  Future<List<SetupElement>> getSetupElementsForSetup(int setupId) {
    return (select(setupElements)..where((se) => se.setupId.equals(setupId)))
        .get();
  }

  Future<List<SetupElement>> getSetupElementsForProcessPart(int processPartId) {
    return (select(setupElements)
          ..where((se) => se.processPartId.equals(processPartId)))
        .get();
  }

  Future<SetupElement?> getSetupElementById(int setupElementId) {
    return (select(setupElements)..where((se) => se.id.equals(setupElementId)))
        .getSingleOrNull();
  }

  Future<void> deleteSetupElement(int setupElementId) {
    return (delete(setupElements)..where((se) => se.id.equals(setupElementId)))
        .go();
  }

  Future<void> updateSetupElement(
      int setupElementId, SetupElementsCompanion companion) {
    return (update(setupElements)..where((se) => se.id.equals(setupElementId)))
        .write(companion);
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
          organizationId: Value(organizationId),
          name: Value(name),
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
