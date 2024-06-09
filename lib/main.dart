import 'dart:async';
import 'package:flutter/material.dart';
import 'tasklib.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(const TaskAppHomescreen());
}

class TaskAppHomescreen extends StatelessWidget {
  const TaskAppHomescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const TasksList(title: 'Tasks'),
    );
  }
}

class TasksList extends StatefulWidget {
  final String title;
  const TasksList({super.key, required this.title});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  late Completer<List<int>> taskKeysCompleter;

  void completeKeysCompleter() {
    taskKeysCompleter = Completer<List<int>>();
    taskKeysCompleter.complete(getAllTaskKeys());
  }

  @override
  void initState() {
    super.initState();
    completeKeysCompleter();
  }

  Future<void> removeTask(int taskKey) async {
    await removeTaskFromDB(taskKey);
    completeKeysCompleter();
    setState(() {});
  }

  Future<void> toggleTask(int taskKey) async {
    await toggleTaskInHive(taskKey);
    completeKeysCompleter();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<int>>(
          future: taskKeysCompleter.future,
          builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final taskIndex = snapshot.data![index];
                  return FutureBuilder<Task?>(
                    future: getTask(taskIndex),
                    builder:
                        (BuildContext context, AsyncSnapshot<Task?> snapshot) {
                      if (snapshot.hasData) {
                        return TaskCard(
                          removeTask: () async {
                            await removeTask(taskIndex);
                          },
                          toggleTask: () async {
                            await toggleTask(taskIndex);
                          },
                          taskKey: taskIndex,
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => const AddNewTask()),
          );
          if (result != null) {
            setState(() {
              final newTask = Task(taskString: result);
              addTaskToDB(newTask);
              completeKeysCompleter();
            });
          }
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatefulWidget {
  final VoidCallback removeTask;
  final VoidCallback toggleTask;
  final int taskKey;
  const TaskCard(
      {super.key,
      required this.removeTask,
      required this.taskKey,
      required this.toggleTask});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  // ignore: prefer_const_constructors
  TextDecoration? strikeThrough;
  bool? isDoneVariable;
  late Future<Task?> task;
  late Task taskVar;

  @override
  void initState() {
    super.initState();
    taskCreator();
  }

  Future<void> taskCreator() async {
    task = getTask(widget.taskKey);
    taskVar = (await task)!;
    setState(() {
      isDoneVariable = taskVar.isDone;
      strikeThrough = isDoneVariable! ? TextDecoration.lineThrough : null;
    });
  }

  void _toggleTask() {
    setState(() {
      widget.toggleTask();
      isDoneVariable = taskVar.isDone;
      strikeThrough = isDoneVariable! ? TextDecoration.lineThrough : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var textStyle = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimaryContainer);

    textStyle =
        textStyle.copyWith(fontSize: MediaQuery.of(context).size.width * 0.05);
    textStyle = textStyle.copyWith(decoration: strikeThrough);

    return FutureBuilder<Task?>(
        future: task,
        builder: (BuildContext context, AsyncSnapshot<Task?> snapshot) {
          if (snapshot.hasData) {
            return Card(
              color: theme.colorScheme.primaryContainer,
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TaskFullView(taskKey: widget.taskKey)));
                  if (result != null) {
                    await editTaskInHive(widget.taskKey, result);
                    setState(() {});
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Checkbox(
                        tristate: true,
                        checkColor: theme.colorScheme.onPrimaryContainer,
                        value: isDoneVariable,
                        onChanged: (bool? value) {
                          _toggleTask();
                        },
                      ),
                      Expanded(
                        child: Text(
                          taskVar.taskString,
                          style: textStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: MediaQuery.of(context).size.height ~/ 100,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: widget.removeTask,
                          child: const Icon(Icons.remove))
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class AddNewTask extends StatefulWidget {
  const AddNewTask({super.key});

  @override
  State<AddNewTask> createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.3,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(labelText: 'Task'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _focusNode.unfocus();
                      Navigator.pop(context, _controller.text);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskFullView extends StatefulWidget {
  final int taskKey;
  const TaskFullView({super.key, required this.taskKey});

  @override
  State<TaskFullView> createState() => _TaskFullViewState();
}

class _TaskFullViewState extends State<TaskFullView> {
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  var _controller = TextEditingController();
  late Future<Task?> task;

  @override
  void initState() {
    super.initState();
    initTask();
    _focusNode.requestFocus();
  }

  Future<void> initTask() async {
    task = getTask(widget.taskKey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Task?>(
        future: task,
        builder: (BuildContext context, AsyncSnapshot<Task?> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              _controller.text = snapshot.data!.taskString;
            } else {
              _controller = TextEditingController();
            }
            return Scaffold(
                appBar: AppBar(title: const Text('Edit task')),
                body: Center(
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    height: MediaQuery.sizeOf(context).height * 0.3,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            focusNode: _focusNode,
                            controller: _controller,
                            decoration:
                                const InputDecoration(labelText: 'Task'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a task';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _focusNode.unfocus();
                                  Navigator.pop(context, _controller.text);
                                }
                              },
                              child: const Text('Edit task'))
                        ],
                      ),
                    ),
                  ),
                ));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
