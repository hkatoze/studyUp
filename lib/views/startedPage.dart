import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:study_up/animation/ScaleRoute.dart';
import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';
import 'package:study_up/views/homePage.dart';
import 'package:study_up/views/signInPage.dart';
import 'package:study_up/views/widgets/widget.dart';
import 'package:restart_app/restart_app.dart';

class StartedPage extends StatefulWidget {
  final List<dynamic> libraryBookList;
  final List<dynamic> bookAddedList;
  final List<dynamic> catList;
  final int internet;
  final String amount;
  const StartedPage(
      {Key? key,
      required this.amount,
      required this.internet,
      required this.bookAddedList,
      required this.catList,
      required this.libraryBookList})
      : super(key: key);

  @override
  State<StartedPage> createState() => _StartedPageState();
}

class _StartedPageState extends State<StartedPage> {
  var auth_token = "empty";

  @override
  void initState() {
    super.initState();
    readCredentials().then((String result) {
      setState(() {
        auth_token = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Container(
          height: heightP(context, 1),
          margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Column(
            children: [
              SizedBox(
                height: heightP(context, 0.1),
              ),
              Container(
                  child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Bienvenue\n",
                      children: [
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                print("Inscription en cours");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInPage()),
                                );
                              },
                            text: "sur StudyUp ",
                            style: TextStyle(
                                fontSize: 27,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal))
                      ],
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              )),
              SizedBox(
                height: heightP(context, 0.07),
              ),
              Container(
                child: SvgPicture.asset(
                  'assets/svg/reading.svg',
                  height: heightP(context, 0.4),
                  allowDrawingOutsideViewBox: true,
                ),
              ),
              SizedBox(
                height: heightP(context, 0.03),
              ),
              Container(
                child: Text(
                  "La meilleure plateforme de lecture du moment avec une sélection pertinente de livre spécialement pour vous.",
                  style: TextStyle(
                      fontSize: 15, color: Colors.black.withOpacity(0.5)),
                ),
              ),
              SizedBox(
                height: heightP(context, 0.025),
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
                      Navigator.pushAndRemoveUntil(
                          context,
                          ScaleRoute(
                              page: HomePage(
                            auth_token: auth_token,
                          )),
                          (Route<dynamic> route) => false);
                    },
                    child: Text(
                      "Commencer",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
              )
            ],
          )),
    ));
  }
}
