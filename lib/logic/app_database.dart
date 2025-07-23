import 'package:drift/drift.dart';
part 'app_database.g.dart';

// Value Stream table: stores value stream information for each plant
// Ensures value stream names are unique within each plant
class ValueStreams extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer()();
  TextColumn get name => text()();

  @override
  List<String> get customConstraints => [
        'UNIQUE(plant_id, name)' // Prevent duplicate value stream names per plant
      ];
}

class SetupElements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get processPartId => integer().references(ProcessParts, #id)();
  IntColumn get setupId => integer().references(Setups, #id)();
  DateTimeColumn get setupDateTime => dateTime()();
  TextColumn get elementName => text()();
  TextColumn get time => text()(); // Format: HH:MM:SS
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  // Fields migrated from TaskStudy table
  TextColumn get lrt => text().nullable()(); // LRT time in HH:MM:SS format
  TextColumn get overrideTime =>
      text().nullable()(); // Override time in HH:MM:SS format
  TextColumn get comments => text().nullable()();
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
  TextColumn get taskName => text()();
  TextColumn get iterationTime => text()(); // IterationTime in HH:MM:SS format
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

    try {
      return await into(organizations)
          .insert(OrganizationsCompanion(name: Value(name)));
    } catch (e) {
      // Handle unique constraint violation - another process may have inserted the same name
      final existing = await (select(organizations)
            ..where((o) => o.name.equals(name)))
          .getSingleOrNull();
      if (existing != null) return existing.id;
      rethrow; // Re-throw if it's a different error
    }
  }

  AppDatabase(super.e);

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Force complete recreation for version 15 - TaskStudy consolidated into SetupElements
          if (to >= 15) {
            await m.deleteTable('parts');
            await m.deleteTable('processes');
            await m.deleteTable('value_streams');
            await m.deleteTable('plants');
            await m.deleteTable('organizations');
            await m.deleteTable('setup_elements');
            await m.deleteTable('setups');
            await m.deleteTable('study');
            await m.deleteTable('task_study');
            await m.deleteTable('time_study');
            await m.deleteTable('process_parts');

            // Recreate all tables with current schema
            await m.createAll();
            return;
          }

          // Force complete recreation for version 14
          if (to >= 14) {
            await m.deleteTable('parts');
            await m.deleteTable('processes');
            await m.deleteTable('value_streams');
            await m.deleteTable('plants');
            await m.deleteTable('organizations');
            await m.deleteTable('setup_elements');
            await m.deleteTable('setups');
            await m.deleteTable('study');
            await m.deleteTable('task_study');
            await m.deleteTable('time_study');
            await m.deleteTable('process_parts');

            // Recreate all tables with current schema
            await m.createAll();
            return;
          }

          // Force complete recreation for version 13
          if (to >= 13) {
            await m.deleteTable('parts');
            await m.deleteTable('processes');
            await m.deleteTable('value_streams');
            await m.deleteTable('plants');
            await m.deleteTable('organizations');
            await m.deleteTable('setup_elements');
            await m.deleteTable('setups');
            await m.deleteTable('study');
            await m.deleteTable('time_study');
            await m.deleteTable('process_parts');

            // Recreate all tables with current schema
            await m.createAll();
            return;
          }

          // Handle any migration by recreating all tables if we're going to version 12
          if (to == 12) {
            // Drop all tables and recreate them with the latest schema
            await m.deleteTable('parts');
            await m.deleteTable('processes');
            await m.deleteTable('value_streams');
            await m.deleteTable('plants');
            await m.deleteTable('organizations');
            await m.deleteTable('setup_elements');
            await m.deleteTable('setups');
            await m.deleteTable('study');
            await m.deleteTable('time_study');
            await m.deleteTable('process_parts');

            // Recreate all tables with current schema
            await m.createAll();
            return;
          }

          // Legacy migrations for incremental updates
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
          if (from == 6 && to == 7) {
            // Add orderIndex column to SetupElements
            await m.addColumn(setupElements,
                setupElements.orderIndex as GeneratedColumn<Object>);
          }
          if (from == 7 && to == 8) {
            // Add organizationId column to Parts table and unique constraint
            // This requires recreating the table to add the constraint
            await m.deleteTable('parts');
            await m.createTable(parts);
          }
          if (from == 8 && to == 9) {
            // Add unique constraint to organization name
            // This requires recreating the table to add the constraint
            await m.deleteTable('organizations');
            await m.createTable(organizations);
          }
          if (from == 9 && to == 10) {
            // Add unique constraint to plant name per organization
            // This requires recreating the table to add the constraint
            await m.deleteTable('plants');
            await m.createTable(plants);
          }
          if (from == 10 && to == 11) {
            // Add unique constraint to value stream name per plant
            // This requires recreating the table to add the constraint
            await m.deleteTable('value_streams');
            await m.createTable(valueStreams);
          }
          if (from == 11 && to == 12) {
            // Add unique constraint to process name per value stream
            // This requires recreating the table to add the constraint
            await m.deleteTable('processes');
            await m.createTable(processes);
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

  // Upsert value stream - handles unique constraint on (plant_id, name)
  Future<int> upsertValueStream(ValueStreamsCompanion entry) async {
    return into(valueStreams).insertOnConflictUpdate(entry);
  }

  // Upsert process - handles unique constraint on (value_stream_id, process_name)
  Future<int> upsertProcess(ProcessesCompanion entry) async {
    return into(processes).insertOnConflictUpdate(entry);
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

  Future<TimeStudyData?> getTimeStudyById(int timeStudyId) {
    return (select(timeStudy)..where((ts) => ts.id.equals(timeStudyId)))
        .getSingleOrNull();
  }

  // SetupElements management methods (now includes TaskStudy functionality)
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

  // Method to replace TaskStudy functionality - get setup elements for a study
  Future<List<SetupElement>> getSetupElementsForStudy(int studyId) async {
    // Get the study to find its setupId
    final study = await (select(this.study)..where((s) => s.id.equals(studyId)))
        .getSingleOrNull();
    if (study == null) return [];

    // Get setup elements for this setup
    return (select(setupElements)
          ..where((se) => se.setupId.equals(study.setupId)))
        .get();
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
      try {
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
      } catch (e) {
        // Handle unique constraint violation - another process may have inserted the same plant name
        final existing = await (select(plants)
              ..where((tbl) =>
                  tbl.organizationId.equals(organizationId) &
                  tbl.name.equals(name)))
            .getSingleOrNull();
        if (existing != null) {
          // Update the existing plant with new information
          await (update(plants)..where((tbl) => tbl.id.equals(existing.id)))
              .write(
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
          rethrow; // Re-throw if it's a different error
        }
      }
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
// Ensures process names are unique within each value stream
class Processes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get valueStreamId => integer().references(ValueStreams, #id)();
  TextColumn get processName => text().named('process_name')();
  TextColumn get processDescription =>
      text().named('process_description').nullable()();

  @override
  List<String> get customConstraints => [
        'UNIQUE(value_stream_id, process_name)' // Prevent duplicate process names per value stream
      ];
}

// Part table: associates a part with a value stream
// Ensures part numbers are unique within each organization/company
class Parts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get valueStreamId => integer().references(ValueStreams, #id)();
  IntColumn get organizationId => integer().references(Organizations, #id)();
  TextColumn get partNumber => text()();
  TextColumn get partDescription => text().nullable()();

  @override
  List<String> get customConstraints => [
        'UNIQUE(organization_id, part_number)' // Prevent duplicate part numbers per company
      ];
}

// Organization/Company table: stores company information
// Ensures company names are unique across the system
@DataClassName('Organization')
class Organizations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().named('Org_Name').unique()();
}

// Plant table: stores plant information for each organization
// Ensures plant names are unique within each company
@DataClassName('PlantData')
class Plants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get organizationId => integer()();
  TextColumn get name => text()();
  TextColumn get street => text()();
  TextColumn get city => text()();
  TextColumn get state => text()();
  TextColumn get zip => text()();

  @override
  List<String> get customConstraints => [
        'UNIQUE(organization_id, name)' // Prevent duplicate plant names per company
      ];
}
