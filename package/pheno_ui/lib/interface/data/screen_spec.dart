class PhenoScreenSpec {
  final String id;
  final String name;
  final String slug;
  final Map<String, dynamic> spec;

  PhenoScreenSpec(this.id, this.name, this.slug, this.spec);

  factory PhenoScreenSpec.fromJson(Map<String, dynamic> json) {
    return PhenoScreenSpec(
        json['id'],
        json['name'],
        json['tag']['path'] + '/' + json['name'],
        json['data']
    );
  }
}