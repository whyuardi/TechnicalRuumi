// lib/features/listing/data/models/property_type_model.dart

class PropertyTypeModel {
  final String id;
  final String name;
  final String? description;

  const PropertyTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyTypeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
