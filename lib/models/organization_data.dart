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
}

class OrganizationData {
  static String companyName = '';
  static List<PlantData> plants = [];
}
