import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double screenWidth;
  late double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/indexBg.png'),
                fit: BoxFit.cover)),
        width: screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, screenHeight * 0.1, 0, 0),
              child: Text('เข้าสู่ระบบ',
                  style: TextStyle(
                      fontSize: 65,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic)),
            ),
            SizedBox(
              width: screenWidth * 0.9,
              height: screenHeight * 0.4,
              child: Card(
                elevation: 5,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.775),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'อีเมล์',
                                style: TextStyle(fontSize: 20),
                              ),
                              Material(
                                elevation: 5,
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: screenHeight * 0.055,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('รหัสผ่าน',
                                      style: TextStyle(fontSize: 20)),
                                  Material(
                                    elevation: 5,
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      height: screenHeight * 0.055,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: forgetPasswordButton,
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'ลืมรหัสผ่าน?',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.lightBlue,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.lightBlue,
                                        decorationThickness: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: screenWidth * 0.5,
                              height: screenHeight * 0.055,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Color(0xFF916b44)),
                                  onPressed: loginButton,
                                  child: Text(
                                    'เข้าสู่ระบบ',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void loginButton() {}

  void forgetPasswordButton() {}
}
