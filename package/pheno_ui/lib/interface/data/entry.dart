class PhenoDataEntry {
  final Map<String, dynamic> data;
  const PhenoDataEntry(this.data);
  String get id => data['id'];
  String get uid => data['path'];
  String get name => data['name'];
}