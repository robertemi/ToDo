import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task.dart';
import '../widgets/task_tile.dart';

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  final List<Task> tasks = [];
  final TextEditingController _controller = TextEditingController();

  /*

    Supabase DB methods

  */

  // used to diaplyed created tasks
  Future<PostgrestList> _getTasks() async {
    final supabaseClient = Supabase.instance.client;

    PostgrestList tasks = await supabaseClient.from('tasks').select();

    return tasks;
  }

  Future<void> _addTask(String taskName) async {
    final supabaseClient = Supabase.instance.client;

    await supabaseClient.from('tasks').insert({
      'name': taskName,
      'completed': false,
    });

    // update state to reflect recently added task
    setState(() {});
  }

  // index = index of the task in the list
  Future<void> _deleteTask(int id) async {
    final supabaseClient = Supabase.instance.client;

    await supabaseClient.from('tasks').delete().eq('id', id);

    setState(() {});
  }

  Future<void> _editTaskName(int id, String newName) async {
    final supabaseClient = Supabase.instance.client;

    await supabaseClient.from('tasks').update({'name': newName}).eq('id', id);

    setState(() {});
  }

  Future<void> _editTaskStatus(int id, bool newStatus) async {
    final supabaseClient = Supabase.instance.client;

    await supabaseClient
        .from('tasks')
        .update({'completed': newStatus})
        .eq('id', id);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const taskCompletedSnackBar = SnackBar(
      content: Text('Task completed!'),
      backgroundColor: Colors.greenAccent,
    );
    const taskUncompletedSnackBar = SnackBar(
      content: Text('Task marked as uncompleted!'),
      backgroundColor: Colors.redAccent,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("ToDo App")),
      body: FutureBuilder(
        future: _getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tasks yet"));
          }

          // convert PostgrestList into List<Task>
          final tasks = snapshot.data!
              .map((json) => Task.fromJson(json))
              .toList();

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return TaskTile(
                task: tasks[index],
                onChanged: (value) {
                  setState(() {
                    int taskId = tasks[index].id!;
                    _editTaskStatus(taskId, value!);
                  });
                  if (value == true) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(taskCompletedSnackBar);
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(taskUncompletedSnackBar);
                  }
                },
                onEdit: () {
                  String updatedName = tasks[index].name;

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Edit Task"),
                        content: TextField(
                          autofocus: true,
                          controller: TextEditingController(text: updatedName),
                          onChanged: (value) {
                            updatedName = value;
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (updatedName.trim().isNotEmpty) {
                                _editTaskName(tasks[index].id!, updatedName);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDelete: () {
                  int taskId = tasks[index].id!;
                  _deleteTask(taskId);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Add Task"),
              content: TextField(
                controller: _controller,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _addTask(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
