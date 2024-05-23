import 'package:flutter/material.dart';
import 'dart:async';
import 'package:terp_to_do/todo.dart';
import 'package:provider/provider.dart';
import 'package:terp_to_do/main.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TimerPage extends StatefulWidget {
  final Todo todo;
  TimerPage({required this.todo});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  bool _isEnabled = true;
  int _minutes = 0;
  int _secondsRemaining = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer.cancel();
      WakelockPlus.disable();
    }
  }

  void _startTimer() {
    _isEnabled = !_isEnabled;
    _secondsRemaining = _minutes * 60;
    WakelockPlus.enable();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          widget.todo.timeCompleted += _minutes;
          _isEnabled = !_isEnabled;
          Provider.of<TerpState>(context, listen: false)
              .updateCompletedTime(widget.todo);
          WakelockPlus.disable();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Timer'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter minutes'),
                onChanged: (value) {
                  setState(() {
                    _minutes = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _isEnabled ? _startTimer : null,
                child: const Text(
                  "Start Timer",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Time Remaining: ",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "${(_secondsRemaining / 60).floor()} minutes ${(_secondsRemaining % 60)} seconds",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Time Completed:",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "${widget.todo.timeCompleted} minutes",
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ));
  }
}
