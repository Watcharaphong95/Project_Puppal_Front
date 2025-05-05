import 'package:flutter/material.dart';

class RegisterdogPage extends StatefulWidget {
  const RegisterdogPage({super.key});

  @override
  State<RegisterdogPage> createState() => _RegisterdogPageState();
}

class _RegisterdogPageState extends State<RegisterdogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ลงทะเบียนสุนัข'),
      ),
      body: Container(),
    );
  }
}
