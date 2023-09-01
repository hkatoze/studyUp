import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:flutter/material.dart';

import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';

import 'package:study_up/views/firstpage.dart';
import 'package:study_up/views/homePage.dart';
import 'package:study_up/views/notificationsServices.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:study_up/views/widgets/widget.dart';

void main() {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StudyUp(),
  ));
}

class StudyUp extends StatefulWidget {
  const StudyUp({Key? key}) : super(key: key);

  @override
  State<StudyUp> createState() => _StudyUpState();
}

class _StudyUpState extends State<StudyUp> {
  var auth_token = "empty";
  int bookLength = 0;
  var internet;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    readCredentials().then((String result) {
      setState(() {
        auth_token = result;
      });
    });
    internetCheck().then((int result) {
      setState(() {
        internet = result;
      });
    });
    readBookLength().then((int value) {
      setState(() {
        bookLength = value;
      });
    });
    print(auth_token);
  }

  void notification(List<dynamic> bookAdded) {
    if (bookAdded.length > bookLength &&
        (auth_token != '' || auth_token != "empty")) {
      NotificationService()
          .showNotification(1, "Nouveau livre", bookAdded.last.bookTitle, 5);

      saveNotififications("Livre ajouté|${bookAdded.last.bookTitle!}|" +
          DateTime.now().hour.toString() +
          ":" +
          DateTime.now().minute.toString() +
          "|" +
          (bookAdded.last.price == null
              ? "Gratuit"
              : bookAdded.last.price + " Frs"));
    }
  }

  Stream<List<dynamic>> _getBook() async* {
    while (true) {
      final _bookAdded = await getBookRecentlyAdded(auth_token);
      notification(_bookAdded);
      await Future.delayed(Duration(seconds: 1));

      yield _bookAdded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return futureMethod();
  }

  Widget futureMethod() {
    return StreamBuilder(
      stream: _getBook(), // async work
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot1) {
        notification(
          snapshot1.data == null ? [] : snapshot1.data!,
        );

        switch (snapshot1.connectionState) {
          case ConnectionState.waiting:
            return ProcessPage();
          default:
            if (snapshot1.hasError)
              return Text('Error: ${snapshot1.error}');
            else
              return auth_token == '' || auth_token == "empty"
                  ? FirstPage()
                  : HomePage(
                      auth_token: auth_token,
                    );
        }
      },
    );
  }
}

class ErrorConnexion extends StatefulWidget {
  const ErrorConnexion({Key? key}) : super(key: key);

  @override
  State<ErrorConnexion> createState() => _ErrorConnexionState();
}

class _ErrorConnexionState extends State<ErrorConnexion> {
  @override
  Widget build(BuildContext context) {
    void showAlert(BuildContext context) {
      AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.ERROR,
        body: Center(
          child: Text(
            "Echec de connexion au server\nVérifier votre connexion internet et réessayer !",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: "Connexion échouer!",
        btnOkColor: Colors.red,
        btnOkText: "OK",
        btnOkOnPress: () {
          exit(0);
        },
      )..show();
    }

    Future.delayed(Duration.zero, () => showAlert(context));
    return Scaffold();
  }
}
