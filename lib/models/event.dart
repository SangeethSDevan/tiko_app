class Event {
  final String id;
  final String title;
  final String reccurence;
  final String eventDate;

  Event({
    required this.id,
    required this.title,
    required this.reccurence,
    required this.eventDate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      reccurence: json['reccurence'] ?? '',
      eventDate: json['eventDate'] ?? '',
    );
  }
}
