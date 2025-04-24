import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puppal_application/pages/login.dart';
import 'package:puppal_application/pages/registerType.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
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
              child: Text('PUPPAL',
                  style: TextStyle(
                      fontSize: 65,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.7,
                              child: Text(
                                'จองฉีดยาให้กับสุนัขของคุณ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 7.5),
                              child: SizedBox(
                                width: screenWidth * 0.75,
                                child: ElevatedButton(
                                    onPressed: loginButton,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Color(0xFF916b44),
                                    ),
                                    child: Text(
                                      'ล็อกอิน',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.75,
                              child: ElevatedButton(
                                  onPressed: googleLoginButton,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/googleLoginIcon.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      Text(
                                        ' เข้าสู่ระบบโดย Google ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  )),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('คุณมีบัญชีผู้ใช้หรือยัง?'),
                                TextButton(
                                    onPressed: registerButton,
                                    child: Text(
                                      'สมัคร',
                                      style: TextStyle(
                                          color: Colors.black,
                                          decoration: TextDecoration.underline),
                                    ))
                              ],
                            )
                          ],
                        )
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

  void registerButton() {
    Get.to(() => RegistertypePage());
  }

  void googleLoginButton() {}

  void loginButton() {
    Get.to(() => LoginPage());
  }
}
