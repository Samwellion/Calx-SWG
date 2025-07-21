# Plant Object Model Documentation

## Overview

The Plant model represents a comprehensive manufacturing plant/facility entity with full business logic, validation capabilities, and database integration. This model is designed to support industrial time observation systems and lean manufacturing processes.

## Architecture

### Core Components

1. **Plant Model** (`lib/models/plant.dart`)
   - Main Plant class with comprehensive properties
   - PlantType and PlantStatus enumerations
   - PlantValidationResult for validation feedback
   - Legacy PlantData for backward compatibility

2. **Plant Service** (`lib/services/plant_service.dart`)
   - CRUD operations for Plant entities
   - Business logic and validation
   - Database integration
   - Search and filtering capabilities

3. **Database Integration** (`lib/logic/app_database.dart`)
   - Plants table definition
   - Relationships with Organizations and ValueStreams
   - Migration support

## Plant Model Structure

### Core Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `int?` | No | Unique identifier (auto-generated) |
| `organizationId` | `int` | Yes | Reference to parent organization |
| `name` | `String` | Yes | Plant name (max 100 characters) |
| `street` | `String` | Yes | Street address |
| `city` | `String` | Yes | City location |
| `state` | `String` | Yes | State/Province |
| `zip` | `String` | Yes | Postal/ZIP code |

### Extended Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `country` | `String` | 'USA' | Country location |
| `plantCode` | `String?` | null | Internal plant identifier |
| `phoneNumber` | `String?` | null | Contact phone number |
| `email` | `String?` | null | Contact email address |
| `managerName` | `String?` | null | Plant manager name |
| `plantType` | `PlantType` | manufacturing | Type of facility |
| `status` | `PlantStatus` | active | Operational status |
| `squareFootage` | `double?` | null | Plant size in square feet |
| `employeeCount` | `int?` | null | Number of employees |
| `establishedDate` | `DateTime?` | null | Date plant was established |
| `createdAt` | `DateTime` | DateTime.now() | Record creation timestamp |
| `updatedAt` | `DateTime` | DateTime.now() | Last update timestamp |
| `notes` | `String?` | null | Additional notes |
| `valueStreams` | `List<String>` | [] | Associated value streams |
| `isPrimary` | `bool` | false | Whether this is the primary plant |

## Enumerations

### PlantType

- `manufacturing` - Manufacturing facility
- `warehouse` - Warehouse/storage facility  
- `distribution` - Distribution center
- `assembly` - Assembly facility
- `research` - Research & Development facility
- `office` - Office facility
- `mixed` - Mixed operations facility

### PlantStatus

- `active` - Currently operational
- `inactive` - Not currently operational
- `underConstruction` - Being built/renovated
- `maintenance` - Under maintenance
- `decommissioned` - No longer in use

## Key Methods

### Plant Model Methods

#### Validation
```dart
PlantValidationResult validate()
```
Validates all plant data according to business rules:
- Name is required and ≤ 100 characters
- Organization ID is valid (> 0)
- Email format validation (if provided)
- Phone number format validation (if provided)
- ZIP code format validation (US format)
- Employee count ≥ 0 (if provided)
- Square footage > 0 (if provided)

#### Utility Methods
```dart
String get fullAddress          // Formatted complete address
String get displayName          // Name with plant code if available
bool get hasCompleteAddress     // Checks if all address fields are filled
```

#### Conversion Methods
```dart
Map<String, dynamic> toJson()                    // Convert to JSON
factory Plant.fromJson(Map<String, dynamic>)    // Create from JSON
PlantData toLegacyPlantData()                   // Convert to legacy format
factory Plant.fromLegacyPlantData(...)          // Create from legacy format
```

### Plant Service Methods

#### CRUD Operations
```dart
Future<Plant> createPlant(Plant plant)          // Create new plant
Future<Plant> updatePlant(Plant plant)          // Update existing plant
Future<Plant?> getPlantById(int plantId)        // Get plant by ID
Future<Plant?> getPlantByName(String, int)      // Get plant by name & org
Future<void> deletePlant(int plantId)           // Delete plant
```

#### Query Operations
```dart
Future<List<Plant>> getPlantsForOrganization(int)   // Get plants for org
Future<List<Plant>> getAllPlants()                  // Get all plants
Future<Plant?> getPrimaryPlantForOrganization(int)  // Get primary plant
```

#### Search and Filtering
```dart
Future<List<Plant>> searchPlants({
  String? nameFilter,
  String? cityFilter,
  String? stateFilter,
  PlantStatus? statusFilter,
  PlantType? typeFilter,
  int? organizationId,
})
```

#### Value Stream Management
```dart
Future<void> addValueStreamToPlant(int, String)     // Add value stream
Future<void> removeValueStreamFromPlant(int, String) // Remove value stream
```

#### Statistics
```dart
Future<PlantStatistics> getPlantStatistics({int? organizationId})
```

## Usage Examples

### Creating a New Plant

```dart
final plantService = PlantService(database);

final plant = Plant(
  organizationId: 1,
  name: 'Goleta Manufacturing Plant',
  street: '123 Industrial Way',
  city: 'Goleta',
  state: 'CA',
  zip: '93117',
  plantType: PlantType.manufacturing,
  status: PlantStatus.active,
  managerName: 'John Smith',
  email: 'john.smith@company.com',
  valueStreams: ['Assembly Line 1', 'Quality Control'],
);

// Validate before saving
final validation = plant.validate();
if (validation.isValid) {
  final savedPlant = await plantService.createPlant(plant);
  print('Plant created with ID: ${savedPlant.id}');
} else {
  print('Validation errors: ${validation.errorMessage}');
}
```

### Querying Plants

```dart
// Get all plants for an organization
final plants = await plantService.getPlantsForOrganization(1);

// Search for manufacturing plants in California
final caPlants = await plantService.searchPlants(
  stateFilter: 'CA',
  typeFilter: PlantType.manufacturing,
  statusFilter: PlantStatus.active,
);

// Get plant statistics
final stats = await plantService.getPlantStatistics(organizationId: 1);
print('Total plants: ${stats.totalPlants}');
print('Plants by state: ${stats.plantsByState}');
```

### Updating Plant Information

```dart
final plant = await plantService.getPlantById(1);
if (plant != null) {
  final updatedPlant = plant.copyWith(
    managerName: 'Jane Doe',
    employeeCount: 150,
    notes: 'Recently expanded facility',
  );
  
  await plantService.updatePlant(updatedPlant);
}
```

### Working with Value Streams

```dart
// Add a value stream
await plantService.addValueStreamToPlant(1, 'New Production Line');

// Remove a value stream
await plantService.removeValueStreamFromPlant(1, 'Old Assembly Line');
```

## Database Schema

### Plants Table
```sql
CREATE TABLE plants (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  organization_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  street TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  zip TEXT NOT NULL,
  FOREIGN KEY (organization_id) REFERENCES organizations (id)
);
```

### Value Streams Table
```sql
CREATE TABLE value_streams (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plant_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  FOREIGN KEY (plant_id) REFERENCES plants (id)
);
```

## Validation Rules

### Required Fields
- `name`: Must be non-empty and ≤ 100 characters
- `organizationId`: Must be > 0
- `street`, `city`, `state`, `zip`: Must be provided (can be empty strings)

### Format Validation
- **Email**: Must match standard email pattern if provided
- **Phone**: Must match phone number pattern if provided  
- **ZIP Code**: Must match US ZIP format (12345 or 12345-6789)

### Business Rules
- `employeeCount`: Must be ≥ 0 if provided
- `squareFootage`: Must be > 0 if provided
- Only one plant per organization can be marked as primary

## Error Handling

### PlantValidationException
Thrown when plant validation fails during create/update operations.

```dart
try {
  await plantService.createPlant(invalidPlant);
} catch (e) {
  if (e is PlantValidationException) {
    print('Validation errors: ${e.errors.join(', ')}');
  }
}
```

## Migration and Backward Compatibility

The model maintains backward compatibility with the existing `PlantData` class:

```dart
// Convert legacy PlantData to new Plant model
final plant = legacyPlantData.toPlant(organizationId: 1);

// Convert Plant model to legacy PlantData
final legacyData = plant.toLegacyPlantData();
```

## Future Enhancements

### Planned Database Schema Updates
- Add `plant_code`, `phone_number`, `email`, `manager_name` columns
- Add `plant_type`, `status` enum columns
- Add `square_footage`, `employee_count` numeric columns
- Add `established_date`, `created_at`, `updated_at` timestamp columns
- Add `notes` text column
- Add `is_primary` boolean column

### Additional Features
- GPS coordinates for plant location
- Plant capacity and utilization metrics
- Integration with external mapping services
- Plant hierarchy support (multi-site organizations)
- Audit trail for plant changes
- Document attachments (floor plans, certifications)

## Testing

### Unit Tests
Test coverage should include:
- Plant model validation rules
- PlantService CRUD operations
- Search and filtering functionality
- Error handling scenarios
- Legacy compatibility methods

### Integration Tests
- Database operations with real data
- Performance testing with large datasets
- Migration testing from legacy format

## Performance Considerations

- Use database indexes on frequently queried fields (name, organizationId, state)
- Implement pagination for large plant lists
- Cache frequently accessed plant data
- Use database transactions for multi-table operations
- Consider read replicas for reporting queries
