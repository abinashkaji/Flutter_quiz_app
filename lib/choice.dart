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
              leading: IconButton(
              icon: Icon(Icons.power_settings_new), 
                onPressed: () =>         
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
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 238, 148, 148))),
                                  
                                  child: const Text('Yes',style: TextStyle(fontSize: 20),),
                                ),
                                const SizedBox(width: 10,),
                
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.greenAccent)),
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
            const SizedBox(height: 150,child: Text('\nPractice type \n ',style:TextStyle(fontStyle: FontStyle.italic ,fontWeight: FontWeight.bold,fontSize: 35),),),
            SizedBox(height: 40,child: Text('(Select your Qestion Type)',style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),),
            
            Container(
              width: MediaQuery.of(context).size.width*.75,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)), color: const Color.fromARGB(255, 214, 212, 212),                   ),         
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,              
                  children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectQuestionType = true;
                            _question_type = "Objective";
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _selectQuestionType ? Colors.blue : Colors.grey.withOpacity(0.5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: _selectQuestionType ? Colors.white : Colors.transparent,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Objective',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: _selectQuestionType ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        height: 50,
                        width: 2,
                        color: Colors.black,
                      ), // Vertical line
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectQuestionType = false;
                            _question_type = "Flash Card";
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: !_selectQuestionType ? Colors.blue : Colors.grey.withOpacity(0.5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: !_selectQuestionType ? Colors.white : Colors.transparent,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Flash Card',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: !_selectQuestionType ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],                
                ),
              ),
            ),


            SizedBox(height: 20,),
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color: Colors.grey),
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
                Visibility(
                  visible: _selectQuestionType,
                  child: SizedBox(width: MediaQuery.of(context).size.width*.3 ,height:MediaQuery.of(context).size.height*.3 ,
                    child: PieChart(
                              dataMap: {"Remaining":300-numbers.length.toDouble(),"Solved":numbers.length.toDouble(),},
                              centerText: "Quiz",
                              colorList: [Color.fromARGB(255, 223, 97, 88),Colors.blue],
                              animationDuration: const Duration(milliseconds: 1000),
                              chartLegendSpacing: 20,                          
                              chartRadius: MediaQuery.of(context).size.width / 2,
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
                ),   

                Visibility(
                  visible: !_selectQuestionType,
                  child: SizedBox(width: MediaQuery.of(context).size.width*.3 ,height:MediaQuery.of(context).size.height*.3 ,
                    child: PieChart(
                      centerText: "Flashcard",
                              dataMap: {"Remaining":1660-flash.length.toDouble(),"Reviewed ":flash.length.toDouble(),},
                              animationDuration: const Duration(milliseconds: 1000),
                              chartLegendSpacing: 20,
                              
                              chartRadius: MediaQuery.of(context).size.width / 2,
                              initialAngleInDegree: 300,
                              chartType: ChartType.ring,
                              ringStrokeWidth: 32,
                              colorList: [Color.fromARGB(255, 239, 97, 87),Colors.green,],
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
                ),
              ],
            ),
          ),
       ],
     );
  }
}