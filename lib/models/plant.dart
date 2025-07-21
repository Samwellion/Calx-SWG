/// Comprehensive Plant model that represents a manufacturing plant/facility
/// with full business logic and validation capabilities
class Plant {
  /// Unique identifier for the plant
  final int? id;

  /// Organization/Company ID that owns this plant
  final int organizationId;

  /// Plant name (required, non-empty)
  final String name;

  /// Street address
  final String street;

  /// City location
  final String city;

  /// State/Province
  final String state;

  /// Postal/ZIP code
  final String zip;

  /// Country (defaults to 'USA')
  final String country;

  /// Plant code/identifier for internal reference
  final String? plantCode;

  /// Phone number
  final String? phoneNumber;

  /// Email contact
  final String? email;

  /// Plant manager name
  final String? managerName;

  /// Plant type (Manufacturing, Warehouse, Distribution, etc.)
  final PlantType plantType;

  /// Current operational status
  final PlantStatus status;

  /// Square footage of the plant
  final double? squareFootage;

  /// Number of employees
  final int? employeeCount;

  /// Date when plant was established
  final DateTime? establishedDate;

  /// Date when record was created
  final DateTime createdAt;

  /// Date when record was last updated
  final DateTime updatedAt;

  /// Additional notes or description
  final String? notes;

  /// List of value stream names associated with this plant
  final List<String> valueStreams;

  /// Whether this plant is the primary/main plant for the organization
  final bool isPrimary;

  Plant({
    this.id,
    required this.organizationId,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    this.country = 'USA',
    this.plantCode,
    this.phoneNumber,
    this.email,
    this.managerName,
    this.plantType = PlantType.manufacturing,
    this.status = PlantStatus.active,
    this.squareFootage,
    this.employeeCount,
    this.establishedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notes,
    this.valueStreams = const [],
    this.isPrimary = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with modified fields
  Plant copyWith({
    int? id,
    int? organizationId,
    String? name,
    String? street,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? plantCode,
    String? phoneNumber,
    String? email,
    String? managerName,
    PlantType? plantType,
    PlantStatus? status,
    double? squareFootage,
    int? employeeCount,
    DateTime? establishedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    List<String>? valueStreams,
    bool? isPrimary,
  }) {
    return Plant(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      plantCode: plantCode ?? this.plantCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      managerName: managerName ?? this.managerName,
      plantType: plantType ?? this.plantType,
      status: status ?? this.status,
      squareFootage: squareFootage ?? this.squareFootage,
      employeeCount: employeeCount ?? this.employeeCount,
      establishedDate: establishedDate ?? this.establishedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notes: notes ?? this.notes,
      valueStreams: valueStreams ?? this.valueStreams,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  /// Get full address as a formatted string
  String get fullAddress {
    final parts = [street, city, state, zip, country];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  /// Get display name (combines name and plant code if available)
  String get displayName {
    if (plantCode != null && plantCode!.isNotEmpty) {
      return '$name ($plantCode)';
    }
    return name;
  }

  /// Check if plant has complete address information
  bool get hasCompleteAddress {
    return street.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        zip.isNotEmpty;
  }

  /// Validate plant data
  PlantValidationResult validate() {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('Plant name is required');
    }

    if (name.length > 100) {
      errors.add('Plant name must be 100 characters or less');
    }

    if (organizationId <= 0) {
      errors.add('Valid organization ID is required');
    }

    // Validate email format if provided
    if (email != null && email!.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email!)) {
        errors.add('Invalid email format');
      }
    }

    // Validate phone number format if provided
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
      if (!phoneRegex.hasMatch(phoneNumber!)) {
        errors.add('Invalid phone number format');
      }
    }

    // Validate ZIP code format (basic US ZIP)
    if (zip.isNotEmpty) {
      final zipRegex = RegExp(r'^\d{5}(-\d{4})?$');
      if (!zipRegex.hasMatch(zip)) {
        errors.add('Invalid ZIP code format (should be 12345 or 12345-6789)');
      }
    }

    // Validate employee count
    if (employeeCount != null && employeeCount! < 0) {
      errors.add('Employee count cannot be negative');
    }

    // Validate square footage
    if (squareFootage != null && squareFootage! <= 0) {
      errors.add('Square footage must be positive');
    }

    return PlantValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Convert to the legacy PlantData format for backward compatibility
  PlantData toLegacyPlantData() {
    return PlantData(
      name: name,
      street: street,
      city: city,
      state: state,
      zip: zip,
    );
  }

  /// Create Plant from legacy PlantData
  factory Plant.fromLegacyPlantData(
    PlantData plantData, {
    required int organizationId,
    int? id,
  }) {
    return Plant(
      id: id,
      organizationId: organizationId,
      name: plantData.name,
      street: plantData.street,
      city: plantData.city,
      state: plantData.state,
      zip: plantData.zip,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'plantCode': plantCode,
      'phoneNumber': phoneNumber,
      'email': email,
      'managerName': managerName,
      'plantType': plantType.name,
      'status': status.name,
      'squareFootage': squareFootage,
      'employeeCount': employeeCount,
      'establishedDate': establishedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'valueStreams': valueStreams,
      'isPrimary': isPrimary,
    };
  }

  /// Create Plant from JSON map
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as int?,
      organizationId: json['organizationId'] as int,
      name: json['name'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zip: json['zip'] as String,
      country: json['country'] as String? ?? 'USA',
      plantCode: json['plantCode'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      managerName: json['managerName'] as String?,
      plantType: PlantType.values.firstWhere(
        (e) => e.name == json['plantType'],
        orElse: () => PlantType.manufacturing,
      ),
      status: PlantStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PlantStatus.active,
      ),
      squareFootage: json['squareFootage'] as double?,
      employeeCount: json['employeeCount'] as int?,
      establishedDate: json['establishedDate'] != null
          ? DateTime.parse(json['establishedDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
      valueStreams: List<String>.from(json['valueStreams'] ?? []),
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Plant) return false;
    return other.id == id &&
        other.organizationId == organizationId &&
        other.name == name &&
        other.street == street &&
        other.city == city &&
        other.state == state &&
        other.zip == zip &&
        other.country == country &&
        other.plantCode == plantCode &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.managerName == managerName &&
        other.plantType == plantType &&
        other.status == status &&
        other.squareFootage == squareFootage &&
        other.employeeCount == employeeCount &&
        other.establishedDate == establishedDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.notes == notes &&
        _listEquals(other.valueStreams, valueStreams) &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      organizationId,
      name,
      street,
      city,
      state,
      zip,
      country,
      plantCode,
      phoneNumber,
      email,
      managerName,
      plantType,
      status,
      squareFootage,
      employeeCount,
      establishedDate,
      createdAt,
      updatedAt,
      notes,
      valueStreams,
      isPrimary,
    ]);
  }

  @override
  String toString() {
    return 'Plant(id: $id, name: $name, city: $city, state: $state, status: $status)';
  }

  /// Helper method for list equality
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Enumeration of plant types
enum PlantType {
  manufacturing,
  warehouse,
  distribution,
  assembly,
  research,
  office,
  mixed;

  String get displayName {
    switch (this) {
      case PlantType.manufacturing:
        return 'Manufacturing';
      case PlantType.warehouse:
        return 'Warehouse';
      case PlantType.distribution:
        return 'Distribution';
      case PlantType.assembly:
        return 'Assembly';
      case PlantType.research:
        return 'Research & Development';
      case PlantType.office:
        return 'Office';
      case PlantType.mixed:
        return 'Mixed Operations';
    }
  }
}

/// Enumeration of plant operational status
enum PlantStatus {
  active,
  inactive,
  underConstruction,
  maintenance,
  decommissioned;

  String get displayName {
    switch (this) {
      case PlantStatus.active:
        return 'Active';
      case PlantStatus.inactive:
        return 'Inactive';
      case PlantStatus.underConstruction:
        return 'Under Construction';
      case PlantStatus.maintenance:
        return 'Under Maintenance';
      case PlantStatus.decommissioned:
        return 'Decommissioned';
    }
  }

  bool get isOperational => this == PlantStatus.active;
}

/// Result of plant validation
class PlantValidationResult {
  final bool isValid;
  final List<String> errors;

  const PlantValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join(', ');
}

/// Legacy PlantData class for backward compatibility
class PlantData {
  String name;
  String street;
  String city;
  String state;
  String zip;

  PlantData({
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
  });

  int? get id => null;

  PlantData copyWith({
    String? name,
    String? street,
    String? city,
    String? state,
    String? zip,
  }) {
    return PlantData(
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
    );
  }

  /// Convert to the new Plant model
  Plant toPlant({required int organizationId, int? id}) {
    return Plant.fromLegacyPlantData(this,
        organizationId: organizationId, id: id);
  }
}
