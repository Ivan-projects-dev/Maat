import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const TasksApp());
}

class TasksApp extends StatelessWidget {
  const TasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Tasks Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TasksScreen(),
    );
  }
}

class Task {
  final String title;
  final DateTime? deadline;

  Task({required this.title, this.deadline});
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  TasksScreenState createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> {
  final List<Task> tasks = [];
  final List<Task> completedTasks = [];

  void _addTask(String title, DateTime? deadline) {
    setState(() {
      tasks.add(Task(title: title, deadline: deadline));
      _sortTasks();
    });
  }

  void _markTaskAsCompleted(int index) {
    setState(() {
      completedTasks.add(tasks[index]);
      tasks.removeAt(index);
      _sortTasks();
    });
  }

  void _clearCompletedTasks() {
    setState(() {
      completedTasks.clear();
    });
  }

  void _sortTasks() {
    tasks.sort((a, b) {
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return -1; // Tasks without deadlines appear first.
      if (b.deadline == null) return 1;
      return a.deadline!.compareTo(b.deadline!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Completed Tasks',
            onPressed: _clearCompletedTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text('No tasks yet!'),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        leading: Radio<int>(
                          value: index,
                          groupValue: null, // Set to null since we're not grouping
                          onChanged: (_) {
                            _markTaskAsCompleted(index);
                          },
                        ),
                        title: Text(task.title),
                        subtitle: task.deadline != null
                            ? Text(
                                'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(task.deadline!)}',
                              )
                            : null,
                      );
                    },
                  ),
          ),
          if (completedTasks.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Completed Tasks:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = completedTasks[index];
                    return ListTile(
                      title: Text(
                        task.title,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: task.deadline != null
                          ? Text(
                              'Completed: ${DateFormat('yyyy-MM-dd HH:mm').format(task.deadline!)}',
                            )
                          : null,
                    );
                  },
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog() {
    String newTask = '';
    DateTime? selectedDeadline;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newTask = value;
                },
                decoration: const InputDecoration(hintText: 'Enter task'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      selectedDeadline = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    }
                  }
                },
                child: const Text('Select Deadline'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newTask.isNotEmpty) {
                  _addTask(newTask, selectedDeadline);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}