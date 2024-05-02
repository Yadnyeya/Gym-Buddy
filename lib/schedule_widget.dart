import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleWidget extends StatefulWidget {
  @override
  _ScheduleWidgetState createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Event>> _selectedEvents = {};  // Initialize as empty map.

  @override
  void initState() {
    super.initState();
    // You can also initialize _selectedEvents here if preferred
    // _selectedEvents = {};
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _selectedEvents[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: _getEventsForDay,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _getEventsForDay(_selectedDay).length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_getEventsForDay(_selectedDay)[index].title),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Event {
  final String title;

  Event(this.title);
}
