import 'package:flutter/material.dart';
import 'package:security_plus/choice.dart';
void main() {
  runApp( MainPage());
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});
  @override
  Widget build(BuildContext context) {
     return  //MyApp(
        MaterialApp(
      theme: ThemeData(navigationBarTheme: NavigationBarThemeData(height: 200,shadowColor: Colors.black),
      ),
    title: "Security+ (701)",    
    debugShowCheckedModeBanner: false,
    home: //MainOptionWidget(),//ConfirmationDialogDemo(),
    Scaffold(
    backgroundColor: Colors.grey,     
     body:MainOptionWidget(),
     ),
  )   ;
  }
}