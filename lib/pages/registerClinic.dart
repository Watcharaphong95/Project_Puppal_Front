import 'package:flutter/material.dart';

class RegisterclinicPage extends StatefulWidget {
  const RegisterclinicPage({super.key});

  @override
  State<RegisterclinicPage> createState() => _RegisterclinicPageState();
}

class _RegisterclinicPageState extends State<RegisterclinicPage> {
  late double screenWidth;
  late double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(),
    );
  }
}
