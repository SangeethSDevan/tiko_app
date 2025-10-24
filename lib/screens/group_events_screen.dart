import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../models/group.dart';
import 'group_details_screen.dart';

class GroupEventsScreen extends StatefulWidget {
  const GroupEventsScreen({super.key});

  @override
  State<GroupEventsScreen> createState() => _GroupEventsScreenState();
}

class _GroupEventsScreenState extends State<GroupEventsScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    setState(() => isLoading = true);
    await eventProvider.fetchGroups(auth.token!);
    setState(() => isLoading = false);
  }

  Future<void> _showCreateGroupDialog() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Create Group"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Group Name"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a group name")),
                  );
                  return;
                }

                Navigator.pop(ctx);
                setState(() => isLoading = true);

                bool success = await eventProvider.createGroup(
                  nameController.text.trim(),
                  auth.token!,
                );

                setState(() => isLoading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "Group created successfully"
                          : "Failed to create group",
                    ),
                  ),
                );

                if (success) _loadGroups();
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final groups = eventProvider.groups;

    return Scaffold(
      appBar: AppBar(title: const Text("Groups")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groups.isEmpty
          ? const Center(child: Text("No groups found"))
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  title: Text(group.groupName ?? "Unnamed Group"),
                  subtitle: Text(group.description ?? ""),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupDetailsScreen(group: group),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
