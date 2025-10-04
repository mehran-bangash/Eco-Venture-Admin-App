import 'package:flutter/material.dart';

class InteractiveQuizScreen extends StatefulWidget {
  const InteractiveQuizScreen({super.key});

  @override
  State<InteractiveQuizScreen> createState() => _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends State<InteractiveQuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: 
      Center(child: Text("interactive_quiz_screen"),),);
  }
}
