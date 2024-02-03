class FigmaSimpleChildModel {
  final Map<String, dynamic> child;

  FigmaSimpleChildModel({
    required this.child,
  });

  FigmaSimpleChildModel._fromJson(Map<String, dynamic> json):
      child = json['child'] as Map<String, dynamic>;

  factory FigmaSimpleChildModel.fromJson(Map<String, dynamic> json) =>
      FigmaSimpleChildModel._fromJson(json);
}