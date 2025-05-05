import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:puppal_application/pages/general/registerGeneral/dog/registerDogInjection.dart';

class RegisterdoginjectionrecordPage extends StatefulWidget {
  const RegisterdoginjectionrecordPage({super.key});

  @override
  State<RegisterdoginjectionrecordPage> createState() =>
      _RegisterdoginjectionrecordPageState();
}

class _RegisterdoginjectionrecordPageState
    extends State<RegisterdoginjectionrecordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ประวัติการฉีดยา'),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => RegisterdoginjectionPage());
              },
              icon: CircleAvatar(
                backgroundColor: Color(0xFFDBA871),
                child: Icon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                ),
              ))
        ],
      ),
      body: Container(),
    );
  }
}
