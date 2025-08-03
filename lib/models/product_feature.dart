class ProductFeatureName {
  final String name;

  ProductFeatureName({
    required this.name,
  });

  factory ProductFeatureName.fromJson(Map<String, dynamic> json) {
    return ProductFeatureName(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFeatureName &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class ProductFeatureValue {
  final String value;

  ProductFeatureValue({
    required this.value,
  });

  factory ProductFeatureValue.fromJson(Map<String, dynamic> json) {
    return ProductFeatureValue(
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFeatureValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class SelectedFeature {
  final String featureName;
  final List<String> featureValues;

  SelectedFeature({
    required this.featureName,
    required this.featureValues,
  });

  factory SelectedFeature.fromJson(Map<String, dynamic> json) {
    return SelectedFeature(
      featureName: json['featureName'] ?? '',
      featureValues: List<String>.from(json['featureValues'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'featureName': featureName,
      'featureValues': featureValues,
    };
  }

  SelectedFeature copyWith({
    String? featureName,
    List<String>? featureValues,
  }) {
    return SelectedFeature(
      featureName: featureName ?? this.featureName,
      featureValues: featureValues ?? this.featureValues,
    );
  }
}