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
  static const VerificationMeta _mDemandMeta =
      const VerificationMeta('mDemand');
  @override
  late final GeneratedColumn<int> mDemand = GeneratedColumn<int>(
      'm_demand', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<UnitOfMeasure?, int> uom =
      GeneratedColumn<int>('uom', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<UnitOfMeasure?>($ValueStreamsTable.$converteruomn);
  static const VerificationMeta _mngrEmpIdMeta =
      const VerificationMeta('mngrEmpId');
  @override
  late final GeneratedColumn<int> mngrEmpId = GeneratedColumn<int>(
      'mngr_emp_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _taktTimeMeta =
      const VerificationMeta('taktTime');
  @override
  late final GeneratedColumn<String> taktTime = GeneratedColumn<String>(
      'takt_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, plantId, name, mDemand, uom, mngrEmpId, taktTime];
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
    if (data.containsKey('m_demand')) {
      context.handle(_mDemandMeta,
          mDemand.isAcceptableOrUnknown(data['m_demand']!, _mDemandMeta));
    }
    if (data.containsKey('mngr_emp_id')) {
      context.handle(
          _mngrEmpIdMeta,
          mngrEmpId.isAcceptableOrUnknown(
              data['mngr_emp_id']!, _mngrEmpIdMeta));
    }
    if (data.containsKey('takt_time')) {
      context.handle(_taktTimeMeta,
          taktTime.isAcceptableOrUnknown(data['takt_time']!, _taktTimeMeta));
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
      mDemand: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}m_demand']),
      uom: $ValueStreamsTable.$converteruomn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uom'])),
      mngrEmpId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mngr_emp_id']),
      taktTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}takt_time']),
    );
  }

  @override
  $ValueStreamsTable createAlias(String alias) {
    return $ValueStreamsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<UnitOfMeasure, int, int> $converteruom =
      const EnumIndexConverter<UnitOfMeasure>(UnitOfMeasure.values);
  static JsonTypeConverter2<UnitOfMeasure?, int?, int?> $converteruomn =
      JsonTypeConverter2.asNullable($converteruom);
}

class ValueStream extends DataClass implements Insertable<ValueStream> {
  final int id;
  final int plantId;
  final String name;
  final int? mDemand;
  final UnitOfMeasure? uom;
  final int? mngrEmpId;
  final String? taktTime;
  const ValueStream(
      {required this.id,
      required this.plantId,
      required this.name,
      this.mDemand,
      this.uom,
      this.mngrEmpId,
      this.taktTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plant_id'] = Variable<int>(plantId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || mDemand != null) {
      map['m_demand'] = Variable<int>(mDemand);
    }
    if (!nullToAbsent || uom != null) {
      map['uom'] = Variable<int>($ValueStreamsTable.$converteruomn.toSql(uom));
    }
    if (!nullToAbsent || mngrEmpId != null) {
      map['mngr_emp_id'] = Variable<int>(mngrEmpId);
    }
    if (!nullToAbsent || taktTime != null) {
      map['takt_time'] = Variable<String>(taktTime);
    }
    return map;
  }

  ValueStreamsCompanion toCompanion(bool nullToAbsent) {
    return ValueStreamsCompanion(
      id: Value(id),
      plantId: Value(plantId),
      name: Value(name),
      mDemand: mDemand == null && nullToAbsent
          ? const Value.absent()
          : Value(mDemand),
      uom: uom == null && nullToAbsent ? const Value.absent() : Value(uom),
      mngrEmpId: mngrEmpId == null && nullToAbsent
          ? const Value.absent()
          : Value(mngrEmpId),
      taktTime: taktTime == null && nullToAbsent
          ? const Value.absent()
          : Value(taktTime),
    );
  }

  factory ValueStream.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ValueStream(
      id: serializer.fromJson<int>(json['id']),
      plantId: serializer.fromJson<int>(json['plantId']),
      name: serializer.fromJson<String>(json['name']),
      mDemand: serializer.fromJson<int?>(json['mDemand']),
      uom: $ValueStreamsTable.$converteruomn
          .fromJson(serializer.fromJson<int?>(json['uom'])),
      mngrEmpId: serializer.fromJson<int?>(json['mngrEmpId']),
      taktTime: serializer.fromJson<String?>(json['taktTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plantId': serializer.toJson<int>(plantId),
      'name': serializer.toJson<String>(name),
      'mDemand': serializer.toJson<int?>(mDemand),
      'uom': serializer
          .toJson<int?>($ValueStreamsTable.$converteruomn.toJson(uom)),
      'mngrEmpId': serializer.toJson<int?>(mngrEmpId),
      'taktTime': serializer.toJson<String?>(taktTime),
    };
  }

  ValueStream copyWith(
          {int? id,
          int? plantId,
          String? name,
          Value<int?> mDemand = const Value.absent(),
          Value<UnitOfMeasure?> uom = const Value.absent(),
          Value<int?> mngrEmpId = const Value.absent(),
          Value<String?> taktTime = const Value.absent()}) =>
      ValueStream(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        name: name ?? this.name,
        mDemand: mDemand.present ? mDemand.value : this.mDemand,
        uom: uom.present ? uom.value : this.uom,
        mngrEmpId: mngrEmpId.present ? mngrEmpId.value : this.mngrEmpId,
        taktTime: taktTime.present ? taktTime.value : this.taktTime,
      );
  ValueStream copyWithCompanion(ValueStreamsCompanion data) {
    return ValueStream(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      name: data.name.present ? data.name.value : this.name,
      mDemand: data.mDemand.present ? data.mDemand.value : this.mDemand,
      uom: data.uom.present ? data.uom.value : this.uom,
      mngrEmpId: data.mngrEmpId.present ? data.mngrEmpId.value : this.mngrEmpId,
      taktTime: data.taktTime.present ? data.taktTime.value : this.taktTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ValueStream(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('name: $name, ')
          ..write('mDemand: $mDemand, ')
          ..write('uom: $uom, ')
          ..write('mngrEmpId: $mngrEmpId, ')
          ..write('taktTime: $taktTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, plantId, name, mDemand, uom, mngrEmpId, taktTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ValueStream &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.name == this.name &&
          other.mDemand == this.mDemand &&
          other.uom == this.uom &&
          other.mngrEmpId == this.mngrEmpId &&
          other.taktTime == this.taktTime);
}

class ValueStreamsCompanion extends UpdateCompanion<ValueStream> {
  final Value<int> id;
  final Value<int> plantId;
  final Value<String> name;
  final Value<int?> mDemand;
  final Value<UnitOfMeasure?> uom;
  final Value<int?> mngrEmpId;
  final Value<String?> taktTime;
  const ValueStreamsCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.name = const Value.absent(),
    this.mDemand = const Value.absent(),
    this.uom = const Value.absent(),
    this.mngrEmpId = const Value.absent(),
    this.taktTime = const Value.absent(),
  });
  ValueStreamsCompanion.insert({
    this.id = const Value.absent(),
    required int plantId,
    required String name,
    this.mDemand = const Value.absent(),
    this.uom = const Value.absent(),
    this.mngrEmpId = const Value.absent(),
    this.taktTime = const Value.absent(),
  })  : plantId = Value(plantId),
        name = Value(name);
  static Insertable<ValueStream> custom({
    Expression<int>? id,
    Expression<int>? plantId,
    Expression<String>? name,
    Expression<int>? mDemand,
    Expression<int>? uom,
    Expression<int>? mngrEmpId,
    Expression<String>? taktTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (name != null) 'name': name,
      if (mDemand != null) 'm_demand': mDemand,
      if (uom != null) 'uom': uom,
      if (mngrEmpId != null) 'mngr_emp_id': mngrEmpId,
      if (taktTime != null) 'takt_time': taktTime,
    });
  }

  ValueStreamsCompanion copyWith(
      {Value<int>? id,
      Value<int>? plantId,
      Value<String>? name,
      Value<int?>? mDemand,
      Value<UnitOfMeasure?>? uom,
      Value<int?>? mngrEmpId,
      Value<String?>? taktTime}) {
    return ValueStreamsCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      name: name ?? this.name,
      mDemand: mDemand ?? this.mDemand,
      uom: uom ?? this.uom,
      mngrEmpId: mngrEmpId ?? this.mngrEmpId,
      taktTime: taktTime ?? this.taktTime,
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
    if (mDemand.present) {
      map['m_demand'] = Variable<int>(mDemand.value);
    }
    if (uom.present) {
      map['uom'] =
          Variable<int>($ValueStreamsTable.$converteruomn.toSql(uom.value));
    }
    if (mngrEmpId.present) {
      map['mngr_emp_id'] = Variable<int>(mngrEmpId.value);
    }
    if (taktTime.present) {
      map['takt_time'] = Variable<String>(taktTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ValueStreamsCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('name: $name, ')
          ..write('mDemand: $mDemand, ')
          ..write('uom: $uom, ')
          ..write('mngrEmpId: $mngrEmpId, ')
          ..write('taktTime: $taktTime')
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
  static const VerificationMeta _dailyDemandMeta =
      const VerificationMeta('dailyDemand');
  @override
  late final GeneratedColumn<int> dailyDemand = GeneratedColumn<int>(
      'daily_demand', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _staffMeta = const VerificationMeta('staff');
  @override
  late final GeneratedColumn<int> staff = GeneratedColumn<int>(
      'staff', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wipMeta = const VerificationMeta('wip');
  @override
  late final GeneratedColumn<int> wip = GeneratedColumn<int>(
      'wip', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _uptimeMeta = const VerificationMeta('uptime');
  @override
  late final GeneratedColumn<double> uptime = GeneratedColumn<double>(
      'uptime', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _coTimeMeta = const VerificationMeta('coTime');
  @override
  late final GeneratedColumn<String> coTime = GeneratedColumn<String>(
      'co_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _taktTimeMeta =
      const VerificationMeta('taktTime');
  @override
  late final GeneratedColumn<String> taktTime = GeneratedColumn<String>(
      'takt_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _positionXMeta =
      const VerificationMeta('positionX');
  @override
  late final GeneratedColumn<double> positionX = GeneratedColumn<double>(
      'position_x', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _positionYMeta =
      const VerificationMeta('positionY');
  @override
  late final GeneratedColumn<double> positionY = GeneratedColumn<double>(
      'position_y', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        valueStreamId,
        processName,
        processDescription,
        dailyDemand,
        staff,
        wip,
        uptime,
        coTime,
        taktTime,
        orderIndex,
        positionX,
        positionY,
        color
      ];
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
    if (data.containsKey('daily_demand')) {
      context.handle(
          _dailyDemandMeta,
          dailyDemand.isAcceptableOrUnknown(
              data['daily_demand']!, _dailyDemandMeta));
    }
    if (data.containsKey('staff')) {
      context.handle(
          _staffMeta, staff.isAcceptableOrUnknown(data['staff']!, _staffMeta));
    }
    if (data.containsKey('wip')) {
      context.handle(
          _wipMeta, wip.isAcceptableOrUnknown(data['wip']!, _wipMeta));
    }
    if (data.containsKey('uptime')) {
      context.handle(_uptimeMeta,
          uptime.isAcceptableOrUnknown(data['uptime']!, _uptimeMeta));
    }
    if (data.containsKey('co_time')) {
      context.handle(_coTimeMeta,
          coTime.isAcceptableOrUnknown(data['co_time']!, _coTimeMeta));
    }
    if (data.containsKey('takt_time')) {
      context.handle(_taktTimeMeta,
          taktTime.isAcceptableOrUnknown(data['takt_time']!, _taktTimeMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('position_x')) {
      context.handle(_positionXMeta,
          positionX.isAcceptableOrUnknown(data['position_x']!, _positionXMeta));
    }
    if (data.containsKey('position_y')) {
      context.handle(_positionYMeta,
          positionY.isAcceptableOrUnknown(data['position_y']!, _positionYMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
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
      dailyDemand: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_demand']),
      staff: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}staff']),
      wip: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wip']),
      uptime: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}uptime']),
      coTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}co_time']),
      taktTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}takt_time']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      positionX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}position_x']),
      positionY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}position_y']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
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
  final int? dailyDemand;
  final int? staff;
  final int? wip;
  final double? uptime;
  final String? coTime;
  final String? taktTime;
  final int orderIndex;
  final double? positionX;
  final double? positionY;
  final String? color;
  const ProcessesData(
      {required this.id,
      required this.valueStreamId,
      required this.processName,
      this.processDescription,
      this.dailyDemand,
      this.staff,
      this.wip,
      this.uptime,
      this.coTime,
      this.taktTime,
      required this.orderIndex,
      this.positionX,
      this.positionY,
      this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['value_stream_id'] = Variable<int>(valueStreamId);
    map['process_name'] = Variable<String>(processName);
    if (!nullToAbsent || processDescription != null) {
      map['process_description'] = Variable<String>(processDescription);
    }
    if (!nullToAbsent || dailyDemand != null) {
      map['daily_demand'] = Variable<int>(dailyDemand);
    }
    if (!nullToAbsent || staff != null) {
      map['staff'] = Variable<int>(staff);
    }
    if (!nullToAbsent || wip != null) {
      map['wip'] = Variable<int>(wip);
    }
    if (!nullToAbsent || uptime != null) {
      map['uptime'] = Variable<double>(uptime);
    }
    if (!nullToAbsent || coTime != null) {
      map['co_time'] = Variable<String>(coTime);
    }
    if (!nullToAbsent || taktTime != null) {
      map['takt_time'] = Variable<String>(taktTime);
    }
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || positionX != null) {
      map['position_x'] = Variable<double>(positionX);
    }
    if (!nullToAbsent || positionY != null) {
      map['position_y'] = Variable<double>(positionY);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
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
      dailyDemand: dailyDemand == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyDemand),
      staff:
          staff == null && nullToAbsent ? const Value.absent() : Value(staff),
      wip: wip == null && nullToAbsent ? const Value.absent() : Value(wip),
      uptime:
          uptime == null && nullToAbsent ? const Value.absent() : Value(uptime),
      coTime:
          coTime == null && nullToAbsent ? const Value.absent() : Value(coTime),
      taktTime: taktTime == null && nullToAbsent
          ? const Value.absent()
          : Value(taktTime),
      orderIndex: Value(orderIndex),
      positionX: positionX == null && nullToAbsent
          ? const Value.absent()
          : Value(positionX),
      positionY: positionY == null && nullToAbsent
          ? const Value.absent()
          : Value(positionY),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
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
      dailyDemand: serializer.fromJson<int?>(json['dailyDemand']),
      staff: serializer.fromJson<int?>(json['staff']),
      wip: serializer.fromJson<int?>(json['wip']),
      uptime: serializer.fromJson<double?>(json['uptime']),
      coTime: serializer.fromJson<String?>(json['coTime']),
      taktTime: serializer.fromJson<String?>(json['taktTime']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      positionX: serializer.fromJson<double?>(json['positionX']),
      positionY: serializer.fromJson<double?>(json['positionY']),
      color: serializer.fromJson<String?>(json['color']),
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
      'dailyDemand': serializer.toJson<int?>(dailyDemand),
      'staff': serializer.toJson<int?>(staff),
      'wip': serializer.toJson<int?>(wip),
      'uptime': serializer.toJson<double?>(uptime),
      'coTime': serializer.toJson<String?>(coTime),
      'taktTime': serializer.toJson<String?>(taktTime),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'positionX': serializer.toJson<double?>(positionX),
      'positionY': serializer.toJson<double?>(positionY),
      'color': serializer.toJson<String?>(color),
    };
  }

  ProcessesData copyWith(
          {int? id,
          int? valueStreamId,
          String? processName,
          Value<String?> processDescription = const Value.absent(),
          Value<int?> dailyDemand = const Value.absent(),
          Value<int?> staff = const Value.absent(),
          Value<int?> wip = const Value.absent(),
          Value<double?> uptime = const Value.absent(),
          Value<String?> coTime = const Value.absent(),
          Value<String?> taktTime = const Value.absent(),
          int? orderIndex,
          Value<double?> positionX = const Value.absent(),
          Value<double?> positionY = const Value.absent(),
          Value<String?> color = const Value.absent()}) =>
      ProcessesData(
        id: id ?? this.id,
        valueStreamId: valueStreamId ?? this.valueStreamId,
        processName: processName ?? this.processName,
        processDescription: processDescription.present
            ? processDescription.value
            : this.processDescription,
        dailyDemand: dailyDemand.present ? dailyDemand.value : this.dailyDemand,
        staff: staff.present ? staff.value : this.staff,
        wip: wip.present ? wip.value : this.wip,
        uptime: uptime.present ? uptime.value : this.uptime,
        coTime: coTime.present ? coTime.value : this.coTime,
        taktTime: taktTime.present ? taktTime.value : this.taktTime,
        orderIndex: orderIndex ?? this.orderIndex,
        positionX: positionX.present ? positionX.value : this.positionX,
        positionY: positionY.present ? positionY.value : this.positionY,
        color: color.present ? color.value : this.color,
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
      dailyDemand:
          data.dailyDemand.present ? data.dailyDemand.value : this.dailyDemand,
      staff: data.staff.present ? data.staff.value : this.staff,
      wip: data.wip.present ? data.wip.value : this.wip,
      uptime: data.uptime.present ? data.uptime.value : this.uptime,
      coTime: data.coTime.present ? data.coTime.value : this.coTime,
      taktTime: data.taktTime.present ? data.taktTime.value : this.taktTime,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      positionX: data.positionX.present ? data.positionX.value : this.positionX,
      positionY: data.positionY.present ? data.positionY.value : this.positionY,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessesData(')
          ..write('id: $id, ')
          ..write('valueStreamId: $valueStreamId, ')
          ..write('processName: $processName, ')
          ..write('processDescription: $processDescription, ')
          ..write('dailyDemand: $dailyDemand, ')
          ..write('staff: $staff, ')
          ..write('wip: $wip, ')
          ..write('uptime: $uptime, ')
          ..write('coTime: $coTime, ')
          ..write('taktTime: $taktTime, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      valueStreamId,
      processName,
      processDescription,
      dailyDemand,
      staff,
      wip,
      uptime,
      coTime,
      taktTime,
      orderIndex,
      positionX,
      positionY,
      color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessesData &&
          other.id == this.id &&
          other.valueStreamId == this.valueStreamId &&
          other.processName == this.processName &&
          other.processDescription == this.processDescription &&
          other.dailyDemand == this.dailyDemand &&
          other.staff == this.staff &&
          other.wip == this.wip &&
          other.uptime == this.uptime &&
          other.coTime == this.coTime &&
          other.taktTime == this.taktTime &&
          other.orderIndex == this.orderIndex &&
          other.positionX == this.positionX &&
          other.positionY == this.positionY &&
          other.color == this.color);
}

class ProcessesCompanion extends UpdateCompanion<ProcessesData> {
  final Value<int> id;
  final Value<int> valueStreamId;
  final Value<String> processName;
  final Value<String?> processDescription;
  final Value<int?> dailyDemand;
  final Value<int?> staff;
  final Value<int?> wip;
  final Value<double?> uptime;
  final Value<String?> coTime;
  final Value<String?> taktTime;
  final Value<int> orderIndex;
  final Value<double?> positionX;
  final Value<double?> positionY;
  final Value<String?> color;
  const ProcessesCompanion({
    this.id = const Value.absent(),
    this.valueStreamId = const Value.absent(),
    this.processName = const Value.absent(),
    this.processDescription = const Value.absent(),
    this.dailyDemand = const Value.absent(),
    this.staff = const Value.absent(),
    this.wip = const Value.absent(),
    this.uptime = const Value.absent(),
    this.coTime = const Value.absent(),
    this.taktTime = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.positionX = const Value.absent(),
    this.positionY = const Value.absent(),
    this.color = const Value.absent(),
  });
  ProcessesCompanion.insert({
    this.id = const Value.absent(),
    required int valueStreamId,
    required String processName,
    this.processDescription = const Value.absent(),
    this.dailyDemand = const Value.absent(),
    this.staff = const Value.absent(),
    this.wip = const Value.absent(),
    this.uptime = const Value.absent(),
    this.coTime = const Value.absent(),
    this.taktTime = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.positionX = const Value.absent(),
    this.positionY = const Value.absent(),
    this.color = const Value.absent(),
  })  : valueStreamId = Value(valueStreamId),
        processName = Value(processName);
  static Insertable<ProcessesData> custom({
    Expression<int>? id,
    Expression<int>? valueStreamId,
    Expression<String>? processName,
    Expression<String>? processDescription,
    Expression<int>? dailyDemand,
    Expression<int>? staff,
    Expression<int>? wip,
    Expression<double>? uptime,
    Expression<String>? coTime,
    Expression<String>? taktTime,
    Expression<int>? orderIndex,
    Expression<double>? positionX,
    Expression<double>? positionY,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (valueStreamId != null) 'value_stream_id': valueStreamId,
      if (processName != null) 'process_name': processName,
      if (processDescription != null) 'process_description': processDescription,
      if (dailyDemand != null) 'daily_demand': dailyDemand,
      if (staff != null) 'staff': staff,
      if (wip != null) 'wip': wip,
      if (uptime != null) 'uptime': uptime,
      if (coTime != null) 'co_time': coTime,
      if (taktTime != null) 'takt_time': taktTime,
      if (orderIndex != null) 'order_index': orderIndex,
      if (positionX != null) 'position_x': positionX,
      if (positionY != null) 'position_y': positionY,
      if (color != null) 'color': color,
    });
  }

  ProcessesCompanion copyWith(
      {Value<int>? id,
      Value<int>? valueStreamId,
      Value<String>? processName,
      Value<String?>? processDescription,
      Value<int?>? dailyDemand,
      Value<int?>? staff,
      Value<int?>? wip,
      Value<double?>? uptime,
      Value<String?>? coTime,
      Value<String?>? taktTime,
      Value<int>? orderIndex,
      Value<double?>? positionX,
      Value<double?>? positionY,
      Value<String?>? color}) {
    return ProcessesCompanion(
      id: id ?? this.id,
      valueStreamId: valueStreamId ?? this.valueStreamId,
      processName: processName ?? this.processName,
      processDescription: processDescription ?? this.processDescription,
      dailyDemand: dailyDemand ?? this.dailyDemand,
      staff: staff ?? this.staff,
      wip: wip ?? this.wip,
      uptime: uptime ?? this.uptime,
      coTime: coTime ?? this.coTime,
      taktTime: taktTime ?? this.taktTime,
      orderIndex: orderIndex ?? this.orderIndex,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      color: color ?? this.color,
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
    if (dailyDemand.present) {
      map['daily_demand'] = Variable<int>(dailyDemand.value);
    }
    if (staff.present) {
      map['staff'] = Variable<int>(staff.value);
    }
    if (wip.present) {
      map['wip'] = Variable<int>(wip.value);
    }
    if (uptime.present) {
      map['uptime'] = Variable<double>(uptime.value);
    }
    if (coTime.present) {
      map['co_time'] = Variable<String>(coTime.value);
    }
    if (taktTime.present) {
      map['takt_time'] = Variable<String>(taktTime.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (positionX.present) {
      map['position_x'] = Variable<double>(positionX.value);
    }
    if (positionY.present) {
      map['position_y'] = Variable<double>(positionY.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessesCompanion(')
          ..write('id: $id, ')
          ..write('valueStreamId: $valueStreamId, ')
          ..write('processName: $processName, ')
          ..write('processDescription: $processDescription, ')
          ..write('dailyDemand: $dailyDemand, ')
          ..write('staff: $staff, ')
          ..write('wip: $wip, ')
          ..write('uptime: $uptime, ')
          ..write('coTime: $coTime, ')
          ..write('taktTime: $taktTime, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('color: $color')
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
  static const VerificationMeta _dailyDemandMeta =
      const VerificationMeta('dailyDemand');
  @override
  late final GeneratedColumn<int> dailyDemand = GeneratedColumn<int>(
      'daily_demand', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _processTimeMeta =
      const VerificationMeta('processTime');
  @override
  late final GeneratedColumn<String> processTime = GeneratedColumn<String>(
      'process_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userOverrideTimeMeta =
      const VerificationMeta('userOverrideTime');
  @override
  late final GeneratedColumn<String> userOverrideTime = GeneratedColumn<String>(
      'user_override_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fpyMeta = const VerificationMeta('fpy');
  @override
  late final GeneratedColumn<double> fpy = GeneratedColumn<double>(
      'fpy', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        partNumber,
        processId,
        dailyDemand,
        processTime,
        userOverrideTime,
        fpy
      ];
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
    if (data.containsKey('daily_demand')) {
      context.handle(
          _dailyDemandMeta,
          dailyDemand.isAcceptableOrUnknown(
              data['daily_demand']!, _dailyDemandMeta));
    }
    if (data.containsKey('process_time')) {
      context.handle(
          _processTimeMeta,
          processTime.isAcceptableOrUnknown(
              data['process_time']!, _processTimeMeta));
    }
    if (data.containsKey('user_override_time')) {
      context.handle(
          _userOverrideTimeMeta,
          userOverrideTime.isAcceptableOrUnknown(
              data['user_override_time']!, _userOverrideTimeMeta));
    }
    if (data.containsKey('fpy')) {
      context.handle(
          _fpyMeta, fpy.isAcceptableOrUnknown(data['fpy']!, _fpyMeta));
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
      dailyDemand: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_demand']),
      processTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}process_time']),
      userOverrideTime: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}user_override_time']),
      fpy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fpy']),
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
  final int? dailyDemand;
  final String? processTime;
  final String? userOverrideTime;
  final double? fpy;
  const ProcessPart(
      {required this.id,
      required this.partNumber,
      required this.processId,
      this.dailyDemand,
      this.processTime,
      this.userOverrideTime,
      this.fpy});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['part_number'] = Variable<String>(partNumber);
    map['process_id'] = Variable<int>(processId);
    if (!nullToAbsent || dailyDemand != null) {
      map['daily_demand'] = Variable<int>(dailyDemand);
    }
    if (!nullToAbsent || processTime != null) {
      map['process_time'] = Variable<String>(processTime);
    }
    if (!nullToAbsent || userOverrideTime != null) {
      map['user_override_time'] = Variable<String>(userOverrideTime);
    }
    if (!nullToAbsent || fpy != null) {
      map['fpy'] = Variable<double>(fpy);
    }
    return map;
  }

  ProcessPartsCompanion toCompanion(bool nullToAbsent) {
    return ProcessPartsCompanion(
      id: Value(id),
      partNumber: Value(partNumber),
      processId: Value(processId),
      dailyDemand: dailyDemand == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyDemand),
      processTime: processTime == null && nullToAbsent
          ? const Value.absent()
          : Value(processTime),
      userOverrideTime: userOverrideTime == null && nullToAbsent
          ? const Value.absent()
          : Value(userOverrideTime),
      fpy: fpy == null && nullToAbsent ? const Value.absent() : Value(fpy),
    );
  }

  factory ProcessPart.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessPart(
      id: serializer.fromJson<int>(json['id']),
      partNumber: serializer.fromJson<String>(json['partNumber']),
      processId: serializer.fromJson<int>(json['processId']),
      dailyDemand: serializer.fromJson<int?>(json['dailyDemand']),
      processTime: serializer.fromJson<String?>(json['processTime']),
      userOverrideTime: serializer.fromJson<String?>(json['userOverrideTime']),
      fpy: serializer.fromJson<double?>(json['fpy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partNumber': serializer.toJson<String>(partNumber),
      'processId': serializer.toJson<int>(processId),
      'dailyDemand': serializer.toJson<int?>(dailyDemand),
      'processTime': serializer.toJson<String?>(processTime),
      'userOverrideTime': serializer.toJson<String?>(userOverrideTime),
      'fpy': serializer.toJson<double?>(fpy),
    };
  }

  ProcessPart copyWith(
          {int? id,
          String? partNumber,
          int? processId,
          Value<int?> dailyDemand = const Value.absent(),
          Value<String?> processTime = const Value.absent(),
          Value<String?> userOverrideTime = const Value.absent(),
          Value<double?> fpy = const Value.absent()}) =>
      ProcessPart(
        id: id ?? this.id,
        partNumber: partNumber ?? this.partNumber,
        processId: processId ?? this.processId,
        dailyDemand: dailyDemand.present ? dailyDemand.value : this.dailyDemand,
        processTime: processTime.present ? processTime.value : this.processTime,
        userOverrideTime: userOverrideTime.present
            ? userOverrideTime.value
            : this.userOverrideTime,
        fpy: fpy.present ? fpy.value : this.fpy,
      );
  ProcessPart copyWithCompanion(ProcessPartsCompanion data) {
    return ProcessPart(
      id: data.id.present ? data.id.value : this.id,
      partNumber:
          data.partNumber.present ? data.partNumber.value : this.partNumber,
      processId: data.processId.present ? data.processId.value : this.processId,
      dailyDemand:
          data.dailyDemand.present ? data.dailyDemand.value : this.dailyDemand,
      processTime:
          data.processTime.present ? data.processTime.value : this.processTime,
      userOverrideTime: data.userOverrideTime.present
          ? data.userOverrideTime.value
          : this.userOverrideTime,
      fpy: data.fpy.present ? data.fpy.value : this.fpy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessPart(')
          ..write('id: $id, ')
          ..write('partNumber: $partNumber, ')
          ..write('processId: $processId, ')
          ..write('dailyDemand: $dailyDemand, ')
          ..write('processTime: $processTime, ')
          ..write('userOverrideTime: $userOverrideTime, ')
          ..write('fpy: $fpy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, partNumber, processId, dailyDemand,
      processTime, userOverrideTime, fpy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessPart &&
          other.id == this.id &&
          other.partNumber == this.partNumber &&
          other.processId == this.processId &&
          other.dailyDemand == this.dailyDemand &&
          other.processTime == this.processTime &&
          other.userOverrideTime == this.userOverrideTime &&
          other.fpy == this.fpy);
}

class ProcessPartsCompanion extends UpdateCompanion<ProcessPart> {
  final Value<int> id;
  final Value<String> partNumber;
  final Value<int> processId;
  final Value<int?> dailyDemand;
  final Value<String?> processTime;
  final Value<String?> userOverrideTime;
  final Value<double?> fpy;
  const ProcessPartsCompanion({
    this.id = const Value.absent(),
    this.partNumber = const Value.absent(),
    this.processId = const Value.absent(),
    this.dailyDemand = const Value.absent(),
    this.processTime = const Value.absent(),
    this.userOverrideTime = const Value.absent(),
    this.fpy = const Value.absent(),
  });
  ProcessPartsCompanion.insert({
    this.id = const Value.absent(),
    required String partNumber,
    required int processId,
    this.dailyDemand = const Value.absent(),
    this.processTime = const Value.absent(),
    this.userOverrideTime = const Value.absent(),
    this.fpy = const Value.absent(),
  })  : partNumber = Value(partNumber),
        processId = Value(processId);
  static Insertable<ProcessPart> custom({
    Expression<int>? id,
    Expression<String>? partNumber,
    Expression<int>? processId,
    Expression<int>? dailyDemand,
    Expression<String>? processTime,
    Expression<String>? userOverrideTime,
    Expression<double>? fpy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partNumber != null) 'part_number': partNumber,
      if (processId != null) 'process_id': processId,
      if (dailyDemand != null) 'daily_demand': dailyDemand,
      if (processTime != null) 'process_time': processTime,
      if (userOverrideTime != null) 'user_override_time': userOverrideTime,
      if (fpy != null) 'fpy': fpy,
    });
  }

  ProcessPartsCompanion copyWith(
      {Value<int>? id,
      Value<String>? partNumber,
      Value<int>? processId,
      Value<int?>? dailyDemand,
      Value<String?>? processTime,
      Value<String?>? userOverrideTime,
      Value<double?>? fpy}) {
    return ProcessPartsCompanion(
      id: id ?? this.id,
      partNumber: partNumber ?? this.partNumber,
      processId: processId ?? this.processId,
      dailyDemand: dailyDemand ?? this.dailyDemand,
      processTime: processTime ?? this.processTime,
      userOverrideTime: userOverrideTime ?? this.userOverrideTime,
      fpy: fpy ?? this.fpy,
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
    if (dailyDemand.present) {
      map['daily_demand'] = Variable<int>(dailyDemand.value);
    }
    if (processTime.present) {
      map['process_time'] = Variable<String>(processTime.value);
    }
    if (userOverrideTime.present) {
      map['user_override_time'] = Variable<String>(userOverrideTime.value);
    }
    if (fpy.present) {
      map['fpy'] = Variable<double>(fpy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessPartsCompanion(')
          ..write('id: $id, ')
          ..write('partNumber: $partNumber, ')
          ..write('processId: $processId, ')
          ..write('dailyDemand: $dailyDemand, ')
          ..write('processTime: $processTime, ')
          ..write('userOverrideTime: $userOverrideTime, ')
          ..write('fpy: $fpy')
          ..write(')'))
        .toString();
  }
}

class $ProcessShiftTable extends ProcessShift
    with TableInfo<$ProcessShiftTable, ProcessShiftData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessShiftTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _processIdMeta =
      const VerificationMeta('processId');
  @override
  late final GeneratedColumn<int> processId = GeneratedColumn<int>(
      'process_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES processes (id)'));
  static const VerificationMeta _shiftNameMeta =
      const VerificationMeta('shiftName');
  @override
  late final GeneratedColumn<String> shiftName = GeneratedColumn<String>(
      'shift_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sunMeta = const VerificationMeta('sun');
  @override
  late final GeneratedColumn<String> sun = GeneratedColumn<String>(
      'sun', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _monMeta = const VerificationMeta('mon');
  @override
  late final GeneratedColumn<String> mon = GeneratedColumn<String>(
      'mon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tueMeta = const VerificationMeta('tue');
  @override
  late final GeneratedColumn<String> tue = GeneratedColumn<String>(
      'tue', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wedMeta = const VerificationMeta('wed');
  @override
  late final GeneratedColumn<String> wed = GeneratedColumn<String>(
      'wed', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thuMeta = const VerificationMeta('thu');
  @override
  late final GeneratedColumn<String> thu = GeneratedColumn<String>(
      'thu', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _friMeta = const VerificationMeta('fri');
  @override
  late final GeneratedColumn<String> fri = GeneratedColumn<String>(
      'fri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _satMeta = const VerificationMeta('sat');
  @override
  late final GeneratedColumn<String> sat = GeneratedColumn<String>(
      'sat', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, processId, shiftName, sun, mon, tue, wed, thu, fri, sat];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'process_shift';
  @override
  VerificationContext validateIntegrity(Insertable<ProcessShiftData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('process_id')) {
      context.handle(_processIdMeta,
          processId.isAcceptableOrUnknown(data['process_id']!, _processIdMeta));
    } else if (isInserting) {
      context.missing(_processIdMeta);
    }
    if (data.containsKey('shift_name')) {
      context.handle(_shiftNameMeta,
          shiftName.isAcceptableOrUnknown(data['shift_name']!, _shiftNameMeta));
    } else if (isInserting) {
      context.missing(_shiftNameMeta);
    }
    if (data.containsKey('sun')) {
      context.handle(
          _sunMeta, sun.isAcceptableOrUnknown(data['sun']!, _sunMeta));
    }
    if (data.containsKey('mon')) {
      context.handle(
          _monMeta, mon.isAcceptableOrUnknown(data['mon']!, _monMeta));
    }
    if (data.containsKey('tue')) {
      context.handle(
          _tueMeta, tue.isAcceptableOrUnknown(data['tue']!, _tueMeta));
    }
    if (data.containsKey('wed')) {
      context.handle(
          _wedMeta, wed.isAcceptableOrUnknown(data['wed']!, _wedMeta));
    }
    if (data.containsKey('thu')) {
      context.handle(
          _thuMeta, thu.isAcceptableOrUnknown(data['thu']!, _thuMeta));
    }
    if (data.containsKey('fri')) {
      context.handle(
          _friMeta, fri.isAcceptableOrUnknown(data['fri']!, _friMeta));
    }
    if (data.containsKey('sat')) {
      context.handle(
          _satMeta, sat.isAcceptableOrUnknown(data['sat']!, _satMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessShiftData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessShiftData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      processId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}process_id'])!,
      shiftName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_name'])!,
      sun: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sun']),
      mon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mon']),
      tue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tue']),
      wed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wed']),
      thu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thu']),
      fri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fri']),
      sat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sat']),
    );
  }

  @override
  $ProcessShiftTable createAlias(String alias) {
    return $ProcessShiftTable(attachedDatabase, alias);
  }
}

class ProcessShiftData extends DataClass
    implements Insertable<ProcessShiftData> {
  final int id;
  final int processId;
  final String shiftName;
  final String? sun;
  final String? mon;
  final String? tue;
  final String? wed;
  final String? thu;
  final String? fri;
  final String? sat;
  const ProcessShiftData(
      {required this.id,
      required this.processId,
      required this.shiftName,
      this.sun,
      this.mon,
      this.tue,
      this.wed,
      this.thu,
      this.fri,
      this.sat});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['process_id'] = Variable<int>(processId);
    map['shift_name'] = Variable<String>(shiftName);
    if (!nullToAbsent || sun != null) {
      map['sun'] = Variable<String>(sun);
    }
    if (!nullToAbsent || mon != null) {
      map['mon'] = Variable<String>(mon);
    }
    if (!nullToAbsent || tue != null) {
      map['tue'] = Variable<String>(tue);
    }
    if (!nullToAbsent || wed != null) {
      map['wed'] = Variable<String>(wed);
    }
    if (!nullToAbsent || thu != null) {
      map['thu'] = Variable<String>(thu);
    }
    if (!nullToAbsent || fri != null) {
      map['fri'] = Variable<String>(fri);
    }
    if (!nullToAbsent || sat != null) {
      map['sat'] = Variable<String>(sat);
    }
    return map;
  }

  ProcessShiftCompanion toCompanion(bool nullToAbsent) {
    return ProcessShiftCompanion(
      id: Value(id),
      processId: Value(processId),
      shiftName: Value(shiftName),
      sun: sun == null && nullToAbsent ? const Value.absent() : Value(sun),
      mon: mon == null && nullToAbsent ? const Value.absent() : Value(mon),
      tue: tue == null && nullToAbsent ? const Value.absent() : Value(tue),
      wed: wed == null && nullToAbsent ? const Value.absent() : Value(wed),
      thu: thu == null && nullToAbsent ? const Value.absent() : Value(thu),
      fri: fri == null && nullToAbsent ? const Value.absent() : Value(fri),
      sat: sat == null && nullToAbsent ? const Value.absent() : Value(sat),
    );
  }

  factory ProcessShiftData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessShiftData(
      id: serializer.fromJson<int>(json['id']),
      processId: serializer.fromJson<int>(json['processId']),
      shiftName: serializer.fromJson<String>(json['shiftName']),
      sun: serializer.fromJson<String?>(json['sun']),
      mon: serializer.fromJson<String?>(json['mon']),
      tue: serializer.fromJson<String?>(json['tue']),
      wed: serializer.fromJson<String?>(json['wed']),
      thu: serializer.fromJson<String?>(json['thu']),
      fri: serializer.fromJson<String?>(json['fri']),
      sat: serializer.fromJson<String?>(json['sat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'processId': serializer.toJson<int>(processId),
      'shiftName': serializer.toJson<String>(shiftName),
      'sun': serializer.toJson<String?>(sun),
      'mon': serializer.toJson<String?>(mon),
      'tue': serializer.toJson<String?>(tue),
      'wed': serializer.toJson<String?>(wed),
      'thu': serializer.toJson<String?>(thu),
      'fri': serializer.toJson<String?>(fri),
      'sat': serializer.toJson<String?>(sat),
    };
  }

  ProcessShiftData copyWith(
          {int? id,
          int? processId,
          String? shiftName,
          Value<String?> sun = const Value.absent(),
          Value<String?> mon = const Value.absent(),
          Value<String?> tue = const Value.absent(),
          Value<String?> wed = const Value.absent(),
          Value<String?> thu = const Value.absent(),
          Value<String?> fri = const Value.absent(),
          Value<String?> sat = const Value.absent()}) =>
      ProcessShiftData(
        id: id ?? this.id,
        processId: processId ?? this.processId,
        shiftName: shiftName ?? this.shiftName,
        sun: sun.present ? sun.value : this.sun,
        mon: mon.present ? mon.value : this.mon,
        tue: tue.present ? tue.value : this.tue,
        wed: wed.present ? wed.value : this.wed,
        thu: thu.present ? thu.value : this.thu,
        fri: fri.present ? fri.value : this.fri,
        sat: sat.present ? sat.value : this.sat,
      );
  ProcessShiftData copyWithCompanion(ProcessShiftCompanion data) {
    return ProcessShiftData(
      id: data.id.present ? data.id.value : this.id,
      processId: data.processId.present ? data.processId.value : this.processId,
      shiftName: data.shiftName.present ? data.shiftName.value : this.shiftName,
      sun: data.sun.present ? data.sun.value : this.sun,
      mon: data.mon.present ? data.mon.value : this.mon,
      tue: data.tue.present ? data.tue.value : this.tue,
      wed: data.wed.present ? data.wed.value : this.wed,
      thu: data.thu.present ? data.thu.value : this.thu,
      fri: data.fri.present ? data.fri.value : this.fri,
      sat: data.sat.present ? data.sat.value : this.sat,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessShiftData(')
          ..write('id: $id, ')
          ..write('processId: $processId, ')
          ..write('shiftName: $shiftName, ')
          ..write('sun: $sun, ')
          ..write('mon: $mon, ')
          ..write('tue: $tue, ')
          ..write('wed: $wed, ')
          ..write('thu: $thu, ')
          ..write('fri: $fri, ')
          ..write('sat: $sat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, processId, shiftName, sun, mon, tue, wed, thu, fri, sat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessShiftData &&
          other.id == this.id &&
          other.processId == this.processId &&
          other.shiftName == this.shiftName &&
          other.sun == this.sun &&
          other.mon == this.mon &&
          other.tue == this.tue &&
          other.wed == this.wed &&
          other.thu == this.thu &&
          other.fri == this.fri &&
          other.sat == this.sat);
}

class ProcessShiftCompanion extends UpdateCompanion<ProcessShiftData> {
  final Value<int> id;
  final Value<int> processId;
  final Value<String> shiftName;
  final Value<String?> sun;
  final Value<String?> mon;
  final Value<String?> tue;
  final Value<String?> wed;
  final Value<String?> thu;
  final Value<String?> fri;
  final Value<String?> sat;
  const ProcessShiftCompanion({
    this.id = const Value.absent(),
    this.processId = const Value.absent(),
    this.shiftName = const Value.absent(),
    this.sun = const Value.absent(),
    this.mon = const Value.absent(),
    this.tue = const Value.absent(),
    this.wed = const Value.absent(),
    this.thu = const Value.absent(),
    this.fri = const Value.absent(),
    this.sat = const Value.absent(),
  });
  ProcessShiftCompanion.insert({
    this.id = const Value.absent(),
    required int processId,
    required String shiftName,
    this.sun = const Value.absent(),
    this.mon = const Value.absent(),
    this.tue = const Value.absent(),
    this.wed = const Value.absent(),
    this.thu = const Value.absent(),
    this.fri = const Value.absent(),
    this.sat = const Value.absent(),
  })  : processId = Value(processId),
        shiftName = Value(shiftName);
  static Insertable<ProcessShiftData> custom({
    Expression<int>? id,
    Expression<int>? processId,
    Expression<String>? shiftName,
    Expression<String>? sun,
    Expression<String>? mon,
    Expression<String>? tue,
    Expression<String>? wed,
    Expression<String>? thu,
    Expression<String>? fri,
    Expression<String>? sat,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (processId != null) 'process_id': processId,
      if (shiftName != null) 'shift_name': shiftName,
      if (sun != null) 'sun': sun,
      if (mon != null) 'mon': mon,
      if (tue != null) 'tue': tue,
      if (wed != null) 'wed': wed,
      if (thu != null) 'thu': thu,
      if (fri != null) 'fri': fri,
      if (sat != null) 'sat': sat,
    });
  }

  ProcessShiftCompanion copyWith(
      {Value<int>? id,
      Value<int>? processId,
      Value<String>? shiftName,
      Value<String?>? sun,
      Value<String?>? mon,
      Value<String?>? tue,
      Value<String?>? wed,
      Value<String?>? thu,
      Value<String?>? fri,
      Value<String?>? sat}) {
    return ProcessShiftCompanion(
      id: id ?? this.id,
      processId: processId ?? this.processId,
      shiftName: shiftName ?? this.shiftName,
      sun: sun ?? this.sun,
      mon: mon ?? this.mon,
      tue: tue ?? this.tue,
      wed: wed ?? this.wed,
      thu: thu ?? this.thu,
      fri: fri ?? this.fri,
      sat: sat ?? this.sat,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (processId.present) {
      map['process_id'] = Variable<int>(processId.value);
    }
    if (shiftName.present) {
      map['shift_name'] = Variable<String>(shiftName.value);
    }
    if (sun.present) {
      map['sun'] = Variable<String>(sun.value);
    }
    if (mon.present) {
      map['mon'] = Variable<String>(mon.value);
    }
    if (tue.present) {
      map['tue'] = Variable<String>(tue.value);
    }
    if (wed.present) {
      map['wed'] = Variable<String>(wed.value);
    }
    if (thu.present) {
      map['thu'] = Variable<String>(thu.value);
    }
    if (fri.present) {
      map['fri'] = Variable<String>(fri.value);
    }
    if (sat.present) {
      map['sat'] = Variable<String>(sat.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessShiftCompanion(')
          ..write('id: $id, ')
          ..write('processId: $processId, ')
          ..write('shiftName: $shiftName, ')
          ..write('sun: $sun, ')
          ..write('mon: $mon, ')
          ..write('tue: $tue, ')
          ..write('wed: $wed, ')
          ..write('thu: $thu, ')
          ..write('fri: $fri, ')
          ..write('sat: $sat')
          ..write(')'))
        .toString();
  }
}

class $VSShiftsTable extends VSShifts with TableInfo<$VSShiftsTable, VSShift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VSShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _vsIdMeta = const VerificationMeta('vsId');
  @override
  late final GeneratedColumn<int> vsId = GeneratedColumn<int>(
      'vs_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES value_streams (id)'));
  static const VerificationMeta _shiftNameMeta =
      const VerificationMeta('shiftName');
  @override
  late final GeneratedColumn<String> shiftName = GeneratedColumn<String>(
      'shift_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sunMeta = const VerificationMeta('sun');
  @override
  late final GeneratedColumn<String> sun = GeneratedColumn<String>(
      'sun', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _monMeta = const VerificationMeta('mon');
  @override
  late final GeneratedColumn<String> mon = GeneratedColumn<String>(
      'mon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tueMeta = const VerificationMeta('tue');
  @override
  late final GeneratedColumn<String> tue = GeneratedColumn<String>(
      'tue', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wedMeta = const VerificationMeta('wed');
  @override
  late final GeneratedColumn<String> wed = GeneratedColumn<String>(
      'wed', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thuMeta = const VerificationMeta('thu');
  @override
  late final GeneratedColumn<String> thu = GeneratedColumn<String>(
      'thu', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _friMeta = const VerificationMeta('fri');
  @override
  late final GeneratedColumn<String> fri = GeneratedColumn<String>(
      'fri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _satMeta = const VerificationMeta('sat');
  @override
  late final GeneratedColumn<String> sat = GeneratedColumn<String>(
      'sat', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, vsId, shiftName, sun, mon, tue, wed, thu, fri, sat];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vs_shifts';
  @override
  VerificationContext validateIntegrity(Insertable<VSShift> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vs_id')) {
      context.handle(
          _vsIdMeta, vsId.isAcceptableOrUnknown(data['vs_id']!, _vsIdMeta));
    } else if (isInserting) {
      context.missing(_vsIdMeta);
    }
    if (data.containsKey('shift_name')) {
      context.handle(_shiftNameMeta,
          shiftName.isAcceptableOrUnknown(data['shift_name']!, _shiftNameMeta));
    } else if (isInserting) {
      context.missing(_shiftNameMeta);
    }
    if (data.containsKey('sun')) {
      context.handle(
          _sunMeta, sun.isAcceptableOrUnknown(data['sun']!, _sunMeta));
    }
    if (data.containsKey('mon')) {
      context.handle(
          _monMeta, mon.isAcceptableOrUnknown(data['mon']!, _monMeta));
    }
    if (data.containsKey('tue')) {
      context.handle(
          _tueMeta, tue.isAcceptableOrUnknown(data['tue']!, _tueMeta));
    }
    if (data.containsKey('wed')) {
      context.handle(
          _wedMeta, wed.isAcceptableOrUnknown(data['wed']!, _wedMeta));
    }
    if (data.containsKey('thu')) {
      context.handle(
          _thuMeta, thu.isAcceptableOrUnknown(data['thu']!, _thuMeta));
    }
    if (data.containsKey('fri')) {
      context.handle(
          _friMeta, fri.isAcceptableOrUnknown(data['fri']!, _friMeta));
    }
    if (data.containsKey('sat')) {
      context.handle(
          _satMeta, sat.isAcceptableOrUnknown(data['sat']!, _satMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VSShift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VSShift(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      vsId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vs_id'])!,
      shiftName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_name'])!,
      sun: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sun']),
      mon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mon']),
      tue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tue']),
      wed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wed']),
      thu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thu']),
      fri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fri']),
      sat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sat']),
    );
  }

  @override
  $VSShiftsTable createAlias(String alias) {
    return $VSShiftsTable(attachedDatabase, alias);
  }
}

class VSShift extends DataClass implements Insertable<VSShift> {
  final int id;
  final int vsId;
  final String shiftName;
  final String? sun;
  final String? mon;
  final String? tue;
  final String? wed;
  final String? thu;
  final String? fri;
  final String? sat;
  const VSShift(
      {required this.id,
      required this.vsId,
      required this.shiftName,
      this.sun,
      this.mon,
      this.tue,
      this.wed,
      this.thu,
      this.fri,
      this.sat});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vs_id'] = Variable<int>(vsId);
    map['shift_name'] = Variable<String>(shiftName);
    if (!nullToAbsent || sun != null) {
      map['sun'] = Variable<String>(sun);
    }
    if (!nullToAbsent || mon != null) {
      map['mon'] = Variable<String>(mon);
    }
    if (!nullToAbsent || tue != null) {
      map['tue'] = Variable<String>(tue);
    }
    if (!nullToAbsent || wed != null) {
      map['wed'] = Variable<String>(wed);
    }
    if (!nullToAbsent || thu != null) {
      map['thu'] = Variable<String>(thu);
    }
    if (!nullToAbsent || fri != null) {
      map['fri'] = Variable<String>(fri);
    }
    if (!nullToAbsent || sat != null) {
      map['sat'] = Variable<String>(sat);
    }
    return map;
  }

  VSShiftsCompanion toCompanion(bool nullToAbsent) {
    return VSShiftsCompanion(
      id: Value(id),
      vsId: Value(vsId),
      shiftName: Value(shiftName),
      sun: sun == null && nullToAbsent ? const Value.absent() : Value(sun),
      mon: mon == null && nullToAbsent ? const Value.absent() : Value(mon),
      tue: tue == null && nullToAbsent ? const Value.absent() : Value(tue),
      wed: wed == null && nullToAbsent ? const Value.absent() : Value(wed),
      thu: thu == null && nullToAbsent ? const Value.absent() : Value(thu),
      fri: fri == null && nullToAbsent ? const Value.absent() : Value(fri),
      sat: sat == null && nullToAbsent ? const Value.absent() : Value(sat),
    );
  }

  factory VSShift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VSShift(
      id: serializer.fromJson<int>(json['id']),
      vsId: serializer.fromJson<int>(json['vsId']),
      shiftName: serializer.fromJson<String>(json['shiftName']),
      sun: serializer.fromJson<String?>(json['sun']),
      mon: serializer.fromJson<String?>(json['mon']),
      tue: serializer.fromJson<String?>(json['tue']),
      wed: serializer.fromJson<String?>(json['wed']),
      thu: serializer.fromJson<String?>(json['thu']),
      fri: serializer.fromJson<String?>(json['fri']),
      sat: serializer.fromJson<String?>(json['sat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vsId': serializer.toJson<int>(vsId),
      'shiftName': serializer.toJson<String>(shiftName),
      'sun': serializer.toJson<String?>(sun),
      'mon': serializer.toJson<String?>(mon),
      'tue': serializer.toJson<String?>(tue),
      'wed': serializer.toJson<String?>(wed),
      'thu': serializer.toJson<String?>(thu),
      'fri': serializer.toJson<String?>(fri),
      'sat': serializer.toJson<String?>(sat),
    };
  }

  VSShift copyWith(
          {int? id,
          int? vsId,
          String? shiftName,
          Value<String?> sun = const Value.absent(),
          Value<String?> mon = const Value.absent(),
          Value<String?> tue = const Value.absent(),
          Value<String?> wed = const Value.absent(),
          Value<String?> thu = const Value.absent(),
          Value<String?> fri = const Value.absent(),
          Value<String?> sat = const Value.absent()}) =>
      VSShift(
        id: id ?? this.id,
        vsId: vsId ?? this.vsId,
        shiftName: shiftName ?? this.shiftName,
        sun: sun.present ? sun.value : this.sun,
        mon: mon.present ? mon.value : this.mon,
        tue: tue.present ? tue.value : this.tue,
        wed: wed.present ? wed.value : this.wed,
        thu: thu.present ? thu.value : this.thu,
        fri: fri.present ? fri.value : this.fri,
        sat: sat.present ? sat.value : this.sat,
      );
  VSShift copyWithCompanion(VSShiftsCompanion data) {
    return VSShift(
      id: data.id.present ? data.id.value : this.id,
      vsId: data.vsId.present ? data.vsId.value : this.vsId,
      shiftName: data.shiftName.present ? data.shiftName.value : this.shiftName,
      sun: data.sun.present ? data.sun.value : this.sun,
      mon: data.mon.present ? data.mon.value : this.mon,
      tue: data.tue.present ? data.tue.value : this.tue,
      wed: data.wed.present ? data.wed.value : this.wed,
      thu: data.thu.present ? data.thu.value : this.thu,
      fri: data.fri.present ? data.fri.value : this.fri,
      sat: data.sat.present ? data.sat.value : this.sat,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VSShift(')
          ..write('id: $id, ')
          ..write('vsId: $vsId, ')
          ..write('shiftName: $shiftName, ')
          ..write('sun: $sun, ')
          ..write('mon: $mon, ')
          ..write('tue: $tue, ')
          ..write('wed: $wed, ')
          ..write('thu: $thu, ')
          ..write('fri: $fri, ')
          ..write('sat: $sat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vsId, shiftName, sun, mon, tue, wed, thu, fri, sat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VSShift &&
          other.id == this.id &&
          other.vsId == this.vsId &&
          other.shiftName == this.shiftName &&
          other.sun == this.sun &&
          other.mon == this.mon &&
          other.tue == this.tue &&
          other.wed == this.wed &&
          other.thu == this.thu &&
          other.fri == this.fri &&
          other.sat == this.sat);
}

class VSShiftsCompanion extends UpdateCompanion<VSShift> {
  final Value<int> id;
  final Value<int> vsId;
  final Value<String> shiftName;
  final Value<String?> sun;
  final Value<String?> mon;
  final Value<String?> tue;
  final Value<String?> wed;
  final Value<String?> thu;
  final Value<String?> fri;
  final Value<String?> sat;
  const VSShiftsCompanion({
    this.id = const Value.absent(),
    this.vsId = const Value.absent(),
    this.shiftName = const Value.absent(),
    this.sun = const Value.absent(),
    this.mon = const Value.absent(),
    this.tue = const Value.absent(),
    this.wed = const Value.absent(),
    this.thu = const Value.absent(),
    this.fri = const Value.absent(),
    this.sat = const Value.absent(),
  });
  VSShiftsCompanion.insert({
    this.id = const Value.absent(),
    required int vsId,
    required String shiftName,
    this.sun = const Value.absent(),
    this.mon = const Value.absent(),
    this.tue = const Value.absent(),
    this.wed = const Value.absent(),
    this.thu = const Value.absent(),
    this.fri = const Value.absent(),
    this.sat = const Value.absent(),
  })  : vsId = Value(vsId),
        shiftName = Value(shiftName);
  static Insertable<VSShift> custom({
    Expression<int>? id,
    Expression<int>? vsId,
    Expression<String>? shiftName,
    Expression<String>? sun,
    Expression<String>? mon,
    Expression<String>? tue,
    Expression<String>? wed,
    Expression<String>? thu,
    Expression<String>? fri,
    Expression<String>? sat,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vsId != null) 'vs_id': vsId,
      if (shiftName != null) 'shift_name': shiftName,
      if (sun != null) 'sun': sun,
      if (mon != null) 'mon': mon,
      if (tue != null) 'tue': tue,
      if (wed != null) 'wed': wed,
      if (thu != null) 'thu': thu,
      if (fri != null) 'fri': fri,
      if (sat != null) 'sat': sat,
    });
  }

  VSShiftsCompanion copyWith(
      {Value<int>? id,
      Value<int>? vsId,
      Value<String>? shiftName,
      Value<String?>? sun,
      Value<String?>? mon,
      Value<String?>? tue,
      Value<String?>? wed,
      Value<String?>? thu,
      Value<String?>? fri,
      Value<String?>? sat}) {
    return VSShiftsCompanion(
      id: id ?? this.id,
      vsId: vsId ?? this.vsId,
      shiftName: shiftName ?? this.shiftName,
      sun: sun ?? this.sun,
      mon: mon ?? this.mon,
      tue: tue ?? this.tue,
      wed: wed ?? this.wed,
      thu: thu ?? this.thu,
      fri: fri ?? this.fri,
      sat: sat ?? this.sat,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vsId.present) {
      map['vs_id'] = Variable<int>(vsId.value);
    }
    if (shiftName.present) {
      map['shift_name'] = Variable<String>(shiftName.value);
    }
    if (sun.present) {
      map['sun'] = Variable<String>(sun.value);
    }
    if (mon.present) {
      map['mon'] = Variable<String>(mon.value);
    }
    if (tue.present) {
      map['tue'] = Variable<String>(tue.value);
    }
    if (wed.present) {
      map['wed'] = Variable<String>(wed.value);
    }
    if (thu.present) {
      map['thu'] = Variable<String>(thu.value);
    }
    if (fri.present) {
      map['fri'] = Variable<String>(fri.value);
    }
    if (sat.present) {
      map['sat'] = Variable<String>(sat.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VSShiftsCompanion(')
          ..write('id: $id, ')
          ..write('vsId: $vsId, ')
          ..write('shiftName: $shiftName, ')
          ..write('sun: $sun, ')
          ..write('mon: $mon, ')
          ..write('tue: $tue, ')
          ..write('wed: $wed, ')
          ..write('thu: $thu, ')
          ..write('fri: $fri, ')
          ..write('sat: $sat')
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
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
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
  static const VerificationMeta _organizationIdMeta =
      const VerificationMeta('organizationId');
  @override
  late final GeneratedColumn<int> organizationId = GeneratedColumn<int>(
      'organization_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES organizations (id)'));
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
  static const VerificationMeta _monthlyDemandMeta =
      const VerificationMeta('monthlyDemand');
  @override
  late final GeneratedColumn<int> monthlyDemand = GeneratedColumn<int>(
      'monthly_demand', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        valueStreamId,
        organizationId,
        partNumber,
        partDescription,
        monthlyDemand
      ];
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
    if (data.containsKey('organization_id')) {
      context.handle(
          _organizationIdMeta,
          organizationId.isAcceptableOrUnknown(
              data['organization_id']!, _organizationIdMeta));
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
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
    if (data.containsKey('monthly_demand')) {
      context.handle(
          _monthlyDemandMeta,
          monthlyDemand.isAcceptableOrUnknown(
              data['monthly_demand']!, _monthlyDemandMeta));
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
      organizationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}organization_id'])!,
      partNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_number'])!,
      partDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}part_description']),
      monthlyDemand: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}monthly_demand']),
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
  final int organizationId;
  final String partNumber;
  final String? partDescription;
  final int? monthlyDemand;
  const Part(
      {required this.id,
      required this.valueStreamId,
      required this.organizationId,
      required this.partNumber,
      this.partDescription,
      this.monthlyDemand});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['value_stream_id'] = Variable<int>(valueStreamId);
    map['organization_id'] = Variable<int>(organizationId);
    map['part_number'] = Variable<String>(partNumber);
    if (!nullToAbsent || partDescription != null) {
      map['part_description'] = Variable<String>(partDescription);
    }
    if (!nullToAbsent || monthlyDemand != null) {
      map['monthly_demand'] = Variable<int>(monthlyDemand);
    }
    return map;
  }

  PartsCompanion toCompanion(bool nullToAbsent) {
    return PartsCompanion(
      id: Value(id),
      valueStreamId: Value(valueStreamId),
      organizationId: Value(organizationId),
      partNumber: Value(partNumber),
      partDescription: partDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(partDescription),
      monthlyDemand: monthlyDemand == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyDemand),
    );
  }

  factory Part.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Part(
      id: serializer.fromJson<int>(json['id']),
      valueStreamId: serializer.fromJson<int>(json['valueStreamId']),
      organizationId: serializer.fromJson<int>(json['organizationId']),
      partNumber: serializer.fromJson<String>(json['partNumber']),
      partDescription: serializer.fromJson<String?>(json['partDescription']),
      monthlyDemand: serializer.fromJson<int?>(json['monthlyDemand']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'valueStreamId': serializer.toJson<int>(valueStreamId),
      'organizationId': serializer.toJson<int>(organizationId),
      'partNumber': serializer.toJson<String>(partNumber),
      'partDescription': serializer.toJson<String?>(partDescription),
      'monthlyDemand': serializer.toJson<int?>(monthlyDemand),
    };
  }

  Part copyWith(
          {int? id,
          int? valueStreamId,
          int? organizationId,
          String? partNumber,
          Value<String?> partDescription = const Value.absent(),
          Value<int?> monthlyDemand = const Value.absent()}) =>
      Part(
        id: id ?? this.id,
        valueStreamId: valueStreamId ?? this.valueStreamId,
        organizationId: organizationId ?? this.organizationId,
        partNumber: partNumber ?? this.partNumber,
        partDescription: partDescription.present
            ? partDescription.value
            : this.partDescription,
        monthlyDemand:
            monthlyDemand.present ? monthlyDemand.value : this.monthlyDemand,
      );
  Part copyWithCompanion(PartsCompanion data) {
    return Part(
      id: data.id.present ? data.id.value : this.id,
      valueStreamId: data.valueStreamId.present
          ? data.valueStreamId.value
          : this.valueStreamId,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      partNumber:
          data.partNumber.present ? data.partNumber.value : this.partNumber,
      partDescription: data.partDescription.present
          ? data.partDescription.value
          : this.partDescription,
      monthlyDemand: data.monthlyDemand.present
          ? data.monthlyDemand.value
          : this.monthlyDemand,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Part(')
          ..write('id: $id, ')
          ..write('valueStreamId: $valueStreamId, ')
          ..write('organizationId: $organizationId, ')
          ..write('partNumber: $partNumber, ')
          ..write('partDescription: $partDescription, ')
          ..write('monthlyDemand: $monthlyDemand')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, valueStreamId, organizationId, partNumber,
      partDescription, monthlyDemand);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Part &&
          other.id == this.id &&
          other.valueStreamId == this.valueStreamId &&
          other.organizationId == this.organizationId &&
          other.partNumber == this.partNumber &&
          other.partDescription == this.partDescription &&
          other.monthlyDemand == this.monthlyDemand);
}

class PartsCompanion extends UpdateCompanion<Part> {
  final Value<int> id;
  final Value<int> valueStreamId;
  final Value<int> organizationId;
  final Value<String> partNumber;
  final Value<String?> partDescription;
  final Value<int?> monthlyDemand;
  const PartsCompanion({
    this.id = const Value.absent(),
    this.valueStreamId = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.partNumber = const Value.absent(),
    this.partDescription = const Value.absent(),
    this.monthlyDemand = const Value.absent(),
  });
  PartsCompanion.insert({
    this.id = const Value.absent(),
    required int valueStreamId,
    required int organizationId,
    required String partNumber,
    this.partDescription = const Value.absent(),
    this.monthlyDemand = const Value.absent(),
  })  : valueStreamId = Value(valueStreamId),
        organizationId = Value(organizationId),
        partNumber = Value(partNumber);
  static Insertable<Part> custom({
    Expression<int>? id,
    Expression<int>? valueStreamId,
    Expression<int>? organizationId,
    Expression<String>? partNumber,
    Expression<String>? partDescription,
    Expression<int>? monthlyDemand,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (valueStreamId != null) 'value_stream_id': valueStreamId,
      if (organizationId != null) 'organization_id': organizationId,
      if (partNumber != null) 'part_number': partNumber,
      if (partDescription != null) 'part_description': partDescription,
      if (monthlyDemand != null) 'monthly_demand': monthlyDemand,
    });
  }

  PartsCompanion copyWith(
      {Value<int>? id,
      Value<int>? valueStreamId,
      Value<int>? organizationId,
      Value<String>? partNumber,
      Value<String?>? partDescription,
      Value<int?>? monthlyDemand}) {
    return PartsCompanion(
      id: id ?? this.id,
      valueStreamId: valueStreamId ?? this.valueStreamId,
      organizationId: organizationId ?? this.organizationId,
      partNumber: partNumber ?? this.partNumber,
      partDescription: partDescription ?? this.partDescription,
      monthlyDemand: monthlyDemand ?? this.monthlyDemand,
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
    if (organizationId.present) {
      map['organization_id'] = Variable<int>(organizationId.value);
    }
    if (partNumber.present) {
      map['part_number'] = Variable<String>(partNumber.value);
    }
    if (partDescription.present) {
      map['part_description'] = Variable<String>(partDescription.value);
    }
    if (monthlyDemand.present) {
      map['monthly_demand'] = Variable<int>(monthlyDemand.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartsCompanion(')
          ..write('id: $id, ')
          ..write('valueStreamId: $valueStreamId, ')
          ..write('organizationId: $organizationId, ')
          ..write('partNumber: $partNumber, ')
          ..write('partDescription: $partDescription, ')
          ..write('monthlyDemand: $monthlyDemand')
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

class $SetupsTable extends Setups with TableInfo<$SetupsTable, Setup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetupsTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [id, processPartId, setupName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setups';
  @override
  VerificationContext validateIntegrity(Insertable<Setup> instance,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setup(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      processPartId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}process_part_id'])!,
      setupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setup_name'])!,
    );
  }

  @override
  $SetupsTable createAlias(String alias) {
    return $SetupsTable(attachedDatabase, alias);
  }
}

class Setup extends DataClass implements Insertable<Setup> {
  final int id;
  final int processPartId;
  final String setupName;
  const Setup(
      {required this.id, required this.processPartId, required this.setupName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['process_part_id'] = Variable<int>(processPartId);
    map['setup_name'] = Variable<String>(setupName);
    return map;
  }

  SetupsCompanion toCompanion(bool nullToAbsent) {
    return SetupsCompanion(
      id: Value(id),
      processPartId: Value(processPartId),
      setupName: Value(setupName),
    );
  }

  factory Setup.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setup(
      id: serializer.fromJson<int>(json['id']),
      processPartId: serializer.fromJson<int>(json['processPartId']),
      setupName: serializer.fromJson<String>(json['setupName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'processPartId': serializer.toJson<int>(processPartId),
      'setupName': serializer.toJson<String>(setupName),
    };
  }

  Setup copyWith({int? id, int? processPartId, String? setupName}) => Setup(
        id: id ?? this.id,
        processPartId: processPartId ?? this.processPartId,
        setupName: setupName ?? this.setupName,
      );
  Setup copyWithCompanion(SetupsCompanion data) {
    return Setup(
      id: data.id.present ? data.id.value : this.id,
      processPartId: data.processPartId.present
          ? data.processPartId.value
          : this.processPartId,
      setupName: data.setupName.present ? data.setupName.value : this.setupName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setup(')
          ..write('id: $id, ')
          ..write('processPartId: $processPartId, ')
          ..write('setupName: $setupName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, processPartId, setupName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setup &&
          other.id == this.id &&
          other.processPartId == this.processPartId &&
          other.setupName == this.setupName);
}

class SetupsCompanion extends UpdateCompanion<Setup> {
  final Value<int> id;
  final Value<int> processPartId;
  final Value<String> setupName;
  const SetupsCompanion({
    this.id = const Value.absent(),
    this.processPartId = const Value.absent(),
    this.setupName = const Value.absent(),
  });
  SetupsCompanion.insert({
    this.id = const Value.absent(),
    required int processPartId,
    required String setupName,
  })  : processPartId = Value(processPartId),
        setupName = Value(setupName);
  static Insertable<Setup> custom({
    Expression<int>? id,
    Expression<int>? processPartId,
    Expression<String>? setupName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (processPartId != null) 'process_part_id': processPartId,
      if (setupName != null) 'setup_name': setupName,
    });
  }

  SetupsCompanion copyWith(
      {Value<int>? id, Value<int>? processPartId, Value<String>? setupName}) {
    return SetupsCompanion(
      id: id ?? this.id,
      processPartId: processPartId ?? this.processPartId,
      setupName: setupName ?? this.setupName,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetupsCompanion(')
          ..write('id: $id, ')
          ..write('processPartId: $processPartId, ')
          ..write('setupName: $setupName')
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
  static const VerificationMeta _setupIdMeta =
      const VerificationMeta('setupId');
  @override
  late final GeneratedColumn<int> setupId = GeneratedColumn<int>(
      'setup_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES setups (id)'));
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
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lrtMeta = const VerificationMeta('lrt');
  @override
  late final GeneratedColumn<String> lrt = GeneratedColumn<String>(
      'lrt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _overrideTimeMeta =
      const VerificationMeta('overrideTime');
  @override
  late final GeneratedColumn<String> overrideTime = GeneratedColumn<String>(
      'override_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _commentsMeta =
      const VerificationMeta('comments');
  @override
  late final GeneratedColumn<String> comments = GeneratedColumn<String>(
      'comments', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        processPartId,
        setupId,
        setupDateTime,
        elementName,
        time,
        orderIndex,
        lrt,
        overrideTime,
        comments
      ];
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
    if (data.containsKey('setup_id')) {
      context.handle(_setupIdMeta,
          setupId.isAcceptableOrUnknown(data['setup_id']!, _setupIdMeta));
    } else if (isInserting) {
      context.missing(_setupIdMeta);
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
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('lrt')) {
      context.handle(
          _lrtMeta, lrt.isAcceptableOrUnknown(data['lrt']!, _lrtMeta));
    }
    if (data.containsKey('override_time')) {
      context.handle(
          _overrideTimeMeta,
          overrideTime.isAcceptableOrUnknown(
              data['override_time']!, _overrideTimeMeta));
    }
    if (data.containsKey('comments')) {
      context.handle(_commentsMeta,
          comments.isAcceptableOrUnknown(data['comments']!, _commentsMeta));
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
      setupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}setup_id'])!,
      setupDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}setup_date_time'])!,
      elementName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}element_name'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      lrt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lrt']),
      overrideTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}override_time']),
      comments: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comments']),
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
  final int setupId;
  final DateTime setupDateTime;
  final String elementName;
  final String time;
  final int orderIndex;
  final String? lrt;
  final String? overrideTime;
  final String? comments;
  const SetupElement(
      {required this.id,
      required this.processPartId,
      required this.setupId,
      required this.setupDateTime,
      required this.elementName,
      required this.time,
      required this.orderIndex,
      this.lrt,
      this.overrideTime,
      this.comments});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['process_part_id'] = Variable<int>(processPartId);
    map['setup_id'] = Variable<int>(setupId);
    map['setup_date_time'] = Variable<DateTime>(setupDateTime);
    map['element_name'] = Variable<String>(elementName);
    map['time'] = Variable<String>(time);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || lrt != null) {
      map['lrt'] = Variable<String>(lrt);
    }
    if (!nullToAbsent || overrideTime != null) {
      map['override_time'] = Variable<String>(overrideTime);
    }
    if (!nullToAbsent || comments != null) {
      map['comments'] = Variable<String>(comments);
    }
    return map;
  }

  SetupElementsCompanion toCompanion(bool nullToAbsent) {
    return SetupElementsCompanion(
      id: Value(id),
      processPartId: Value(processPartId),
      setupId: Value(setupId),
      setupDateTime: Value(setupDateTime),
      elementName: Value(elementName),
      time: Value(time),
      orderIndex: Value(orderIndex),
      lrt: lrt == null && nullToAbsent ? const Value.absent() : Value(lrt),
      overrideTime: overrideTime == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideTime),
      comments: comments == null && nullToAbsent
          ? const Value.absent()
          : Value(comments),
    );
  }

  factory SetupElement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetupElement(
      id: serializer.fromJson<int>(json['id']),
      processPartId: serializer.fromJson<int>(json['processPartId']),
      setupId: serializer.fromJson<int>(json['setupId']),
      setupDateTime: serializer.fromJson<DateTime>(json['setupDateTime']),
      elementName: serializer.fromJson<String>(json['elementName']),
      time: serializer.fromJson<String>(json['time']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      lrt: serializer.fromJson<String?>(json['lrt']),
      overrideTime: serializer.fromJson<String?>(json['overrideTime']),
      comments: serializer.fromJson<String?>(json['comments']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'processPartId': serializer.toJson<int>(processPartId),
      'setupId': serializer.toJson<int>(setupId),
      'setupDateTime': serializer.toJson<DateTime>(setupDateTime),
      'elementName': serializer.toJson<String>(elementName),
      'time': serializer.toJson<String>(time),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'lrt': serializer.toJson<String?>(lrt),
      'overrideTime': serializer.toJson<String?>(overrideTime),
      'comments': serializer.toJson<String?>(comments),
    };
  }

  SetupElement copyWith(
          {int? id,
          int? processPartId,
          int? setupId,
          DateTime? setupDateTime,
          String? elementName,
          String? time,
          int? orderIndex,
          Value<String?> lrt = const Value.absent(),
          Value<String?> overrideTime = const Value.absent(),
          Value<String?> comments = const Value.absent()}) =>
      SetupElement(
        id: id ?? this.id,
        processPartId: processPartId ?? this.processPartId,
        setupId: setupId ?? this.setupId,
        setupDateTime: setupDateTime ?? this.setupDateTime,
        elementName: elementName ?? this.elementName,
        time: time ?? this.time,
        orderIndex: orderIndex ?? this.orderIndex,
        lrt: lrt.present ? lrt.value : this.lrt,
        overrideTime:
            overrideTime.present ? overrideTime.value : this.overrideTime,
        comments: comments.present ? comments.value : this.comments,
      );
  SetupElement copyWithCompanion(SetupElementsCompanion data) {
    return SetupElement(
      id: data.id.present ? data.id.value : this.id,
      processPartId: data.processPartId.present
          ? data.processPartId.value
          : this.processPartId,
      setupId: data.setupId.present ? data.setupId.value : this.setupId,
      setupDateTime: data.setupDateTime.present
          ? data.setupDateTime.value
          : this.setupDateTime,
      elementName:
          data.elementName.present ? data.elementName.value : this.elementName,
      time: data.time.present ? data.time.value : this.time,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      lrt: data.lrt.present ? data.lrt.value : this.lrt,
      overrideTime: data.overrideTime.present
          ? data.overrideTime.value
          : this.overrideTime,
      comments: data.comments.present ? data.comments.value : this.comments,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetupElement(')
          ..write('id: $id, ')
          ..write('processPartId: $processPartId, ')
          ..write('setupId: $setupId, ')
          ..write('setupDateTime: $setupDateTime, ')
          ..write('elementName: $elementName, ')
          ..write('time: $time, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('lrt: $lrt, ')
          ..write('overrideTime: $overrideTime, ')
          ..write('comments: $comments')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, processPartId, setupId, setupDateTime,
      elementName, time, orderIndex, lrt, overrideTime, comments);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetupElement &&
          other.id == this.id &&
          other.processPartId == this.processPartId &&
          other.setupId == this.setupId &&
          other.setupDateTime == this.setupDateTime &&
          other.elementName == this.elementName &&
          other.time == this.time &&
          other.orderIndex == this.orderIndex &&
          other.lrt == this.lrt &&
          other.overrideTime == this.overrideTime &&
          other.comments == this.comments);
}

class SetupElementsCompanion extends UpdateCompanion<SetupElement> {
  final Value<int> id;
  final Value<int> processPartId;
  final Value<int> setupId;
  final Value<DateTime> setupDateTime;
  final Value<String> elementName;
  final Value<String> time;
  final Value<int> orderIndex;
  final Value<String?> lrt;
  final Value<String?> overrideTime;
  final Value<String?> comments;
  const SetupElementsCompanion({
    this.id = const Value.absent(),
    this.processPartId = const Value.absent(),
    this.setupId = const Value.absent(),
    this.setupDateTime = const Value.absent(),
    this.elementName = const Value.absent(),
    this.time = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.lrt = const Value.absent(),
    this.overrideTime = const Value.absent(),
    this.comments = const Value.absent(),
  });
  SetupElementsCompanion.insert({
    this.id = const Value.absent(),
    required int processPartId,
    required int setupId,
    required DateTime setupDateTime,
    required String elementName,
    required String time,
    this.orderIndex = const Value.absent(),
    this.lrt = const Value.absent(),
    this.overrideTime = const Value.absent(),
    this.comments = const Value.absent(),
  })  : processPartId = Value(processPartId),
        setupId = Value(setupId),
        setupDateTime = Value(setupDateTime),
        elementName = Value(elementName),
        time = Value(time);
  static Insertable<SetupElement> custom({
    Expression<int>? id,
    Expression<int>? processPartId,
    Expression<int>? setupId,
    Expression<DateTime>? setupDateTime,
    Expression<String>? elementName,
    Expression<String>? time,
    Expression<int>? orderIndex,
    Expression<String>? lrt,
    Expression<String>? overrideTime,
    Expression<String>? comments,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (processPartId != null) 'process_part_id': processPartId,
      if (setupId != null) 'setup_id': setupId,
      if (setupDateTime != null) 'setup_date_time': setupDateTime,
      if (elementName != null) 'element_name': elementName,
      if (time != null) 'time': time,
      if (orderIndex != null) 'order_index': orderIndex,
      if (lrt != null) 'lrt': lrt,
      if (overrideTime != null) 'override_time': overrideTime,
      if (comments != null) 'comments': comments,
    });
  }

  SetupElementsCompanion copyWith(
      {Value<int>? id,
      Value<int>? processPartId,
      Value<int>? setupId,
      Value<DateTime>? setupDateTime,
      Value<String>? elementName,
      Value<String>? time,
      Value<int>? orderIndex,
      Value<String?>? lrt,
      Value<String?>? overrideTime,
      Value<String?>? comments}) {
    return SetupElementsCompanion(
      id: id ?? this.id,
      processPartId: processPartId ?? this.processPartId,
      setupId: setupId ?? this.setupId,
      setupDateTime: setupDateTime ?? this.setupDateTime,
      elementName: elementName ?? this.elementName,
      time: time ?? this.time,
      orderIndex: orderIndex ?? this.orderIndex,
      lrt: lrt ?? this.lrt,
      overrideTime: overrideTime ?? this.overrideTime,
      comments: comments ?? this.comments,
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
    if (setupId.present) {
      map['setup_id'] = Variable<int>(setupId.value);
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
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (lrt.present) {
      map['lrt'] = Variable<String>(lrt.value);
    }
    if (overrideTime.present) {
      map['override_time'] = Variable<String>(overrideTime.value);
    }
    if (comments.present) {
      map['comments'] = Variable<String>(comments.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetupElementsCompanion(')
          ..write('id: $id, ')
          ..write('processPartId: $processPartId, ')
          ..write('setupId: $setupId, ')
          ..write('setupDateTime: $setupDateTime, ')
          ..write('elementName: $elementName, ')
          ..write('time: $time, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('lrt: $lrt, ')
          ..write('overrideTime: $overrideTime, ')
          ..write('comments: $comments')
          ..write(')'))
        .toString();
  }
}

class $StudyTable extends Study with TableInfo<$StudyTable, StudyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _setupIdMeta =
      const VerificationMeta('setupId');
  @override
  late final GeneratedColumn<int> setupId = GeneratedColumn<int>(
      'setup_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES setups (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _observerNameMeta =
      const VerificationMeta('observerName');
  @override
  late final GeneratedColumn<String> observerName = GeneratedColumn<String>(
      'observer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, setupId, date, time, observerName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study';
  @override
  VerificationContext validateIntegrity(Insertable<StudyData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('setup_id')) {
      context.handle(_setupIdMeta,
          setupId.isAcceptableOrUnknown(data['setup_id']!, _setupIdMeta));
    } else if (isInserting) {
      context.missing(_setupIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('observer_name')) {
      context.handle(
          _observerNameMeta,
          observerName.isAcceptableOrUnknown(
              data['observer_name']!, _observerNameMeta));
    } else if (isInserting) {
      context.missing(_observerNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      setupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}setup_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      observerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observer_name'])!,
    );
  }

  @override
  $StudyTable createAlias(String alias) {
    return $StudyTable(attachedDatabase, alias);
  }
}

class StudyData extends DataClass implements Insertable<StudyData> {
  final int id;
  final int setupId;
  final DateTime date;
  final DateTime time;
  final String observerName;
  const StudyData(
      {required this.id,
      required this.setupId,
      required this.date,
      required this.time,
      required this.observerName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['setup_id'] = Variable<int>(setupId);
    map['date'] = Variable<DateTime>(date);
    map['time'] = Variable<DateTime>(time);
    map['observer_name'] = Variable<String>(observerName);
    return map;
  }

  StudyCompanion toCompanion(bool nullToAbsent) {
    return StudyCompanion(
      id: Value(id),
      setupId: Value(setupId),
      date: Value(date),
      time: Value(time),
      observerName: Value(observerName),
    );
  }

  factory StudyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyData(
      id: serializer.fromJson<int>(json['id']),
      setupId: serializer.fromJson<int>(json['setupId']),
      date: serializer.fromJson<DateTime>(json['date']),
      time: serializer.fromJson<DateTime>(json['time']),
      observerName: serializer.fromJson<String>(json['observerName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'setupId': serializer.toJson<int>(setupId),
      'date': serializer.toJson<DateTime>(date),
      'time': serializer.toJson<DateTime>(time),
      'observerName': serializer.toJson<String>(observerName),
    };
  }

  StudyData copyWith(
          {int? id,
          int? setupId,
          DateTime? date,
          DateTime? time,
          String? observerName}) =>
      StudyData(
        id: id ?? this.id,
        setupId: setupId ?? this.setupId,
        date: date ?? this.date,
        time: time ?? this.time,
        observerName: observerName ?? this.observerName,
      );
  StudyData copyWithCompanion(StudyCompanion data) {
    return StudyData(
      id: data.id.present ? data.id.value : this.id,
      setupId: data.setupId.present ? data.setupId.value : this.setupId,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      observerName: data.observerName.present
          ? data.observerName.value
          : this.observerName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyData(')
          ..write('id: $id, ')
          ..write('setupId: $setupId, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('observerName: $observerName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, setupId, date, time, observerName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyData &&
          other.id == this.id &&
          other.setupId == this.setupId &&
          other.date == this.date &&
          other.time == this.time &&
          other.observerName == this.observerName);
}

class StudyCompanion extends UpdateCompanion<StudyData> {
  final Value<int> id;
  final Value<int> setupId;
  final Value<DateTime> date;
  final Value<DateTime> time;
  final Value<String> observerName;
  const StudyCompanion({
    this.id = const Value.absent(),
    this.setupId = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.observerName = const Value.absent(),
  });
  StudyCompanion.insert({
    this.id = const Value.absent(),
    required int setupId,
    required DateTime date,
    required DateTime time,
    required String observerName,
  })  : setupId = Value(setupId),
        date = Value(date),
        time = Value(time),
        observerName = Value(observerName);
  static Insertable<StudyData> custom({
    Expression<int>? id,
    Expression<int>? setupId,
    Expression<DateTime>? date,
    Expression<DateTime>? time,
    Expression<String>? observerName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setupId != null) 'setup_id': setupId,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (observerName != null) 'observer_name': observerName,
    });
  }

  StudyCompanion copyWith(
      {Value<int>? id,
      Value<int>? setupId,
      Value<DateTime>? date,
      Value<DateTime>? time,
      Value<String>? observerName}) {
    return StudyCompanion(
      id: id ?? this.id,
      setupId: setupId ?? this.setupId,
      date: date ?? this.date,
      time: time ?? this.time,
      observerName: observerName ?? this.observerName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (setupId.present) {
      map['setup_id'] = Variable<int>(setupId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (observerName.present) {
      map['observer_name'] = Variable<String>(observerName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyCompanion(')
          ..write('id: $id, ')
          ..write('setupId: $setupId, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('observerName: $observerName')
          ..write(')'))
        .toString();
  }
}

class $TimeStudyTable extends TimeStudy
    with TableInfo<$TimeStudyTable, TimeStudyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeStudyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _studyIdMeta =
      const VerificationMeta('studyId');
  @override
  late final GeneratedColumn<int> studyId = GeneratedColumn<int>(
      'study_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES study (id)'));
  static const VerificationMeta _taskNameMeta =
      const VerificationMeta('taskName');
  @override
  late final GeneratedColumn<String> taskName = GeneratedColumn<String>(
      'task_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iterationTimeMeta =
      const VerificationMeta('iterationTime');
  @override
  late final GeneratedColumn<String> iterationTime = GeneratedColumn<String>(
      'iteration_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, studyId, taskName, iterationTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_study';
  @override
  VerificationContext validateIntegrity(Insertable<TimeStudyData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('study_id')) {
      context.handle(_studyIdMeta,
          studyId.isAcceptableOrUnknown(data['study_id']!, _studyIdMeta));
    } else if (isInserting) {
      context.missing(_studyIdMeta);
    }
    if (data.containsKey('task_name')) {
      context.handle(_taskNameMeta,
          taskName.isAcceptableOrUnknown(data['task_name']!, _taskNameMeta));
    } else if (isInserting) {
      context.missing(_taskNameMeta);
    }
    if (data.containsKey('iteration_time')) {
      context.handle(
          _iterationTimeMeta,
          iterationTime.isAcceptableOrUnknown(
              data['iteration_time']!, _iterationTimeMeta));
    } else if (isInserting) {
      context.missing(_iterationTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeStudyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeStudyData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      studyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}study_id'])!,
      taskName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_name'])!,
      iterationTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iteration_time'])!,
    );
  }

  @override
  $TimeStudyTable createAlias(String alias) {
    return $TimeStudyTable(attachedDatabase, alias);
  }
}

class TimeStudyData extends DataClass implements Insertable<TimeStudyData> {
  final int id;
  final int studyId;
  final String taskName;
  final String iterationTime;
  const TimeStudyData(
      {required this.id,
      required this.studyId,
      required this.taskName,
      required this.iterationTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['study_id'] = Variable<int>(studyId);
    map['task_name'] = Variable<String>(taskName);
    map['iteration_time'] = Variable<String>(iterationTime);
    return map;
  }

  TimeStudyCompanion toCompanion(bool nullToAbsent) {
    return TimeStudyCompanion(
      id: Value(id),
      studyId: Value(studyId),
      taskName: Value(taskName),
      iterationTime: Value(iterationTime),
    );
  }

  factory TimeStudyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeStudyData(
      id: serializer.fromJson<int>(json['id']),
      studyId: serializer.fromJson<int>(json['studyId']),
      taskName: serializer.fromJson<String>(json['taskName']),
      iterationTime: serializer.fromJson<String>(json['iterationTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studyId': serializer.toJson<int>(studyId),
      'taskName': serializer.toJson<String>(taskName),
      'iterationTime': serializer.toJson<String>(iterationTime),
    };
  }

  TimeStudyData copyWith(
          {int? id, int? studyId, String? taskName, String? iterationTime}) =>
      TimeStudyData(
        id: id ?? this.id,
        studyId: studyId ?? this.studyId,
        taskName: taskName ?? this.taskName,
        iterationTime: iterationTime ?? this.iterationTime,
      );
  TimeStudyData copyWithCompanion(TimeStudyCompanion data) {
    return TimeStudyData(
      id: data.id.present ? data.id.value : this.id,
      studyId: data.studyId.present ? data.studyId.value : this.studyId,
      taskName: data.taskName.present ? data.taskName.value : this.taskName,
      iterationTime: data.iterationTime.present
          ? data.iterationTime.value
          : this.iterationTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeStudyData(')
          ..write('id: $id, ')
          ..write('studyId: $studyId, ')
          ..write('taskName: $taskName, ')
          ..write('iterationTime: $iterationTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studyId, taskName, iterationTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeStudyData &&
          other.id == this.id &&
          other.studyId == this.studyId &&
          other.taskName == this.taskName &&
          other.iterationTime == this.iterationTime);
}

class TimeStudyCompanion extends UpdateCompanion<TimeStudyData> {
  final Value<int> id;
  final Value<int> studyId;
  final Value<String> taskName;
  final Value<String> iterationTime;
  const TimeStudyCompanion({
    this.id = const Value.absent(),
    this.studyId = const Value.absent(),
    this.taskName = const Value.absent(),
    this.iterationTime = const Value.absent(),
  });
  TimeStudyCompanion.insert({
    this.id = const Value.absent(),
    required int studyId,
    required String taskName,
    required String iterationTime,
  })  : studyId = Value(studyId),
        taskName = Value(taskName),
        iterationTime = Value(iterationTime);
  static Insertable<TimeStudyData> custom({
    Expression<int>? id,
    Expression<int>? studyId,
    Expression<String>? taskName,
    Expression<String>? iterationTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studyId != null) 'study_id': studyId,
      if (taskName != null) 'task_name': taskName,
      if (iterationTime != null) 'iteration_time': iterationTime,
    });
  }

  TimeStudyCompanion copyWith(
      {Value<int>? id,
      Value<int>? studyId,
      Value<String>? taskName,
      Value<String>? iterationTime}) {
    return TimeStudyCompanion(
      id: id ?? this.id,
      studyId: studyId ?? this.studyId,
      taskName: taskName ?? this.taskName,
      iterationTime: iterationTime ?? this.iterationTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studyId.present) {
      map['study_id'] = Variable<int>(studyId.value);
    }
    if (taskName.present) {
      map['task_name'] = Variable<String>(taskName.value);
    }
    if (iterationTime.present) {
      map['iteration_time'] = Variable<String>(iterationTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeStudyCompanion(')
          ..write('id: $id, ')
          ..write('studyId: $studyId, ')
          ..write('taskName: $taskName, ')
          ..write('iterationTime: $iterationTime')
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
  late final $ProcessShiftTable processShift = $ProcessShiftTable(this);
  late final $VSShiftsTable vSShifts = $VSShiftsTable(this);
  late final $OrganizationsTable organizations = $OrganizationsTable(this);
  late final $PartsTable parts = $PartsTable(this);
  late final $PlantsTable plants = $PlantsTable(this);
  late final $SetupsTable setups = $SetupsTable(this);
  late final $SetupElementsTable setupElements = $SetupElementsTable(this);
  late final $StudyTable study = $StudyTable(this);
  late final $TimeStudyTable timeStudy = $TimeStudyTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        valueStreams,
        processes,
        processParts,
        processShift,
        vSShifts,
        organizations,
        parts,
        plants,
        setups,
        setupElements,
        study,
        timeStudy
      ];
}

typedef $$ValueStreamsTableCreateCompanionBuilder = ValueStreamsCompanion
    Function({
  Value<int> id,
  required int plantId,
  required String name,
  Value<int?> mDemand,
  Value<UnitOfMeasure?> uom,
  Value<int?> mngrEmpId,
  Value<String?> taktTime,
});
typedef $$ValueStreamsTableUpdateCompanionBuilder = ValueStreamsCompanion
    Function({
  Value<int> id,
  Value<int> plantId,
  Value<String> name,
  Value<int?> mDemand,
  Value<UnitOfMeasure?> uom,
  Value<int?> mngrEmpId,
  Value<String?> taktTime,
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

  static MultiTypedResultKey<$VSShiftsTable, List<VSShift>> _vSShiftsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.vSShifts,
          aliasName:
              $_aliasNameGenerator(db.valueStreams.id, db.vSShifts.vsId));

  $$VSShiftsTableProcessedTableManager get vSShiftsRefs {
    final manager = $$VSShiftsTableTableManager($_db, $_db.vSShifts)
        .filter((f) => f.vsId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vSShiftsRefsTable($_db));
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

  ColumnFilters<int> get mDemand => $composableBuilder(
      column: $table.mDemand, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<UnitOfMeasure?, UnitOfMeasure, int> get uom =>
      $composableBuilder(
          column: $table.uom,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get mngrEmpId => $composableBuilder(
      column: $table.mngrEmpId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taktTime => $composableBuilder(
      column: $table.taktTime, builder: (column) => ColumnFilters(column));

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

  Expression<bool> vSShiftsRefs(
      Expression<bool> Function($$VSShiftsTableFilterComposer f) f) {
    final $$VSShiftsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vSShifts,
        getReferencedColumn: (t) => t.vsId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VSShiftsTableFilterComposer(
              $db: $db,
              $table: $db.vSShifts,
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

  ColumnOrderings<int> get mDemand => $composableBuilder(
      column: $table.mDemand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get uom => $composableBuilder(
      column: $table.uom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mngrEmpId => $composableBuilder(
      column: $table.mngrEmpId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taktTime => $composableBuilder(
      column: $table.taktTime, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<int> get mDemand =>
      $composableBuilder(column: $table.mDemand, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UnitOfMeasure?, int> get uom =>
      $composableBuilder(column: $table.uom, builder: (column) => column);

  GeneratedColumn<int> get mngrEmpId =>
      $composableBuilder(column: $table.mngrEmpId, builder: (column) => column);

  GeneratedColumn<String> get taktTime =>
      $composableBuilder(column: $table.taktTime, builder: (column) => column);

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

  Expression<T> vSShiftsRefs<T extends Object>(
      Expression<T> Function($$VSShiftsTableAnnotationComposer a) f) {
    final $$VSShiftsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vSShifts,
        getReferencedColumn: (t) => t.vsId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VSShiftsTableAnnotationComposer(
              $db: $db,
              $table: $db.vSShifts,
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
    PrefetchHooks Function(
        {bool processesRefs, bool vSShiftsRefs, bool partsRefs})> {
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
            Value<int?> mDemand = const Value.absent(),
            Value<UnitOfMeasure?> uom = const Value.absent(),
            Value<int?> mngrEmpId = const Value.absent(),
            Value<String?> taktTime = const Value.absent(),
          }) =>
              ValueStreamsCompanion(
            id: id,
            plantId: plantId,
            name: name,
            mDemand: mDemand,
            uom: uom,
            mngrEmpId: mngrEmpId,
            taktTime: taktTime,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int plantId,
            required String name,
            Value<int?> mDemand = const Value.absent(),
            Value<UnitOfMeasure?> uom = const Value.absent(),
            Value<int?> mngrEmpId = const Value.absent(),
            Value<String?> taktTime = const Value.absent(),
          }) =>
              ValueStreamsCompanion.insert(
            id: id,
            plantId: plantId,
            name: name,
            mDemand: mDemand,
            uom: uom,
            mngrEmpId: mngrEmpId,
            taktTime: taktTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ValueStreamsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {processesRefs = false,
              vSShiftsRefs = false,
              partsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (processesRefs) db.processes,
                if (vSShiftsRefs) db.vSShifts,
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
                  if (vSShiftsRefs)
                    await $_getPrefetchedData<ValueStream, $ValueStreamsTable,
                            VSShift>(
                        currentTable: table,
                        referencedTable: $$ValueStreamsTableReferences
                            ._vSShiftsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ValueStreamsTableReferences(db, table, p0)
                                .vSShiftsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.vsId == item.id),
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
    PrefetchHooks Function(
        {bool processesRefs, bool vSShiftsRefs, bool partsRefs})>;
typedef $$ProcessesTableCreateCompanionBuilder = ProcessesCompanion Function({
  Value<int> id,
  required int valueStreamId,
  required String processName,
  Value<String?> processDescription,
  Value<int?> dailyDemand,
  Value<int?> staff,
  Value<int?> wip,
  Value<double?> uptime,
  Value<String?> coTime,
  Value<String?> taktTime,
  Value<int> orderIndex,
  Value<double?> positionX,
  Value<double?> positionY,
  Value<String?> color,
});
typedef $$ProcessesTableUpdateCompanionBuilder = ProcessesCompanion Function({
  Value<int> id,
  Value<int> valueStreamId,
  Value<String> processName,
  Value<String?> processDescription,
  Value<int?> dailyDemand,
  Value<int?> staff,
  Value<int?> wip,
  Value<double?> uptime,
  Value<String?> coTime,
  Value<String?> taktTime,
  Value<int> orderIndex,
  Value<double?> positionX,
  Value<double?> positionY,
  Value<String?> color,
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

  static MultiTypedResultKey<$ProcessShiftTable, List<ProcessShiftData>>
      _processShiftRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.processShift,
          aliasName:
              $_aliasNameGenerator(db.processes.id, db.processShift.processId));

  $$ProcessShiftTableProcessedTableManager get processShiftRefs {
    final manager = $$ProcessShiftTableTableManager($_db, $_db.processShift)
        .filter((f) => f.processId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_processShiftRefsTable($_db));
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

  ColumnFilters<int> get dailyDemand => $composableBuilder(
      column: $table.dailyDemand, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get staff => $composableBuilder(
      column: $table.staff, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wip => $composableBuilder(
      column: $table.wip, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get uptime => $composableBuilder(
      column: $table.uptime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coTime => $composableBuilder(
      column: $table.coTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taktTime => $composableBuilder(
      column: $table.taktTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get positionX => $composableBuilder(
      column: $table.positionX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get positionY => $composableBuilder(
      column: $table.positionY, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

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

  Expression<bool> processShiftRefs(
      Expression<bool> Function($$ProcessShiftTableFilterComposer f) f) {
    final $$ProcessShiftTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.processShift,
        getReferencedColumn: (t) => t.processId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessShiftTableFilterComposer(
              $db: $db,
              $table: $db.processShift,
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

  ColumnOrderings<int> get dailyDemand => $composableBuilder(
      column: $table.dailyDemand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get staff => $composableBuilder(
      column: $table.staff, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wip => $composableBuilder(
      column: $table.wip, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get uptime => $composableBuilder(
      column: $table.uptime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coTime => $composableBuilder(
      column: $table.coTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taktTime => $composableBuilder(
      column: $table.taktTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get positionX => $composableBuilder(
      column: $table.positionX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get positionY => $composableBuilder(
      column: $table.positionY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<int> get dailyDemand => $composableBuilder(
      column: $table.dailyDemand, builder: (column) => column);

  GeneratedColumn<int> get staff =>
      $composableBuilder(column: $table.staff, builder: (column) => column);

  GeneratedColumn<int> get wip =>
      $composableBuilder(column: $table.wip, builder: (column) => column);

  GeneratedColumn<double> get uptime =>
      $composableBuilder(column: $table.uptime, builder: (column) => column);

  GeneratedColumn<String> get coTime =>
      $composableBuilder(column: $table.coTime, builder: (column) => column);

  GeneratedColumn<String> get taktTime =>
      $composableBuilder(column: $table.taktTime, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<double> get positionX =>
      $composableBuilder(column: $table.positionX, builder: (column) => column);

  GeneratedColumn<double> get positionY =>
      $composableBuilder(column: $table.positionY, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

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

  Expression<T> processShiftRefs<T extends Object>(
      Expression<T> Function($$ProcessShiftTableAnnotationComposer a) f) {
    final $$ProcessShiftTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.processShift,
        getReferencedColumn: (t) => t.processId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProcessShiftTableAnnotationComposer(
              $db: $db,
              $table: $db.processShift,
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
    PrefetchHooks Function(
        {bool valueStreamId, bool processPartsRefs, bool processShiftRefs})> {
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
            Value<int?> dailyDemand = const Value.absent(),
            Value<int?> staff = const Value.absent(),
            Value<int?> wip = const Value.absent(),
            Value<double?> uptime = const Value.absent(),
            Value<String?> coTime = const Value.absent(),
            Value<String?> taktTime = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<double?> positionX = const Value.absent(),
            Value<double?> positionY = const Value.absent(),
            Value<String?> color = const Value.absent(),
          }) =>
              ProcessesCompanion(
            id: id,
            valueStreamId: valueStreamId,
            processName: processName,
            processDescription: processDescription,
            dailyDemand: dailyDemand,
            staff: staff,
            wip: wip,
            uptime: uptime,
            coTime: coTime,
            taktTime: taktTime,
            orderIndex: orderIndex,
            positionX: positionX,
            positionY: positionY,
            color: color,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int valueStreamId,
            required String processName,
            Value<String?> processDescription = const Value.absent(),
            Value<int?> dailyDemand = const Value.absent(),
            Value<int?> staff = const Value.absent(),
            Value<int?> wip = const Value.absent(),
            Value<double?> uptime = const Value.absent(),
            Value<String?> coTime = const Value.absent(),
            Value<String?> taktTime = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<double?> positionX = const Value.absent(),
            Value<double?> positionY = const Value.absent(),
            Value<String?> color = const Value.absent(),
          }) =>
              ProcessesCompanion.insert(
            id: id,
            valueStreamId: valueStreamId,
            processName: processName,
            processDescription: processDescription,
            dailyDemand: dailyDemand,
            staff: staff,
            wip: wip,
            uptime: uptime,
            coTime: coTime,
            taktTime: taktTime,
            orderIndex: orderIndex,
            positionX: positionX,
            positionY: positionY,
            color: color,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProcessesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {valueStreamId = false,
              processPartsRefs = false,
              processShiftRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (processPartsRefs) db.processParts,
                if (processShiftRefs) db.processShift
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
                        typedResults: items),
                  if (processShiftRefs)
                    await $_getPrefetchedData<ProcessesData, $ProcessesTable,
                            ProcessShiftData>(
                        currentTable: table,
                        referencedTable: $$ProcessesTableReferences
                            ._processShiftRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProcessesTableReferences(db, table, p0)
                                .processShiftRefs,
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
    PrefetchHooks Function(
        {bool valueStreamId, bool processPartsRefs, bool processShiftRefs})>;
typedef $$ProcessPartsTableCreateCompanionBuilder = ProcessPartsCompanion
    Function({
  Value<int> id,
  required String partNumber,
  required int processId,
  Value<int?> dailyDemand,
  Value<String?> processTime,
  Value<String?> userOverrideTime,
  Value<double?> fpy,
});
typedef $$ProcessPartsTableUpdateCompanionBuilder = ProcessPartsCompanion
    Function({
  Value<int> id,
  Value<String> partNumber,
  Value<int> processId,
  Value<int?> dailyDemand,
  Value<String?> processTime,
  Value<String?> userOverrideTime,
  Value<double?> fpy,
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

  static MultiTypedResultKey<$SetupsTable, List<Setup>> _setupsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.setups,
          aliasName: $_aliasNameGenerator(
              db.processParts.id, db.setups.processPartId));

  $$SetupsTableProcessedTableManager get setupsRefs {
    final manager = $$SetupsTableTableManager($_db, $_db.setups)
        .filter((f) => f.processPartId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setupsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
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

  ColumnFilters<int> get dailyDemand => $composableBuilder(
      column: $table.dailyDemand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processTime => $composableBuilder(
      column: $table.processTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userOverrideTime => $composableBuilder(
      column: $table.userOverrideTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fpy => $composableBuilder(
      column: $table.fpy, builder: (column) => ColumnFilters(column));

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

  Expression<bool> setupsRefs(
      Expression<bool> Function($$SetupsTableFilterComposer f) f) {
    final $$SetupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.setups,
        getReferencedColumn: (t) => t.processPartId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetupsTableFilterComposer(
              $db: $db,
              $table: $db.setups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
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

  ColumnOrderings<int> get dailyDemand => $composableBuilder(
      column: $table.dailyDemand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processTime => $composableBuilder(
      column: $table.processTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userOverrideTime => $composableBuilder(
      column: $table.userOverrideTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fpy => $composableBuilder(
      column: $table.fpy, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<int> get dailyDemand => $composableBuilder(
      column: $table.dailyDemand, builder: (column) => column);

  GeneratedColumn<String> get processTime => $composableBuilder(
      column: $table.processTime, builder: (column) => column);

  GeneratedColumn<String> get userOverrideTime => $composableBuilder(
      column: $table.userOverrideTime, builder: (column) => column);

  GeneratedColumn<double> get fpy =>
      $composableBuilder(column: $table.fpy, builder: (column) => column);

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

  Expression<T> setupsRefs<T extends Object>(
      Expression<T> Function($$SetupsTableAnnotationComposer a) f) {
    final $$SetupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.setups,
        getReferencedColumn: (t) => t.processPartId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetupsTableAnnotationComposer(
              $db: $db,
              $table: $db.setups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
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
    PrefetchHooks Function(
        {bool processId, bool setupsRefs, bool setupElementsRefs})> {
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
            Value<int?> dailyDemand = const Value.absent(),
            Value<String?> processTime = const Value.absent(),
            Value<String?> userOverrideTime = const Value.absent(),
            Value<double?> fpy = const Value.absent(),
          }) =>
              ProcessPartsCompanion(
            id: id,
            partNumber: partNumber,
            processId: processId,
            dailyDemand: dailyDemand,
            processTime: processTime,
            userOverrideTime: userOverrideTime,
            fpy: fpy,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String partNumber,
            required int processId,
            Value<int?> dailyDemand = const Value.absent(),
            Value<String?> processTime = const Value.absent(),
            Value<String?> userOverrideTime = const Value.absent(),
            Value<double?> fpy = const Value.absent(),
          }) =>
              ProcessPartsCompanion.insert(
            id: id,
            partNumber: partNumber,
            processId: processId,
            dailyDemand: dailyDemand,
            processTime: processTime,
            userOverrideTime: userOverrideTime,
            fpy: fpy,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProcessPartsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {processId = false,
              setupsRefs = false,
              setupElementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (setupsRefs) db.setups,
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
                  if (setupsRefs)
                    await $_getPrefetchedData<ProcessPart, $ProcessPartsTable,
                            Setup>(
                        currentTable: table,
                        referencedTable:
                            $$ProcessPartsTableReferences._setupsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProcessPartsTableReferences(db, table, p0)
                                .setupsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.processPartId == item.id),
                        typedResults: items),
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
    PrefetchHooks Function(
        {bool processId, bool setupsRefs, bool setupElementsRefs})>;
typedef $$ProcessShiftTableCreateCompanionBuilder = ProcessShiftCompanion
    Function({
  Value<int> id,
  required int processId,
  required String shiftName,
  Value<String?> sun,
  Value<String?> mon,
  Value<String?> tue,
  Value<String?> wed,
  Value<String?> thu,
  Value<String?> fri,
  Value<String?> sat,
});
typedef $$ProcessShiftTableUpdateCompanionBuilder = ProcessShiftCompanion
    Function({
  Value<int> id,
  Value<int> processId,
  Value<String> shiftName,
  Value<String?> sun,
  Value<String?> mon,
  Value<String?> tue,
  Value<String?> wed,
  Value<String?> thu,
  Value<String?> fri,
  Value<String?> sat,
});

final class $$ProcessShiftTableReferences extends BaseReferences<_$AppDatabase,
    $ProcessShiftTable, ProcessShiftData> {
  $$ProcessShiftTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProcessesTable _processIdTable(_$AppDatabase db) =>
      db.processes.createAlias(
          $_aliasNameGenerator(db.processShift.processId, db.processes.id));

  $$ProcessesTableProcessedTableManager get processId {
    final $_column = $_itemColumn<int>('process_id')!;

    final manager = $$ProcessesTableTableManager($_db, $_db.processes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_processIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProcessShiftTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessShiftTable> {
  $$ProcessShiftTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shiftName => $composableBuilder(
      column: $table.shiftName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sun => $composableBuilder(
      column: $table.sun, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mon => $composableBuilder(
      column: $table.mon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tue => $composableBuilder(
      column: $table.tue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wed => $composableBuilder(
      column: $table.wed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thu => $composableBuilder(
      column: $table.thu, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fri => $composableBuilder(
      column: $table.fri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sat => $composableBuilder(
      column: $table.sat, builder: (column) => ColumnFilters(column));

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
}

class $$ProcessShiftTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessShiftTable> {
  $$ProcessShiftTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shiftName => $composableBuilder(
      column: $table.shiftName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sun => $composableBuilder(
      column: $table.sun, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mon => $composableBuilder(
      column: $table.mon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tue => $composableBuilder(
      column: $table.tue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wed => $composableBuilder(
      column: $table.wed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thu => $composableBuilder(
      column: $table.thu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fri => $composableBuilder(
      column: $table.fri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sat => $composableBuilder(
      column: $table.sat, builder: (column) => ColumnOrderings(column));

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

class $$ProcessShiftTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessShiftTable> {
  $$ProcessShiftTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shiftName =>
      $composableBuilder(column: $table.shiftName, builder: (column) => column);

  GeneratedColumn<String> get sun =>
      $composableBuilder(column: $table.sun, builder: (column) => column);

  GeneratedColumn<String> get mon =>
      $composableBuilder(column: $table.mon, builder: (column) => column);

  GeneratedColumn<String> get tue =>
      $composableBuilder(column: $table.tue, builder: (column) => column);

  GeneratedColumn<String> get wed =>
      $composableBuilder(column: $table.wed, builder: (column) => column);

  GeneratedColumn<String> get thu =>
      $composableBuilder(column: $table.thu, builder: (column) => column);

  GeneratedColumn<String> get fri =>
      $composableBuilder(column: $table.fri, builder: (column) => column);

  GeneratedColumn<String> get sat =>
      $composableBuilder(column: $table.sat, builder: (column) => column);

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
}

class $$ProcessShiftTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProcessShiftTable,
    ProcessShiftData,
    $$ProcessShiftTableFilterComposer,
    $$ProcessShiftTableOrderingComposer,
    $$ProcessShiftTableAnnotationComposer,
    $$ProcessShiftTableCreateCompanionBuilder,
    $$ProcessShiftTableUpdateCompanionBuilder,
    (ProcessShiftData, $$ProcessShiftTableReferences),
    ProcessShiftData,
    PrefetchHooks Function({bool processId})> {
  $$ProcessShiftTableTableManager(_$AppDatabase db, $ProcessShiftTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessShiftTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessShiftTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessShiftTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> processId = const Value.absent(),
            Value<String> shiftName = const Value.absent(),
            Value<String?> sun = const Value.absent(),
            Value<String?> mon = const Value.absent(),
            Value<String?> tue = const Value.absent(),
            Value<String?> wed = const Value.absent(),
            Value<String?> thu = const Value.absent(),
            Value<String?> fri = const Value.absent(),
            Value<String?> sat = const Value.absent(),
          }) =>
              ProcessShiftCompanion(
            id: id,
            processId: processId,
            shiftName: shiftName,
            sun: sun,
            mon: mon,
            tue: tue,
            wed: wed,
            thu: thu,
            fri: fri,
            sat: sat,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int processId,
            required String shiftName,
            Value<String?> sun = const Value.absent(),
            Value<String?> mon = const Value.absent(),
            Value<String?> tue = const Value.absent(),
            Value<String?> wed = const Value.absent(),
            Value<String?> thu = const Value.absent(),
            Value<String?> fri = const Value.absent(),
            Value<String?> sat = const Value.absent(),
          }) =>
              ProcessShiftCompanion.insert(
            id: id,
            processId: processId,
            shiftName: shiftName,
            sun: sun,
            mon: mon,
            tue: tue,
            wed: wed,
            thu: thu,
            fri: fri,
            sat: sat,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProcessShiftTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({processId = false}) {
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
                if (processId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.processId,
                    referencedTable:
                        $$ProcessShiftTableReferences._processIdTable(db),
                    referencedColumn:
                        $$ProcessShiftTableReferences._processIdTable(db).id,
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

typedef $$ProcessShiftTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProcessShiftTable,
    ProcessShiftData,
    $$ProcessShiftTableFilterComposer,
    $$ProcessShiftTableOrderingComposer,
    $$ProcessShiftTableAnnotationComposer,
    $$ProcessShiftTableCreateCompanionBuilder,
    $$ProcessShiftTableUpdateCompanionBuilder,
    (ProcessShiftData, $$ProcessShiftTableReferences),
    ProcessShiftData,
    PrefetchHooks Function({bool processId})>;
typedef $$VSShiftsTableCreateCompanionBuilder = VSShiftsCompanion Function({
  Value<int> id,
  required int vsId,
  required String shiftName,
  Value<String?> sun,
  Value<String?> mon,
  Value<String?> tue,
  Value<String?> wed,
  Value<String?> thu,
  Value<String?> fri,
  Value<String?> sat,
});
typedef $$VSShiftsTableUpdateCompanionBuilder = VSShiftsCompanion Function({
  Value<int> id,
  Value<int> vsId,
  Value<String> shiftName,
  Value<String?> sun,
  Value<String?> mon,
  Value<String?> tue,
  Value<String?> wed,
  Value<String?> thu,
  Value<String?> fri,
  Value<String?> sat,
});

final class $$VSShiftsTableReferences
    extends BaseReferences<_$AppDatabase, $VSShiftsTable, VSShift> {
  $$VSShiftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ValueStreamsTable _vsIdTable(_$AppDatabase db) => db.valueStreams
      .createAlias($_aliasNameGenerator(db.vSShifts.vsId, db.valueStreams.id));

  $$ValueStreamsTableProcessedTableManager get vsId {
    final $_column = $_itemColumn<int>('vs_id')!;

    final manager = $$ValueStreamsTableTableManager($_db, $_db.valueStreams)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vsIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VSShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $VSShiftsTable> {
  $$VSShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shiftName => $composableBuilder(
      column: $table.shiftName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sun => $composableBuilder(
      column: $table.sun, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mon => $composableBuilder(
      column: $table.mon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tue => $composableBuilder(
      column: $table.tue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wed => $composableBuilder(
      column: $table.wed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thu => $composableBuilder(
      column: $table.thu, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fri => $composableBuilder(
      column: $table.fri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sat => $composableBuilder(
      column: $table.sat, builder: (column) => ColumnFilters(column));

  $$ValueStreamsTableFilterComposer get vsId {
    final $$ValueStreamsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vsId,
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

class $$VSShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $VSShiftsTable> {
  $$VSShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shiftName => $composableBuilder(
      column: $table.shiftName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sun => $composableBuilder(
      column: $table.sun, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mon => $composableBuilder(
      column: $table.mon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tue => $composableBuilder(
      column: $table.tue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wed => $composableBuilder(
      column: $table.wed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thu => $composableBuilder(
      column: $table.thu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fri => $composableBuilder(
      column: $table.fri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sat => $composableBuilder(
      column: $table.sat, builder: (column) => ColumnOrderings(column));

  $$ValueStreamsTableOrderingComposer get vsId {
    final $$ValueStreamsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vsId,
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

class $$VSShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VSShiftsTable> {
  $$VSShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shiftName =>
      $composableBuilder(column: $table.shiftName, builder: (column) => column);

  GeneratedColumn<String> get sun =>
      $composableBuilder(column: $table.sun, builder: (column) => column);

  GeneratedColumn<String> get mon =>
      $composableBuilder(column: $table.mon, builder: (column) => column);

  GeneratedColumn<String> get tue =>
      $composableBuilder(column: $table.tue, builder: (column) => column);

  GeneratedColumn<String> get wed =>
      $composableBuilder(column: $table.wed, builder: (column) => column);

  GeneratedColumn<String> get thu =>
      $composableBuilder(column: $table.thu, builder: (column) => column);

  GeneratedColumn<String> get fri =>
      $composableBuilder(column: $table.fri, builder: (column) => column);

  GeneratedColumn<String> get sat =>
      $composableBuilder(column: $table.sat, builder: (column) => column);

  $$ValueStreamsTableAnnotationComposer get vsId {
    final $$ValueStreamsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vsId,
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

class $$VSShiftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VSShiftsTable,
    VSShift,
    $$VSShiftsTableFilterComposer,
    $$VSShiftsTableOrderingComposer,
    $$VSShiftsTableAnnotationComposer,
    $$VSShiftsTableCreateCompanionBuilder,
    $$VSShiftsTableUpdateCompanionBuilder,
    (VSShift, $$VSShiftsTableReferences),
    VSShift,
    PrefetchHooks Function({bool vsId})> {
  $$VSShiftsTableTableManager(_$AppDatabase db, $VSShiftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VSShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VSShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VSShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> vsId = const Value.absent(),
            Value<String> shiftName = const Value.absent(),
            Value<String?> sun = const Value.absent(),
            Value<String?> mon = const Value.absent(),
            Value<String?> tue = const Value.absent(),
            Value<String?> wed = const Value.absent(),
            Value<String?> thu = const Value.absent(),
            Value<String?> fri = const Value.absent(),
            Value<String?> sat = const Value.absent(),
          }) =>
              VSShiftsCompanion(
            id: id,
            vsId: vsId,
            shiftName: shiftName,
            sun: sun,
            mon: mon,
            tue: tue,
            wed: wed,
            thu: thu,
            fri: fri,
            sat: sat,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int vsId,
            required String shiftName,
            Value<String?> sun = const Value.absent(),
            Value<String?> mon = const Value.absent(),
            Value<String?> tue = const Value.absent(),
            Value<String?> wed = const Value.absent(),
            Value<String?> thu = const Value.absent(),
            Value<String?> fri = const Value.absent(),
            Value<String?> sat = const Value.absent(),
          }) =>
              VSShiftsCompanion.insert(
            id: id,
            vsId: vsId,
            shiftName: shiftName,
            sun: sun,
            mon: mon,
            tue: tue,
            wed: wed,
            thu: thu,
            fri: fri,
            sat: sat,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VSShiftsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({vsId = false}) {
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
                if (vsId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vsId,
                    referencedTable: $$VSShiftsTableReferences._vsIdTable(db),
                    referencedColumn:
                        $$VSShiftsTableReferences._vsIdTable(db).id,
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

typedef $$VSShiftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VSShiftsTable,
    VSShift,
    $$VSShiftsTableFilterComposer,
    $$VSShiftsTableOrderingComposer,
    $$VSShiftsTableAnnotationComposer,
    $$VSShiftsTableCreateCompanionBuilder,
    $$VSShiftsTableUpdateCompanionBuilder,
    (VSShift, $$VSShiftsTableReferences),
    VSShift,
    PrefetchHooks Function({bool vsId})>;
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

final class $$OrganizationsTableReferences
    extends BaseReferences<_$AppDatabase, $OrganizationsTable, Organization> {
  $$OrganizationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PartsTable, List<Part>> _partsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.parts,
          aliasName: $_aliasNameGenerator(
              db.organizations.id, db.parts.organizationId));

  $$PartsTableProcessedTableManager get partsRefs {
    final manager = $$PartsTableTableManager($_db, $_db.parts)
        .filter((f) => f.organizationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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

  Expression<bool> partsRefs(
      Expression<bool> Function($$PartsTableFilterComposer f) f) {
    final $$PartsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.organizationId,
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

  Expression<T> partsRefs<T extends Object>(
      Expression<T> Function($$PartsTableAnnotationComposer a) f) {
    final $$PartsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.organizationId,
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

class $$OrganizationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrganizationsTable,
    Organization,
    $$OrganizationsTableFilterComposer,
    $$OrganizationsTableOrderingComposer,
    $$OrganizationsTableAnnotationComposer,
    $$OrganizationsTableCreateCompanionBuilder,
    $$OrganizationsTableUpdateCompanionBuilder,
    (Organization, $$OrganizationsTableReferences),
    Organization,
    PrefetchHooks Function({bool partsRefs})> {
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
              .map((e) => (
                    e.readTable(table),
                    $$OrganizationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({partsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (partsRefs) db.parts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (partsRefs)
                    await $_getPrefetchedData<Organization, $OrganizationsTable,
                            Part>(
                        currentTable: table,
                        referencedTable:
                            $$OrganizationsTableReferences._partsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrganizationsTableReferences(db, table, p0)
                                .partsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.organizationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
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
    (Organization, $$OrganizationsTableReferences),
    Organization,
    PrefetchHooks Function({bool partsRefs})>;
typedef $$PartsTableCreateCompanionBuilder = PartsCompanion Function({
  Value<int> id,
  required int valueStreamId,
  required int organizationId,
  required String partNumber,
  Value<String?> partDescription,
  Value<int?> monthlyDemand,
});
typedef $$PartsTableUpdateCompanionBuilder = PartsCompanion Function({
  Value<int> id,
  Value<int> valueStreamId,
  Value<int> organizationId,
  Value<String> partNumber,
  Value<String?> partDescription,
  Value<int?> monthlyDemand,
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

  static $OrganizationsTable _organizationIdTable(_$AppDatabase db) =>
      db.organizations.createAlias(
          $_aliasNameGenerator(db.parts.organizationId, db.organizations.id));

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<int>('organization_id')!;

    final manager = $$OrganizationsTableTableManager($_db, $_db.organizations)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
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

  ColumnFilters<int> get monthlyDemand => $composableBuilder(
      column: $table.monthlyDemand, builder: (column) => ColumnFilters(column));

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

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.organizationId,
        referencedTable: $db.organizations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrganizationsTableFilterComposer(
              $db: $db,
              $table: $db.organizations,
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

  ColumnOrderings<int> get monthlyDemand => $composableBuilder(
      column: $table.monthlyDemand,
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

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.organizationId,
        referencedTable: $db.organizations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrganizationsTableOrderingComposer(
              $db: $db,
              $table: $db.organizations,
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

  GeneratedColumn<int> get monthlyDemand => $composableBuilder(
      column: $table.monthlyDemand, builder: (column) => column);

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

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.organizationId,
        referencedTable: $db.organizations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrganizationsTableAnnotationComposer(
              $db: $db,
              $table: $db.organizations,
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
    PrefetchHooks Function({bool valueStreamId, bool organizationId})> {
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
            Value<int> organizationId = const Value.absent(),
            Value<String> partNumber = const Value.absent(),
            Value<String?> partDescription = const Value.absent(),
            Value<int?> monthlyDemand = const Value.absent(),
          }) =>
              PartsCompanion(
            id: id,
            valueStreamId: valueStreamId,
            organizationId: organizationId,
            partNumber: partNumber,
            partDescription: partDescription,
            monthlyDemand: monthlyDemand,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int valueStreamId,
            required int organizationId,
            required String partNumber,
            Value<String?> partDescription = const Value.absent(),
            Value<int?> monthlyDemand = const Value.absent(),
          }) =>
              PartsCompanion.insert(
            id: id,
            valueStreamId: valueStreamId,
            organizationId: organizationId,
            partNumber: partNumber,
            partDescription: partDescription,
            monthlyDemand: monthlyDemand,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PartsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {valueStreamId = false, organizationId = false}) {
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
                if (organizationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.organizationId,
                    referencedTable:
                        $$PartsTableReferences._organizationIdTable(db),
                    referencedColumn:
                        $$PartsTableReferences._organizationIdTable(db).id,
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
    PrefetchHooks Function({bool valueStreamId, bool organizationId})>;
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
typedef $$SetupsTableCreateCompanionBuilder = SetupsCompanion Function({
  Value<int> id,
  required int processPartId,
  required String setupName,
});
typedef $$SetupsTableUpdateCompanionBuilder = SetupsCompanion Function({
  Value<int> id,
  Value<int> processPartId,
  Value<String> setupName,
});

final class $$SetupsTableReferences
    extends BaseReferences<_$AppDatabase, $SetupsTable, Setup> {
  $$SetupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProcessPartsTable _processPartIdTable(_$AppDatabase db) =>
      db.processParts.createAlias(
          $_aliasNameGenerator(db.setups.processPartId, db.processParts.id));

  $$ProcessPartsTableProcessedTableManager get processPartId {
    final $_column = $_itemColumn<int>('process_part_id')!;

    final manager = $$ProcessPartsTableTableManager($_db, $_db.processParts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_processPartIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SetupElementsTable, List<SetupElement>>
      _setupElementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.setupElements,
              aliasName:
                  $_aliasNameGenerator(db.setups.id, db.setupElements.setupId));

  $$SetupElementsTableProcessedTableManager get setupElementsRefs {
    final manager = $$SetupElementsTableTableManager($_db, $_db.setupElements)
        .filter((f) => f.setupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_setupElementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$StudyTable, List<StudyData>> _studyRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.study,
          aliasName: $_aliasNameGenerator(db.setups.id, db.study.setupId));

  $$StudyTableProcessedTableManager get studyRefs {
    final manager = $$StudyTableTableManager($_db, $_db.study)
        .filter((f) => f.setupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SetupsTableFilterComposer
    extends Composer<_$AppDatabase, $SetupsTable> {
  $$SetupsTableFilterComposer({
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

  Expression<bool> setupElementsRefs(
      Expression<bool> Function($$SetupElementsTableFilterComposer f) f) {
    final $$SetupElementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.setupElements,
        getReferencedColumn: (t) => t.setupId,
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

  Expression<bool> studyRefs(
      Expression<bool> Function($$StudyTableFilterComposer f) f) {
    final $$StudyTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.study,
        getReferencedColumn: (t) => t.setupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudyTableFilterComposer(
              $db: $db,
              $table: $db.study,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SetupsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetupsTable> {
  $$SetupsTableOrderingComposer({
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

class $$SetupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetupsTable> {
  $$SetupsTableAnnotationComposer({
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

  Expression<T> setupElementsRefs<T extends Object>(
      Expression<T> Function($$SetupElementsTableAnnotationComposer a) f) {
    final $$SetupElementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.setupElements,
        getReferencedColumn: (t) => t.setupId,
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

  Expression<T> studyRefs<T extends Object>(
      Expression<T> Function($$StudyTableAnnotationComposer a) f) {
    final $$StudyTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.study,
        getReferencedColumn: (t) => t.setupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudyTableAnnotationComposer(
              $db: $db,
              $table: $db.study,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SetupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SetupsTable,
    Setup,
    $$SetupsTableFilterComposer,
    $$SetupsTableOrderingComposer,
    $$SetupsTableAnnotationComposer,
    $$SetupsTableCreateCompanionBuilder,
    $$SetupsTableUpdateCompanionBuilder,
    (Setup, $$SetupsTableReferences),
    Setup,
    PrefetchHooks Function(
        {bool processPartId, bool setupElementsRefs, bool studyRefs})> {
  $$SetupsTableTableManager(_$AppDatabase db, $SetupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> processPartId = const Value.absent(),
            Value<String> setupName = const Value.absent(),
          }) =>
              SetupsCompanion(
            id: id,
            processPartId: processPartId,
            setupName: setupName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int processPartId,
            required String setupName,
          }) =>
              SetupsCompanion.insert(
            id: id,
            processPartId: processPartId,
            setupName: setupName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SetupsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {processPartId = false,
              setupElementsRefs = false,
              studyRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (setupElementsRefs) db.setupElements,
                if (studyRefs) db.study
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
                if (processPartId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.processPartId,
                    referencedTable:
                        $$SetupsTableReferences._processPartIdTable(db),
                    referencedColumn:
                        $$SetupsTableReferences._processPartIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (setupElementsRefs)
                    await $_getPrefetchedData<Setup, $SetupsTable,
                            SetupElement>(
                        currentTable: table,
                        referencedTable:
                            $$SetupsTableReferences._setupElementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SetupsTableReferences(db, table, p0)
                                .setupElementsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.setupId == item.id),
                        typedResults: items),
                  if (studyRefs)
                    await $_getPrefetchedData<Setup, $SetupsTable, StudyData>(
                        currentTable: table,
                        referencedTable:
                            $$SetupsTableReferences._studyRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SetupsTableReferences(db, table, p0).studyRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.setupId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SetupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SetupsTable,
    Setup,
    $$SetupsTableFilterComposer,
    $$SetupsTableOrderingComposer,
    $$SetupsTableAnnotationComposer,
    $$SetupsTableCreateCompanionBuilder,
    $$SetupsTableUpdateCompanionBuilder,
    (Setup, $$SetupsTableReferences),
    Setup,
    PrefetchHooks Function(
        {bool processPartId, bool setupElementsRefs, bool studyRefs})>;
typedef $$SetupElementsTableCreateCompanionBuilder = SetupElementsCompanion
    Function({
  Value<int> id,
  required int processPartId,
  required int setupId,
  required DateTime setupDateTime,
  required String elementName,
  required String time,
  Value<int> orderIndex,
  Value<String?> lrt,
  Value<String?> overrideTime,
  Value<String?> comments,
});
typedef $$SetupElementsTableUpdateCompanionBuilder = SetupElementsCompanion
    Function({
  Value<int> id,
  Value<int> processPartId,
  Value<int> setupId,
  Value<DateTime> setupDateTime,
  Value<String> elementName,
  Value<String> time,
  Value<int> orderIndex,
  Value<String?> lrt,
  Value<String?> overrideTime,
  Value<String?> comments,
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

  static $SetupsTable _setupIdTable(_$AppDatabase db) => db.setups.createAlias(
      $_aliasNameGenerator(db.setupElements.setupId, db.setups.id));

  $$SetupsTableProcessedTableManager get setupId {
    final $_column = $_itemColumn<int>('setup_id')!;

    final manager = $$SetupsTableTableManager($_db, $_db.setups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_setupIdTable($_db));
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

  ColumnFilters<DateTime> get setupDateTime => $composableBuilder(
      column: $table.setupDateTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get elementName => $composableBuilder(
      column: $table.elementName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lrt => $composableBuilder(
      column: $table.lrt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overrideTime => $composableBuilder(
      column: $table.overrideTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comments => $composableBuilder(
      column: $table.comments, builder: (column) => ColumnFilters(column));

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

  $$SetupsTableFilterComposer get setupId {
    final $$SetupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setupId,
        referencedTable: $db.setups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetupsTableFilterComposer(
              $db: $db,
              $table: $db.setups,
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

  ColumnOrderings<DateTime> get setupDateTime => $composableBuilder(
      column: $table.setupDateTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get elementName => $composableBuilder(
      column: $table.elementName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lrt => $composableBuilder(
      column: $table.lrt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overrideTime => $composableBuilder(
      column: $table.overrideTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comments => $composableBuilder(
      column: $table.comments, builder: (column) => ColumnOrderings(column));

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

  $$SetupsTableOrderingComposer get setupId {
    final $$SetupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setupId,
        referencedTable: $db.setups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetupsTableOrderingComposer(
              $db: $db,
              $table: $db.setups,
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

  GeneratedColumn<DateTime> get setupDateTime => $composableBuilder(
      column: $table.setupDateTime, builder: (column) => column);

  GeneratedColumn<String> get elementName => $composableBuilder(
      column: $table.elementName, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<String> get lrt =>
      $composableBuilder(column: $table.lrt, builder: (column) => column);

  GeneratedColumn<String> get overrideTime => $composableBuilder(
      column: $table.overrideTime, builder: (column) => column);

  GeneratedColumn<String> get comments =>
      $composableBuilder(column: $table.comments, builder: (column) => column);

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

  $$SetupsTableAnnotationComposer get setupId {
    final $$SetupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setupId,
        referencedTable: $db.setups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetupsTableAnnotationComposer(
              $db: $db,
              $table: $db.setups,
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
    PrefetchHooks Function({bool processPartId, bool setupId})> {
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
            Value<int> setupId = const Value.absent(),
            Value<DateTime> setupDateTime = const Value.absent(),
            Value<String> elementName = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<String?> lrt = const Value.absent(),
            Value<String?> overrideTime = const Value.absent(),
            Value<String?> comments = const Value.absent(),
          }) =>
              SetupElementsCompanion(
            id: id,
            processPartId: processPartId,
            setupId: setupId,
            setupDateTime: setupDateTime,
            elementName: elementName,
            time: time,
            orderIndex: orderIndex,
            lrt: lrt,
            overrideTime: overrideTime,
            comments: comments,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int processPartId,
            required int setupId,
            required DateTime setupDateTime,
            required String elementName,
            required String time,
            Value<int> orderIndex = const Value.absent(),
            Value<String?> lrt = const Value.absent(),
            Value<String?> overrideTime = const Value.absent(),
            Value<String?> comments = const Value.absent(),
          }) =>
              SetupElementsCompanion.insert(
            id: id,
            processPartId: processPartId,
            setupId: setupId,
            setupDateTime: setupDateTime,
            elementName: elementName,
            time: time,
            orderIndex: orderIndex,
            lrt: lrt,
            overrideTime: overrideTime,
            comments: comments,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SetupElementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({processPartId = false, setupId = false}) {
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
                if (setupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.setupId,
                    referencedTable:
                        $$SetupElementsTableReferences._setupIdTable(db),
                    referencedColumn:
                        $$SetupElementsTableReferences._setupIdTable(db).id,
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
    PrefetchHooks Function({bool processPartId, bool setupId})>;
typedef $$StudyTableCreateCompanionBuilder = StudyCompanion Function({
  Value<int> id,
  required int setupId,
  required DateTime date,
  required DateTime time,
  required String observerName,
});
typedef $$StudyTableUpdateCompanionBuilder = StudyCompanion Function({
  Value<int> id,
  Value<int> setupId,
  Value<DateTime> date,
  Value<DateTime> time,
  Value<String> observerName,
});

final class $$StudyTableReferences
    extends BaseReferences<_$AppDatabase, $StudyTable, StudyData> {
  $$StudyTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SetupsTable _setupIdTable(_$AppDatabase db) => db.setups
      .createAlias($_aliasNameGenerator(db.study.setupId, db.setups.id));

  $$SetupsTableProcessedTableManager get setupId {
    final $_column = $_itemColumn<int>('setup_id')!;

    final manager = $$SetupsTableTableManager($_db, $_db.setups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_setupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TimeStudyTable, List<TimeStudyData>>
      _timeStudyRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.timeStudy,
          aliasName: $_aliasNameGenerator(db.study.id, db.timeStudy.studyId));

  $$TimeStudyTableProcessedTableManager get timeStudyRefs {
    final manager = $$TimeStudyTableTableManager($_db, $_db.timeStudy)
        .filter((f) => f.studyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_timeStudyRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$StudyTableFilterComposer extends Composer<_$AppDatabase, $StudyTable> {
  $$StudyTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observerName => $composableBuilder(
      column: $table.observerName, builder: (column) => ColumnFilters(column));

  $$SetupsTableFilterComposer get setupId {
    final $$SetupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setupId,
        referencedTable: $db.setups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetupsTableFilterComposer(
              $db: $db,
              $table: $db.setups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> timeStudyRefs(
      Expression<bool> Function($$TimeStudyTableFilterComposer f) f) {
    final $$TimeStudyTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.timeStudy,
        getReferencedColumn: (t) => t.studyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimeStudyTableFilterComposer(
              $db: $db,
              $table: $db.timeStudy,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StudyTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyTable> {
  $$StudyTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observerName => $composableBuilder(
      column: $table.observerName,
      builder: (column) => ColumnOrderings(column));

  $$SetupsTableOrderingComposer get setupId {
    final $$SetupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setupId,
        referencedTable: $db.setups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetupsTableOrderingComposer(
              $db: $db,
              $table: $db.setups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudyTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyTable> {
  $$StudyTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get observerName => $composableBuilder(
      column: $table.observerName, builder: (column) => column);

  $$SetupsTableAnnotationComposer get setupId {
    final $$SetupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setupId,
        referencedTable: $db.setups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SetupsTableAnnotationComposer(
              $db: $db,
              $table: $db.setups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> timeStudyRefs<T extends Object>(
      Expression<T> Function($$TimeStudyTableAnnotationComposer a) f) {
    final $$TimeStudyTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.timeStudy,
        getReferencedColumn: (t) => t.studyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimeStudyTableAnnotationComposer(
              $db: $db,
              $table: $db.timeStudy,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StudyTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudyTable,
    StudyData,
    $$StudyTableFilterComposer,
    $$StudyTableOrderingComposer,
    $$StudyTableAnnotationComposer,
    $$StudyTableCreateCompanionBuilder,
    $$StudyTableUpdateCompanionBuilder,
    (StudyData, $$StudyTableReferences),
    StudyData,
    PrefetchHooks Function({bool setupId, bool timeStudyRefs})> {
  $$StudyTableTableManager(_$AppDatabase db, $StudyTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> setupId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<String> observerName = const Value.absent(),
          }) =>
              StudyCompanion(
            id: id,
            setupId: setupId,
            date: date,
            time: time,
            observerName: observerName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int setupId,
            required DateTime date,
            required DateTime time,
            required String observerName,
          }) =>
              StudyCompanion.insert(
            id: id,
            setupId: setupId,
            date: date,
            time: time,
            observerName: observerName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$StudyTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({setupId = false, timeStudyRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (timeStudyRefs) db.timeStudy],
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
                if (setupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.setupId,
                    referencedTable: $$StudyTableReferences._setupIdTable(db),
                    referencedColumn:
                        $$StudyTableReferences._setupIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timeStudyRefs)
                    await $_getPrefetchedData<StudyData, $StudyTable,
                            TimeStudyData>(
                        currentTable: table,
                        referencedTable:
                            $$StudyTableReferences._timeStudyRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$StudyTableReferences(db, table, p0).timeStudyRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.studyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$StudyTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudyTable,
    StudyData,
    $$StudyTableFilterComposer,
    $$StudyTableOrderingComposer,
    $$StudyTableAnnotationComposer,
    $$StudyTableCreateCompanionBuilder,
    $$StudyTableUpdateCompanionBuilder,
    (StudyData, $$StudyTableReferences),
    StudyData,
    PrefetchHooks Function({bool setupId, bool timeStudyRefs})>;
typedef $$TimeStudyTableCreateCompanionBuilder = TimeStudyCompanion Function({
  Value<int> id,
  required int studyId,
  required String taskName,
  required String iterationTime,
});
typedef $$TimeStudyTableUpdateCompanionBuilder = TimeStudyCompanion Function({
  Value<int> id,
  Value<int> studyId,
  Value<String> taskName,
  Value<String> iterationTime,
});

final class $$TimeStudyTableReferences
    extends BaseReferences<_$AppDatabase, $TimeStudyTable, TimeStudyData> {
  $$TimeStudyTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudyTable _studyIdTable(_$AppDatabase db) => db.study
      .createAlias($_aliasNameGenerator(db.timeStudy.studyId, db.study.id));

  $$StudyTableProcessedTableManager get studyId {
    final $_column = $_itemColumn<int>('study_id')!;

    final manager = $$StudyTableTableManager($_db, $_db.study)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TimeStudyTableFilterComposer
    extends Composer<_$AppDatabase, $TimeStudyTable> {
  $$TimeStudyTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskName => $composableBuilder(
      column: $table.taskName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iterationTime => $composableBuilder(
      column: $table.iterationTime, builder: (column) => ColumnFilters(column));

  $$StudyTableFilterComposer get studyId {
    final $$StudyTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studyId,
        referencedTable: $db.study,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudyTableFilterComposer(
              $db: $db,
              $table: $db.study,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimeStudyTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeStudyTable> {
  $$TimeStudyTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskName => $composableBuilder(
      column: $table.taskName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iterationTime => $composableBuilder(
      column: $table.iterationTime,
      builder: (column) => ColumnOrderings(column));

  $$StudyTableOrderingComposer get studyId {
    final $$StudyTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studyId,
        referencedTable: $db.study,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudyTableOrderingComposer(
              $db: $db,
              $table: $db.study,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimeStudyTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeStudyTable> {
  $$TimeStudyTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskName =>
      $composableBuilder(column: $table.taskName, builder: (column) => column);

  GeneratedColumn<String> get iterationTime => $composableBuilder(
      column: $table.iterationTime, builder: (column) => column);

  $$StudyTableAnnotationComposer get studyId {
    final $$StudyTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.studyId,
        referencedTable: $db.study,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudyTableAnnotationComposer(
              $db: $db,
              $table: $db.study,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimeStudyTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TimeStudyTable,
    TimeStudyData,
    $$TimeStudyTableFilterComposer,
    $$TimeStudyTableOrderingComposer,
    $$TimeStudyTableAnnotationComposer,
    $$TimeStudyTableCreateCompanionBuilder,
    $$TimeStudyTableUpdateCompanionBuilder,
    (TimeStudyData, $$TimeStudyTableReferences),
    TimeStudyData,
    PrefetchHooks Function({bool studyId})> {
  $$TimeStudyTableTableManager(_$AppDatabase db, $TimeStudyTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeStudyTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeStudyTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeStudyTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> studyId = const Value.absent(),
            Value<String> taskName = const Value.absent(),
            Value<String> iterationTime = const Value.absent(),
          }) =>
              TimeStudyCompanion(
            id: id,
            studyId: studyId,
            taskName: taskName,
            iterationTime: iterationTime,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int studyId,
            required String taskName,
            required String iterationTime,
          }) =>
              TimeStudyCompanion.insert(
            id: id,
            studyId: studyId,
            taskName: taskName,
            iterationTime: iterationTime,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TimeStudyTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({studyId = false}) {
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
                if (studyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.studyId,
                    referencedTable:
                        $$TimeStudyTableReferences._studyIdTable(db),
                    referencedColumn:
                        $$TimeStudyTableReferences._studyIdTable(db).id,
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

typedef $$TimeStudyTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TimeStudyTable,
    TimeStudyData,
    $$TimeStudyTableFilterComposer,
    $$TimeStudyTableOrderingComposer,
    $$TimeStudyTableAnnotationComposer,
    $$TimeStudyTableCreateCompanionBuilder,
    $$TimeStudyTableUpdateCompanionBuilder,
    (TimeStudyData, $$TimeStudyTableReferences),
    TimeStudyData,
    PrefetchHooks Function({bool studyId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ValueStreamsTableTableManager get valueStreams =>
      $$ValueStreamsTableTableManager(_db, _db.valueStreams);
  $$ProcessesTableTableManager get processes =>
      $$ProcessesTableTableManager(_db, _db.processes);
  $$ProcessPartsTableTableManager get processParts =>
      $$ProcessPartsTableTableManager(_db, _db.processParts);
  $$ProcessShiftTableTableManager get processShift =>
      $$ProcessShiftTableTableManager(_db, _db.processShift);
  $$VSShiftsTableTableManager get vSShifts =>
      $$VSShiftsTableTableManager(_db, _db.vSShifts);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db, _db.organizations);
  $$PartsTableTableManager get parts =>
      $$PartsTableTableManager(_db, _db.parts);
  $$PlantsTableTableManager get plants =>
      $$PlantsTableTableManager(_db, _db.plants);
  $$SetupsTableTableManager get setups =>
      $$SetupsTableTableManager(_db, _db.setups);
  $$SetupElementsTableTableManager get setupElements =>
      $$SetupElementsTableTableManager(_db, _db.setupElements);
  $$StudyTableTableManager get study =>
      $$StudyTableTableManager(_db, _db.study);
  $$TimeStudyTableTableManager get timeStudy =>
      $$TimeStudyTableTableManager(_db, _db.timeStudy);
}
