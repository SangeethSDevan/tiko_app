import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../models/event.dart';
import 'event_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    if (auth.token != null) {
      await eventProvider.fetchPersonalEvents(auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiko Reminder App'),
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
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: eventProvider.personalEvents.isEmpty
            ? const Center(child: Text("No personal events"))
            : ListView.builder(
                itemCount: eventProvider.personalEvents.length,
                itemBuilder: (context, index) {
                  Event event = eventProvider.personalEvents[index];
                  String eventDateFormatted;
                  try {
                    eventDateFormatted = "${event.reccurence} | ${DateTime.parse(event.eventDate).toLocal().toIso8601String().split('T')[0]}";
                  } catch (_) {
                    eventDateFormatted = "${event.reccurence} | Invalid date";
                  }

                  return ListTile(
                    title: Text(event.title),
                    subtitle: Text(eventDateFormatted),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navigate to EventScreen and refresh events after returning
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventScreen()),
          );
          _loadEvents(); // Refresh events after adding new one
        },
      ),
    );
  }
}
