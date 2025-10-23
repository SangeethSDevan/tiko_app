import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _descController = TextEditingController();
  String _recurrence = "NONE";
  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Open calendar to pick date
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _dateController.text = DateFormat("yyyy-MM-dd").format(picked);
    }
  }

  /// Create event using API
  Future<void> _createEvent(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (_titleController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and date are required")),
      );
      return;
    }

    setState(() => isLoading = true);

    // Format date in ISO 8601
    DateTime eventDate = DateTime.parse(_dateController.text);
    String isoDate = eventDate.toUtc().toIso8601String(); // yyyy-MM-ddTHH:mm:ssZ

    Map<String, dynamic> eventData = {
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "reccurence": _recurrence,
      "eventDate": isoDate,
    };

    bool success = await eventProvider.createEvent(eventData, auth.token!);

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event created successfully")),
      );
      _titleController.clear();
      _dateController.clear();
      _descController.clear();
      await eventProvider.fetchPersonalEvents(auth.token!);
      Navigator.pop(context); // Go back to HomeScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event creation failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Event Title"),
            ),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: "Event Date"),
              readOnly: true,
              onTap: _selectDate,
            ),
            DropdownButton<String>(
              value: _recurrence,
              items: ["NONE", "DAILY", "WEEKLY", "MONTHLY"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _recurrence = v!),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _createEvent(context),
                    child: const Text("Create Event"),
                  ),
          ],
        ),
      ),
    );
  }
}
