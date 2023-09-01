import 'dart:io';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:restart_app/restart_app.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:study_up/animation/ScaleRoute.dart';
import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';

import 'package:study_up/views/notificationsPage.dart';
import 'package:study_up/views/notificationsServices.dart';
import 'package:study_up/views/widgets/bottomBar.dart';
import 'package:study_up/views/widgets/webviewSpace.dart';
import 'package:study_up/views/widgets/widget.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfilPage extends StatefulWidget {
  final String auth_token;
  const ProfilPage({
    Key? key,
    required this.auth_token,
  }) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool inDeconnextionProcess = false;

  var username = "";
  var email = "";
  int bookLength = 0;
  String _profilImg = 'empty';
  dynamic _profilImgDefault = AssetImage("assets/images/user.png");
  @override
  void initState() {
    super.initState();

    readEmail().then((String result) {
      setState(() {
        email = result;
      });
    });
    readUserName().then((String result) {
      setState(() {
        username = result;
      });
    });
    readProfilPath().then((String result) => () {
          setState(() {
            _profilImg = result;
          });
          print(result);
        });

    readBookLength().then((int value) {
      setState(() {
        bookLength = value;
      });
    });
  }

  getImage() async {
    var _pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _profilImg = _pickedFile!.path;
    });

    await writeProfilPath(_profilImg);
  }

  dynamic viewProfilImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            alignment: Alignment.topCenter,
            content: Container(
              height: heightP(context, 0.4),
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: _profilImg == "empty"
                        ? _profilImgDefault
                        : FileImage(File(_profilImg))),
              ),
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          getImage();
                          Navigator.pop(context);
                        },
                        child: Text("Changer")),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Fermer"))
                  ],
                ),
              )
            ],
          );
        });
  }

  void openInstagramOrTwitter(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      throw 'There was a problem to open the url: $url';
    }
  }

  Stream<List<dynamic>> _getBook() async* {
    while (true) {
      final _bookAdded = await getBookRecentlyAdded(widget.auth_token);
      notification(_bookAdded);
      await Future.delayed(Duration(seconds: 1));

      yield _bookAdded;
    }
  }

  Stream<int> _internetStatus() async* {
    while (true) {
      final _internet = await internetCheck();
      await Future.delayed(Duration(seconds: 1));

      yield _internet;
    }
  }

  Stream<List<dynamic>> _getCat() async* {
    while (true) {
      final _cat = await getCategories(widget.auth_token);
      await Future.delayed(Duration(seconds: 1));

      yield _cat;
    }
  }

  Stream<String> _getAmount() async* {
    while (true) {
      final amount = await getAmount(widget.auth_token) == null
          ? "......."
          : await getAmount(widget.auth_token);
      await Future.delayed(Duration(seconds: 1));

      yield amount;
    }
  }

  Stream<List<dynamic>> _getLibraryBook() async* {
    while (true) {
      final _favorisBook = await getFavorisBook(widget.auth_token);
      await Future.delayed(Duration(seconds: 1));

      yield _favorisBook;
    }
  }

  void notification(List<dynamic> bookAdded) {
    if (bookAdded.length > bookLength &&
        (widget.auth_token != '' || widget.auth_token != "empty")) {
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

  void openFacebook() async {
    // Don't use canLaunch because of fbProtocolUrl (fb://)
    try {
      bool launched = await launch(
          Platform.isIOS
              ? "fb://profile/104972078267223"
              : "fb://page/104972078267223",
          forceSafariVC: false,
          forceWebView: false);
      if (!launched) {
        await launch("https://www.facebook.com/smartouchgroup",
            forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch("https://www.facebook.com/smartouchgroup",
          forceSafariVC: false, forceWebView: false);
    }
  }

  Widget futureMethod() {
    return StreamBuilder(
      stream: _getBook(), // async work
      builder:
          (BuildContext context, AsyncSnapshot<List<dynamic>> bookAddedList) {
        return StreamBuilder(
            stream: _getAmount(),
            builder: (BuildContext context, AsyncSnapshot<String> amount) {
              return StreamBuilder(
                  stream: _getLibraryBook(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<dynamic>> libraryBookList) {
                    return StreamBuilder(
                        stream: _getCat(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<dynamic>> catList) {
                          return Scaffold(
                            bottomNavigationBar: BottomNavBarWidget(
                              index: 2,
                              amount: amount.data,
                              bookAddedList: bookAddedList.data,
                              libraryBookList: libraryBookList.data,
                              catList: catList.data,
                            ),
                            body: SingleChildScrollView(
                                physics: BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: heightP(context, 0.1),
                                    ),
                                    Container(
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                SizedBox(
                                                  height:
                                                      heightP(context, 0.05),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    settingsModalSheet(context);
                                                  },
                                                  child: Container(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Card(
                                                      elevation: 10,
                                                      shape: RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color:
                                                                  KSecondaryColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100)),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 2),
                                                        height: 40,
                                                        width: 40,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100)),
                                                        child: Icon(
                                                          Icons.settings_sharp,
                                                          color: kPrimaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                showMenu(
                                                  context: context,
                                                  position: RelativeRect.fromLTRB(
                                                      10,
                                                      10,
                                                      10,
                                                      10), //here you can specify the location,
                                                  items: [
                                                    PopupMenuItem(
                                                      value: 0,
                                                      onTap: () {},
                                                      child:
                                                          Text("Voir la photo"),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 1,
                                                      onTap: () {},
                                                      child: Text(
                                                          "Changer de photo"),
                                                    ),
                                                  ],
                                                ).then((value) {
                                                  if (value == 0) {
                                                    viewProfilImage(context);
                                                  } else if (value == 1) {
                                                    getImage();
                                                    print("change image");
                                                  } else {}
                                                });
                                              },
                                              child: Container(
                                                alignment: Alignment.topCenter,
                                                child: Card(
                                                  elevation: 10,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color:
                                                              KSecondaryColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100)),
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 2),
                                                    height: 100,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100)),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          image: DecorationImage(
                                                              image: _profilImg ==
                                                                      "empty"
                                                                  ? _profilImgDefault
                                                                  : FileImage(File(
                                                                      _profilImg)),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(
                                                  height:
                                                      heightP(context, 0.05),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    EditInformations(context);
                                                  },
                                                  child: Container(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Card(
                                                      elevation: 10,
                                                      shape: RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color:
                                                                  KSecondaryColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100)),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 2),
                                                        height: 40,
                                                        width: 40,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100)),
                                                        child: Icon(
                                                          Icons.edit_sharp,
                                                          color: kPrimaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      child: Text(
                                        username,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      child: Text(
                                        email,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: KSecondaryColor),
                                      ),
                                    ),
                                    SizedBox(
                                      height: heightP(context, 0.1),
                                    ),
                                    InkWell(
                                      child: ProfilElement(
                                        icon: Icons.wallet,
                                        title: "Mon Portefeuille",
                                        numOfItems: 0,
                                      ),
                                      onTap: () {
                                        AwesomeDialog(
                                          aligment: Alignment.center,
                                          context: context,
                                          animType: AnimType.SCALE,
                                          dialogType: DialogType.NO_HEADER,
                                          body: WalletDialog(
                                            token: widget.auth_token,
                                          ),
                                          title: "Mon portefeuille",
                                        )..show();
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          NotificationModalSheet(context);
                                        },
                                        child: ProfilElement(
                                          icon: Icons.notifications,
                                          title: "Notifications",
                                          numOfItems: 0,
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        AwesomeDialog(
                                          context: context,
                                          animType: AnimType.SCALE,
                                          dialogType: DialogType.NO_HEADER,
                                          body: PasswordChangingModal(
                                            auth_token: widget.auth_token,
                                          ),
                                          title: "Changement de mot de passe !",
                                        )..show();
                                      },
                                      child: ProfilElement(
                                        icon: Icons.password,
                                        title: "Changer mon mot de passe",
                                        numOfItems: 0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    InkWell(
                                      child: ProfilElement(
                                        icon: Icons.logout,
                                        title: "Se déconnecter",
                                        numOfItems: 0,
                                      ),
                                      onTap: () {
                                        AwesomeDialog(
                                          context: context,
                                          animType: AnimType.SCALE,
                                          dialogType: DialogType.WARNING,
                                          body: Center(
                                            child: Text(
                                              "Voulez vous vraiment vous déconnecter de StudyUp ?",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: "Connexion échouer!",
                                          btnOkColor: kPrimaryColor,
                                          btnCancelColor: kPrimaryColor,
                                          btnOkText: "OUI",
                                          btnCancelText: "ANNULER",
                                          btnCancelOnPress: () {
                                            Navigator.canPop(context);
                                          },
                                          btnOkOnPress: () async {
                                            setState(() {
                                              inDeconnextionProcess = true;
                                            });

                                            var internet =
                                                await internetCheck();
                                            int response =
                                                await logout(widget.auth_token);

                                            if (response == null ||
                                                internet != 200) {
                                              setState(() {
                                                inDeconnextionProcess = false;
                                              });
                                              Fluttertoast.showToast(
                                                  msg: "Echec de déconnexion !",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
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
                                                        ? "Echec de déconnexion au server\nVérifier votre connexion internet et réessayer !"
                                                        : "Une erreur a intervenue lors de votre déconnexion\nVeuilez réessayer plus-tard.",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                title: "Connexion échouer!",
                                                btnOkColor: Colors.red,
                                                btnOkText: "OK",
                                                btnOkOnPress: () {
                                                  Navigator.canPop(context);
                                                },
                                              )..show();
                                            } else {
                                              setState(() {
                                                inDeconnextionProcess = false;
                                              });

                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Déconnexion du serveur réussie !",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.green,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                              writeCredentials("empty");
                                              Restart.restartApp();
                                            }
                                          },
                                        )..show();
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                openFacebook();
                                              },
                                              child: Container(
                                                alignment: Alignment.topCenter,
                                                child: Card(
                                                  elevation: 10,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color:
                                                              KSecondaryColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100)),
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 2),
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100)),
                                                    child: Center(
                                                        child: FaIcon(
                                                      FontAwesomeIcons
                                                          .facebookF,
                                                      color: kPrimaryColor,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                openInstagramOrTwitter(
                                                    "https://www.twitter.com/smartouchgroup");
                                              },
                                              child: Container(
                                                alignment: Alignment.topCenter,
                                                child: Card(
                                                  elevation: 10,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color:
                                                              KSecondaryColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100)),
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 2),
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100)),
                                                    child: Center(
                                                        child: FaIcon(
                                                      FontAwesomeIcons.twitter,
                                                      color: kPrimaryColor,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                openInstagramOrTwitter(
                                                    "https://www.instagram.com/_u/smartouchgroup1");
                                              },
                                              child: Container(
                                                alignment: Alignment.topCenter,
                                                child: Card(
                                                  elevation: 10,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color:
                                                              KSecondaryColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100)),
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 2),
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100)),
                                                    child: Center(
                                                        child: FaIcon(
                                                      FontAwesomeIcons
                                                          .instagram,
                                                      color: kPrimaryColor,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ]),
                                    ),
                                  ],
                                )),
                          );
                        });
                  });
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return futureMethod();
  }
}

void NotificationModalSheet(BuildContext context) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      context: context,
      isScrollControlled: true,
      builder: (context) => NotificationPage());
}

void depositModalSheet(BuildContext context) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      context: context,
      isScrollControlled: true,
      builder: (context) => DoMoneyDeposit());
}

void settingsModalSheet(BuildContext context) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      context: context,
      isScrollControlled: true,
      builder: (context) => SettingsModal());
}

void EditInformations(BuildContext context) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ChangeProfilBottom();
      });
}

class SettingsModal extends StatefulWidget {
  const SettingsModal({Key? key}) : super(key: key);

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  String appName = "Unknow";
  String packageName = "Unknow";
  String version = "Unknow";
  String buildNumber = "Unknow";

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    appInfos();
  }

  Future<void> appInfos() async {
    _packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = _packageInfo.appName;
      packageName = _packageInfo.packageName;
      version = _packageInfo.version;
      buildNumber = _packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightP(context, 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          height: 10,
        ),
        Container(
            child: Text(
          "Settings",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: kPrimaryColor),
        )),
        SizedBox(
          height: 30,
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Appropos()),
            );
          },
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: widthP(context, 0.17)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "À propos de StudyUp",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              )),
        ),
        SizedBox(
          height: heightP(context, 0.04),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Politics()),
            );
          },
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: widthP(context, 0.05)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Nos conditions de services & d'utilisation ",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              )),
        ),
        Expanded(child: Container()),
        Container(
            child: Text(
          "Version",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, color: KSecondaryColor),
        )),
        Container(
            child: Text(
          version,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: KSecondaryColor),
        )),
        SizedBox(
          height: 5,
        ),
        Container(
          child: Text(
            "Copyright-" +
                DateTime.now().year.toString() +
                " | Smart Touch Group",
            style: TextStyle(
                color: Color(0xFF787878).withOpacity(0.5),
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 5,
        )
      ]),
    );
  }
}

class DoMoneyDeposit extends StatefulWidget {
  const DoMoneyDeposit({Key? key}) : super(key: key);

  @override
  State<DoMoneyDeposit> createState() => _DoMoneyDepositState();
}

class _DoMoneyDepositState extends State<DoMoneyDeposit> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  bool inLoginProcessBottom = false;

  var auth_token;

  void initState() {
    super.initState();

    readCredentials().then((String result) {
      setState(() {
        auth_token = result;
      });
      print("Auth_token reccupéré :" + auth_token);
    });
  }

  void notification(String amount) {
    NotificationService().showNotification(1, "Dépôt dans portefeuille",
        "Dépôt de ${amount} Frs dans votre portefeuille", 5);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 30),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.topLeft,
              child: Text(
                "Formulaire de dépôt",
                style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w400),
              )),
          SizedBox(
            height: 17,
          ),
          Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.topLeft,
              color: kPrimaryColor.withOpacity(0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_sharp),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 290,
                          child: Text(
                            "Veuillez composer le code suivant sur votre téléphone avant de procéder !",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                            width: 290,
                            child: Text(
                              "*144*XXXXXX*3*montant#",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                  ),
                  Container()
                ],
              )),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Numéro de téléphone",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                IntlPhoneField(
                  controller: phoneController,
                  dropdownTextStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFebd6cf),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: kPrimaryColor,
                    ),
                    hintText: "Numéro de téléphone du dépôt",
                    hintStyle:
                        TextStyle(color: Color(0XFFc97a63), fontSize: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0XFFc97a63),
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: kPrimaryColor,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  initialCountryCode: 'BF',
                  onChanged: (phone) {
                    print(phone.completeNumber);
                  },
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  "Montant",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFebd6cf),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.money,
                      color: kPrimaryColor,
                    ),
                    hintText: "Entrer le montant ",
                    hintStyle:
                        TextStyle(color: Color(0XFFc97a63), fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0XFFc97a63),
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: kPrimaryColor,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Le Code OTP",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: otpController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFebd6cf),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.password,
                      color: kPrimaryColor,
                    ),
                    hintText: "Entrer le code OTP ",
                    hintStyle:
                        TextStyle(color: Color(0XFFc97a63), fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0XFFc97a63),
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: kPrimaryColor,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                )
              ],
            )),
          ),
          SizedBox(
            height: 8,
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Entrer le code OTP que vous avez reçu par SMS",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 15,
                ),
                textAlign: TextAlign.start,
              )),
          SizedBox(
            height: 8,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            width: 95,
            child: Center(
              child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: inLoginProcessBottom
                      ? SpinKitFadingCircle(color: kPrimaryColor)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            primary: kPrimaryColor,
                          ),
                          onPressed: () async {
                            Navigator.canPop(context);
                            AwesomeDialog(
                                context: context,
                                animType: AnimType.SCALE,
                                dialogType: DialogType.QUESTION,
                                body: Center(
                                  child: Text(
                                    "Voulez vous faire un dépôt de ${amountController.text} Frs sur votre portefeuille ?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: "Connexion échouer!",
                                btnOkColor: kPrimaryColor,
                                btnCancelColor: kPrimaryColor,
                                btnOkText: "OUI",
                                btnCancelText: "ANNULER",
                                btnCancelOnPress: () {
                                  Navigator.canPop(context);
                                },
                                btnOkOnPress: () async {
                                  setState(() {
                                    inLoginProcessBottom =
                                        !inLoginProcessBottom;
                                  });
                                  int response = await MakeDeposit(
                                      phoneController.text,
                                      amountController.text,
                                      otpController.text,
                                      auth_token);

                                  var internet = await internetCheck();

                                  if (response == 400 || response == null) {
                                    setState(() {
                                      inLoginProcessBottom =
                                          !inLoginProcessBottom;
                                    });
                                    Fluttertoast.showToast(
                                        msg: "Echec du dépôt !",
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
                                              : "Les informations entrées ne sont pas conformes\nVeuillez saisir des informations valides.",
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
                                        Navigator.canPop(context);
                                      },
                                    )..show();
                                  } else {
                                    notification(amountController.text);
                                    saveNotififications(
                                        "Dépôt d'argent|Dépôt sur votre portefeuille|" +
                                            DateTime.now().hour.toString() +
                                            ":" +
                                            DateTime.now().minute.toString() +
                                            "|+" +
                                            amountController.text +
                                            " Frs");

                                    setState(() {
                                      inLoginProcessBottom =
                                          !inLoginProcessBottom;
                                    });
                                    Fluttertoast.showToast(
                                        msg: "Dépôt éffectuée !",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0);

                                    phoneController.clear();
                                    amountController.clear();
                                    otpController.clear();
                                    setState(() {});
                                    Navigator.pop(context);
                                  }
                                })
                              ..show();
                          },
                          child: Text(
                            "Envoyer",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ))),
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}

class WalletDialog extends StatefulWidget {
  final String token;
  const WalletDialog({Key? key, required this.token}) : super(key: key);

  @override
  State<WalletDialog> createState() => _WalletDialogState();
}

class _WalletDialogState extends State<WalletDialog> {
  void initState() {
    super.initState();
  }

  Stream<String> _getAmount() async* {
    while (true) {
      final amount = await getAmount(widget.token);
      await Future.delayed(Duration(seconds: 1));

      yield amount;
    }
  }

  Widget futureMethod() {
    return StreamBuilder(
        stream: _getAmount(),
        builder: (BuildContext context, AsyncSnapshot<String> amount) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "Solde Actuel",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Text(
                    amount.data == null ? "........." : amount.data!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: KSecondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: kPrimaryColor,
                        padding: EdgeInsets.all(15),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(35.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.canPop(context);
                        depositModalSheet(context);
                      },
                      child: Text(
                        "Faire un dépôt",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      )),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return futureMethod();
  }
}

class ChangeProfilBottom extends StatefulWidget {
  const ChangeProfilBottom({Key? key}) : super(key: key);

  @override
  State<ChangeProfilBottom> createState() => _ChangeProfilBottomState();
}

class _ChangeProfilBottomState extends State<ChangeProfilBottom> {
  TextEditingController lastNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool inLoginProcessBottom = false;

  var auth_token;

  void initState() {
    super.initState();
    readCredentials().then((String result) {
      setState(() {
        auth_token = result;
      });
      print("Auth_token reccupéré :" + auth_token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 15,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Nom",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: firstNameController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFebd6cf),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.account_box,
                      color: kPrimaryColor,
                    ),
                    hintText: "Entrer votre nom",
                    hintStyle:
                        TextStyle(color: Color(0XFFc97a63), fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0XFFc97a63),
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: kPrimaryColor,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Prénoms",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: lastNameController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFebd6cf),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.account_box,
                      color: kPrimaryColor,
                    ),
                    hintText: "Entrer votre prénom ",
                    hintStyle:
                        TextStyle(color: Color(0XFFc97a63), fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0XFFc97a63),
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: kPrimaryColor,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ],
            )),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: widthP(context, 0.4),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Center(
                  child: inLoginProcessBottom
                      ? CircularProgressIndicator(
                          color: kPrimaryColor,
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            primary: kPrimaryColor,
                          ),
                          onPressed: () async {
                            setState(() {
                              inLoginProcessBottom = !inLoginProcessBottom;
                            });
                            int response = await changeInformations(
                                firstNameController.text,
                                lastNameController.text,
                                auth_token);

                            var internet = await internetCheck();

                            if (response == null) {
                              setState(() {
                                inLoginProcessBottom = !inLoginProcessBottom;
                              });
                              Fluttertoast.showToast(
                                  msg: "Echec de changement des informations !",
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
                                        : "Les informations entrées ne sont pas conformes\nVeuillez saisir des informations valides.",
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
                                  Navigator.canPop(context);
                                },
                              )..show();
                            } else {
                              setState(() {
                                inLoginProcessBottom = !inLoginProcessBottom;
                              });
                              Fluttertoast.showToast(
                                  msg: "Mise à jour de profil effectuée !",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              writeUserName(lastNameController.text +
                                  " " +
                                  firstNameController.text);
                              firstNameController.clear();
                              lastNameController.clear();
                              phoneController.clear();
                              setState(() {});
                              Navigator.pop(context);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  ScaleRoute(
                                    page: ProfilPage(
                                      auth_token: auth_token,
                                    ),
                                  ),
                                  (Route<dynamic> route) => false);
                            }
                          },
                          child: Center(
                            child: Text(
                              "Modifier",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          )),
                ),
              )),
          SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }
}

class PasswordChangingModal extends StatefulWidget {
  final String auth_token;
  const PasswordChangingModal({Key? key, required this.auth_token})
      : super(key: key);

  @override
  State<PasswordChangingModal> createState() => _PasswordChangingModalState();
}

class _PasswordChangingModalState extends State<PasswordChangingModal> {
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  TextEditingController _oldPassword = TextEditingController();
  ButtonState stateTextWithIcon = ButtonState.idle;
  String oldPassword = "";
  void initState() {
    super.initState();

    readPassword().then((String value) {
      setState(() {
        oldPassword = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 300,
            child: TextFormField(
                controller: _oldPassword,
                decoration: InputDecoration(
                    hintStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    hintText: "Ancien mot de passe")),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            width: 300,
            child: TextFormField(
                controller: _password,
                decoration: InputDecoration(
                    hintStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    hintText: "Nouveau mot de passe")),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            width: 300,
            child: TextFormField(
                controller: _confirmPassword,
                decoration: InputDecoration(
                    hintStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    hintText: "Confirmer mot de passe")),
          ),
          SizedBox(
            height: 15,
          ),
          Center(
            child: ProgressButton.icon(
                iconedButtons: {
                  ButtonState.idle: IconedButton(
                      text: "CHANGER",
                      icon: Icon(Icons.send, color: Colors.white),
                      color: kPrimaryColor),
                  ButtonState.loading: IconedButton(
                      text: "CONNEXION AU SERVEUR", color: kPrimaryColor),
                  ButtonState.fail: IconedButton(
                      text: "ECHEC",
                      icon: Icon(Icons.cancel, color: Colors.white),
                      color: Colors.red),
                  ButtonState.success: IconedButton(
                      text: "Success",
                      icon: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                      color: Colors.green.shade400)
                },
                onPressed: () async {
                  if (stateTextWithIcon == ButtonState.success) {
                    Navigator.pop(context);
                  } else {
                    if (oldPassword == _oldPassword.text) {
                      setState(() {
                        stateTextWithIcon = ButtonState.loading;
                      });
                      int response = await changePassword(
                          _password.text, widget.auth_token);

                      var internet = await internetCheck();

                      if (response == 0) {
                        setState(() {
                          stateTextWithIcon = ButtonState.fail;
                        });

                        Fluttertoast.showToast(
                            msg: "Echec de changement de mot de passe!",
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
                                  : "Le mot de passe inséré n'est pas autorisé !\nVeuillez saisir un mot de passe valide.",
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
                            Navigator.canPop(context);
                          },
                        )..show();
                      } else {
                        setState(() {
                          stateTextWithIcon = ButtonState.success;
                        });

                        Fluttertoast.showToast(
                            msg: "Changement de mot de passe réussi !",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0);

                        _password.clear();
                        _confirmPassword.clear();
                        _oldPassword.clear();
                      }
                    } else {
                      AwesomeDialog(
                        context: context,
                        animType: AnimType.SCALE,
                        dialogType: DialogType.ERROR,
                        body: Center(
                          child: Text(
                            "Votre ancien mot de passe est incorrect.\nVeuillez entrer le bon mot de passe",
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
                          Navigator.canPop(context);
                        },
                      )..show();
                    }
                  }
                },
                state: stateTextWithIcon),
          )
        ],
      ),
    );
  }
}
