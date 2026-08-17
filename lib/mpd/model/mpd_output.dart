class MpdOutput {
  final String id;
  final String name;
  final String? plugin;
  final String? attribute;
  final bool enabled;

  MpdOutput({
    required this.id,
    required this.name,
    required this.enabled,
    this.plugin,
    this.attribute,
  });
}
