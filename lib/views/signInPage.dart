import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';

import 'package:study_up/models/models.dart';
import 'package:study_up/views/forgetPassword.dart';
import 'package:study_up/views/signupPage.dart';
import 'package:study_up/views/startedPage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool emailIsValid = false;
  bool passwordIsValid = false;
  bool showPassword = false;
  bool inLoginProcess = false;
  String _email = "";
  String _password = "";
  bool startMailEdit = false;
  String amount = "";
  bool startPasswordEdit = false;
  List<dynamic> libraryBookList = [];
  List<dynamic> bookAddedList = [];
  List<dynamic> catList = [];

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void initState() {
    super.initState();
    // Start listening to changes.
    _emailController.addListener(_checkEmail);
    _passwordController.addListener(_checkPassword);
  }

  _checkEmail() {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text);

    if (emailValid)
      setState(() {
        emailIsValid = true;
        _email = _emailController.text;
      });
    else {
      setState(() {
        emailIsValid = false;
      });
    }
  }

  _checkPassword() {
    bool passwordValid = (_passwordController.text.length >= 8);

    if (passwordValid)
      setState(() {
        passwordIsValid = true;
        _password = _passwordController.text;
      });
    else {
      setState(() {
        passwordIsValid = false;
      });
    }
  }

  void sendLogin() async {
    setState(() {
      inLoginProcess = true;
    });
    var internet = await internetCheck();
    var response =
        await loginChecked(_emailController.text, _passwordController.text);

    print("RESULTAT*********: " + response.auth_token);

    if (response.auth_token == "auth_token" || internet != 200) {
      setState(() {
        inLoginProcess = false;
      });
      Fluttertoast.showToast(
          msg: "Echec de la connexion !",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.ERROR,
        body: Center(
          child: Text(
            internet != 200
                ? "Echec de connexion au server\nVérifier votre connexion internet et réessayer !"
                : "Vos identifiants sont invalides !\nVérifier les et réessayer.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: "Connexion échouer!",
        btnOkColor: Colors.red,
        btnOkText: "REESAYER",
        btnOkOnPress: () {
          print("RESULTAT*********: " + response.auth_token);
          Navigator.canPop(context);
        },
      )..show();
    } else {
      setState(() {
        inLoginProcess = false;
      });
      writeCredentials(response.auth_token);
      writeUserId(response.user.id.toString());
      writePassword(_passwordController.text);
      writeEmail(response.user.email.toString());
      writeUserName(response.user.lastname! + " " + response.user.firstname!);

      getBookRecentlyAdded(response.auth_token)
          .then((List<dynamic> value) => () {
                setState(() {
                  bookAddedList = value;
                });
              });

      getFavorisBook(response.auth_token).then((List<dynamic> value) => () {
            setState(() {
              libraryBookList = value;
            });
          });

      getCategories(response.auth_token).then((List<dynamic> value) => () {
            setState(() {
              catList = value;
            });
          });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StartedPage(
                  amount: amount,
                  internet: internet,
                  bookAddedList: bookAddedList,
                  libraryBookList: libraryBookList,
                  catList: catList,
                )),
      );
      Fluttertoast.showToast(
          msg: "Connexion réussie !",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Container(
          height: heightP(context, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: heightP(context, 0.05),
              ),
              Image.asset(
                "assets/images/logo.png",
                scale: heightP(context, 0.0012),
              ),
              SizedBox(
                height: heightP(context, 0.05),
              ),
              Center(
                child: Container(
                    child: Text(
                  "Connexion",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.7)),
                )),
              ),
              SizedBox(
                height: heightP(context, 0.02),
              ),
              Container(
                width: widthP(context, 0.95),
                child: Theme(
                    data: Theme.of(context)
                        .copyWith(splashColor: Colors.transparent),
                    child: TextFormField(
                      controller: _emailController,
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          startMailEdit = true;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: emailIsValid == false
                                  ? Colors.red
                                  : Colors.green,
                              width: 2.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        suffixIcon: Icon(
                          emailIsValid == false
                              ? Icons.cancel
                              : Icons.check_rounded,
                          color:
                              emailIsValid == false ? Colors.red : Colors.green,
                        ),
                        hintText: "Adresse email",
                        hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.6), fontSize: 18),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: kPrimaryColor,
                            ),
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                    )),
              ),
              SizedBox(
                height: heightP(context, 0.005),
              ),
              Container(
                width: widthP(context, 0.90),
                child: Visibility(
                    visible: startMailEdit ? !emailIsValid : false,
                    child: Text("Entrer une adresse email valide",
                        style: TextStyle(color: Colors.red))),
              ),
              SizedBox(
                height: heightP(context, 0.02),
              ),
              Container(
                width: widthP(context, 0.95),
                child: Theme(
                    data: Theme.of(context)
                        .copyWith(splashColor: Colors.transparent),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !showPassword,
                      onChanged: (value) {
                        setState(() {
                          startPasswordEdit = true;
                        });
                      },
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: passwordIsValid == false
                                  ? Colors.red
                                  : Colors.green,
                              width: 2.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            child: Icon(
                              showPassword == false
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black.withOpacity(0.6),
                            )),
                        hintText: "Mot de passe",
                        hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.6), fontSize: 18),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: kPrimaryColor,
                            ),
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                    )),
              ),
              SizedBox(
                height: heightP(context, 0.005),
              ),
              Container(
                width: widthP(context, 0.90),
                child: Visibility(
                    visible: startPasswordEdit ? !passwordIsValid : false,
                    child: Text(
                        "Utiliser un mélange d'au moins 8 caractères de lettres et de chiffres.",
                        style: TextStyle(color: Colors.red))),
              ),
              SizedBox(
                height: heightP(context, 0.01),
              ),
              Container(
                  child: Center(
                child: RichText(
                  text: TextSpan(
                      text: "",
                      children: [
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                print("");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForgetPassWord()),
                                );
                              },
                            text: "Mot de passe oublié ?",
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
              SizedBox(
                height: heightP(context, 0.05),
              ),
              Container(
                width: widthP(context, 0.9),
                child: inLoginProcess
                    ? Center(
                        child: CircularProgressIndicator(
                          color: kPrimaryColor,
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0XFF223170),
                          padding: EdgeInsets.all(15),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(35.0),
                          ),
                        ),
                        onPressed:
                            emailIsValid & passwordIsValid ? sendLogin : null,
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
                                      builder: (context) => SignUpPage()),
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
            ],
          )),
    ));
  }
}
