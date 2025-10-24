import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../models/group.dart';
import '../models/event.dart';
import 'event_screen_for_group.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGroupEvents();
  }

  Future<void> _loadGroupEvents() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    setState(() => isLoading = true);
    await eventProvider.fetchGroupEvents(auth.token!, widget.group.groupId);
    setState(() => isLoading = false);
  }

  /// Dialog to add member
  Future<void> _showAddMemberDialog() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final TextEditingController memberController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add Member"),
          content: TextField(
            controller: memberController,
            decoration: const InputDecoration(labelText: "Member Email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (memberController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter member info")),
                  );
                  return;
                }

                Navigator.pop(ctx);
                setState(() => isLoading = true);

                bool success = await eventProvider.addMemberToGroup(
                  groupId: widget.group.groupId,
                  emails: [memberController.text.trim()],
                  token: auth.token!,
                );

                setState(() => isLoading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "Member added successfully"
                          : "Failed to add member",
                    ),
                  ),
                );
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// Dialog to create group event
  Future<void> _showCreateGroupEventDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return EventScreenForGroup(groupId: widget.group.groupId);
      },
    ).then((_) => _loadGroupEvents());
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.groupEvents;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.groupName ?? "Group Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddMemberDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateGroupEventDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
          ? const Center(child: Text("No group events"))
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Event event = events[index];
                String eventDate;
                try {
                  eventDate =
                      "${event.reccurence} | ${DateTime.parse(event.eventDate).toLocal().toIso8601String().split('T')[0]}";
                } catch (_) {
                  eventDate = "${event.reccurence} | Invalid date";
                }
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  tileColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(Icons.event, color: Colors.black),
                  title: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      eventDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    // Your navigation or action
                  },
                );
              },
            ),
    );
  }
}
