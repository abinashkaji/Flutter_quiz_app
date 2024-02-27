// objective and number slider
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
  bool _selectQuestionType = true;
  String _question_type="Objective";
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
      join(await getDatabasesPath(), 'number_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE numbers(id INTEGER PRIMARY KEY, Quiz INTEGER)'
          'CREATE TABLE flashcard(id INTEGER PRIMARY KEY, flash_id INTEGER)'
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

// Future<void> _fetchNumbers() async {
//     List<int> fetchedNumbers = await getNumbers();
//     setState(() {
//       numbers.addAll(fetchedNumbers);
//     });
//     for(int i=0;i<numbers.length;i++){print(i);}
//   }

   Future<List<int>> getNumbers() async {
    final Database? db = await database;
//    await db?.insert(      'numbers',      {'number': 5},      conflictAlgorithm: ConflictAlgorithm.replace,    );

    final List<Map<String, dynamic>> maps = await db?.query('numbers')??[];
    return List.generate(maps.length, (i) {
      print(maps[i]['number']);
      return maps[i]['number'];
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
            const SizedBox(height: 90,child: Text('\nChoose your practice type \n ',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),),
            SizedBox(height: 80,child: Text('Question Type: ${_question_type}   ',style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),),
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
  for(int i=0;i<numbers.length;i++){print(numbers[i]);}

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
            Text('Number of Questions: $_sliderValue',style: const TextStyle(fontSize: 20),),
            const SizedBox(height: 20),        
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

 Column(
  mainAxisAlignment: MainAxisAlignment.center,
   children: [
    Text(numbers.length.toString()),

     Container(width: MediaQuery.of(context).size.width*.3 ,height:MediaQuery.of(context).size.height*.3 ,
       child: PieChart(
                dataMap: {"Solved":numbers.length.toDouble(),"Remaining":35-numbers.length.toDouble()},
                centerText: "Quiz",
                animationDuration: const Duration(milliseconds: 800),
                chartLegendSpacing: 32,
                chartRadius: MediaQuery.of(context).size.width / 2.7,
                initialAngleInDegree: 0,
                chartType: ChartType.disc,
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
                  showChartValuesInPercentage: false,
                  showChartValuesOutside: false,
                ),
              ),
     ),
     Container(width: MediaQuery.of(context).size.width*.3 ,height:MediaQuery.of(context).size.height*.3 ,
       child: PieChart(
        centerText: "Flashcard",
                dataMap: {"Flashcard Watched":numbers.length.toDouble(),"Remaining":166-numbers.length.toDouble()},
                animationDuration: const Duration(milliseconds: 800),
                chartLegendSpacing: 32,
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

       ],
     );
  }
}