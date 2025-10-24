import 'package:flutter/material.dart';
import '../models/group.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class GroupProvider extends ChangeNotifier {
  List<Group> _groups = [];
  List<Group> get groups => _groups;

  /// Fetch all groups the user belongs to
  Future<void> fetchGroups(String token) async {
    final res = await ApiService.get(GROUPS_URL, token: token);
    if (res['status'] == 'success') {
      _groups = List<Group>.from(
        res['groups'].map((g) => Group.fromJson(g)),
      );
      notifyListeners();
    } else {
      print("Failed to fetch groups: ${res['message']}");
    }
  }

  /// Create a new group
  Future<bool> createGroup(Map<String, dynamic> data, String token) async {
    final res = await ApiService.post(CREATE_GROUP_URL, data, token: token);
    print("Create Group Response: $res");
print(res['status']);
    if (res['status'] == 'success') {
      _groups.add(Group.fromJson(res['group']));
      notifyListeners();
      return true;
    }
    return false;
  }
}
