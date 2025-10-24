import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiko_app/screens/group_details_screen.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../models/event.dart';
import '../models/group.dart';
import 'event_screen.dart';
import 'group_events_screen.dart';
import 'login_screen.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    Widget body;
    FloatingActionButton? fab;

    if (_selectedIndex == 0) {
      // Personal Events Tab (unchanged)
      body = RefreshIndicator(
        onRefresh: _loadData,
        child: eventProvider.personalEvents.isEmpty
            ? const Center(child: Text("No personal events"))
            : ListView.builder(
                itemCount: eventProvider.personalEvents.length,
                itemBuilder: (context, index) {
                  Event event = eventProvider.personalEvents[index];
                  String eventDate;
                  try {
                    eventDate =
                        "${event.reccurence} | ${DateTime.parse(event.eventDate).toLocal().toIso8601String().split('T')[0]}";
                  } catch (_) {
                    eventDate = "${event.reccurence} | Invalid date";
                  }
                  return ListTile(
                    title: Text(event.title),
                    subtitle: Text(eventDate),
                  );
                },
              ),
      );

      fab = FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventScreen()),
          );
          _loadData();
        },
      );
    } else {
      // Groups Tab
      body = RefreshIndicator(
        onRefresh: _loadData,
        child: eventProvider.groups.isEmpty
            ? const Center(child: Text("No groups"))
            : ListView.builder(
                itemCount: eventProvider.groups.length,
                itemBuilder: (context, index) {
                  Group group = eventProvider.groups[index];
                  return ListTile(
                    title: Text(group.groupName ?? "Unnamed Group"),
                    subtitle: Text(group.description ?? ""),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GroupDetailsScreen(group: group),
                        ),
                      ).then((_) => _loadData());
                    },
                  );
                },
              ),
      );

      fab = FloatingActionButton(
        child: const Icon(Icons.group_add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GroupEventsScreen(),
            ),
          ).then((_) => _loadData());
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tiko Reminder App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton: fab,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Personal",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Groups",
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
