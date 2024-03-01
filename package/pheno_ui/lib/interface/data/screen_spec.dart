class PhenoScreenSpec {
  final int id;
  final String name;
  final String slug;
  final Map<String, dynamic> spec;

  PhenoScreenSpec(this.id, this.name, this.slug, this.spec);

  factory PhenoScreenSpec.fromJson(Map<String, dynamic> json) {
    return PhenoScreenSpec(
        json['data']['id'].toInt(),
        json['data']['attributes']['name'],
        json['data']['attributes']['slug'],
        json['data']['attributes']['spec']
    );
  }
}