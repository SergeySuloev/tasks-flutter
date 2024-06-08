import 'package:flutter/material.dart';
import 'tasklib.dart';

void main() {
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
      home: TasksList(title: 'Tasks'),
    );
  }
}

// ignore: must_be_immutable
class TasksList extends StatefulWidget {
  final String title;
  List<Task> tasks = <Task>[];
  TasksList({super.key, required this.title});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  @override
  void initState() {
    super.initState();
  }

  void removeTask(int index) {
    setState(() {
      widget.tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (BuildContext context, int index) {
          var task = widget.tasks[index];
          return TaskCard(removeTask: () => removeTask(index), taskVar: task);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => const AddNewTask()),
          );
          if (result != null) {
            setState(() {
              widget.tasks.add(Task(taskString: result));
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
  final Task taskVar;
  const TaskCard({super.key, required this.removeTask, required this.taskVar});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  // ignore: prefer_const_constructors
  TextDecoration? strikeThrough;
  bool? isDoneVariable;

  @override
  void initState() {
    super.initState();
    isDoneVariable = widget.taskVar.isDone;
    strikeThrough = isDoneVariable! ? TextDecoration.lineThrough : null;
  }

  void _toggleTask() {
    setState(() {
      widget.taskVar.toggleTask();
      isDoneVariable = widget.taskVar.isDone;
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

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                  builder: (context) => TaskFullView(taskVar: widget.taskVar)));
          if (result != null) {
            setState(() => widget.taskVar.editTask(result));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Checkbox(
                checkColor: theme.colorScheme.onPrimaryContainer,
                value: isDoneVariable,
                onChanged: (bool? value) {
                  _toggleTask();
                },
              ),
              Expanded(
                child: Text(
                  widget.taskVar.taskString,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: MediaQuery.of(context).size.height ~/ 100,
                ),
              ),
              ElevatedButton(
                  onPressed: widget.removeTask, child: const Icon(Icons.remove))
            ],
          ),
        ),
      ),
    );
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
  final Task taskVar;
  const TaskFullView({super.key, required this.taskVar});

  @override
  State<TaskFullView> createState() => _TaskFullViewState();
}

class _TaskFullViewState extends State<TaskFullView> {
  final _formKey = GlobalKey<FormState>();
  var _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.taskVar.taskString);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
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
                      child: const Text('Edit task'))
                ],
              ),
            ),
          ),
        ));
  }
}
