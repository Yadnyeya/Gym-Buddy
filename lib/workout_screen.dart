import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Event data class
class Event {
  String title;
  DateTime date;
  TimeOfDay time;

  Event({required this.title, required this.date, required this.time});
}

// Main WorkoutScreen Widget
class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

// State class for WorkoutScreen
class _WorkoutScreenState extends State<WorkoutScreen> {
  Map<DateTime, List<Event>> _events = {};
  List<Event> _selectedEvents = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedEvents = _events[_selectedDay] ?? [];
  }

  // Method to handle day selection
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _events[selectedDay] ?? [];
    });
  }

  // Method to add or edit events
  void _addOrEditEvent({Event? event}) {
    final titleController = TextEditingController(text: event?.title);
    DateTime? selectedDate = event?.date;
    TimeOfDay? selectedTime = event?.time;

    // Show dialog for event details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event == null ? "Add New Event" : "Edit Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Event Title"),
            ),
            ElevatedButton(
              child: Text(selectedDate == null ? "Pick date" : selectedDate.toString().split(' ')[0]),
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2050)
                );
                if (pickedDate != null) {
                  selectedDate = pickedDate;
                }
              },
            ),
            ElevatedButton(
              child: Text(selectedTime == null ? "Pick time" : selectedTime!.format(context)),
              onPressed: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  selectedTime = pickedTime;
                }
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              final newEvent = Event(
                title: titleController.text,
                date: selectedDate!,
                time: selectedTime!
              );
              if (event == null) {
                // Add new event
                _events[newEvent.date] ??= [];
                _events[newEvent.date]!.add(newEvent);
              } else {
                // Update existing event
                event.title = newEvent.title;
                event.date = newEvent.date;
                event.time = newEvent.time;
                // Re-adding event to handle potential date change
                _events[event.date]!.remove(event);
                _events[newEvent.date]!.add(event);
              }
              Navigator.of(context).pop();
              setState(() {
                _selectedEvents = _events[_selectedDay] ?? [];
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildWelcomeSection(context),
            _buildSummaryCards(context),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.week,
              eventLoader: (day) => _events[day] ?? [],
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_selectedEvents[index].title),
                subtitle: Text('${_selectedEvents[index].time.format(context)}'),
                onTap: () => _addOrEditEvent(event: _selectedEvents[index]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditEvent(),
        child: Icon(Icons.add),
        tooltip: 'Add Event',
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
            radius: 30,
          ),
          Expanded(
            child: Text(
              'Welcome back!\nYour daily summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Today's achievements\nGreat progress!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard('Duration', '3 hours 30', Icons.access_time),
                _buildSummaryCard('Distance', '8.2 km', Icons.map),
                _buildSummaryCard('Heart Rate', '120 bpm', Icons.favorite),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData iconData) {
    return Column(
      children: [
        Icon(iconData, size: 48, color: Colors.orange),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}
