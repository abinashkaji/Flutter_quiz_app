import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:security_plus/animation.dart';
import 'dart:async';
import 'package:security_plus/flash_question.dart';
import 'package:security_plus/main.dart';
import 'package:security_plus/timer.dart';
import 'package:sqflite/sqflite.dart';

class FlashcardApp extends StatefulWidget {
  final int numberOfCards;
  FlashcardApp(this.numberOfCards);
  @override
  _FlashcardAppState createState() => _FlashcardAppState();
}
class _FlashcardAppState extends State<FlashcardApp> {     
  int _numberOfCards=5;
  int _currentIndex = 100+Random().nextInt(20), last_flip=0;
  bool _showAnswer = false, _auto=false,_next_click=false;
  Timer? _timer;
  int _time_flash=5,time=3;
  int count=0;
  List<Flashcard> _flashcards = flash_question_load();
   Future<Database>? database;
   List <int> numbers=[];
   
    @override
  void initState() {
    super.initState();
    initializeDatabase();
   // _startTimer();
  }

  Future<void> initializeDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(await getDatabasesPath(), 'quiz_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE flashcard(id INTEGER PRIMARY KEY, flash_id INTEGER)',
        );
      },
      version: 1,
    );

  List<int> fetchedNumbers = await getNumbers();
    setState(() {
      numbers.addAll(fetchedNumbers);
      print("success");
    });    
  }

//get list of watched flashcard numbers
  Future<List<int>> getNumbers() async {
    final Database? db = await database;
//    await db?.insert(      'numbers',      {'number': 11},      conflictAlgorithm: ConflictAlgorithm.replace,    );
    final List<Map<String, dynamic>> maps = await db?.query('flashcard')??[];
    return List.generate(maps.length, (i) {
      //print(maps[i]['flash_id']);
      return maps[i]['flash_id'];
    });
  }
// set timer in autoplay 
  Future<void> _getTimeInput() async {
    return showDialog<void>(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Flashcard Autoplay Time'),

          content: TextField(
//            autofocus: true,
            autofillHints: ["3"],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Time in seconds (minimum 3)'),
            onChanged: (value) {
              setState(() {
                time = int.tryParse(value) ?? 10; // Convert input to integer
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
//                  _auto=!_auto;
                  _time_flash=time;
                });
                _autoPlay();
              },
            ),
          ],
        );
      },
    );
  }


  
Future<bool> _checkquestion(int number) async {
   final Database? db = await database;
     final List<Map<String, dynamic>> existingNumbers = await db?.query(
      'flashcard',
      where: 'flash_id = ?',
      whereArgs: [number],
    )??[];
  return  existingNumbers.isEmpty;
}
  void _nextFlashcard()
  {
    setState(() {
      _next_click=true;
    //  _auto=false;
    });
    _nextFlash();
  
  }

  void _nextFlash() async{
    _currentIndex = (_currentIndex +1) % _flashcards.length;
    if (await _checkquestion( _currentIndex)){
         setState(() {
      _showAnswer = false;
      _currentIndex = _currentIndex;
    });
    }
     else{
          print("skipped flashcard id ${_currentIndex}");
          _nextFlash();
          }
}

  void _next_20Flashcard() {
    setState(() {
      _showAnswer = false;
      _currentIndex = (_currentIndex + 20) % _flashcards.length;
    });
  }

  void _next_Randomcard() {
    setState(() {
      _showAnswer = false;
      _currentIndex = (_currentIndex + Random().nextInt(_flashcards.length) ) % _flashcards.length;
    });
  }

  void _previousFlashcard() {
    setState(() {
      _showAnswer = false;
      _currentIndex = (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
    });
    //print(_auto);
  }

  Future<void> insertNumber(int number) async {
    final Database? db = await database;
     final List<Map<String, dynamic>> existingNumbers = await db?.query(
      'flashcard',
      where: 'flash_id = ?',
      whereArgs: [number],
    )??[];
 if (existingNumbers.isEmpty) {
    await db?.insert(
      'flashcard',
      {'flash_id': number},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    }
  }

void _autoPlay() {
    setState(() {
    _auto=!_auto;
  });
auto();
}

void auto() async{
  _time_flash=_time_flash>3?_time_flash:3;
  for(;_auto ;){
    await Future.delayed( Duration(seconds: _time_flash));
    setState(() {
      _showAnswer = !_showAnswer;
    });
    await Future.delayed( Duration(seconds: _time_flash));
    _showAnswer = false;
    _nextFlash();
  }
}

  void _flipCard() {
    if(!_auto & _next_click) {insertNumber(_currentIndex);
    print(_currentIndex);
     }//await db?.insert(      'numbers',      {'number': _currentQuestionIndex},      conflictAlgorithm: ConflictAlgorithm.replace,    );
    setState(() {
      _showAnswer = !_showAnswer;
    });

    if (last_flip!=_currentIndex){
      count++;
      last_flip=_currentIndex;
    }
    if(_numberOfCards<=count){showMessage(this.context, "Rest");}
  }

void showMessage(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.5), // Background overlay
        ),
        Center(
          child: Text(
            "Get some ${message} for 2 minutes! \n Stretch your body and close your eyes! \nRelax! Relax!! Relax!!!",
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 5), () => entry.remove());
  count=0; // Remove after 5 seconds
}

  @override
  Widget build(BuildContext context) {
    setState(() {
      _numberOfCards= widget.numberOfCards;
    });
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.grey[300],
        title: const Text("Security+ 701"),// Text('Flashcards'), 
                leading: BackButton(onPressed: () => 
                        
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Going Back? ",),
                    backgroundColor: Colors.grey,
                    actions: [Dialog(
                      child: Container(
                        color: Colors.grey[500],
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Confirmation',style: TextStyle(fontSize: 25)),
                            const Text('Go to Home?',style: TextStyle(fontSize: 20)),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () => 
                                    Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => 
                                    MainPage(),             
                                  ),
                                  ),
                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 238, 148, 148))),
                                  child: const Text('Yes',style: TextStyle(fontSize: 20)),
                                ),
                                SizedBox(width: 10,),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, false),
                                 style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.greenAccent)),

                                  child: const Text('No',style: TextStyle(fontSize: 20)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),]
                    ),
                ),        
         ),// Simulate back button press
  ),      
  backgroundColor: Colors.grey[600],
      body: Stack(
        children: [
          ListView(
            children: [ Text('Flashcards \t\t ${_currentIndex-100<0?(_currentIndex-99)*-1:_currentIndex-99} /${_flashcards.length}',style: TextStyle(color: Colors.white70, fontSize: 15,),textAlign:TextAlign.center),
              Column(                
                children: [ 
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    // width: MediaQuery.of(context).size.width * 0.75,
                    // height: MediaQuery.of(context).size.height * 0.85 ,
                    alignment: Alignment.center,                  
                    child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [ //FloatingStopwatch(),
                            GestureDetector(
                              onTap: _flipCard,
                              child: Container(
                                width: double.infinity, 
                              height:MediaQuery.of(context).size.height*.50,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: _showAnswer ?const Color.fromARGB(255, 87, 87, 87):const Color.fromARGB(255, 133, 133, 133),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FlipAnimation(
                                      showAnswer: _showAnswer,
                                      question: _flashcards[_currentIndex].question, 
                                      answer: _flashcards[_currentIndex].answer,
                                      //Text( _showAnswer ? _flashcards[_currentIndex].answer : _flashcards[_currentIndex].question,
                                      // style: const TextStyle(
                                      //   fontSize: 30.0,                                
                                      //   color: Colors.black,
                                      // ),
                                      // textAlign: TextAlign.center,
                                      // selectionColor: Colors.black,
                                      //background: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15.0),
                    
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                                    children: [
                                      ElevatedButton(
                                        onPressed: _previousFlashcard ,                                          
                                        style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color.fromARGB(31, 237, 236, 236))),
                                        child: const Text('Previous',style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),),
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width*.3),

                                      ElevatedButton(
                                        onPressed: _nextFlashcard,
                                          style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color.fromARGB(31, 237, 236, 236))),
                                        child: const Text('Next',style: TextStyle(fontSize: 25,color: Colors.black, fontWeight: FontWeight.bold),),
                                      ),
                                    ],
                                  ),              
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center,                                    
                                      children: [
                                        ElevatedButton(                                  
                                          onPressed: _next_20Flashcard,
                                          style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color.fromARGB(31, 237, 236, 236))),
                                          child: Text('Skip 20 Cards',style: TextStyle(fontSize: 25, color: Colors.grey[900],),
                                          ),
                                        ),
                                        
                                        SizedBox(width: MediaQuery.of(context).size.width*.03),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: _next_Randomcard,
                                            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color.fromARGB(31, 237, 236, 236))),
                                            child:const Text("Random", style: TextStyle(fontSize: 25, color: Colors.black),),                                            
                                            ),
                                        ),
                                      ],
                                    ),                            
                                ),                            

                             Container(alignment: Alignment.center,
                              height: 60,width: 60,
                              decoration:  BoxDecoration(
                                  border: Border.all(
                                    color: Colors.green, // Border color
                                    width: 2, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(12), // Border radius
                                ),
                              child://Checkbox.adaptive(value: _auto, onChanged:(value) => _autoPlay,),

                                   IconButton(onPressed: _auto? _autoPlay:_getTimeInput, icon: !_auto? Icon(Icons.play_arrow,size: 40,color: Colors.green,):Icon(Icons.pause,size: 40,color: Colors.grey,), ),
                             ), // _getTimeInput,
                             
                             ],
                            ),              
                          ],               
                    ),
                  ),
                ],
              ),
            ],
          ),
         FloatingTimer(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class Flashcard {
  final String question;
  final String answer;
  Flashcard({required this.question, required this.answer});
}
