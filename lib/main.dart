import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leak_tracker/leak_tracker.dart';

/// Main
void main() {
  enableLeakTracking(
    config: const LeakTrackingConfiguration(
      stackTraceCollectionConfig: StackTraceCollectionConfig(
        collectStackTraceOnStart: true,
      ),
    ),
  );

  MemoryAllocations.instance.addListener(
    (event) => dispatchObjectEvent(
      event.toMap(),
    ),
  );

  runApp(
    const MaterialApp(
      home: MainPage(),
    ),
  );
}

/// UI
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _showContainer = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_showContainer)
            Positioned(
              left: 60,
              top: 120,
              right: 60,
              child: Container(
                color: Colors.lightGreen,
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: CustomStatefulWidget(),
                ),
              ),
            ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  color: Colors.redAccent,
                  onPressed: _onToggleLeakingContainer,
                  child: const Text(
                    'Toggle container',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 32),
                MaterialButton(
                  color: Colors.blueAccent,
                  onPressed: _onIncreaseLeakingObject,
                  child: const Text(
                    'Increase leaking objects',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onToggleLeakingContainer() => setState(() {
        _showContainer = !_showContainer;
      });

  void _onIncreaseLeakingObject() {
    for (var i = 0; i < 10000000; i++) {
      var obj = LeakObject('Id: $i');
      Singleton().addLeakObject(obj);
    }
  }
}

class CustomStatefulWidget extends StatefulWidget {
  const CustomStatefulWidget({Key? key}) : super(key: key);

  @override
  State<CustomStatefulWidget> createState() => _CustomStatefulWidgetState();
}

class _CustomStatefulWidgetState extends State<CustomStatefulWidget>
    with DisposableMixin {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Leaking container',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w700),
    );
  }

  @override
  List<ChangeNotifier> get disposables => [
        _textEditingController,
      ];
}

/// Mixin
mixin DisposableMixin<T extends StatefulWidget> on State<T> {
  // ignore: prefer_final_fields
  List<ChangeNotifier> get disposables;

  @override
  void dispose() {
    for (final disposable in disposables) {
      // Disabled for DEMO purposes
      // disposable.dispose();
    }

    super.dispose();
  }
}

/// Other
class LeakObject {
  final String id;

  LeakObject(this.id);
}

class Singleton {
  static final Singleton _singleton = Singleton._internal();
  final List<LeakObject> _leakObjects = [];

  factory Singleton() {
    return _singleton;
  }

  Singleton._internal();

  void addLeakObject(LeakObject obj) {
    _leakObjects.add(obj);
  }
}
