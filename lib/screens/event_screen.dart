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

    DateTime eventDate = DateTime.parse(_dateController.text);
    String isoDate = eventDate.toUtc().toIso8601String();

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
      _descController.clear();
      _dateController.clear();
      await eventProvider.fetchPersonalEvents(auth.token!);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event creation failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text("Create Event"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading Tile
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 20),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(Icons.event_note,
                          color: theme.colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Plan your next reminder",
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Event Details Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Event Title",
                        prefixIcon: Icon(Icons.title_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Event Date",
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _recurrence,
                      items: ["NONE", "DAILY", "WEEKLY", "MONTHLY","YEARLY"]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: "Recurrence",
                        prefixIcon: Icon(Icons.repeat_outlined),
                      ),
                      onChanged: (v) => setState(() => _recurrence = v!),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Action Button Tile
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.colorScheme.primary,
              elevation: 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: isLoading ? null : () => _createEvent(context),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Create Event",
                            style: theme.textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
