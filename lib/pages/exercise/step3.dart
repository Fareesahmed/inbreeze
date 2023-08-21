import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inner_breeze/components/animated_circle.dart';
import 'shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class Step3Page extends StatefulWidget {
  Step3Page({super.key});

  @override
  State<Step3Page> createState() => _Step3PageState();
}


class _Step3PageState extends State<Step3Page> {
  int volume = 80;
  int countdown = 30;
  int rounds = 1;
  Duration tempoDuration = Duration(seconds: 2);
  String innerText= 'in';

  Timer? breathCycleTimer;

  @override
  void initState() {
    super.initState();
    _loadDataFromPreferences();    
    startBreathCounting();

  }
  
  Future<void> _loadDataFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      volume = prefs.getInt('volume') ?? 80;
      rounds = prefs.getInt('rounds') ?? 1;
    });
  }

  void _navigateToNextExercise() async{
    rounds += 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('rounds', rounds);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/exercise/step1');
    });
  }

  void startBreathCounting() {
    breathCycleTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        print('tickr ${timer.tick}');
        if (timer.tick < 2) {
          // 'in' phase
          innerText = 'in';
        } else if ( timer.tick < 17) {
          // Countdown phase
          innerText = (17 - timer.tick).toString();
        } else if (timer.tick >= 15 && timer.tick < 18) {
          // 'out' phase
          innerText = 'out';
        } else {
          // Completion
          timer.cancel();
          _navigateToNextExercise();
        }
      });
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Recovery',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AnimatedCircle(
                volume: volume,
                tempoDuration: tempoDuration,
                innerText: innerText,
                controlCallback: () {
                  if (innerText == 'in') {
                    return 'forward';
                  }
                  else if (innerText == 'out') {
                    return 'reverse';
                  }
                  else {
                    return 'stop';
                  }
                },

              ),
              SizedBox(height: 200),
              StopSessionButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    breathCycleTimer?.cancel();

    super.dispose();
  }
}