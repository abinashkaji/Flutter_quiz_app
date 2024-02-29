// objective and number slider
//import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:security_plus/flashcard.dart';
import 'package:security_plus/questions.dart';
import 'package:sqflite/sqflite.dart';
class MainOptionWidget extends StatefulWidget {
  @override
  _MainOptionWidgetState createState() => _MainOptionWidgetState();
}

class _MainOptionWidgetState extends State<MainOptionWidget> {
  int  _sliderValue = 50; //default values
  bool _selectQuestionType = true, _isVisible=false;
  String _question_type="Objective";
   Future<Database>? database;
   List <int> numbers=[];
   List <int> flash=[];   
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
      onCreate: (db, version) async {
         await db.execute(
        'CREATE TABLE objective(id INTEGER PRIMARY KEY, question_id INTEGER)',
      );
      await db.execute(
        'CREATE TABLE flashcard(id INTEGER PRIMARY KEY, flash_id INTEGER)',
      );
    },
      version: 1,
    );
  List<int> fetchedNumbers = await getNumbers();
  List<int> fetchedFlash = await getFlashcard();
  
    setState(() {
      numbers.addAll(fetchedNumbers);
      flash.addAll(fetchedFlash);
      print("success");
    });
    
  }


   Future<List<int>> getNumbers() async {
    final Database? db = await database;
//    await db?.insert(      'objective',      {'question_id': 5},      conflictAlgorithm: ConflictAlgorithm.replace,    );
//  await db?.insert(      'flashcard',      {'flash_id': 5},      conflictAlgorithm: ConflictAlgorithm.replace,    );
    final List<Map<String, dynamic>> maps = await db?.query('objective')??[];
    return List.generate(maps.length, (i) {
      //print(maps[i]['question_id']);
      return maps[i]['question_id'];
    });
  }

   Future<List<int>> getFlashcard() async {
    final Database? db = await database;

    final List<Map<String, dynamic>> maps = await db?.query('flashcard')??[];
    return List.generate(maps.length, (i) {
      //print(maps[i]['flash_id']);
      return maps[i]['flash_id'];
    });
  }


  @override
  Widget build(BuildContext context) {
    return
     ListView(            
       children: [AppBar(title: const Text("Security+ 701"),backgroundColor: Colors.grey[300],
               leading: BackButton(onPressed: () =>         
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey,
                    title: const Text("Exit? "),
                    actions: [Dialog(
                      child: Container(color: const Color.fromARGB(255, 145, 145, 145),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Confirmation',style: TextStyle(fontSize: 25),),
                            const Text('Are you sure! Exit?',style: TextStyle(fontSize: 20),),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>  SystemNavigator.pop(),
                                  
                                  child: const Text('Yes',style: TextStyle(fontSize: 20),),
                                ),
                                const SizedBox(width: 10,),
                
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('No',style: TextStyle(fontSize: 20),),
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

         Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [         
            const SizedBox(height: 80,child: Text('\nChoose your practice type \n ',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),),
            SizedBox(height: 70,child: Text('Question Type: ${_question_type}   ',style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              
              children: [

                Row(
                  children: [Radio(
                  value: true,
                  groupValue: _selectQuestionType,
                  onChanged: (value) {
                    setState(() {
                      _selectQuestionType = !_selectQuestionType;
                      _question_type="Objective";
//                      solved= getNumbers();
                    });
//                    for(int i=0;i<solved.length;i++){print(i);}
                  },
                ),
                const Text('Objective Questions',style:TextStyle(fontSize: 20), 
                
                ),
                ],
                ),
         
                Row(
                  children: [            
                    Radio(
                    value:false,
                    groupValue: _selectQuestionType,
                    onChanged: (value) {
                      setState(() {
                        _selectQuestionType = !_selectQuestionType;
                        _question_type="Flash Card";
                      });
  //_fetchNumbers();
//  for(int i=0;i<numbers.length;i++){print(numbers[i]);}

                    },
                  ),
                  const Text('Flash Card',style: TextStyle(fontSize: 20), )
                  
                ]),
                   ],                
            ),
            Slider(
              value: _sliderValue.toDouble(),
              min: 1,
              max: 90,
              onChanged: (newValue) {
                setState(() {
                  _sliderValue = newValue.toInt();         
                });
              },
            ),
            Text('Number of ${_question_type}: $_sliderValue',style: const TextStyle(fontSize: 16),),
            const SizedBox(height: 15),        
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color: Colors.green),
            child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => 
                    _selectQuestionType? question(_sliderValue):FlashcardApp(_sliderValue), //  data:_sliderValue             
                  ),
                  );
                },
                label: const Text('Next',style: TextStyle(fontSize: 20,color: Colors.black87,fontWeight: FontWeight.bold),),
                icon: const Icon(Icons.arrow_forward,color: Colors.green,),
                
            ),
          ),    
          ],
        ),
          SizedBox(height: 20,),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox.adaptive(value: _isVisible, onChanged: (value) => setState(() {
             _isVisible=!_isVisible; 
            }),semanticLabel: "Show Progress",
            activeColor: Colors.blueAccent,
          
            ),
            Text("Show Progress",style: TextStyle(fontSize: 18),),
          ],
        ),

          Visibility(
            visible: _isVisible,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: MediaQuery.of(context).size.width*.3 ,height:MediaQuery.of(context).size.height*.3 ,
                  child: PieChart(
                            dataMap: {"Remaining":300-numbers.length.toDouble(),"Solved":numbers.length.toDouble(),},
                            centerText: "Quiz",
                            colorList: [Colors.red,Colors.blue],
                            animationDuration: const Duration(milliseconds: 1000),
                            chartLegendSpacing: 20,                          
                            chartRadius: MediaQuery.of(context).size.width / 2.7,
                            initialAngleInDegree: 270,            
                            chartType: ChartType.ring,
                            ringStrokeWidth: 32,
                            legendOptions: const LegendOptions(            
                              showLegendsInRow: true,
                              legendPosition: LegendPosition.bottom,
                              showLegends: true,
                              legendShape: BoxShape.rectangle,
                              legendTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            chartValuesOptions: const ChartValuesOptions(
                              showChartValueBackground: true,
                              showChartValues: true,
                              showChartValuesInPercentage: false,
                              showChartValuesOutside: false,
                            ),
                          ),
                ),   

                Container(width: MediaQuery.of(context).size.width*.3 ,height:MediaQuery.of(context).size.height*.3 ,
                  child: PieChart(
                    centerText: "Flashcard",
                            dataMap: {"Remaining":1660-flash.length.toDouble(),"Reviewed ":flash.length.toDouble(),},
                            animationDuration: const Duration(milliseconds: 1000),
                            chartLegendSpacing: 20,
                            
                            chartRadius: MediaQuery.of(context).size.width / 2.7,
                            initialAngleInDegree: 0,
                            chartType: ChartType.ring,
                            ringStrokeWidth: 32,
                            legendOptions: const LegendOptions(
                              showLegendsInRow: true,
                              legendPosition: LegendPosition.bottom,
                              showLegends: true,
                              legendShape: BoxShape.circle,
                              legendTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            chartValuesOptions: const ChartValuesOptions(
                              showChartValueBackground: true,
                              showChartValues: true,
                              showChartValuesInPercentage: true,
                              showChartValuesOutside: false,
                            ),
                          ),
                ),
              ],
            ),
          ),
       ],
     );
  }
}