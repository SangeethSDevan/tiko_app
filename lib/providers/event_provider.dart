import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _personalEvents = [];
  List<Event> get personalEvents => _personalEvents;

  Future<void> fetchPersonalEvents(String token) async {
    final res = await ApiService.get(PERSONAL_EVENTS_URL, token: token);
    if (res['status'] == 'success') {
      _personalEvents = List<Event>.from(
        res['events'].map((e) => Event.fromJson(e)),
      );
      notifyListeners();
    } else {
      print("Failed to fetch events: ${res['message']}");
    }
  }

  Future<bool> createEvent(Map<String, dynamic> eventData, String token) async {
    final res = await ApiService.post(
      CREATE_EVENT_URL,
      eventData,
      token: token,
    );
    print("Create Event Response: $res");

    if (res['status'] == 'success') {
      _personalEvents.add(Event.fromJson(res['event']));
      notifyListeners();
      return true;
    } else {
      print("Event creation failed: ${res['message']}");
      return false;
    }
  }
}
