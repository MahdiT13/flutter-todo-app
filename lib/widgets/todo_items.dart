import 'package:flutter/material.dart';
import 'package:todoapp/models/todo.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const TaskCard({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = task.isDone ? Colors.green.shade100 : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black54, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: task.isDone,
                onChanged: (_) => onToggle(),
                activeColor: Colors.teal,
              ),
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.caudex(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.category.name.toUpperCase(),
                  style: GoogleFonts.caudex(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.teal.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (task.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(task.notes, style: GoogleFonts.caudex(fontSize: 16)),
            ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              "Time: ${task.time.toLocal().toString().substring(0, 16)}",
              style: GoogleFonts.caudex(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
