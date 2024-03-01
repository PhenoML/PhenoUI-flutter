class PhenoComponentSpec {
  final int id;
  final String type;
  final String defaultVariant;
  final Map<String, dynamic> variants;
  final Map<String, dynamic> arguments;

  PhenoComponentSpec(
      this.id,
      this.type,
      this.defaultVariant,
      this.variants,
      this.arguments
      );

  factory PhenoComponentSpec.fromJson(Map<String, dynamic> json) {
    return PhenoComponentSpec(
      json['id'].toInt(),
      json['attributes']['name'],
      json['attributes']['defaultVariant'],
      json['attributes']['variants'],
      json['attributes']['arguments'],
    );
  }
}