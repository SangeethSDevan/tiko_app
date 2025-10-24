import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class EventScreenForGroup extends StatefulWidget {
  final String groupId;

  const EventScreenForGroup({super.key, required this.groupId});

  @override
  State<EventScreenForGroup> createState() => _EventScreenForGroupState();
}

class _EventScreenForGroupState extends State<EventScreenForGroup> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _recurrence = "NONE";
  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

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

  Future<void> _createGroupEvent(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (_titleController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and date are required")),
      );
      return;
    }

    setState(() => isLoading = true);

    DateTime eventDate = DateTime.parse(_dateController.text);
    String isoDate = eventDate.toUtc().toIso8601String();

    Map<String, dynamic> eventData = {
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "reccurence": _recurrence,
      "eventDate": isoDate,
      "groupId": widget.groupId,
    };

    bool success = await eventProvider.createEvent(eventData, auth.token!);

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group event created successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Event creation failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Group Event"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Event Title"),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: "Event Date"),
              readOnly: true,
              onTap: _selectDate,
            ),
            DropdownButton<String>(
              value: _recurrence,
              items: [
                "NONE",
                "DAILY",
                "WEEKLY",
                "MONTHLY",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _recurrence = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : () => _createGroupEvent(context),
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text("Create"),
        ),
      ],
    );
  }
}
