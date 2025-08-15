import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'app_database.g.dart';

// Unit of Measure enum for ValueStreams
enum UnitOfMeasure {
  each('Each'),
  pieces('Pieces'),
  units('Units'),
  pounds('Pounds'),
  kilograms('Kilograms'),
  tons('Tons'),
  feet('Feet'),
  meters('Meters'),
  inches('Inches'),
  centimeters('Centimeters'),
  gallons('Gallons'),
  liters('Liters'),
  hours('Hours'),
  days('Days'),
  boxes('Boxes'),
  pallets('Pallets'),
  cases('Cases'),
  dozens('Dozens');

  const UnitOfMeasure(this.displayName);
  final String displayName;
}

// Value Stream table: stores value stream information for each plant
// Ensures value stream names are unique within each plant
class ValueStreams extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plantId => integer()();
  TextColumn get name => text()();

  // New fields
  IntColumn get mDemand => integer().nullable()(); // Monthly Demand
  IntColumn get uom => intEnum<UnitOfMeasure>().nullable()(); // Unit of Measure
  IntColumn get mngrEmpId => integer().nullable()(); // Manager Employee ID
  TextColumn get taktTime => text().nullable()(); // Format: HH:MM:SS

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

// Canvas State table: stores the state of canvas icons for each value stream and part
@DataClassName('CanvasState')
class CanvasStates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get valueStreamId => integer()();
  TextColumn get partNumber => text()();
  TextColumn get iconType => text()(); // Type of icon (customer, supplier, truck, etc.)
  TextColumn get iconId => text()(); // Unique ID for the icon instance
  RealColumn get positionX => real()(); // X position on canvas
  RealColumn get positionY => real()(); // Y position on canvas
  TextColumn get userData => text().nullable()(); // JSON string for user input data
  DateTimeColumn get lastModified => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
        'UNIQUE(value_stream_id, part_number, icon_id)' // Prevent duplicate icon IDs per value stream/part
      ];
}

@DriftDatabase(tables: [
  ProcessParts,
  ProcessShift,
  VSShifts,
  Processes,
  Parts,
  Organizations,
  Plants,
  ValueStreams,
  CanvasStates,
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
  int get schemaVersion => 25;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Add CanvasStates table for version 25
          if (to >= 25) {
            // Just create the new table if it doesn't exist
            await m.createTable(canvasStates);
            return;
          }

          // Force complete recreation for version 17 - Added ProcessShift table and new fields to ProcessParts
          if (to >= 17) {
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
            await m.deleteTable('process_shift');

            // Recreate all tables with current schema
            await m.createAll();
            return;
          }

          // Force complete recreation for version 16 - Added new fields to Processes table
          if (to >= 16) {
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
          if (from == 17 && to == 18) {
            // Add orderIndex column to Processes table
            await m.addColumn(processes, processes.orderIndex);
          }
          if (from == 18 && to == 19) {
            // Add new fields to ValueStreams and create VSShifts table
            await m.addColumn(
                valueStreams, valueStreams.mDemand as GeneratedColumn<Object>);
            await m.addColumn(
                valueStreams, valueStreams.uom as GeneratedColumn<Object>);
            await m.addColumn(valueStreams,
                valueStreams.mngrEmpId as GeneratedColumn<Object>);
            await m.createTable(vSShifts);
          }
          if (from == 19 && to == 20) {
            // Fix VSShifts table name - try to preserve data if the old table exists
            try {
              // Check if the old table exists and has data
              final oldData =
                  await customSelect('SELECT * FROM v_s_shifts').get();

              // Create the new table with correct name
              await m.createTable(vSShifts);

              // If we had data in the old table, migrate it
              if (oldData.isNotEmpty) {
                for (final row in oldData) {
                  await customInsert(
                    'INSERT INTO vs_shifts (id, vs_id, shift_name, sun, mon, tue, wed, thu, fri, sat) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                    variables: [
                      Variable<int>(row.data['id'] as int),
                      Variable<int>(row.data['vs_id'] as int),
                      Variable<String>(row.data['shift_name'] as String),
                      Variable<String>(row.data['sun'] as String? ?? ''),
                      Variable<String>(row.data['mon'] as String? ?? ''),
                      Variable<String>(row.data['tue'] as String? ?? ''),
                      Variable<String>(row.data['wed'] as String? ?? ''),
                      Variable<String>(row.data['thu'] as String? ?? ''),
                      Variable<String>(row.data['fri'] as String? ?? ''),
                      Variable<String>(row.data['sat'] as String? ?? ''),
                    ],
                  );
                }
              }

              // Drop the old table
              await m.deleteTable('v_s_shifts');
            } catch (e) {
              // If old table doesn't exist or migration fails, just create the new table
              await m.createTable(vSShifts);
            }
          }
          if (from == 20 && to == 21) {
            // Add canvas positioning fields to Processes table
            await m.addColumn(
                processes, processes.positionX as GeneratedColumn<Object>);
            await m.addColumn(
                processes, processes.positionY as GeneratedColumn<Object>);
            await m.addColumn(
                processes, processes.color as GeneratedColumn<Object>);
          }
          if (from == 21 && to == 22) {
            // Add monthlyDemand field to Parts table
            await m.addColumn(
                parts, parts.monthlyDemand as GeneratedColumn<Object>);
          }
          if (from == 22 && to == 23) {
            // Add taktTime field to ValueStreams table
            await m.addColumn(
                valueStreams, valueStreams.taktTime as GeneratedColumn<Object>);
          }
          if (from == 23 && to == 24) {
            // Rename cycleTime to processTime in ProcessParts table
            // This requires recreating the table due to column rename
            await m.deleteTable('process_parts');
            await m.createTable(processParts);
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

  // Copy VSShifts to ProcessShift when a new process is added
  Future<void> copyVSShiftsToProcessShift(
      int valueStreamId, int processId) async {
    try {
      // Get all shift records for the value stream
      final vsShifts = await (select(vSShifts)
            ..where((vs) => vs.vsId.equals(valueStreamId)))
          .get();

      if (vsShifts.isNotEmpty) {
        // Copy each VSShift record to ProcessShift table
        for (final vsShift in vsShifts) {
          await into(processShift).insert(
            ProcessShiftCompanion.insert(
              processId: processId,
              shiftName: vsShift.shiftName,
              sun: Value(vsShift.sun),
              mon: Value(vsShift.mon),
              tue: Value(vsShift.tue),
              wed: Value(vsShift.wed),
              thu: Value(vsShift.thu),
              fri: Value(vsShift.fri),
              sat: Value(vsShift.sat),
            ),
          );
        }
      } else {
        // No VSShifts records exist, create a placeholder record
        await into(processShift).insert(
          ProcessShiftCompanion.insert(
            processId: processId,
            shiftName: 'TBD',
            sun: const Value(null),
            mon: const Value(null),
            tue: const Value(null),
            wed: const Value(null),
            thu: const Value(null),
            fri: const Value(null),
            sat: const Value(null),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error copying VSShifts to ProcessShift: $e');
      rethrow;
    }
  }

  // Get ProcessShift records for a specific process
  Future<List<ProcessShiftData>> getProcessShifts(int processId) async {
    try {
      final shifts = await (select(processShift)
            ..where((ps) => ps.processId.equals(processId)))
          .get();

      // If no shifts exist, create a "TBD" record
      if (shifts.isEmpty) {
        await into(processShift).insert(
          ProcessShiftCompanion.insert(
            processId: processId,
            shiftName: 'TBD',
            sun: const Value(null),
            mon: const Value(null),
            tue: const Value(null),
            wed: const Value(null),
            thu: const Value(null),
            fri: const Value(null),
            sat: const Value(null),
          ),
        );

        // Return the newly created record
        return await (select(processShift)
              ..where((ps) => ps.processId.equals(processId)))
            .get();
      }

      return shifts;
    } catch (e) {
      debugPrint('Error getting ProcessShifts: $e');
      rethrow;
    }
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

  // Process Canvas Methods
  Future<List<ProcessesData>> getProcessesForValueStream(int valueStreamId) {
    return (select(processes)
          ..where((p) => p.valueStreamId.equals(valueStreamId)))
        .get();
  }

  Future<ProcessPart?> getProcessPartByPartNumberAndProcessId(
      String partNumber, int processId) async {
    return await (select(processParts)
          ..where((pp) =>
              pp.partNumber.equals(partNumber) &
              pp.processId.equals(processId)))
        .getSingleOrNull();
  }

  Future<String?> calculateAverageCycleTimeForProcess(int processId) async {
    try {
      // Get all cycle times from ProcessParts for this process
      final query = select(processParts)
        ..where((pp) => pp.processId.equals(processId));

      final processPartsList = await query.get();

      List<int> cycleTimesInSeconds = [];

      for (final part in processPartsList) {
        String? processTimeString = part.userOverrideTime ?? part.processTime;

        if (processTimeString != null && processTimeString.isNotEmpty) {
          final timeInSeconds = _parseTimeStringToSeconds(processTimeString);
          if (timeInSeconds > 0) {
            cycleTimesInSeconds.add(timeInSeconds);
          }
        }
      }

      if (cycleTimesInSeconds.isNotEmpty) {
        // Calculate average cycle time
        final averageSeconds = cycleTimesInSeconds.reduce((a, b) => a + b) /
            cycleTimesInSeconds.length;
        return _formatSecondsToTimeString(averageSeconds.round());
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  int _parseTimeStringToSeconds(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return (hours * 3600) + (minutes * 60) + seconds;
      }
    } catch (e) {
      // Invalid time format
    }
    return 0;
  }

  String _formatSecondsToTimeString(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<String?> getSelectedPartNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedPartNumber');
  }

  Future<void> updateProcessPosition(int processId, double x, double y) async {
    await (update(processes)..where((p) => p.id.equals(processId)))
        .write(ProcessesCompanion(
      positionX: Value(x),
      positionY: Value(y),
    ));
  }

  Future<void> updateProcess(
    int processId, {
    String? name,
    String? description,
    String? colorHex,
    int? staff,
    int? dailyDemand,
    int? wip,
    double? uptime,
    String? coTime,
    String? taktTime,
  }) async {
    final companion = ProcessesCompanion(
      processName: name != null ? Value(name) : const Value.absent(),
      processDescription:
          description != null ? Value(description) : const Value.absent(),
      color: colorHex != null ? Value(colorHex) : const Value.absent(),
      staff: staff != null ? Value(staff) : const Value.absent(),
      dailyDemand:
          dailyDemand != null ? Value(dailyDemand) : const Value.absent(),
      wip: wip != null ? Value(wip) : const Value.absent(),
      uptime: uptime != null ? Value(uptime) : const Value.absent(),
      coTime: coTime != null ? Value(coTime) : const Value.absent(),
      taktTime: taktTime != null ? Value(taktTime) : const Value.absent(),
    );

    await (update(processes)..where((p) => p.id.equals(processId)))
        .write(companion);
  }

  Future<void> updateProcessPart(
    String partNumber,
    int processId, {
    String? processTime,
    double? fpy,
  }) async {
    final companion = ProcessPartsCompanion(
      processTime: processTime != null ? Value(processTime) : const Value.absent(),
      fpy: fpy != null ? Value(fpy) : const Value.absent(),
    );

    await (update(processParts)
          ..where((pp) =>
              pp.partNumber.equals(partNumber) &
              pp.processId.equals(processId)))
        .write(companion);
  }

  Future<void> deleteProcess(int processId) async {
    await (delete(processes)..where((p) => p.id.equals(processId))).go();
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

  // Canvas State Management Methods
  Future<void> saveCanvasState({
    required int valueStreamId,
    required String partNumber,
    required String iconType,
    required String iconId,
    required double positionX,
    required double positionY,
    String? userData,
  }) async {
    await into(canvasStates).insertOnConflictUpdate(
      CanvasStatesCompanion.insert(
        valueStreamId: valueStreamId,
        partNumber: partNumber,
        iconType: iconType,
        iconId: iconId,
        positionX: positionX,
        positionY: positionY,
        userData: Value(userData),
        lastModified: Value(DateTime.now()),
      ),
    );
  }

  Future<List<CanvasState>> loadCanvasState({
    required int valueStreamId,
    required String partNumber,
  }) async {
    return await (select(canvasStates)
          ..where((cs) =>
              cs.valueStreamId.equals(valueStreamId) &
              cs.partNumber.equals(partNumber)))
        .get();
  }

  Future<void> deleteCanvasIcon({
    required int valueStreamId,
    required String partNumber,
    required String iconId,
  }) async {
    await (delete(canvasStates)
          ..where((cs) =>
              cs.valueStreamId.equals(valueStreamId) &
              cs.partNumber.equals(partNumber) &
              cs.iconId.equals(iconId)))
        .go();
  }

  Future<void> clearCanvasState({
    required int valueStreamId,
    required String partNumber,
  }) async {
    await (delete(canvasStates)
          ..where((cs) =>
              cs.valueStreamId.equals(valueStreamId) &
              cs.partNumber.equals(partNumber)))
        .go();
  }
}

// ProcessPart table: associates a part number with a process
class ProcessParts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get partNumber => text()();
  IntColumn get processId => integer().references(Processes, #id)();

  // New fields for process parts management
  IntColumn get dailyDemand => integer().nullable()();
  TextColumn get processTime => text().nullable()(); // Format: HH:MM:SS
  TextColumn get userOverrideTime => text().nullable()(); // Format: HH:MM:SS
  RealColumn get fpy =>
      real().nullable()(); // First Pass Yield as decimal (e.g., 0.95 for 95%)
}

// ProcessShift table: stores shift schedules for each process
class ProcessShift extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get processId => integer().references(Processes, #id)();
  TextColumn get shiftName => text()();

  // Shift times for each day of the week (Format: HH:MM:SS)
  TextColumn get sun => text().nullable()(); // Sunday shift time
  TextColumn get mon => text().nullable()(); // Monday shift time
  TextColumn get tue => text().nullable()(); // Tuesday shift time
  TextColumn get wed => text().nullable()(); // Wednesday shift time
  TextColumn get thu => text().nullable()(); // Thursday shift time
  TextColumn get fri => text().nullable()(); // Friday shift time
  TextColumn get sat => text().nullable()(); // Saturday shift time
}

// VSShifts table: stores shift schedules for each value stream
class VSShifts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vsId => integer().references(
      ValueStreams, #id)(); // Links to ValueStream instead of Process
  TextColumn get shiftName => text()();

  // Shift times for each day of the week (Format: HH:MM:SS)
  TextColumn get sun => text().nullable()(); // Sunday shift time
  TextColumn get mon => text().nullable()(); // Monday shift time
  TextColumn get tue => text().nullable()(); // Tuesday shift time
  TextColumn get wed => text().nullable()(); // Wednesday shift time
  TextColumn get thu => text().nullable()(); // Thursday shift time
  TextColumn get fri => text().nullable()(); // Friday shift time
  TextColumn get sat => text().nullable()(); // Saturday shift time

  @override
  String get tableName => 'vs_shifts';
}

// Process table: associates a process with a value stream
// Ensures process names are unique within each value stream
class Processes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get valueStreamId => integer().references(ValueStreams, #id)();
  TextColumn get processName => text().named('process_name')();
  TextColumn get processDescription =>
      text().named('process_description').nullable()();

  // New fields for process management
  IntColumn get dailyDemand => integer().nullable()();
  IntColumn get staff => integer().nullable()();
  IntColumn get wip => integer().nullable()();
  RealColumn get uptime =>
      real().nullable()(); // Percentage as decimal (e.g., 0.85 for 85%)
  TextColumn get coTime => text().nullable()(); // Format: HH:MM:SS
  TextColumn get taktTime => text().nullable()(); // Format: HH:MM:SS
  IntColumn get orderIndex =>
      integer().withDefault(const Constant(0))(); // For custom user ordering

  // Canvas positioning fields
  RealColumn get positionX => real().nullable()(); // X position on canvas
  RealColumn get positionY => real().nullable()(); // Y position on canvas
  TextColumn get color => text().nullable()(); // Color as hex string

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
  IntColumn get monthlyDemand =>
      integer().nullable()(); // Monthly demand for the part

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
