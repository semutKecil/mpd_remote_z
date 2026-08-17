class MpdTagGroup {
  final String type;
  final String value;
  final List<MpdTagGroup> children;
  const MpdTagGroup({
    required this.type,
    required this.value,
    this.children = const [],
  });

  factory MpdTagGroup.fromJson(Map<String, dynamic> json) => MpdTagGroup(
    type: json['type'],
    value: json['value'],
    children: List<MpdTagGroup>.from(
      json['children'].map((x) => MpdTagGroup.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
    'children': List<dynamic>.from(children.map((x) => x.toJson())),
  };
}
