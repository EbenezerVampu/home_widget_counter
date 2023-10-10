import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidget.setAppGroupId('group.es.antonborri.homeWidgetCounter');
  await HomeWidget.registerInteractivityCallback(interactiveCallback);
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? uri) async {
  await HomeWidget.setAppGroupId('group.es.antonborri.homeWidgetCounter');

  if (uri?.host == 'increment') {
    await _increment();
  } else if (uri?.host == 'clear') {
    await _clear();
  }
}

const _countKey = 'counter';
Future<int> get _value async {
  final value = await HomeWidget.getWidgetData<int>(_countKey, defaultValue: 0);
  return value!;
}

Future<int> _increment() async {
  final oldValue = await _value;
  final newValue = oldValue + 1;
  await _sendAndUpdate(newValue);
  return newValue;
}

Future<void> _clear() async {
  await _sendAndUpdate(null);
}

Future<void> _sendAndUpdate([int? value]) async {
  await HomeWidget.saveWidgetData(_countKey, value);
  await HomeWidget.updateWidget(
    iOSName: 'CounterWidget',
    androidName: 'CounterWidgetProvider',
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home_Screen Demo',
      theme: ThemeData.light(
        useMaterial3: false,
      ),
      home: const MyHomePage(title: 'Flutter Home_Screen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _incrementCounter() async {
    await _increment();
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
            ),
            FutureBuilder<int>(
              future: _value,
              builder: (_, snapshot) => Text(
                (snapshot.data ?? 0).toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            TextButton(
              onPressed: () async {
                await _clear();
                setState(() {});
              },
              child: const Text('Back'),
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
