import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NumberListScreen(),
    );
  }
}

class NumberListScreen extends StatefulWidget {
  @override
  _NumberListScreenState createState() => _NumberListScreenState();
}

class _NumberListScreenState extends State<NumberListScreen> {
  final List<int> numbers = [];
  final TextEditingController _controller = TextEditingController();

  Future<Database>? database;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(await getDatabasesPath(), 'number_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE numbers(id INTEGER PRIMARY KEY, number INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertNumber(int number) async {
    final Database? db = await database;
     final List<Map<String, dynamic>> existingNumbers = await db?.query(
      'numbers',
      where: 'number = ?',
      whereArgs: [number],
    )??[];
 if (existingNumbers.isEmpty) {
    await db?.insert(
      'numbers',
      {'number': number},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    }
  }

  Future<List<int>> getNumbers() async {
    final Database? db = await database;

    final List<Map<String, dynamic>> maps = await db?.query('numbers')??[];

    return List.generate(maps.length, (i) {
      return maps[i]['number'];
    });
  }

  void _addNumberToList() {
    setState(() {
  final String input = _controller.text;
    final List<String> numberStrings = input.split(',');
    
    for (String numberString in numberStrings) {
      final int number = int?.tryParse(numberString.trim())??0;
      if (number != null) {
        numbers.add(number);
        insertNumber(number);
      }
    }      
    _controller.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number List'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter a number',
            ),
            onSubmitted: (_) => _addNumberToList(),
          ),
          TextButton(
            onPressed: _addNumberToList,
            child: Text('Add'),
          ),
          FutureBuilder<List<int>>(
            future: getNumbers(),
            builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(snapshot.data?[index].toString()??""),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
