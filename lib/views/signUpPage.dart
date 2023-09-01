import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';
import 'package:study_up/models/models.dart';
import 'package:study_up/views/startedPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool emailIsValid = false;
  bool nameIsValid = false;
  bool surnameIsValid = false;
  bool passwordIsValid = false;
  bool confirmpasswordIsValid = false;
  bool showPassword = false;
  bool hasReadPolicy = false;
  bool inLoginProcess = false;
  bool startMailEdit = false;
  bool startPasswordEdit = false;
  bool startConfirmPasswordEdit = false;
  List<dynamic> libraryBookList = [];
  List<dynamic> bookAddedList = [];
  List<dynamic> catList = [];
  String amount = "";
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();

  void initState() {
    super.initState();
    // Start listening to changes.
    _emailController.addListener(_checkEmail);
    _passwordController.addListener(_checkPassword);
    _confirmpasswordController.addListener(_checkConfirmPassword);
    _nameController.addListener(_checkName);
    _surnameController.addListener(_checkSurname);
  }

  _checkName() {
    bool nameValid = RegExp(r"([a-zA-Z',.-]+( [a-zA-Z',.-]+)*){2,30}")
        .hasMatch(_nameController.text);

    if (nameValid)
      setState(() {
        nameIsValid = true;
      });
    else {
      setState(() {
        nameIsValid = false;
      });
    }
  }

  _checkSurname() {
    bool surnameValid = RegExp(r"([a-zA-Z',.-]+( [a-zA-Z',.-]+)*){2,30}")
        .hasMatch(_surnameController.text);

    if (surnameValid)
      setState(() {
        surnameIsValid = true;
      });
    else {
      setState(() {
        surnameIsValid = false;
      });
    }
  }

  _checkEmail() {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text);

    if (emailValid)
      setState(() {
        emailIsValid = true;
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
      });
    else {
      setState(() {
        passwordIsValid = false;
      });
    }
  }

  _checkConfirmPassword() {
    bool confirmpasswordValid = (_passwordController.text.length >= 8) &&
        _passwordController.text == _confirmpasswordController.text;

    if (confirmpasswordValid)
      setState(() {
        confirmpasswordIsValid = true;
      });
    else {
      setState(() {
        confirmpasswordIsValid = false;
      });
    }
  }

  void sendRegister() async {
    setState(() {
      inLoginProcess = true;
    });
    var internet = await internetCheck();
    var response = await register(_nameController.text, _surnameController.text,
        _emailController.text, _passwordController.text);

    if (response.email == "email" || internet != 200) {
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
          Navigator.canPop(context);
        },
      )..show();
    } else {
      UserConnecting responseConnecting =
          await loginChecked(_emailController.text, _passwordController.text);
      writeCredentials(responseConnecting.auth_token);
      writeUserId(responseConnecting.user.id.toString());
      writePassword(_passwordController.text);
      writeEmail(responseConnecting.user.email.toString());
      writeUserName(responseConnecting.user.lastname! +
          " " +
          responseConnecting.user.firstname!);
      setState(() {
        inLoginProcess = false;
      });
      getBookRecentlyAdded(responseConnecting.auth_token)
          .then((List<dynamic> value) => () {
                setState(() {
                  bookAddedList = value;
                });
              });

      getFavorisBook(responseConnecting.auth_token)
          .then((List<dynamic> value) => () {
                setState(() {
                  libraryBookList = value;
                });
              });

      getCategories(responseConnecting.auth_token)
          .then((List<dynamic> value) => () {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7)),
                      child: ClipRect(
                          child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            color: KSecondaryColor,
                          ),
                          Text("Retour")
                        ],
                      )),
                    ),
                  ),
                  Text("")
                ],
              ),
              SizedBox(
                height: heightP(context, 0.02),
              ),
              Center(
                child: Container(
                    child: Text(
                  "Créer votre compte",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.7)),
                )),
              ),
              SizedBox(
                height: heightP(context, 0.05),
              ),
              Container(
                width: widthP(context, 0.95),
                child: Theme(
                    data: Theme.of(context)
                        .copyWith(splashColor: Colors.transparent),
                    child: TextFormField(
                      controller: _nameController,
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: nameIsValid == false
                                  ? Colors.red
                                  : Colors.green,
                              width: 2.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        suffixIcon: Icon(
                          nameIsValid == false
                              ? Icons.cancel
                              : Icons.check_rounded,
                          color:
                              nameIsValid == false ? Colors.red : Colors.green,
                        ),
                        hintText: "Nom",
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
                height: heightP(context, 0.02),
              ),
              Container(
                width: widthP(context, 0.95),
                child: Theme(
                    data: Theme.of(context)
                        .copyWith(splashColor: Colors.transparent),
                    child: TextFormField(
                      controller: _surnameController,
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: surnameIsValid == false
                                  ? Colors.red
                                  : Colors.green,
                              width: 2.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        suffixIcon: Icon(
                          surnameIsValid == false
                              ? Icons.cancel
                              : Icons.check_rounded,
                          color: surnameIsValid == false
                              ? Colors.red
                              : Colors.green,
                        ),
                        hintText: "Prénom (s)",
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
                height: heightP(context, 0.02),
              ),
              Container(
                width: widthP(context, 0.95),
                child: Theme(
                    data: Theme.of(context)
                        .copyWith(splashColor: Colors.transparent),
                    child: TextFormField(
                      controller: _confirmpasswordController,
                      obscureText: !showPassword,
                      onChanged: (value) {
                        setState(() {
                          startConfirmPasswordEdit = true;
                        });
                      },
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: confirmpasswordIsValid == false
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
                        hintText: "Confirmer mot de passe",
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
                    visible: startConfirmPasswordEdit
                        ? !confirmpasswordIsValid
                        : false,
                    child: Text("Vos mots de passe ne correspondent pas.",
                        style: TextStyle(color: Colors.red))),
              ),
              SizedBox(
                height: heightP(context, 0.02),
              ),
              Center(
                child: Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: widthP(context, 0.04)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                              text: "J'accepte les ",
                              children: [
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        print(
                                            "Politiques de confidentialité approuvées");
                                      },
                                    text: "Politiques de confidentialité",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor))
                              ],
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              )),
                        ),
                        Checkbox(
                          activeColor: Colors.white,
                          checkColor: Colors.green,
                          value: hasReadPolicy,
                          onChanged: (value) {
                            setState(() {
                              hasReadPolicy = value!;
                            });
                          },
                        ),
                      ]),
                ),
              ),
              SizedBox(
                height: heightP(context, 0.002),
              ),
              Container(
                width: widthP(context, 0.9),
                margin: EdgeInsets.symmetric(vertical: 10),
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
                        onPressed: hasReadPolicy &
                                emailIsValid &
                                nameIsValid &
                                surnameIsValid &
                                passwordIsValid &
                                confirmpasswordIsValid
                            ? sendRegister
                            : null,
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        )),
              ),
            ],
          )),
    ));
  }
}
