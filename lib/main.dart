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

enum Recurrence { none, daily, weekly, monthly }

class Task {
  final String title;
  final DateTime? deadline;
  final Recurrence recurrence;
  DateTime? nextDue;

  Task({
    required this.title,
    this.deadline,
    this.recurrence = Recurrence.none,
    this.nextDue,
  });

  Task copyWith({DateTime? nextDue}) {
    return Task(
      title: title,
      deadline: deadline,
      recurrence: recurrence,
      nextDue: nextDue,
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  TasksScreenState createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> {
  final List<Task> tasks = [];
  final List<Task> completedTasks = [];

  @override
  void initState() {
    super.initState();
    _startReappearanceChecker();
  }

  void _addTask(String title, DateTime? deadline, Recurrence recurrence) {
    setState(() {
      tasks.add(Task(
        title: title,
        deadline: deadline,
        recurrence: recurrence,
        nextDue: _calculateNextDueDate(deadline, recurrence),
      ));
      _sortTasks();
    });
  }

  void _markTaskAsCompleted(int index) {
    final task = tasks[index];
    setState(() {
      if (task.recurrence == Recurrence.none) {
        completedTasks.add(task);
      } else {
        tasks[index] = task.copyWith(
          nextDue: _calculateNextDueDate(task.nextDue, task.recurrence),
        );
      }
      tasks.removeWhere((t) => t.nextDue?.isBefore(DateTime.now()) ?? false);
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
      if (a.nextDue == null && b.nextDue == null) return 0;
      if (a.nextDue == null) return -1;
      if (b.nextDue == null) return 1;
      return a.nextDue!.compareTo(b.nextDue!);
    });
  }

  DateTime? _calculateNextDueDate(DateTime? currentDate, Recurrence recurrence) {
    if (currentDate == null) return null;
    switch (recurrence) {
      case Recurrence.daily:
        return currentDate.add(const Duration(days: 1));
      case Recurrence.weekly:
        return currentDate.add(const Duration(days: 7));
      case Recurrence.monthly:
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
          currentDate.hour,
          currentDate.minute,
        );
      case Recurrence.none:
      default:
        return null;
    }
  }

  void _startReappearanceChecker() {
    Future.delayed(const Duration(minutes: 1), () {
      setState(() {
        final now = DateTime.now();
        for (var i = 0; i < tasks.length; i++) {
          if (tasks[i].nextDue != null && tasks[i].nextDue!.isBefore(now)) {
            tasks[i] = tasks[i].copyWith(
              nextDue: _calculateNextDueDate(tasks[i].nextDue, tasks[i].recurrence),
            );
          }
        }
      });
      _startReappearanceChecker();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Tasks Clone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear Completed Tasks',
            onPressed: _clearCompletedTasks,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (tasks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No tasks yet!'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    visualDensity: const VisualDensity(vertical: 4),
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: Radio<int>(
                        value: index,
                        groupValue: null,
                        onChanged: (_) {
                          _markTaskAsCompleted(index);
                        },
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: task.deadline != null
                        ? Text(
                            'Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(task.deadline!)}',
                            style: const TextStyle(fontSize: 16),
                          )
                        : null,
                  );
                },
              ),
          ],
        ),
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
    Recurrence selectedRecurrence = Recurrence.none;

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
              const SizedBox(height: 10),
              DropdownButton<Recurrence>(
                value: selectedRecurrence,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRecurrence = value;
                    });
                  }
                },
                items: Recurrence.values.map((recurrence) {
                  return DropdownMenuItem<Recurrence>(
                    value: recurrence,
                    child: Text(recurrence.name.toUpperCase()),
                  );
                }).toList(),
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
                  _addTask(newTask, selectedDeadline, selectedRecurrence);
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