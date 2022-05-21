import 'package:flutter/material.dart';
import 'package:input_calculator/input_calculator.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  double? value = 0.0;

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return const SimpleCalculator(
      theme: CalculatorThemeData(
          displayColor: Colors.white,
          displayStyle: TextStyle(fontSize: 80, color: Colors.black),
          operatorColor: const Color(0xff2A9863)),
    );
  }
}
