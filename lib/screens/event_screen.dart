import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../models/event.dart';

class EventScreen extends StatefulWidget {
  final Event? event;
  const EventScreen({super.key, this.event});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _reccurence = 'NONE';

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descController.text = widget.event!.description;
      _dateController.text = widget.event!.eventDate;
      _reccurence = widget.event!.reccurence;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? "Add Event" : "Edit Event")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: _dateController, decoration: const InputDecoration(labelText: 'Event Date ISO format')),
            DropdownButton<String>(
              value: _reccurence,
              items: ['NONE','DAILY','WEEKLY','MONTHLY','YEARLY'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => setState(() => _reccurence = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> eventData = {
                  'title': _titleController.text,
                  'description': _descController.text,
                  'eventDate': _dateController.text,
                  'reccurence': _reccurence,
                };

                if (widget.event == null) {
                  await eventProvider.createEvent(eventData, auth.token!);
                } 
                // Add update logic here if editing
                Navigator.pop(context);
              },
              child: Text(widget.event == null ? "Create Event" : "Update Event"),
            )
          ],
        ),
      ),
    );
  }
}
