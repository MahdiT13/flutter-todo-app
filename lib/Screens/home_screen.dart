import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/widgets/todo_items.dart';
import 'add_task_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _firestore.collection('tasks').snapshots().listen((snapshot) {
      final updatedTasks = snapshot.docs.map((doc) {
        return Task.fromMap(doc.data(), doc.id);
      }).toList();
      setState(() {
        tasks = updatedTasks;
      });
    });
  }

  void _addTask(Task task) async {
    final doc = await _firestore.collection('tasks').add(task.toMap());
    final newTask = Task(
      id: doc.id,
      title: task.title,
      category: task.category,
      time: task.time,
      notes: task.notes,
      isDone: task.isDone,
    );
    setState(() {
      tasks.add(newTask);
    });
  }

  void _toggleDone(Task task) async {
    task.isDone = !task.isDone;
    await _firestore.collection('tasks').doc(task.id).update({
      'isDone': task.isDone,
    });
    setState(() {});
  }

  void _deleteTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).delete();
    setState(() {
      tasks.remove(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((t) => t.isDone).toList();
    final pending = tasks.where((t) => !t.isDone).toList();

    return Scaffold(
      backgroundColor: Color(0xff3f6184),
      appBar: AppBar(
        title: Text(
          'My Todo List',
          style: GoogleFonts.caudex(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff3f6184),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color(0xff5faeb6),
              border: Border.all(
                color: Color(0xff323a45),
                width: MediaQuery.of(context).size.width * 0.02,
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "Today - ${DateTime.now().toLocal().toString().split(' ')[0]}",
                  style: GoogleFonts.caudex(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(color: Colors.black, indent: 55, endIndent: 50),
                Expanded(
                  child: ListView(
                    children: [
                      ...pending.map(
                        (task) => Dismissible(
                          key: ValueKey(task.id),
                          crossAxisEndOffset: -1,
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          onDismissed: (_) {
                            _deleteTask(task);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Task deleted')),
                            );
                          },
                          child: Column(
                            children: [
                              TaskCard(
                                task: task,
                                onToggle: () => _toggleDone(task),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (completed.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Completed (Swipe to delete)',
                            style: GoogleFonts.caudex(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...completed.map(
                          (task) => Dismissible(
                            key: ValueKey(task.id),
                            direction: DismissDirection.startToEnd,
                            crossAxisEndOffset: -1,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.red,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              _deleteTask(task);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Task deleted')),
                              );
                            },
                            child: TaskCard(
                              task: task,
                              onToggle: () => _toggleDone(task),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border(
                        top: BorderSide(color: Color(0xff323a45), width: 1),
                        bottom: BorderSide(color: Color(0xff323a45), width: 5),
                        left: BorderSide(color: Color(0xff323a45), width: 2),
                        right: BorderSide(color: Color(0xff323a45), width: 2),
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff3f6184),
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                          horizontal: MediaQuery.of(context).size.width * 0.07,
                        ),
                      ),
                      child: Text(
                        'Add New Task',
                        style: GoogleFonts.caudex(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddTaskScreen()),
                        );
                        if (result != null && result is Task) {
                          _addTask(result);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
