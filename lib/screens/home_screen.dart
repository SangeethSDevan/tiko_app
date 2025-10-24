import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiko_app/screens/group_details_screen.dart';
import 'package:tiko_app/screens/login_screen.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/event_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (auth.token != null) {
      await eventProvider.fetchPersonalEvents(auth.token!);
      await eventProvider.fetchGroups(auth.token!);
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Color _recurrenceColor(String recurrence) {
    switch (recurrence.toUpperCase()) {
      case "DAILY":
        return Colors.blueAccent.shade100;
      case "WEEKLY":
        return Colors.greenAccent.shade100;
      case "MONTHLY":
        return Colors.orangeAccent.shade100;
      case "YEARLY":
        return Colors.orangeAccent.shade400;
      default:
        return Colors.grey.shade300;
    }
  }

  Widget _recurrenceTag(String recurrence) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _recurrenceColor(recurrence),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        recurrence,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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

                setState(() {});

                bool success = false;
                try {
                  success = await eventProvider.createGroup(
                    nameController.text.trim(),
                    auth.token!,
                    description: descController.text.trim(),
                  );
                } catch (_) {
                  success = false;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "Group created successfully"
                          : "Failed to create group",
                    ),
                  ),
                );

                if (success) _loadData();
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
    final auth = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    Widget body;
    FloatingActionButton? fab;

    if (_selectedIndex == 0) {
      // PERSONAL EVENTS
      body = RefreshIndicator(
        onRefresh: _loadData,
        child: eventProvider.personalEvents.isEmpty
            ? const Center(
                child: Text(
                  "No personal events yet.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: eventProvider.personalEvents.length,
                itemBuilder: (context, index) {
                  final event = eventProvider.personalEvents[index];
                  String formattedDate;
                  try {
                    formattedDate = DateTime.parse(
                      event.eventDate,
                    ).toLocal().toIso8601String().split('T')[0];
                  } catch (_) {
                    formattedDate = "Invalid date";
                  }

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _recurrenceTag(event.reccurence),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );

      fab = FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        label: const Text("Add Event"),
        icon: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventScreen()),
          );
          _loadData();
        },
      );
    } else {
      // GROUPS TAB
      body = RefreshIndicator(
        onRefresh: _loadData,
        child: eventProvider.groups.isEmpty
            ? const Center(
                child: Text(
                  "No groups available.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: eventProvider.groups.length,
                itemBuilder: (context, index) {
                  final group = eventProvider.groups[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupDetailsScreen(group: group),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          group.groupName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          group.description ?? "Empty Description",
                        ),
                      ),
                    ),
                  );
                },
              ),
      );

      fab = FloatingActionButton.extended(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        label: const Text("New Group"),
        icon: const Icon(Icons.group_add),
        onPressed: _showCreateGroupDialog, // Directly open the dialog
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Tiko Reminder",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.black54),
            tooltip: "Logout",
            onPressed: () {
              print("Logged out");
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: body,
      floatingActionButton: fab,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: "Personal",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Groups"),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
