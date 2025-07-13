// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ValueStreamsTable extends ValueStreams
    with TableInfo<$ValueStreamsTable, ValueStream> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ValueStreamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _plantIdMeta =
      const VerificationMeta('plantId');
  @override
  late final GeneratedColumn<int> plantId = GeneratedColumn<int>(
      'plant_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, plantId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'value_streams';
  @override
  VerificationContext validateIntegrity(Insertable<ValueStream> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plant_id')) {
      context.handle(_plantIdMeta,
          plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta));
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ValueStream map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ValueStream(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      plantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plant_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $ValueStreamsTable createAlias(String alias) {
    return $ValueStreamsTable(attachedDatabase, alias);
  }
}

class ValueStream extends DataClass implements Insertable<ValueStream> {
  final int id;
  final int plantId;
  final String name;
  const ValueStream(
      {required this.id, required this.plantId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plant_id'] = Variable<int>(plantId);
    map['name'] = Variable<String>(name);
    return map;
  }

  ValueStreamsCompanion toCompanion(bool nullToAbsent) {
    return ValueStreamsCompanion(
      id: Value(id),
      plantId: Value(plantId),
      name: Value(name),
    );
  }

  factory ValueStream.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ValueStream(
      id: serializer.fromJson<int>(json['id']),
      plantId: serializer.fromJson<int>(json['plantId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plantId': serializer.toJson<int>(plantId),
      'name': serializer.toJson<String>(name),
    };
  }

  ValueStream copyWith({int? id, int? plantId, String? name}) => ValueStream(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        name: name ?? this.name,
      );
  ValueStream copyWithCompanion(ValueStreamsCompanion data) {
    return ValueStream(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ValueStream(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plantId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ValueStream &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.name == this.name);
}

class ValueStreamsCompanion extends UpdateCompanion<ValueStream> {
  final Value<int> id;
  final Value<int> plantId;
  final Value<String> name;
  const ValueStreamsCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.name = const Value.absent(),
  });
  ValueStreamsCompanion.insert({
    this.id = const Value.absent(),
    required int plantId,
    required String name,
  })  : plantId = Value(plantId),
        name = Value(name);
  static Insertable<ValueStream> custom({
    Expression<int>? id,
    Expression<int>? plantId,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (name != null) 'name': name,
    });
  }

  ValueStreamsCompanion copyWith(
      {Value<int>? id, Value<int>? plantId, Value<String>? name}) {
    return ValueStreamsCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<int>(plantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ValueStreamsCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ProcessesTable extends Processes
    with TableInfo<$ProcessesTable, ProcessesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _valueStreamIdMeta =
      const VerificationMeta('valueStreamId');
  @override
  late final GeneratedColumn<int> valueStreamId = GeneratedColumn<int>(
      'value_stream_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES value_streams (id)'));
  static const VerificationMeta _processNameMeta =
      const VerificationMeta('processName');
  @override
  late final GeneratedColumn<String> processName = GeneratedColumn<String>(
      'process_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _processDescriptionMeta =
      const VerificationMeta('processDescription');
  @override
  late final GeneratedColumn<String> processDescription =
      GeneratedColumn<String>('process_description', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, valueStreamId, processName, processDescription];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'processes';
  @override
  VerificationContext validateIntegrity(Insertable<ProcessesData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('value_stream_id')) {
      context.handle(
          _valueStreamIdMeta,
          valueStreamId.isAcceptableOrUnknown(
              data['value_stream_id']!, _valueStreamIdMeta));
    } else if (isInserting) {
      context.missing(_valueStreamIdMeta);
    }
    if (data.containsKey('process_name')) {
      context.handle(
          _processNameMeta,
          processName.isAcceptableOrUnknown(
              data['process_name']!, _processNameMeta));
    } else if (isInserting) {
      context.missing(_processNameMeta);
    }
    if (data.containsKey('process_description')) {
      context.handle(
          _processDescriptionMeta,
          processDescription.isAcceptableOrUnknown(
              data['process_description']!, _processDescriptionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessesData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      valueStreamId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}value_stream_id'])!,
      processName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}process_name'])!,
      processDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}process_description']),
    );
  }

  @override
  $ProcessesTable createAlias(String alias) {
    return $ProcessesTable(attachedDatabase, alias);
  }
}

class ProcessesData extends DataClass implements Insertable<ProcessesData> {
  final int id;
  final int valueStreamId;
  final String processName;
  final String? processDescription;
  const ProcessesData(
      {required this.id,
      required this.valueStreamId,
      required this.processName,
      this.processDescription});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['value_stream_id'] = Variable<int>(valueStreamId);
    map['process_name'] = Variable<String>(processName);
    if (!nullToAbsent || processDescription != null) {
      map['process_description'] = Variable<String>(processDescription);
    }
    return map;
  }

  ProcessesCompanion toCompanion(bool nullToAbsent) {
    return ProcessesCompanion(
      id: Value(id),
      valueStreamId: Value(valueStreamId),
      processName: Value(processName),
      processDescription: processDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(processDescription),
    );
  }

  factory ProcessesData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessesData(
      id: serializer.fromJson<int>(json['id']),
      valueStreamId: serializer.fromJson<int>(json['valueStreamId']),
      processName: serializer.fromJson<String>(json['processName']),
      processDescription:
          serializer.fromJson<String?>(json['processDescription']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'valueStreamId': serializer.toJson<int>(valueStreamId),
      'processName': serializer.toJson<String>(processName),
      'processDescription': serializer.toJson<String?>(processDescription),
    };
  }

  ProcessesData copyWith(
          {int? id,
          int? valueStreamId,
          String? processName,
          Value<String?> processDescription = const Value.absent()}) =>
      ProcessesData(
        id: id ?? this.id,
        valueStreamId: valueStreamId ?? this.valueStreamId,
        processName: processName ?? this.processName,
        processDescription: processDescription.present
            ? processDescription.value
            : this.processDescription,
      );
  ProcessesData copyWithCompanion(ProcessesCompanion data) {
    return ProcessesData(
      id: data.id.present ? data.id.value : this.id,
      valueStreamId: data.valueStreamId.present
          ? data.valueStreamId.value
          : this.valueStreamId,
      processName:
          data.processName.present ? data.processName.value : this.processName,
      processDescription: data.processDescription.present
          ? data.processDescription.value
          : this.processDescription,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessesData(')
          ..write('id: $id, ')
          ..write('valueStreamId: $valueStreamId, ')
          ..write('processName: $processName, ')
          ..write('processDescription: $processDescription')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, valueStreamId, processName, processDescription);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessesData &&
          other.id == this.id &&
          other.valueStreamId == this.valueStreamId &&
          other.processName == this.processName &&
          other.processDescription == this.processDescription);
}

class ProcessesCompanion extends UpdateCompanion<ProcessesData> {
  final Value<int> id;
  final Value<int> valueStreamId;
  final Value<String> processName;
  final Value<String?> processDescription;
  const ProcessesCompanion({
    this.id = const Value.absent(),
    this.valueStreamId = const Value.absent(),
    this.processName = const Value.absent(),
    this.processDescription = const Value.absent(),
  });
  ProcessesCompanion.insert({
    this.id = const Value.absent(),
    required int valueStreamId,
    required String processName,
    this.processDescription = const Value.absent(),
  })  : valueStreamId = Value(valueStreamId),
        processName = Value(processName);
  static Insertable<ProcessesData> custom({
    Expression<int>? id,
    Expression<int>? valueStreamId,
    Expression<String>? processName,
    Expression<String>? processDescription,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (valueStreamId != null) 'value_stream_id': valueStreamId,
      if (processName != null) 'process_name': processName,
      if (processDescription != null) 'process_description': processDescription,
    });
  }

  ProcessesCompanion copyWith(
      {Value<int>? id,
      Value<int>? valueStreamId,
      Value<String>? processName,
      Value<String?>? processDescription}) {
    return ProcessesCompanion(
      id: id ?? this.id,
      valueStreamId: valueStreamId ?? this.valueStreamId,
      processName: processName ?? this.processName,
      processDescription: processDescription ?? this.processDescription,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (valueStreamId.present) {
      map['value_stream_id'] = Variable<int>(valueStreamId.value);
    }
    if (processName.present) {
      map['process_name'] = Variable<String>(processName.value);
    }
    if (processDescription.present) {
      map['process_description'] = Variable<String>(processDescription.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessesCompanion(')
          ..write('id: $id, ')
          ..write('valueStreamId: $valueStreamId, ')
          ..write('processName: $processName, ')
          ..write('processDescription: $processDescription')
          ..write(')'))
        .toString();
  }
}

class $ProcessPartsTable extends ProcessParts
    with TableInfo<$ProcessPartsTable, ProcessPart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessPartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _partNumberMeta =
      const VerificationMeta('partNumber');
  @override
  late final GeneratedColumn<String> partNumber = GeneratedColumn<String>(
      'part_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _processIdMeta =
      const VerificationMeta('processId');
  @override
  late final GeneratedColumn<int> processId = GeneratedColumn<int>(
      'process_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES processes (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, partNumber, processId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'process_parts';
  @override
  VerificationContext validateIntegrity(Insertable<ProcessPart> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('part_number')) {
      context.handle(
          _partNumberMeta,
          partNumber.isAcceptableOrUnknown(
              data['part_number']!, _partNumberMeta));
    } else if (isInserting) {
      context.missing(_partNumberMeta);
    }
    if (data.containsKey('process_id')) {
      context.handle(_processIdMeta,
          processId.isAcceptableOrUnknown(data['process_id']!, _processIdMeta));
    } else if (isInserting) {
      context.missing(_processIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessPart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessPart(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      partNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_number'])!,
      processId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}process_id'])!,
    );
  }

  @override
  $ProcessPartsTable createAlias(String alias) {
    return $ProcessPartsTable(attachedDatabase, alias);
  }
}

class ProcessPart extends DataClass implements Insertable<ProcessPart> {
  final int id;
  final String partNumber;
  final int processId;
  const ProcessPart(
      {required this.id, required this.partNumber, required this.processId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['part_number'] = Variable<String>(partNumber);
    map['process_id'] = Variable<int>(processId);
    return map;
  }

  ProcessPartsCompanion toCompanion(bool nullToAbsent) {
    return ProcessPartsCompanion(
      id: Value(id),
      partNumber: Value(partNumber),
      processId: Value(processId),
    );
  }

  factory ProcessPart.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessPart(
      id: serializer.fromJson<int>(json['id']),
      partNumber: serializer.fromJson<String>(json['partNumber']),
      processId: serializer.fromJson<int>(json['processId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partNumber': serializer.toJson<String>(partNumber),
      'processId': serializer.toJson<int>(processId),
    };
  }

  ProcessPart copyWith({int? id, String? partNumber, int? processId}) =>
      ProcessPart(
        id: id ?? this.id,
        partNumber: partNumber ?? this.partNumber,
        processId: processId ?? this.processId,
      );
  ProcessPart copyWithCompanion(ProcessPartsCompanion data) {
    return ProcessPart(
      id: data.id.present ? data.id.value : this.id,
      partNumber:
          data.partNumber.present ? data.partNumber.value : this.partNumber,
      processId: data.processId.present ? data.processId.value : this.processId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessPart(')
          ..write('id: $id, ')
          ..write('partNumber: $partNumber, ')
          ..write('processId: $processId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, partNumber, processId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessPart &&
          other.id == this.id &&
          other.partNumber == this.partNumber &&
          other.processId == this.processId);
}

class ProcessPartsCompanion extends UpdateCompanion<ProcessPart> {
  final Value<int> id;
  final Value<String> partNumber;
  final Value<int> processId;
  const ProcessPartsCompanion({
    this.id = const Value.absent(),
    this.partNumber = const Value.absent(),
    this.processId = const Value.absent(),
  });
  ProcessPartsCompanion.insert({
    this.id = const Value.absent(),
    required String partNumber,
    required int processId,
  })  : partNumber = Value(partNumber),
        processId = Value(processId);
  static Insertable<ProcessPart> custom({
    Expression<int>? id,
    Expression<String>? partNumber,
    Expression<int>? processId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partNumber != null) 'part_number': partNumber,
      if (processId != null) 'process_id': processId,
    });
  }

  ProcessPartsCompanion copyWith(
      {Value<int>? id, Value<String>? partNumber, Value<int>? processId}) {
    return ProcessPartsCompanion(
      id: id ?? this.id,
      partNumber: partNumber ?? this.partNumber,
      processId: processId ?? this.processId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partNumber.present) {
      map['part_number'] = Variable<String>(partNumber.value);
    }
    if (processId.present) {
      map['process_id'] = Variable<int>(processId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessPartsCompanion(')
          ..write('id: $id, ')
          ..write('partNumber: $partNumber, ')
          ..write('processId: $processId')
          ..write(')'))
        .toString();
  }
}

class $PartsTable extends Parts with TableInfo<$PartsTable, Part> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _valueStreamIdMeta =
      const VerificationMeta('valueStreamId');
  @override
  late final GeneratedColumn<int> valueStreamId = GeneratedColumn<int>(
      'value_stream_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES value_streams (id)'));
  static const VerificationMeta _partNumberMeta =
      const VerificationMeta('partNumber');
  @override
  late final GeneratedColumn<String> partNumber = GeneratedColumn<String>(
      'part_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partDescriptionMeta =
      const VerificationMeta('partDescription');
  @override
  late final GeneratedColumn<String> partDescription = GeneratedColumn<String>(
      'part_description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, valueStreamId, partNumber, partDescription];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parts';
  @override
  VerificationContext validateIntegrity(Insertable<Part> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('value_stream_id')) {
      context.handle(
          _valueStreamIdMeta,
          valueStreamId.isAcceptableOrUnknown(
              data['value_stream_id']!, _valueStreamIdMeta));
    } else if (isInserting) {
      context.missing(_valueStreamIdMeta);
    }
    if (data.containsKey('part_number')) {
      context.handle(
          _partNumberMeta,
          partNumber.isAcceptableOrUnknown(
              data['part_number']!, _partNumberMeta));
    } else if (isInserting) {
      context.missing(_partNumberMeta);
    }
    if (data.containsKey('part_description')) {
      context.handle(
          _partDescriptionMeta,
          partDescription.isAcceptableOrUnknown(
              data['part_description']!, _partDescriptionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Part map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Part(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      valueStreamId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}value_stream_id'])!,
      partNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_number'])!,
      partDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}part_description']),
    );
  }

  @override
  $PartsTable createAlias(String alias) {
    return $PartsTable(attachedDatabase, alias);
  }
}

class Part extends DataClass implements Insertable<Part> {
  final int id;
  final int valueStreamId;
  final String partNumber;
  final String? partDescription;
  const Part(
      {required this.id,
      required this.valueStreamId,
      required this.partNumber,
      this.partDescription});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['value_stream_id'] = Variable<int>(valueStreamId);
    map['part_number'] = Variable<String>(partNumber);
    if (!nullToAbsent || partDescription != null) {
      map['part_description'] = Variable<String>(partDescription);
    }
    return map;
  }

  PartsCompanion toCompanion(bool nullToAbsent) {
    return PartsCompanion(
      id: Value(id),
      valueStreamId: Value(valueStreamId),
      partNumber: Value(partNumber),
      partDescription: partDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(partDescription),
    );
  }

  factory Part.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Part(
      id: serializer.fromJson<int>(json['id']),
      valueStreamId: serializer.fromJson<int>(json['valueStreamId']),
      partNumber: serializer.fromJson<String>(json['partNumber']),
      partDescription: serializer.fromJson<String?>(json['partDescription']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'valueStreamId': serializer.toJson<int>(valueStreamId),
      'partNumber': serializer.toJson<String>(partNumber),
      'partDescription': serializer.toJson<String?>(partDescription),
    };
  }

  Part copyWith(
          {int? id,
          int? valueStreamId,
          String? partNumber,
          Value<String?> partDescription = const Value.absent()}) =>
      Part(
        id: id ?? this.id,
        valueStreamId: valueStreamId ?? this.valueStreamId,
        partNumber: partNumber ?? this.partNumber,
        partDescription: partDescription.present
            ? partDescription.value
            : this.partDescription,
      );
  Part copyWithCompanion(PartsCompanion data) {
    return Part(
      id: data.id.present ? data.id.value : this.id,
      valueStreamId: data.valueStreamId.present
          ? data.valueStreamId.value
          : this.valueStreamId,
      partNumber:
          data.partNumber.present ? data.partNumber.value : this.partNumber,
      partDescription: data.partDescription.present
          ? data.partDescription.value
          : this.partDescription,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Part(')
          ..write('id: $id, ')
          ..write('valueStreamId: $valueStreamId, ')
          ..write('partNumber: $partNumber, ')
          ..write('partDescription: $partDescription')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, valueStreamId, partNumber, partDescription);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Part &&
          other.id == this.id &&
          other.valueStreamId == this.valueStreamId &&
          other.partNumber == this.partNumber &&
          other.partDescription == this.partDescription);
}

class PartsCompanion extends UpdateCompanion<Part> {
  final Value<int> id;
  final Value<int> valueStreamId;
  final Value<String> partNumber;
  final Value<String?> partDescription;
  const PartsCompanion({
    this.id = const Value.absent(),
    this.valueStreamId = const Value.absent(),
    this.partNumber = const Value.absent(),
    this.partDescription = const Value.absent(),
  });
  PartsCompanion.insert({
    this.id = const Value.absent(),
    required int valueStreamId,
    required String partNumber,
    this.partDescription = const Value.absent(),
  })  : valueStreamId = Value(valueStreamId),
        partNumber = Value(partNumber);
  static Insertable<Part> custom({
    Expression<int>? id,
    Expression<int>? valueStreamId,
    Expression<String>? partNumber,
    Expression<String>? partDescription,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (valueStreamId != null) 'value_stream_id': valueStreamId,
      if (partNumber != null) 'part_number': partNumber,
      if (partDescription != null) 'part_description': partDescription,
    });
  }

  PartsCompanion copyWith(
      {Value<int>? id,
      Value<int>? valueStreamId,
      Value<String>? partNumber,
      Value<String?>? partDescription}) {
    return PartsCompanion(
      id: id ?? this.id,
      valueStreamId: valueStreamId ?? this.valueStreamId,
      partNumber: partNumber ?? this.partNumber,
      partDescription: partDescription ?? this.partDescription,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (valueStreamId.present) {
      map['value_stream_id'] = Variable<int>(valueStreamId.value);
    }
    if (partNumber.present) {
      map['part_number'] = Variable<String>(partNumber.value);
    }
    if (partDescription.present) {
      map['part_description'] = Variable<String>(partDescription.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartsCompanion(')
          ..write('id: $id, ')
          ..write('valueStreamId: $valueStreamId, ')
          ..write('partNumber: $partNumber, ')
          ..write('partDescription: $partDescription')
          ..write(')'))
        .toString();
  }
}

class $OrganizationsTable extends Organizations
    with TableInfo<$OrganizationsTable, Organization> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrganizationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'Org_Name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'organizations';
  @override
  VerificationContext validateIntegrity(Insertable<Organization> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('Org_Name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['Org_Name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Organization map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Organization(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Org_Name'])!,
    );
  }

  @override
  $OrganizationsTable createAlias(String alias) {
    return $OrganizationsTable(attachedDatabase, alias);
  }
}

class Organization extends DataClass implements Insertable<Organization> {
  final int id;
  final String name;
  const Organization({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['Org_Name'] = Variable<String>(name);
    return map;
  }

  OrganizationsCompanion toCompanion(bool nullToAbsent) {
    return OrganizationsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Organization.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Organization(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Organization copyWith({int? id, String? name}) => Organization(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Organization copyWithCompanion(OrganizationsCompanion data) {
    return Organization(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Organization(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Organization && other.id == this.id && other.name == this.name);
}

class OrganizationsCompanion extends UpdateCompanion<Organization> {
  final Value<int> id;
  final Value<String> name;
  const OrganizationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  OrganizationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Organization> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'Org_Name': name,
    });
  }

  OrganizationsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return OrganizationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['Org_Name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $PlantsTable extends Plants with TableInfo<$PlantsTable, PlantData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _organizationIdMeta =
      const VerificationMeta('organizationId');
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
      'organization_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
      'street', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _zipMeta = const VerificationMeta('zip');
  @override
  late final GeneratedColumn<String> zip = GeneratedColumn<String>(
      'zip', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, organizationId, name, street, city, state, zip];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plants';
  @override
  VerificationContext validateIntegrity(Insertable<PlantData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('organization_id')) {
      context.handle(
          _organizationIdMeta,
          organizationId.isAcceptableOrUnknown(
              data['organization_id']!, _organizationIdMeta));
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('street')) {
      context.handle(_streetMeta,
          street.isAcceptableOrUnknown(data['street']!, _streetMeta));
    } else if (isInserting) {
      context.missing(_streetMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('zip')) {
      context.handle(
          _zipMeta, zip.isAcceptableOrUnknown(data['zip']!, _zipMeta));
    } else if (isInserting) {
      context.missing(_zipMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlantData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      organizationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}organization_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      street: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}street'])!,
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      zip: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zip'])!,
    );
  }

  @override
  $PlantsTable createAlias(String alias) {
    return $PlantsTable(attachedDatabase, alias);
  }
}

class PlantData extends DataClass implements Insertable<PlantData> {
  final int id;
  final int organizationId;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zip;
  const PlantData(
      {required this.id,
      required this.organizationId,
      required this.name,
      required this.street,
      required this.city,
      required this.state,
      required this.zip});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['organization_id'] = Variable<int>(organizationId);
    map['name'] = Variable<String>(name);
    map['street'] = Variable<String>(street);
    map['city'] = Variable<String>(city);
    map['state'] = Variable<String>(state);
    map['zip'] = Variable<String>(zip);
    return map;
  }

  PlantsCompanion toCompanion(bool nullToAbsent) {
    return PlantsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      name: Value(name),
      street: Value(street),
      city: Value(city),
      state: Value(state),
      zip: Value(zip),
    );
  }

  factory PlantData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantData(
      id: serializer.fromJson<int>(json['id']),
      organizationId: serializer.fromJson<int>(json['organizationId']),
      name: serializer.fromJson<String>(json['name']),
      street: serializer.fromJson<String>(json['street']),
      city: serializer.fromJson<String>(json['city']),
      state: serializer.fromJson<String>(json['state']),
      zip: serializer.fromJson<String>(json['zip']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'organizationId': serializer.toJson<int>(organizationId),
      'name': serializer.toJson<String>(name),
      'street': serializer.toJson<String>(street),
      'city': serializer.toJson<String>(city),
      'state': serializer.toJson<String>(state),
      'zip': serializer.toJson<String>(zip),
    };
  }

  PlantData copyWith(
          {int? id,
          int? organizationId,
          String? name,
          String? street,
          String? city,
          String? state,
          String? zip}) =>
      PlantData(
        id: id ?? this.id,
        organizationId: organizationId ?? this.organizationId,
        name: name ?? this.name,
        street: street ?? this.street,
        city: city ?? this.city,
        state: state ?? this.state,
        zip: zip ?? this.zip,
      );
  PlantData copyWithCompanion(PlantsCompanion data) {
    return PlantData(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      name: data.name.present ? data.name.value : this.name,
      street: data.street.present ? data.street.value : this.street,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      zip: data.zip.present ? data.zip.value : this.zip,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantData(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('name: $name, ')
          ..write('street: $street, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('zip: $zip')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, organizationId, name, street, city, state, zip);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantData &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.name == this.name &&
          other.street == this.street &&
          other.city == this.city &&
          other.state == this.state &&
          other.zip == this.zip);
}

class PlantsCompanion extends UpdateCompanion<PlantData> {
  final Value<int> id;
  final Value<int> organizationId;
  final Value<String> name;
  final Value<String> street;
  final Value<String> city;
  final Value<String> state;
  final Value<String> zip;
  const PlantsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.name = const Value.absent(),
    this.street = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.zip = const Value.absent(),
  });
  PlantsCompanion.insert({
    this.id = const Value.absent(),
    required int organizationId,
    required String name,
    required String street,
    required String city,
    required String state,
    required String zip,
  })  : organizationId = Value(organizationId),
        name = Value(name),
        street = Value(street),
        city = Value(city),
        state = Value(state),
        zip = Value(zip);
  static Insertable<PlantData> custom({
    Expression<int>? id,
    Expression<int>? organizationId,
    Expression<String>? name,
    Expression<String>? street,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? zip,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (name != null) 'name': name,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (zip != null) 'zip': zip,
    });
  }

  PlantsCompanion copyWith(
      {Value<int>? id,
      Value<int>? organizationId,
      Value<String>? name,
      Value<String>? street,
      Value<String>? city,
      Value<String>? state,
      Value<String>? zip}) {
    return PlantsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (zip.present) {
      map['zip'] = Variable<String>(zip.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('name: $name, ')
          ..write('street: $street, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('zip: $zip')
          ..write(')'))
        .toString();
  }
}

class $SetupElementsTable extends SetupElements
    with TableInfo<$SetupElementsTable, SetupElement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetupElementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _processPartIdMeta =
      const VerificationMeta('processPartId');
  @override
  late final GeneratedColumn<int> processPartId = GeneratedColumn<int>(
      'process_part_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES process_parts (id)'));
  static const VerificationMeta _setupNameMeta =
      const VerificationMeta('setupName');
  @override
  late final GeneratedColumn<String> setupName = GeneratedColumn<String>(
      'setup_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _setupDateTimeMeta =
      const VerificationMeta('setupDateTime');
  @override
  late final GeneratedColumn<DateTime> setupDateTime =
      GeneratedColumn<DateTime>('setup_date_time', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _elementNameMeta =
      const VerificationMeta('elementName');
  @override
  late final GeneratedColumn<String> elementName = GeneratedColumn<String>(
      'element_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
      'time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, processPartId, setupName, setupDateTime, elementName, time];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setup_elements';
  @override
  VerificationContext validateIntegrity(Insertable<SetupElement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('process_part_id')) {
      context.handle(
          _processPartIdMeta,
          processPartId.isAcceptableOrUnknown(
              data['process_part_id']!, _processPartIdMeta));
    } else if (isInserting) {
      context.missing(_processPartIdMeta);
    }
    if (data.containsKey('setup_name')) {
      context.handle(_setupNameMeta,
          setupName.isAcceptableOrUnknown(data['setup_name']!, _setupNameMeta));
    } else if (isInserting) {
      context.missing(_setupNameMeta);
    }
    if (data.containsKey('setup_date_time')) {
      context.handle(
          _setupDateTimeMeta,
          setupDateTime.isAcceptableOrUnknown(
              data['setup_date_time']!, _setupDateTimeMeta));
    } else if (isInserting) {
      context.missing(_setupDateTimeMeta);
    }
    if (data.containsKey('element_name')) {
      context.handle(
          _elementNameMeta,
          elementName.isAcceptableOrUnknown(
              data['element_name']!, _elementNameMeta));
    } else if (isInserting) {
      context.missing(_elementNameMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetupElement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetupElement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      processPartId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}process_part_id'])!,
      setupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setup_name'])!,
      setupDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}setup_date_time'])!,
      elementName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}element_name'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
    );
  }

  @override
  $SetupElementsTable createAlias(String alias) {
    return $SetupElementsTable(attachedDatabase, alias);
  }
}

class SetupElement extends DataClass implements Insertable<SetupElement> {
  final int id;
  final int processPartId;
  final String setupName;
  final DateTime setupDateTime;
  final String elementName;
  final String time;
  const SetupElement(
      {required this.id,
      required this.processPartId,
      required this.setupName,
      required this.setupDateTime,
      required this.elementName,
      required this.time});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['process_part_id'] = Variable<int>(processPartId);
    map['setup_name'] = Variable<String>(setupName);
    map['setup_date_time'] = Variable<DateTime>(setupDateTime);
    map['element_name'] = Variable<String>(elementName);
    map['time'] = Variable<String>(time);
    return map;
  }

  SetupElementsCompanion toCompanion(bool nullToAbsent) {
    return SetupElementsCompanion(
      id: Value(id),
      processPartId: Value(processPartId),
      setupName: Value(setupName),
      setupDateTime: Value(setupDateTime),
      elementName: Value(elementName),
      time: Value(time),
    );
  }

  factory SetupElement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetupElement(
      id: serializer.fromJson<int>(json['id']),
      processPartId: serializer.fromJson<int>(json['processPartId']),
      setupName: serializer.fromJson<String>(json['setupName']),
      setupDateTime: serializer.fromJson<DateTime>(json['setupDateTime']),
      elementName: serializer.fromJson<String>(json['elementName']),
      time: serializer.fromJson<String>(json['time']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'processPartId': serializer.toJson<int>(processPartId),
      'setupName': serializer.toJson<String>(setupName),
      'setupDateTime': serializer.toJson<DateTime>(setupDateTime),
      'elementName': serializer.toJson<String>(elementName),
      'time': serializer.toJson<String>(time),
    };
  }

  SetupElement copyWith(
          {int? id,
          int? processPartId,
          String? setupName,
          DateTime? setupDateTime,
          String? elementName,
          String? time}) =>
      SetupElement(
        id: id ?? this.id,
        processPartId: processPartId ?? this.processPartId,
        setupName: setupName ?? this.setupName,
        setupDateTime: setupDateTime ?? this.setupDateTime,
        elementName: elementName ?? this.elementName,
        time: time ?? this.time,
      );
  SetupElement copyWithCompanion(SetupElementsCompanion data) {
    return SetupElement(
      id: data.id.present ? data.id.value : this.id,
      processPartId: data.processPartId.present
          ? data.processPartId.value
          : this.processPartId,
      setupName: data.setupName.present ? data.setupName.value : this.setupName,
      setupDateTime: data.setupDateTime.present
          ? data.setupDateTime.value
          : this.setupDateTime,
      elementName:
          data.elementName.present ? data.elementName.value : this.elementName,
      time: data.time.present ? data.time.value : this.time,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetupElement(')
          ..write('id: $id, ')
          ..write('processPartId: $processPartId, ')
          ..write('setupName: $setupName, ')
          ..write('setupDateTime: $setupDateTime, ')
          ..write('elementName: $elementName, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, processPartId, setupName, setupDateTime, elementName, time);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetupElement &&
          other.id == this.id &&
          other.processPartId == this.processPartId &&
          other.setupName == this.setupName &&
          other.setupDateTime == this.setupDateTime &&
          other.elementName == this.elementName &&
          other.time == this.time);
}

class SetupElementsCompanion extends UpdateCompanion<SetupElement> {
  final Value<int> id;
  final Value<int> processPartId;
  final Value<String> setupName;
  final Value<DateTime> setupDateTime;
  final Value<String> elementName;
  final Value<String> time;
  const SetupElementsCompanion({
    this.id = const Value.absent(),
    this.processPartId = const Value.absent(),
    this.setupName = const Value.absent(),
    this.setupDateTime = const Value.absent(),
    this.elementName = const Value.absent(),
    this.time = const Value.absent(),
  });
  SetupElementsCompanion.insert({
    this.id = const Value.absent(),
    required int processPartId,
    required String setupName,
    required DateTime setupDateTime,
    required String elementName,
    required String time,
  })  : processPartId = Value(processPartId),
        setupName = Value(setupName),
        setupDateTime = Value(setupDateTime),
        elementName = Value(elementName),
        time = Value(time);
  static Insertable<SetupElement> custom({
    Expression<int>? id,
    Expression<int>? processPartId,
    Expression<String>? setupName,
    Expression<DateTime>? setupDateTime,
    Expression<String>? elementName,
    Expression<String>? time,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (processPartId != null) 'process_part_id': processPartId,
      if (setupName != null) 'setup_name': setupName,
      if (setupDateTime != null) 'setup_date_time': setupDateTime,
      if (elementName != null) 'element_name': elementName,
      if (time != null) 'time': time,
    });
  }

  SetupElementsCompanion copyWith(
      {Value<int>? id,
      Value<int>? processPartId,
      Value<String>? setupName,
      Value<DateTime>? setupDateTime,
      Value<String>? elementName,
      Value<String>? time}) {
    return SetupElementsCompanion(
      id: id ?? this.id,
      processPartId: processPartId ?? this.processPartId,
      setupName: setupName ?? this.setupName,
      setupDateTime: setupDateTime ?? this.setupDateTime,
      elementName: elementName ?? this.elementName,
      time: time ?? this.time,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (processPartId.present) {
      map['process_part_id'] = Variable<int>(processPartId.value);
    }
    if (setupName.present) {
      map['setup_name'] = Variable<String>(setupName.value);
    }
    if (setupDateTime.present) {
      map['setup_date_time'] = Variable<DateTime>(setupDateTime.value);
    }
    if (elementName.present) {
      map['element_name'] = Variable<String>(elementName.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetupElementsCompanion(')
          ..write('id: $id, ')
          ..write('processPartId: $processPartId, ')
          ..write('setupName: $setupName, ')
          ..write('setupDateTime: $setupDateTime, ')
          ..write('elementName: $elementName, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ValueStreamsTable valueStreams = $ValueStreamsTable(this);
  late final $ProcessesTable processes = $ProcessesTable(this);
  late final $ProcessPartsTable processParts = $ProcessPartsTable(this);
  late final $PartsTable parts = $PartsTable(this);
  late final $OrganizationsTable organizations = $OrganizationsTable(this);
  late final $PlantsTable plants = $PlantsTable(this);
  late final $SetupElementsTable setupElements = $SetupElementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        valueStreams,
        processes,
        processParts,
        parts,
        organizations,
        plants,
        setupElements
      ];
}

typedef $$ValueStreamsTableCreateCompanionBuilder = ValueStreamsCompanion
    Function({
  Value<int> id,
  required int plantId,
  required String name,
});
typedef $$ValueStreamsTableUpdateCompanionBuilder = ValueStreamsCompanion
    Function({
  Value<int> id,
  Value<int> plantId,
  Value<String> name,
});

final class $$ValueStreamsTableReferences
    extends BaseReferences<_$AppDatabase, $ValueStreamsTable, ValueStream> {
  $$ValueStreamsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProcessesTable, List<ProcessesData>>
      _processesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.processes,
              aliasName: $_aliasNameGenerator(
                  db.valueStreams.id, db.processes.valueStreamId));

  $$ProcessesTableProcessedTableManager get processesRefs {
    final manager = $$ProcessesTableTableManager($_db, $_db.processes)
        .filter((f) => f.valueStreamId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_processesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PartsTable, List<Part>> _partsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.parts,
          aliasName:
              $_aliasNameGenerator(db.valueStreams.id, db.parts.valueStreamId));

  $$PartsTableProcessedTableManager get partsRefs {
    final manager = $$PartsTableTableManager($_db, $_db.parts)
        .filter((f) => f.valueStreamId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ValueStreamsTableFilterComposer
    extends Composer<_$AppDatabase, $ValueStreamsTable> {
  $$ValueStreamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plantId => $composableBuilder(
      column: $table.plantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> processesRefs(
      Expression<bool> Function($$ProcessesTableFilterComposer f) f) {
    final $$ProcessesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.processes,
        getReferencedColumn: (t) => t.valueStreamId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessesTableFilterComposer(
              $db: $db,
              $table: $db.processes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> partsRefs(
      Expression<bool> Function($$PartsTableFilterComposer f) f) {
    final $$PartsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.valueStreamId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableFilterComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ValueStreamsTableOrderingComposer
    extends Composer<_$AppDatabase, $ValueStreamsTable> {
  $$ValueStreamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plantId => $composableBuilder(
      column: $table.plantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$ValueStreamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ValueStreamsTable> {
  $$ValueStreamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> processesRefs<T extends Object>(
      Expression<T> Function($$ProcessesTableAnnotationComposer a) f) {
    final $$ProcessesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.processes,
        getReferencedColumn: (t) => t.valueStreamId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessesTableAnnotationComposer(
              $db: $db,
              $table: $db.processes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> partsRefs<T extends Object>(
      Expression<T> Function($$PartsTableAnnotationComposer a) f) {
    final $$PartsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.valueStreamId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableAnnotationComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ValueStreamsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ValueStreamsTable,
    ValueStream,
    $$ValueStreamsTableFilterComposer,
    $$ValueStreamsTableOrderingComposer,
    $$ValueStreamsTableAnnotationComposer,
    $$ValueStreamsTableCreateCompanionBuilder,
    $$ValueStreamsTableUpdateCompanionBuilder,
    (ValueStream, $$ValueStreamsTableReferences),
    ValueStream,
    PrefetchHooks Function({bool processesRefs, bool partsRefs})> {
  $$ValueStreamsTableTableManager(_$AppDatabase db, $ValueStreamsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ValueStreamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ValueStreamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ValueStreamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> plantId = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              ValueStreamsCompanion(
            id: id,
            plantId: plantId,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int plantId,
            required String name,
          }) =>
              ValueStreamsCompanion.insert(
            id: id,
            plantId: plantId,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ValueStreamsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({processesRefs = false, partsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (processesRefs) db.processes,
                if (partsRefs) db.parts
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (processesRefs)
                    await $_getPrefetchedData<ValueStream, $ValueStreamsTable,
                            ProcessesData>(
                        currentTable: table,
                        referencedTable: $$ValueStreamsTableReferences
                            ._processesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ValueStreamsTableReferences(db, table, p0)
                                .processesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.valueStreamId == item.id),
                        typedResults: items),
                  if (partsRefs)
                    await $_getPrefetchedData<ValueStream, $ValueStreamsTable,
                            Part>(
                        currentTable: table,
                        referencedTable:
                            $$ValueStreamsTableReferences._partsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ValueStreamsTableReferences(db, table, p0)
                                .partsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.valueStreamId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ValueStreamsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ValueStreamsTable,
    ValueStream,
    $$ValueStreamsTableFilterComposer,
    $$ValueStreamsTableOrderingComposer,
    $$ValueStreamsTableAnnotationComposer,
    $$ValueStreamsTableCreateCompanionBuilder,
    $$ValueStreamsTableUpdateCompanionBuilder,
    (ValueStream, $$ValueStreamsTableReferences),
    ValueStream,
    PrefetchHooks Function({bool processesRefs, bool partsRefs})>;
typedef $$ProcessesTableCreateCompanionBuilder = ProcessesCompanion Function({
  Value<int> id,
  required int valueStreamId,
  required String processName,
  Value<String?> processDescription,
});
typedef $$ProcessesTableUpdateCompanionBuilder = ProcessesCompanion Function({
  Value<int> id,
  Value<int> valueStreamId,
  Value<String> processName,
  Value<String?> processDescription,
});

final class $$ProcessesTableReferences
    extends BaseReferences<_$AppDatabase, $ProcessesTable, ProcessesData> {
  $$ProcessesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ValueStreamsTable _valueStreamIdTable(_$AppDatabase db) =>
      db.valueStreams.createAlias(
          $_aliasNameGenerator(db.processes.valueStreamId, db.valueStreams.id));

  $$ValueStreamsTableProcessedTableManager get valueStreamId {
    final $_column = $_itemColumn<int>('value_stream_id')!;

    final manager = $$ValueStreamsTableTableManager($_db, $_db.valueStreams)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_valueStreamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ProcessPartsTable, List<ProcessPart>>
      _processPartsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.processParts,
          aliasName:
              $_aliasNameGenerator(db.processes.id, db.processParts.processId));

  $$ProcessPartsTableProcessedTableManager get processPartsRefs {
    final manager = $$ProcessPartsTableTableManager($_db, $_db.processParts)
        .filter((f) => f.processId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_processPartsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProcessesTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessesTable> {
  $$ProcessesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processName => $composableBuilder(
      column: $table.processName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processDescription => $composableBuilder(
      column: $table.processDescription,
      builder: (column) => ColumnFilters(column));

  $$ValueStreamsTableFilterComposer get valueStreamId {
    final $$ValueStreamsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.valueStreamId,
        referencedTable: $db.valueStreams,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ValueStreamsTableFilterComposer(
              $db: $db,
              $table: $db.valueStreams,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> processPartsRefs(
      Expression<bool> Function($$ProcessPartsTableFilterComposer f) f) {
    final $$ProcessPartsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.processParts,
        getReferencedColumn: (t) => t.processId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessPartsTableFilterComposer(
              $db: $db,
              $table: $db.processParts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProcessesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessesTable> {
  $$ProcessesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processName => $composableBuilder(
      column: $table.processName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processDescription => $composableBuilder(
      column: $table.processDescription,
      builder: (column) => ColumnOrderings(column));

  $$ValueStreamsTableOrderingComposer get valueStreamId {
    final $$ValueStreamsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.valueStreamId,
        referencedTable: $db.valueStreams,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ValueStreamsTableOrderingComposer(
              $db: $db,
              $table: $db.valueStreams,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProcessesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessesTable> {
  $$ProcessesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get processName => $composableBuilder(
      column: $table.processName, builder: (column) => column);

  GeneratedColumn<String> get processDescription => $composableBuilder(
      column: $table.processDescription, builder: (column) => column);

  $$ValueStreamsTableAnnotationComposer get valueStreamId {
    final $$ValueStreamsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.valueStreamId,
        referencedTable: $db.valueStreams,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ValueStreamsTableAnnotationComposer(
              $db: $db,
              $table: $db.valueStreams,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> processPartsRefs<T extends Object>(
      Expression<T> Function($$ProcessPartsTableAnnotationComposer a) f) {
    final $$ProcessPartsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.processParts,
        getReferencedColumn: (t) => t.processId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessPartsTableAnnotationComposer(
              $db: $db,
              $table: $db.processParts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProcessesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProcessesTable,
    ProcessesData,
    $$ProcessesTableFilterComposer,
    $$ProcessesTableOrderingComposer,
    $$ProcessesTableAnnotationComposer,
    $$ProcessesTableCreateCompanionBuilder,
    $$ProcessesTableUpdateCompanionBuilder,
    (ProcessesData, $$ProcessesTableReferences),
    ProcessesData,
    PrefetchHooks Function({bool valueStreamId, bool processPartsRefs})> {
  $$ProcessesTableTableManager(_$AppDatabase db, $ProcessesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> valueStreamId = const Value.absent(),
            Value<String> processName = const Value.absent(),
            Value<String?> processDescription = const Value.absent(),
          }) =>
              ProcessesCompanion(
            id: id,
            valueStreamId: valueStreamId,
            processName: processName,
            processDescription: processDescription,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int valueStreamId,
            required String processName,
            Value<String?> processDescription = const Value.absent(),
          }) =>
              ProcessesCompanion.insert(
            id: id,
            valueStreamId: valueStreamId,
            processName: processName,
            processDescription: processDescription,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProcessesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {valueStreamId = false, processPartsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (processPartsRefs) db.processParts],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (valueStreamId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.valueStreamId,
                    referencedTable:
                        $$ProcessesTableReferences._valueStreamIdTable(db),
                    referencedColumn:
                        $$ProcessesTableReferences._valueStreamIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (processPartsRefs)
                    await $_getPrefetchedData<ProcessesData, $ProcessesTable,
                            ProcessPart>(
                        currentTable: table,
                        referencedTable: $$ProcessesTableReferences
                            ._processPartsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProcessesTableReferences(db, table, p0)
                                .processPartsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.processId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProcessesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProcessesTable,
    ProcessesData,
    $$ProcessesTableFilterComposer,
    $$ProcessesTableOrderingComposer,
    $$ProcessesTableAnnotationComposer,
    $$ProcessesTableCreateCompanionBuilder,
    $$ProcessesTableUpdateCompanionBuilder,
    (ProcessesData, $$ProcessesTableReferences),
    ProcessesData,
    PrefetchHooks Function({bool valueStreamId, bool processPartsRefs})>;
typedef $$ProcessPartsTableCreateCompanionBuilder = ProcessPartsCompanion
    Function({
  Value<int> id,
  required String partNumber,
  required int processId,
});
typedef $$ProcessPartsTableUpdateCompanionBuilder = ProcessPartsCompanion
    Function({
  Value<int> id,
  Value<String> partNumber,
  Value<int> processId,
});

final class $$ProcessPartsTableReferences
    extends BaseReferences<_$AppDatabase, $ProcessPartsTable, ProcessPart> {
  $$ProcessPartsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProcessesTable _processIdTable(_$AppDatabase db) =>
      db.processes.createAlias(
          $_aliasNameGenerator(db.processParts.processId, db.processes.id));

  $$ProcessesTableProcessedTableManager get processId {
    final $_column = $_itemColumn<int>('process_id')!;

    final manager = $$ProcessesTableTableManager($_db, $_db.processes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_processIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SetupElementsTable, List<SetupElement>>
      _setupElementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.setupElements,
              aliasName: $_aliasNameGenerator(
                  db.processParts.id, db.setupElements.processPartId));

  $$SetupElementsTableProcessedTableManager get setupElementsRefs {
    final manager = $$SetupElementsTableTableManager($_db, $_db.setupElements)
        .filter((f) => f.processPartId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setupElementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProcessPartsTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessPartsTable> {
  $$ProcessPartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => ColumnFilters(column));

  $$ProcessesTableFilterComposer get processId {
    final $$ProcessesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.processId,
        referencedTable: $db.processes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessesTableFilterComposer(
              $db: $db,
              $table: $db.processes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> setupElementsRefs(
      Expression<bool> Function($$SetupElementsTableFilterComposer f) f) {
    final $$SetupElementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.setupElements,
        getReferencedColumn: (t) => t.processPartId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetupElementsTableFilterComposer(
              $db: $db,
              $table: $db.setupElements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProcessPartsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessPartsTable> {
  $$ProcessPartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => ColumnOrderings(column));

  $$ProcessesTableOrderingComposer get processId {
    final $$ProcessesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.processId,
        referencedTable: $db.processes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessesTableOrderingComposer(
              $db: $db,
              $table: $db.processes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProcessPartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessPartsTable> {
  $$ProcessPartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => column);

  $$ProcessesTableAnnotationComposer get processId {
    final $$ProcessesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.processId,
        referencedTable: $db.processes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessesTableAnnotationComposer(
              $db: $db,
              $table: $db.processes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> setupElementsRefs<T extends Object>(
      Expression<T> Function($$SetupElementsTableAnnotationComposer a) f) {
    final $$SetupElementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.setupElements,
        getReferencedColumn: (t) => t.processPartId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetupElementsTableAnnotationComposer(
              $db: $db,
              $table: $db.setupElements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProcessPartsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProcessPartsTable,
    ProcessPart,
    $$ProcessPartsTableFilterComposer,
    $$ProcessPartsTableOrderingComposer,
    $$ProcessPartsTableAnnotationComposer,
    $$ProcessPartsTableCreateCompanionBuilder,
    $$ProcessPartsTableUpdateCompanionBuilder,
    (ProcessPart, $$ProcessPartsTableReferences),
    ProcessPart,
    PrefetchHooks Function({bool processId, bool setupElementsRefs})> {
  $$ProcessPartsTableTableManager(_$AppDatabase db, $ProcessPartsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessPartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessPartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessPartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> partNumber = const Value.absent(),
            Value<int> processId = const Value.absent(),
          }) =>
              ProcessPartsCompanion(
            id: id,
            partNumber: partNumber,
            processId: processId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String partNumber,
            required int processId,
          }) =>
              ProcessPartsCompanion.insert(
            id: id,
            partNumber: partNumber,
            processId: processId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProcessPartsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {processId = false, setupElementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (setupElementsRefs) db.setupElements
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (processId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.processId,
                    referencedTable:
                        $$ProcessPartsTableReferences._processIdTable(db),
                    referencedColumn:
                        $$ProcessPartsTableReferences._processIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (setupElementsRefs)
                    await $_getPrefetchedData<ProcessPart, $ProcessPartsTable,
                            SetupElement>(
                        currentTable: table,
                        referencedTable: $$ProcessPartsTableReferences
                            ._setupElementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProcessPartsTableReferences(db, table, p0)
                                .setupElementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.processPartId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProcessPartsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProcessPartsTable,
    ProcessPart,
    $$ProcessPartsTableFilterComposer,
    $$ProcessPartsTableOrderingComposer,
    $$ProcessPartsTableAnnotationComposer,
    $$ProcessPartsTableCreateCompanionBuilder,
    $$ProcessPartsTableUpdateCompanionBuilder,
    (ProcessPart, $$ProcessPartsTableReferences),
    ProcessPart,
    PrefetchHooks Function({bool processId, bool setupElementsRefs})>;
typedef $$PartsTableCreateCompanionBuilder = PartsCompanion Function({
  Value<int> id,
  required int valueStreamId,
  required String partNumber,
  Value<String?> partDescription,
});
typedef $$PartsTableUpdateCompanionBuilder = PartsCompanion Function({
  Value<int> id,
  Value<int> valueStreamId,
  Value<String> partNumber,
  Value<String?> partDescription,
});

final class $$PartsTableReferences
    extends BaseReferences<_$AppDatabase, $PartsTable, Part> {
  $$PartsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ValueStreamsTable _valueStreamIdTable(_$AppDatabase db) =>
      db.valueStreams.createAlias(
          $_aliasNameGenerator(db.parts.valueStreamId, db.valueStreams.id));

  $$ValueStreamsTableProcessedTableManager get valueStreamId {
    final $_column = $_itemColumn<int>('value_stream_id')!;

    final manager = $$ValueStreamsTableTableManager($_db, $_db.valueStreams)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_valueStreamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PartsTableFilterComposer extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partDescription => $composableBuilder(
      column: $table.partDescription,
      builder: (column) => ColumnFilters(column));

  $$ValueStreamsTableFilterComposer get valueStreamId {
    final $$ValueStreamsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.valueStreamId,
        referencedTable: $db.valueStreams,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ValueStreamsTableFilterComposer(
              $db: $db,
              $table: $db.valueStreams,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PartsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partDescription => $composableBuilder(
      column: $table.partDescription,
      builder: (column) => ColumnOrderings(column));

  $$ValueStreamsTableOrderingComposer get valueStreamId {
    final $$ValueStreamsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.valueStreamId,
        referencedTable: $db.valueStreams,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ValueStreamsTableOrderingComposer(
              $db: $db,
              $table: $db.valueStreams,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => column);

  GeneratedColumn<String> get partDescription => $composableBuilder(
      column: $table.partDescription, builder: (column) => column);

  $$ValueStreamsTableAnnotationComposer get valueStreamId {
    final $$ValueStreamsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.valueStreamId,
        referencedTable: $db.valueStreams,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ValueStreamsTableAnnotationComposer(
              $db: $db,
              $table: $db.valueStreams,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PartsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PartsTable,
    Part,
    $$PartsTableFilterComposer,
    $$PartsTableOrderingComposer,
    $$PartsTableAnnotationComposer,
    $$PartsTableCreateCompanionBuilder,
    $$PartsTableUpdateCompanionBuilder,
    (Part, $$PartsTableReferences),
    Part,
    PrefetchHooks Function({bool valueStreamId})> {
  $$PartsTableTableManager(_$AppDatabase db, $PartsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> valueStreamId = const Value.absent(),
            Value<String> partNumber = const Value.absent(),
            Value<String?> partDescription = const Value.absent(),
          }) =>
              PartsCompanion(
            id: id,
            valueStreamId: valueStreamId,
            partNumber: partNumber,
            partDescription: partDescription,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int valueStreamId,
            required String partNumber,
            Value<String?> partDescription = const Value.absent(),
          }) =>
              PartsCompanion.insert(
            id: id,
            valueStreamId: valueStreamId,
            partNumber: partNumber,
            partDescription: partDescription,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PartsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({valueStreamId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (valueStreamId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.valueStreamId,
                    referencedTable:
                        $$PartsTableReferences._valueStreamIdTable(db),
                    referencedColumn:
                        $$PartsTableReferences._valueStreamIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PartsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PartsTable,
    Part,
    $$PartsTableFilterComposer,
    $$PartsTableOrderingComposer,
    $$PartsTableAnnotationComposer,
    $$PartsTableCreateCompanionBuilder,
    $$PartsTableUpdateCompanionBuilder,
    (Part, $$PartsTableReferences),
    Part,
    PrefetchHooks Function({bool valueStreamId})>;
typedef $$OrganizationsTableCreateCompanionBuilder = OrganizationsCompanion
    Function({
  Value<int> id,
  required String name,
});
typedef $$OrganizationsTableUpdateCompanionBuilder = OrganizationsCompanion
    Function({
  Value<int> id,
  Value<String> name,
});

class $$OrganizationsTableFilterComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$OrganizationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$OrganizationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrganizationsTable> {
  $$OrganizationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$OrganizationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrganizationsTable,
    Organization,
    $$OrganizationsTableFilterComposer,
    $$OrganizationsTableOrderingComposer,
    $$OrganizationsTableAnnotationComposer,
    $$OrganizationsTableCreateCompanionBuilder,
    $$OrganizationsTableUpdateCompanionBuilder,
    (
      Organization,
      BaseReferences<_$AppDatabase, $OrganizationsTable, Organization>
    ),
    Organization,
    PrefetchHooks Function()> {
  $$OrganizationsTableTableManager(_$AppDatabase db, $OrganizationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrganizationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrganizationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrganizationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              OrganizationsCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              OrganizationsCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrganizationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrganizationsTable,
    Organization,
    $$OrganizationsTableFilterComposer,
    $$OrganizationsTableOrderingComposer,
    $$OrganizationsTableAnnotationComposer,
    $$OrganizationsTableCreateCompanionBuilder,
    $$OrganizationsTableUpdateCompanionBuilder,
    (
      Organization,
      BaseReferences<_$AppDatabase, $OrganizationsTable, Organization>
    ),
    Organization,
    PrefetchHooks Function()>;
typedef $$PlantsTableCreateCompanionBuilder = PlantsCompanion Function({
  Value<int> id,
  required int organizationId,
  required String name,
  required String street,
  required String city,
  required String state,
  required String zip,
});
typedef $$PlantsTableUpdateCompanionBuilder = PlantsCompanion Function({
  Value<int> id,
  Value<int> organizationId,
  Value<String> name,
  Value<String> street,
  Value<String> city,
  Value<String> state,
  Value<String> zip,
});

class $$PlantsTableFilterComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get street => $composableBuilder(
      column: $table.street, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get zip => $composableBuilder(
      column: $table.zip, builder: (column) => ColumnFilters(column));
}

class $$PlantsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get street => $composableBuilder(
      column: $table.street, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zip => $composableBuilder(
      column: $table.zip, builder: (column) => ColumnOrderings(column));
}

class $$PlantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get organizationId => $composableBuilder(
      column: $table.organizationId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get zip =>
      $composableBuilder(column: $table.zip, builder: (column) => column);
}

class $$PlantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlantsTable,
    PlantData,
    $$PlantsTableFilterComposer,
    $$PlantsTableOrderingComposer,
    $$PlantsTableAnnotationComposer,
    $$PlantsTableCreateCompanionBuilder,
    $$PlantsTableUpdateCompanionBuilder,
    (PlantData, BaseReferences<_$AppDatabase, $PlantsTable, PlantData>),
    PlantData,
    PrefetchHooks Function()> {
  $$PlantsTableTableManager(_$AppDatabase db, $PlantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> organizationId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> street = const Value.absent(),
            Value<String> city = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<String> zip = const Value.absent(),
          }) =>
              PlantsCompanion(
            id: id,
            organizationId: organizationId,
            name: name,
            street: street,
            city: city,
            state: state,
            zip: zip,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int organizationId,
            required String name,
            required String street,
            required String city,
            required String state,
            required String zip,
          }) =>
              PlantsCompanion.insert(
            id: id,
            organizationId: organizationId,
            name: name,
            street: street,
            city: city,
            state: state,
            zip: zip,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlantsTable,
    PlantData,
    $$PlantsTableFilterComposer,
    $$PlantsTableOrderingComposer,
    $$PlantsTableAnnotationComposer,
    $$PlantsTableCreateCompanionBuilder,
    $$PlantsTableUpdateCompanionBuilder,
    (PlantData, BaseReferences<_$AppDatabase, $PlantsTable, PlantData>),
    PlantData,
    PrefetchHooks Function()>;
typedef $$SetupElementsTableCreateCompanionBuilder = SetupElementsCompanion
    Function({
  Value<int> id,
  required int processPartId,
  required String setupName,
  required DateTime setupDateTime,
  required String elementName,
  required String time,
});
typedef $$SetupElementsTableUpdateCompanionBuilder = SetupElementsCompanion
    Function({
  Value<int> id,
  Value<int> processPartId,
  Value<String> setupName,
  Value<DateTime> setupDateTime,
  Value<String> elementName,
  Value<String> time,
});

final class $$SetupElementsTableReferences
    extends BaseReferences<_$AppDatabase, $SetupElementsTable, SetupElement> {
  $$SetupElementsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProcessPartsTable _processPartIdTable(_$AppDatabase db) =>
      db.processParts.createAlias($_aliasNameGenerator(
          db.setupElements.processPartId, db.processParts.id));

  $$ProcessPartsTableProcessedTableManager get processPartId {
    final $_column = $_itemColumn<int>('process_part_id')!;

    final manager = $$ProcessPartsTableTableManager($_db, $_db.processParts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_processPartIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SetupElementsTableFilterComposer
    extends Composer<_$AppDatabase, $SetupElementsTable> {
  $$SetupElementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setupName => $composableBuilder(
      column: $table.setupName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get setupDateTime => $composableBuilder(
      column: $table.setupDateTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get elementName => $composableBuilder(
      column: $table.elementName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  $$ProcessPartsTableFilterComposer get processPartId {
    final $$ProcessPartsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.processPartId,
        referencedTable: $db.processParts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessPartsTableFilterComposer(
              $db: $db,
              $table: $db.processParts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SetupElementsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetupElementsTable> {
  $$SetupElementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setupName => $composableBuilder(
      column: $table.setupName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get setupDateTime => $composableBuilder(
      column: $table.setupDateTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get elementName => $composableBuilder(
      column: $table.elementName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  $$ProcessPartsTableOrderingComposer get processPartId {
    final $$ProcessPartsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.processPartId,
        referencedTable: $db.processParts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessPartsTableOrderingComposer(
              $db: $db,
              $table: $db.processParts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SetupElementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetupElementsTable> {
  $$SetupElementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get setupName =>
      $composableBuilder(column: $table.setupName, builder: (column) => column);

  GeneratedColumn<DateTime> get setupDateTime => $composableBuilder(
      column: $table.setupDateTime, builder: (column) => column);

  GeneratedColumn<String> get elementName => $composableBuilder(
      column: $table.elementName, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  $$ProcessPartsTableAnnotationComposer get processPartId {
    final $$ProcessPartsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.processPartId,
        referencedTable: $db.processParts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessPartsTableAnnotationComposer(
              $db: $db,
              $table: $db.processParts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SetupElementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SetupElementsTable,
    SetupElement,
    $$SetupElementsTableFilterComposer,
    $$SetupElementsTableOrderingComposer,
    $$SetupElementsTableAnnotationComposer,
    $$SetupElementsTableCreateCompanionBuilder,
    $$SetupElementsTableUpdateCompanionBuilder,
    (SetupElement, $$SetupElementsTableReferences),
    SetupElement,
    PrefetchHooks Function({bool processPartId})> {
  $$SetupElementsTableTableManager(_$AppDatabase db, $SetupElementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetupElementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetupElementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetupElementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> processPartId = const Value.absent(),
            Value<String> setupName = const Value.absent(),
            Value<DateTime> setupDateTime = const Value.absent(),
            Value<String> elementName = const Value.absent(),
            Value<String> time = const Value.absent(),
          }) =>
              SetupElementsCompanion(
            id: id,
            processPartId: processPartId,
            setupName: setupName,
            setupDateTime: setupDateTime,
            elementName: elementName,
            time: time,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int processPartId,
            required String setupName,
            required DateTime setupDateTime,
            required String elementName,
            required String time,
          }) =>
              SetupElementsCompanion.insert(
            id: id,
            processPartId: processPartId,
            setupName: setupName,
            setupDateTime: setupDateTime,
            elementName: elementName,
            time: time,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SetupElementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({processPartId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (processPartId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.processPartId,
                    referencedTable:
                        $$SetupElementsTableReferences._processPartIdTable(db),
                    referencedColumn: $$SetupElementsTableReferences
                        ._processPartIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SetupElementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SetupElementsTable,
    SetupElement,
    $$SetupElementsTableFilterComposer,
    $$SetupElementsTableOrderingComposer,
    $$SetupElementsTableAnnotationComposer,
    $$SetupElementsTableCreateCompanionBuilder,
    $$SetupElementsTableUpdateCompanionBuilder,
    (SetupElement, $$SetupElementsTableReferences),
    SetupElement,
    PrefetchHooks Function({bool processPartId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ValueStreamsTableTableManager get valueStreams =>
      $$ValueStreamsTableTableManager(_db, _db.valueStreams);
  $$ProcessesTableTableManager get processes =>
      $$ProcessesTableTableManager(_db, _db.processes);
  $$ProcessPartsTableTableManager get processParts =>
      $$ProcessPartsTableTableManager(_db, _db.processParts);
  $$PartsTableTableManager get parts =>
      $$PartsTableTableManager(_db, _db.parts);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db, _db.organizations);
  $$PlantsTableTableManager get plants =>
      $$PlantsTableTableManager(_db, _db.plants);
  $$SetupElementsTableTableManager get setupElements =>
      $$SetupElementsTableTableManager(_db, _db.setupElements);
}
