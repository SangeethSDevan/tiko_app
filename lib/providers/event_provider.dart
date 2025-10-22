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
      _personalEvents = List<Event>.from(res['events'].map((e) => Event.fromJson(e)));
      notifyListeners();
    }
  }

  Future<void> createEvent(Map<String, dynamic> eventData, String token) async {
    final res = await ApiService.post('${BASE_URL}/event', eventData, token: token);
    if (res['status'] == 'success') {
      _personalEvents.add(Event.fromJson(res['event']));
      notifyListeners();
    }
  }
}
