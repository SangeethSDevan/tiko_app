import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../models/event.dart';
import '../models/group.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _personalEvents = [];
  List<Event> _groupEvents = [];
  List<Group> _groups = [];

  List<Event> get personalEvents => _personalEvents;
  List<Event> get groupEvents => _groupEvents;
  List<Group> get groups => _groups;

  /// Fetch personal events
  Future<void> fetchPersonalEvents(String token) async {
    try {
      final res = await ApiService.get(PERSONAL_EVENTS_URL, token: token);
      if (res['status'] == 'success') {
        final eventsList = res['events'] as List<dynamic>?;
        _personalEvents = eventsList != null
            ? eventsList.map((e) => Event.fromJson(e)).toList()
            : [];
        notifyListeners();
      } else {
        print("Failed to fetch personal events: ${res['message']}");
        _personalEvents = [];
      }
    } catch (e) {
      print("Error fetching personal events: $e");
      _personalEvents = [];
    }
  }

  /// Fetch all groups
  Future<void> fetchGroups(String token) async {
    try {
      final res = await ApiService.get(GROUPS_URL, token: token);
      if (res['status'] == 'success') {
        final groupsList = res['groups'] as List<dynamic>?;
        _groups = groupsList != null
            ? groupsList.map((g) => Group.fromJson(g)).toList()
            : [];
        notifyListeners();
      } else {
        print("Failed to fetch groups: ${res['message']}");
        _groups = [];
      }
    } catch (e) {
      print("Error fetching groups: $e");
      _groups = [];
    }
  }

  /// Fetch events for a specific group
  Future<void> fetchGroupEvents(String token, String groupId) async {
    try {
      final res = await ApiService.get('$BASE_URL/group/$groupId', token: token);
      if (res['status'] == 'success') {
        final eventsList = res['data']['events'] as List<dynamic>?;
        _groupEvents =
            eventsList != null ? eventsList.map((e) => Event.fromJson(e)).toList() : [];
        notifyListeners();
      } else {
        print("Failed to fetch group events: ${res['message']}");
        _groupEvents = [];
      }
    } catch (e) {
      print("Error fetching group events: $e");
      _groupEvents = [];
    }
  }

  /// Create personal or group event
  Future<bool> createEvent(Map<String, dynamic> eventData, String token) async {
    try {
      final url = eventData.containsKey("groupId") ? '$BASE_URL/events' : CREATE_EVENT_URL;
      final res = await ApiService.post(url, eventData, token: token);
      print("Create Event Response: $res");

      if (res['status'] == 'success') {
        final eventJson = res['event'] as Map<String, dynamic>?;
        if (eventJson != null) {
          Event event = Event.fromJson(eventJson);
          if (eventData.containsKey("groupId")) {
            _groupEvents.add(event);
          } else {
            _personalEvents.add(event);
          }
          notifyListeners();
        }
        return true;
      } else {
        print("Event creation failed: ${res['message']}");
        return false;
      }
    } catch (e) {
      print("Error creating event: $e");
      return false;
    }
  }

  /// Create a new group
  Future<bool> createGroup(String groupName, String token, {String? description}) async {
    try {
      final body = {'groupName': groupName};
      if (description != null) {
        body['description'] = description;
      }

      final res = await ApiService.post(CREATE_GROUP_URL, body, token: token);
      print("Create Group Response: $res");

      if (res['status'] == 'success') {
        final groupJson = res['group'] as Map<String, dynamic>?;
        if (groupJson != null) {
          _groups.add(Group.fromJson(groupJson));
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print("Error creating group: $e");
    }
    return false;
  }

  /// Add a member to a group
  Future<bool> addMemberToGroup({
    required String groupId,
    required List<String> emails,
    required String token,
  }) async {
    try {
      final res = await ApiService.post(
        '$BASE_URL/group/member/add?gid=$groupId',
        {'emails': emails},
        token: token,
      );
      print("Add Member Response: $res");
      return res['status'] == 'success' || res['status'] == 'partial_success';
    } catch (e) {
      print("Error adding member to group: $e");
      return false;
    }
  }

  /// Update a member role (ADMIN or LEADER only)
  Future<bool> updateMemberRole({
    required String groupId,
    required String userId,
    required String role,
    required String token,
  }) async {
    try {
      final res = await ApiService.post(
        '$BASE_URL/group/member/role?gid=$groupId&uid=$userId',
        {'role': role},
        token: token,
      );
      print("Update Role Response: $res");
      return res['status'] == 'success';
    } catch (e) {
      print("Error updating member role: $e");
      return false;
    }
  }

  /// Remove a member from group
  Future<bool> removeMember({
    required String groupId,
    required String userId,
    required String token,
  }) async {
    try {
      final res = await ApiService.post(
        '$BASE_URL/group/member/kick?gid=$groupId&uid=$userId',
        {},
        token: token,
      );
      print("Remove Member Response: $res");
      return res['status'] == 'success';
    } catch (e) {
      print("Error removing member: $e");
      return false;
    }
  }
}
