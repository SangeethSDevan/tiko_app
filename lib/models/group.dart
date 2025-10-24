class Group {
  final String groupId;
  final String groupName;
  final String? description;

  Group({
    required this.groupId,
    required this.groupName,
    this.description,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['groupId'] ?? json['id'] ?? '',
      groupName: json['groupName'] ?? json['group']?['groupName'] ?? 'Unnamed Group',
      description: json['description'] ?? json['group']?['description'],
    );
  }
}

 