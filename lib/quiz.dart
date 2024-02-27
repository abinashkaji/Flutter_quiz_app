import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:security_plus/main.dart';
import 'package:security_plus/timer.dart';
import 'package:sqflite/sqflite.dart';
class QuizWidget extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
 const QuizWidget({Key? key, required this.questions}) : super(key: key);
  @override
  _QuizWidgetState createState() => _QuizWidgetState();  
}
class _QuizWidgetState extends State<QuizWidget> {
  int _currentQuestionIndex = 0, total=0,correct=0,current_question=0;
  String msg="";
  bool _showAnswer = false, _isVisible = false,isCorrect=false;
  List <bool> answered=[];
  List <int> correct_answers=[];
  int ? _selectedAnswerIndex=null;
   Future<Database>? database;
   List <int> numbers=[];
   
    @override
  void initState() {
    super.initState();
    initializeDatabase();
  //  _fetchNumbers();
  }

  Future<void> initializeDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(await getDatabasesPath(), 'quiz_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE objective(id INTEGER PRIMARY KEY, question_id INTEGER)',
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
     Future<List<int>> getNumbers() async {
    final Database? db = await database;
//    await db?.insert(      'numbers',      {'number': 11},      conflictAlgorithm: ConflictAlgorithm.replace,    );
    final List<Map<String, dynamic>> maps = await db?.query('objective')??[];
    return List.generate(maps.length, (i) {
      print(maps[i]['question_id']);
      return maps[i]['question_id'];
    });
  }



  void reset_all(){
  _currentQuestionIndex = 0;
  _showAnswer = false;
  total=0;correct=0;current_question=0;
  _isVisible = false;    
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex = (_currentQuestionIndex +1+Random().nextInt(5)) % widget.questions.length;
      current_question=total;
        _showAnswer = false;
        isCorrect=false;
        _isVisible=false;
        _selectedAnswerIndex=null;
      }
    );
  }
      
  void _toggleShowAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
      _isVisible=!_isVisible;
    });
  }
  Future<void> insertNumber(int number) async {
    final Database? db = await database;
     final List<Map<String, dynamic>> existingNumbers = await db?.query(
      'objective',
      where: 'question_id = ?',
      whereArgs: [number],
    )??[];
 if (existingNumbers.isEmpty) {
    await db?.insert(
      'objective',
      {'question_id': number},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    }
  }




void _check_answer(bool a) {
if(a){insertNumber(_currentQuestionIndex); //await db?.insert(      'numbers',      {'number': _currentQuestionIndex},      conflictAlgorithm: ConflictAlgorithm.replace,    );
}
    if(a){setState(() {
      answered.add(true);
      correct=correct+1;
      correct_answers.add(_currentQuestionIndex);
          } );
    }
    else{answered.add(false); }
    total++;  
    for(int i=0;i<correct_answers.length; i++){print(correct_answers[i]);}
}

bool _question_remaining(){
  return widget.questions[0]['q']-total>0;
}
void showMessage(BuildContext context, String message) {
   showDialog(
    context: context,
    builder: (context) => Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.9), // Background overlay
        ),
        Center(
          child: AlertDialog(
            title:Text( message),
            content: Text( message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) => MainPage()));
                },
                child: Text('Home'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
     backgroundColor: Colors.grey,     
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text("Security+ 701"), // Text('Quiz correct: ${correct}/${total}! left: ${widget.questions[0]['q']-total} !! ' ),
              leading: BackButton(onPressed: () =>         
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.grey,
                title: Text("Going Back? "),
                actions: [Dialog(
                  child: Container(
                    color: Colors.grey[500],
                    padding: const EdgeInsets.all(8.0),
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
                              child: const Text('Yes',style: TextStyle(fontSize: 20)),
                            ),
                            SizedBox(width: 10,),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, false),
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
      body: 
      Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child:             
            ListView(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Remaining Questions: ${widget.questions[0]['q']-total} Current Score: ${correct}/${total}' ,textAlign:TextAlign.end,),
                    SizedBox(width: 100,),
                  ],
                ),
                //style: TextStyle(backgroundColor: Color(Colors.black) , ),),       
                Text(
                  'Question ${current_question+1}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),            
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.white24),borderRadius: BorderRadius.circular(10),),
                  child: Column(              
                    children: [ 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(decoration: BoxDecoration(
                            border: Border.all(color: Colors.white10, width: 2,), 
                            borderRadius: BorderRadius.circular(10),
                             ),
                               padding:EdgeInsets.symmetric(horizontal: 20,vertical: 4),
                         
                          child: Text(
                            widget.questions[_currentQuestionIndex]['question'].trimLeft(),
                            style: TextStyle(fontSize: 17,),
                          ),
                        ),
                      ),
                      Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.white24),borderRadius: BorderRadius.circular(8),),
                        child: Column(            
                          children: List.generate(
                            widget.questions[_currentQuestionIndex]['answers'].length,
                            (index) => Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.white10),borderRadius: BorderRadius.circular(8),),
                              child: ListTile(              
                                hoverColor: Color.fromARGB(255, 134, 138, 139),
                                title: Container(
                                  decoration: BoxDecoration(color:_showAnswer && _selectedAnswerIndex == index + 1
                                            ? (isCorrect && _showAnswer ? const Color.fromARGB(255, 37, 120, 39).withOpacity(0.3) : const Color.fromARGB(255, 238, 41, 27).withOpacity(0.3))
                                            : ((widget.questions[_currentQuestionIndex]['correct'] == index + 1) 
                                            && _showAnswer ? const Color.fromARGB(255, 61, 176, 64).withOpacity(0.3) : Color.fromARGB(255, 113, 113, 113)),
                                  border: Border.all(color: Colors.grey, width: .5,), 
                                  borderRadius: BorderRadius.circular(6),),
                                  padding:EdgeInsets.fromLTRB(10,1,5,1),                    
                                  child:Text( 
                                    "${index+1}. ${widget.questions[_currentQuestionIndex]['answers'][index]}",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                
                                onTap: () {
                                  if (!_showAnswer) {
                                    _toggleShowAnswer();
                                    // Call the callback function with the index of the tapped widget
                                    _check_answer(widget.questions[_currentQuestionIndex]['correct'] ==index+1);                      
                                    int selectedIndex = index + 1; 
                                    isCorrect = selectedIndex == widget.questions[_currentQuestionIndex]['correct'];
                                    setState(() {
                                      _selectedAnswerIndex = index + 1;
                                    });
                                    if(!_question_remaining()){
                                      ((correct/total)>=.85)?msg="Congratulations! ":msg="Try Again! " ;
                                      showMessage(context, "${msg} You scored ${correct.toString()}/${total}");
                                      reset_all(); 
                                               
                                    }                    
                                  }
                                },                                      
                               ),
                            ),
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
          
                SizedBox(height: 16),
                ButtonTheme(
            height: 25,
            child: Align(
              alignment: Alignment.center,// centerRight, // Align the button to the right
              child: SizedBox(
          width: MediaQuery.of(context).size.width*2 / 3, // Half the screen width
          height: MediaQuery.of(context).size.height/ 16,
          child: ElevatedButton(
            onPressed: _showAnswer ? _nextQuestion : null,
//            style: ButtonStyle(backgroundColor:MaterialStatePropertyAll(Colors.blueGrey)),
            child: Text('Next Question', style: TextStyle(fontSize: 20,color: Colors.black87)),
          ),
              ),
            ),
          ),
          
                Visibility(
                  visible: _isVisible,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(2,10,2,0),
                    child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),border:Border.all(color: Colors.black26) ),padding: EdgeInsets.fromLTRB(3,15,3,3),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0,0,8,8),
                        child: Text("Explanation: ${widget.questions[_currentQuestionIndex]['explanation']}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        FloatingTimer(),

 
         ],        
      ),

      bottomNavigationBar: Row( children: List.generate(
            answered.length,
            (index) => Icon(
              answered[index] ? Icons.check : Icons.clear,
              color: answered[index] ? Colors.green : Colors.red,
            ),
          ),   
        ), 
       
    );
  }  
}