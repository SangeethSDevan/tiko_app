import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import 'event_screen.dart';
import 'signup_screen.dart';
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    if (auth.token != null) {
      eventProvider.fetchPersonalEvents(auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final events = Provider.of<EventProvider>(context).personalEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiko Reminder App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: events.isEmpty
          ? const Center(child: Text("No personal events"))
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Event event = events[index];
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text('${event.reccurence} | ${event.eventDate}'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventScreen(event: event))),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventScreen())),
      ),
    );
  }
}
