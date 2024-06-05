import 'package:flutter/material.dart';
import 'tasklib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskWidget extends StatefulWidget {
  final Task taskVar;

  const TaskWidget({super.key, required this.taskVar});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
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
        .copyWith(color: theme.colorScheme.onPrimary);

    textStyle = textStyle.copyWith(decoration: strikeThrough);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Checkbox(
              value: isDoneVariable,
              onChanged: (bool? value) {
                _toggleTask();
              },
            ),
            Text('test', style: textStyle),
          ],
        ),
      ),
    );
  }
}
