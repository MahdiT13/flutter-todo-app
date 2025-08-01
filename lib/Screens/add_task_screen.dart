import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/models/todo.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _notesController = TextEditingController();
  TaskCategory _selectedCategory = TaskCategory.todo;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _titleController = TextEditingController();

  void _saveTask() {
    final task = Task(
      title: _titleController.text,
      notes: _notesController.text,
      category: _selectedCategory,
      time: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    );
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff5faeb6),
      appBar: AppBar(
        title: Text(
          'Add New Task',
          style: GoogleFonts.caudex(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff5faeb6),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: TaskCategory.values.map((cat) {
                  IconData icon;
                  switch (cat) {
                    case TaskCategory.todo:
                      icon = Icons.book;
                      break;
                    case TaskCategory.workout:
                      icon = Icons.fitness_center;
                      break;
                    case TaskCategory.event:
                      icon = Icons.celebration;
                      break;
                  }
                  return IconButton(
                    icon: Icon(
                      icon,
                      color: _selectedCategory == cat
                          ? Colors.black
                          : Colors.white,
                    ),
                    onPressed: () => setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),
              ListTile(
                title: Text(
                  'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  style: GoogleFonts.caudex(fontSize: 20),
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.black),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              ListTile(
                title: Text(
                  'Time: ${_selectedTime.format(context)}',
                  style: GoogleFonts.caudex(fontSize: 20),
                ),
                trailing: Icon(Icons.access_time, color: Colors.black),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) setState(() => _selectedTime = time);
                },
              ),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Notes'),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  border: Border(
                    top: BorderSide(color: Color(0xff323a45), width: 1),
                    bottom: BorderSide(color: Color(0xff323a45), width: 5),
                    left: BorderSide(color: Color(0xff323a45), width: 2),
                    right: BorderSide(color: Color(0xff323a45), width: 2),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff3f6184),
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.02,
                      horizontal: MediaQuery.of(context).size.width * 0.06,
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.caudex(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
