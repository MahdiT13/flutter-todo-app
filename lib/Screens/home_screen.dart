import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/widgets/todo_items.dart';
import 'add_task_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      backgroundColor: const Color(0xff3f6184),
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
        backgroundColor: const Color(0xff3f6184),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          height: 700,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: const Color(0xff5faeb6),
            border: Border.all(color: const Color(0xff323a45), width: 6),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                "Today - ${DateTime.now().toLocal().toString().split(' ')[0]}",
                style: GoogleFonts.caudex(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.black, indent: 55, endIndent: 50),
              Expanded(
                child: ListView(
                  children: [
                    ...pending.map(
                      (task) => Dismissible(
                        key: ValueKey(task.id),
                        crossAxisEndOffset: -1,
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        onDismissed: (_) {
                          _deleteTask(task);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task deleted')),
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
                        padding: const EdgeInsets.all(8.0),
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
                          direction: DismissDirection.endToStart,
                          crossAxisEndOffset: -1,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            _deleteTask(task);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Task deleted')),
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
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: const Border(
                      top: BorderSide(color: Color(0xff323a45), width: 1),
                      bottom: BorderSide(color: Color(0xff323a45), width: 5),
                      left: BorderSide(color: Color(0xff323a45), width: 2),
                      right: BorderSide(color: Color(0xff323a45), width: 2),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3f6184),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                    ),
                    child: Text(
                      'Add New Task',
                      style: GoogleFonts.caudex(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTaskScreen(),
                        ),
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
    );
  }
}
