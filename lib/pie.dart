import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pie Chart Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PieChartExample(),
    );
  }
}

class PieChartExample extends StatefulWidget {
  @override
  _PieChartExampleState createState() => _PieChartExampleState();
}

class _PieChartExampleState extends State<PieChartExample> {
  Map<String, double> dataMap = {
    'Sold': 0, // Placeholder values, you should replace them with actual data
    'Remaining': 0,
  };

  @override
  void initState() {
    super.initState();
    // Call your function to fetch data from the database and update dataMap accordingly
    fetchDataFromDatabase();
  }

  void fetchDataFromDatabase() {
    // Simulated data for demonstration, replace it with actual database retrieval
    int totalItems = 100; // Total items
    int soldItems = 75; // Sold items

    int remainingItems = totalItems - soldItems;

    setState(() {
      dataMap['Sold'] = soldItems.toDouble();
      dataMap['Remaining'] = remainingItems.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pie Chart Example'),
      ),
      body: Center(
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 2.7,
          initialAngleInDegree: 0,
          chartType: ChartType.disc,
          ringStrokeWidth: 32,
          legendOptions: LegendOptions(
            showLegendsInRow: true,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
          ),
        ),
      ),
    );
  }
}
