// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable
import 'dart:async';
import 'dart:math';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<StatefulWidget> with TickerProviderStateMixin {
  String tempdate = DateFormat.yMMMMd().format(new DateTime.now());
  
  String data = '';
  List<String> notes = [];
  loadNotesFile() async {
    String note;
    note = await rootBundle.loadString('assets/notesFile.txt');

    setState(() {
      data = note;
      notes = data.split('\n');
    });
  }

  late SharedPreferences _prefs;
  String _displayText = 'Нажмите кнопку, чтобы начать.';
  String timerThick = 'Получить';
  bool timerIsOn = false;  

  Color _buttonColor = Color(0xFF8300FF); 
  

  void _loadData() async {
    _prefs = await SharedPreferences.getInstance(); 
    setState(() {
      _displayText = _prefs.getString('displayText') ?? _displayText;
      timerThick = _prefs.getString('timerThick') ?? timerThick;
      timerIsOn = _prefs.getBool('timerIsOn') ?? false;
      if (timerIsOn == true){
        _buttonColor = Color(0xFF7B727E);
        startTimer();
      }     
    });
  }


  @override
  void initState() {
    loadNotesFile();
    super.initState();
    _loadData();
  }

  var currentindex = 0;


  var tempTime;

  void buttonCliked() {
    print(tempdate);
    tempTime = DateTime.parse(DateTime.now().toString());
    // int hours = 24;
    // int minutes = 0;
    // int seconds = 0;
    if (timerIsOn == false) {
      setState(() {
        _buttonColor = Color(0xFF7B727E);
        currentindex = Random().nextInt(notes.length);

        _displayText = notes[currentindex];
        _prefs.setString('displayText', _displayText);
        startTimer();
      });
      timerIsOn = true;
      _prefs.setBool('timerIsOn', timerIsOn);
      
    }

    print(notes.length);
    print(data);
  }

  void startTimer() { //реализация отсчёта до 00:00 (кнопка обновляется каждый в 00:00 каждого дня)
    const oneSec = const Duration(seconds: 1);
    Timer _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        String toString(x) {
          String xString;
          if (x < 10) {
            xString = "0" + x.toString();
          } else {
            xString = x.toString();
          }
          return xString;
        }
        var tempTimeForParse = DateTime.now().toString();
        var tempTime = DateTime.parse(tempTimeForParse);
        if (tempTime.hour != 0 || tempTime.minute != 0 || tempTime.second != 0 ){
          setState(() {
            timerThick = "${toString(tempTime.hour) } : ${toString(tempTime.minute)} : ${toString(tempTime.second)}"; //22:21:06
            _prefs.setString('timerThick', timerThick);
          });
        } else {
          timeIsOver();
          timer.cancel();
        }    
      },
    );
  }
  // void startTimer(int h, int m, int s) { //реализация обратного отсчёта (кнопка обновляется каждый 24 часа)
  //   const oneSec = const Duration(seconds: 1);
  //   Timer _timer = new Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       String toString(x) {
  //         String xString;
  //         if (x < 10) {
  //           xString = "0" + x.toString();
  //         } else {
  //           xString = x.toString();
  //         }
  //         return xString;
  //       }
  //       if (s != 0) {
  //         s--;
  //         setState(() {
  //         timerThick = toString(h) + " : " + toString(m) + " : " + toString(s);
  //         });
  //       } else {
  //         //seconds = 0
  //         if (m != 0) {
  //           m--;
  //           s = 59;
  //           setState(() {
  //             timerThick = toString(h) + " : " + toString(m) + " : " + toString(s);
  //           });
  //         } else {
  //           //minutes = 0
  //           if (h != 0) {
  //             h--;
  //             m = 59;
  //             s = 59;
  //             setState(() {
  //             timerThick = toString(h) + " : " + toString(m) + " : " + toString(s);
  //             });
  //           } else {
  //             timeIsOver();
  //             timer.cancel();
  //           }
  //         }
  //       }
  //     },
  //   );
  // }

  void timeIsOver(){
    setState(() {
      _buttonColor = Color(0xFF8300FF);
      timerThick = 'Получить';
      _prefs.setString('timerThick', timerThick);
      timerIsOn = false;
      _prefs.setBool('timerIsOn', timerIsOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
          baseColor: Color(0xFFFFFDDE),
          spawnMaxRadius: 2,
          spawnMinSpeed: 3.50,
          particleCount: 50,
          spawnMaxSpeed: 20,
          minOpacity: 0.1,
          spawnOpacity: 0.1,
        )),
        vsync: this,
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Text(tempdate,
                      style: TextStyle(
                        color: Color(0xFFFFFDDE),
                        fontSize: 26,
                        fontFamily: 'Lora',
                      ))
                ],
                mainAxisAlignment: MainAxisAlignment
                    .center, //Center Row contents horizontally,
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: ExactAssetImage("assets/images/circle.png"),
                            fit: BoxFit.cover)),
                    width: 350,
                    height: 400,
                    margin: EdgeInsets.symmetric(vertical: 50.0),
                    child: Center(
                      child: Container(
                        width: 200,
                        child: Text(_displayText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF04003C),
                              fontSize: 16,
                              fontFamily: 'Lora',
                            )),
                      ),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 60.0),
        child: ElevatedButton(
          onPressed: buttonCliked,
          child: Text(
            timerThick,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Lora',
            ),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 1,
            backgroundColor: _buttonColor,
            foregroundColor: Color(0xFFFFFDDE),
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 60.0),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}