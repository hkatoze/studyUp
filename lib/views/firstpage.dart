import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:study_up/constants.dart';

import 'package:study_up/views/signInPage.dart';
import 'package:study_up/views/signUpPage.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Center(
            child: Container(
              height: heightP(context, 1),
              margin: EdgeInsets.symmetric(vertical: heightP(context, 0.02)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: heightP(context, 0.07),
                    ),
                    Image.asset(
                      "assets/images/logo.png",
                      scale: heightP(context, 0.0012),
                    ),
                    Container(
                      child: Text(
                        "StudyUp",
                        style: TextStyle(
                            fontSize: 35, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: heightP(context, 0.015),
                    ),
                    Container(
                        child: Center(
                      child: RichText(
                        text: TextSpan(
                            text: "By  ",
                            children: [
                              TextSpan(
                                  text: "Smart Touch Group".toUpperCase(),
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ],
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            )),
                      ),
                    )),
                    SizedBox(
                      height: heightP(context, 0.1),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text:
                                    "Votre bibliothèque numérique avec une vaste gamme\n",
                                children: [
                                  TextSpan(
                                    text:
                                        "de livre de tout genre à lire et à écouter.",
                                  )
                                ],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                )),
                          ),
                        )),
                    SizedBox(
                      height: heightP(context, 0.1),
                    ),
                    Container(
                      width: widthP(context, 0.9),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0XFF223170),
                            padding: EdgeInsets.all(15),
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(35.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInPage()),
                            );
                          },
                          child: Text(
                            "Se connecter",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          )),
                    ),
                    SizedBox(
                      height: heightP(context, 0.04),
                    ),
                    Container(
                        child: Center(
                      child: RichText(
                        text: TextSpan(
                            text: "Je n'ai pas de compte? ",
                            children: [
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      print("Inscription en cours");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUpPage()),
                                      );
                                    },
                                  text: "S'inscrire",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor))
                            ],
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            )),
                      ),
                    )),
                  ]),
            ),
          )),
    );
  }
}
