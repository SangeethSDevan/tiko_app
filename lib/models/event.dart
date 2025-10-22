class Event {
  String eventId;
  String title;
  String description;
  String eventDate;
  String reccurence;
  String? groupId;

  Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.reccurence,
    this.groupId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'],
      title: json['title'],
      description: json['description'],
      eventDate: json['eventDate'],
      reccurence: json['reccurence'],
      groupId: json['groupId'],
    );
  }
}
