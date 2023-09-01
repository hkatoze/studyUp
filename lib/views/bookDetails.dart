import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shimmer/shimmer.dart';
import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';

import 'package:study_up/views/audioRead.dart';
import 'package:study_up/views/audioTest.dart';
import 'package:study_up/views/notificationsServices.dart';
import 'package:study_up/views/profilPage.dart';
import 'package:study_up/views/readerPage.dart';
import 'package:study_up/views/widgets/bottomBar.dart';

class BookDetailsPage extends StatefulWidget {
  final String? bookpicture;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookPrice;
  final String? bookDescription;
  final String? bookCategory;
  final String? bookLanguage;
  final String? bookEditor;
  final String? book;

  final int? id;
  final List<dynamic>? libraryBookList;
  final List<dynamic>? bookAddedList;
  final List<dynamic>? catList;
  final int? internet;
  final String? amount;
  BookDetailsPage(
      {Key? key,
      required this.internet,
      required this.bookAddedList,
      this.amount,
      required this.id,
      required this.catList,
      required this.bookAuthor,
      required this.bookCategory,
      required this.book,
      required this.bookDescription,
      required this.bookEditor,
      required this.bookLanguage,
      required this.bookPrice,
      required this.bookTitle,
      required this.bookpicture,
      required this.libraryBookList})
      : super(key: key);

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  var user_id = '';
  var book_id = '';
  var auth_token = '';
  bool _isAddToLibrary = false;
  bool _isPaid = false;
  bool _isInLibrary = false;
  bool _isLoadingPaying = false;
  bool _achatValidadted = true;
  List<String> libraryBookIdList = [];

  void initState() {
    super.initState();

    readUserId().then((String result) {
      setState(() {
        user_id = result;
      });
    });
    readCredentials().then((String result) {
      setState(() {
        auth_token = result;
      });
    });
    stockBookId();
    print(widget.id);
    print(libraryBookIdList);
  }

  void notification(String title, String author) {
    NotificationService().showNotification(1, "Achat de livre",
        "Vous avez acheté le livre ${title} de ${author}", 5);
  }

  void listen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AudioRead(
                bookTitle: widget.bookTitle!,
                bookAuthor: widget.bookAuthor!,
                bookPicture: widget.bookpicture!,
                book: widget.book!,
              )),
    );

    /*  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AudioTest()),
    ); */
  }

  void stockBookId() {
    for (int i = 0; i < widget.libraryBookList!.length; i++) {
      libraryBookIdList.add(widget.libraryBookList![i].bookModel.bookTitle);
    }
  }

  bool checkingIfBookInLibrary(String id) {
    if (libraryBookIdList.contains(id) == true) {
      setState(() {
        _isInLibrary = true;
      });
      return true;
    } else {
      return false;
    }
  }

  void read() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReaderPage(widget.book!, widget.bookTitle!,
              widget.id!, widget.libraryBookList!)),
    );
  }

  void buy() async {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.WARNING,
      body: Center(
        child: Text(
          "Voulez vous acheter ${widget.bookTitle} ?",
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
          _isLoadingPaying = true;
        });

        var response = await buyBook(
            user_id, widget.id.toString(), widget.bookPrice!, auth_token);
        setState(() {
          _isLoadingPaying = false;
        });
        if (response ==
            "Compte insufisant!!! veuillez recharger le recharger") {
          setState(() {
            AwesomeDialog(
              context: context,
              animType: AnimType.SCALE,
              dialogType: DialogType.WARNING,
              body: Center(
                child: Text(
                  "Votre compte est insuffisant !\nVoulez vous faire un dépôt ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: "achat échouer!",
              btnOkColor: kPrimaryColor,
              btnCancelColor: kPrimaryColor,
              btnOkText: "FAIRE UN DEPOT",
              btnCancelText: "ANNULER",
              btnCancelOnPress: () {
                Navigator.canPop(context);
              },
              btnOkOnPress: () async {
                depositModalSheet(context);
              },
            )..show();
          });
        } else if (response == "Achat effectué avec succés") {
          addToLibrary();
          Fluttertoast.showToast(
              msg: "Achat de livre réussi!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          notification(widget.bookTitle!, widget.bookAuthor!);
          saveNotififications("Achat de livre|Achat de ${widget.bookTitle!}|" +
              DateTime.now().hour.toString() +
              ":" +
              DateTime.now().minute.toString() +
              "|-" +
              widget.bookPrice! +
              " Frs");
        } else {
          Fluttertoast.showToast(
              msg: "Erreur du serveur ,réessayer",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      },
    )..show();
  }

  void addToLibrary() async {
    setState(() {
      _isAddToLibrary = true;
    });

    var response = await addToLib(user_id, widget.id.toString(), auth_token);
    setState(() {
      _isAddToLibrary = false;
    });

    if (response == "Ajout du livre à été un succès") {
      Fluttertoast.showToast(
          msg: "Ajout de livre réussi!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Erreur de serveur,réessayer",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavBarWidget(
          index: 0,
          bookAddedList: widget.bookAddedList,
          libraryBookList: widget.libraryBookList,
          catList: widget.catList,
          internet: widget.internet,
        ),
        body: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          padding: EdgeInsets.all(5),
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
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 7.0,
                                  color: kPrimaryColor.withOpacity(0.5))
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: CachedNetworkImage(
                                height: 265,
                                width: widthP(context, 0.45),
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return Shimmer.fromColors(
                                    child: Container(
                                      height: 265,
                                      width: widthP(context, 0.45),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: SpinKitFadingCircle(
                                          color: Colors.blue),
                                    ),
                                    baseColor:
                                        Color.fromARGB(255, 226, 224, 224),
                                    highlightColor:
                                        Color.fromARGB(255, 250, 250, 250),
                                    enabled: true,
                                  );
                                },
                                imageUrl:
                                    "https://bookstudy.smt-group.net/image/${widget.bookpicture!}"),
                          ),
                        ),
                        Container(
                          height: 280,
                          width: widthP(context, 0.45),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    widget.bookTitle!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  child: Text(
                                    widget.bookAuthor!.toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.4),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                InkWell(
                                    onTap: widget.bookPrice == null &&
                                            checkingIfBookInLibrary(
                                                    widget.bookTitle!) ==
                                                false
                                        ? addToLibrary
                                        : null,
                                    child: _isAddToLibrary
                                        ? SpinKitThreeInOut(
                                            color: KSecondaryColor,
                                            size: 26,
                                          )
                                        : Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: _isInLibrary
                                                    ? Colors.green
                                                    : KSecondaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: Text(
                                              checkingIfBookInLibrary(
                                                          widget.bookTitle!) ==
                                                      true
                                                  ? "Existe déjà"
                                                  : (widget.bookPrice == null
                                                      ? "Ajouter à ma librarie"
                                                      : widget.bookPrice! +
                                                          " Frs"),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                SizedBox(
                                  height: 50,
                                ),
                                (widget.bookPrice != null ||
                                            !checkingIfBookInLibrary(
                                                widget.bookTitle!)) &&
                                        _isLoadingPaying
                                    ? SpinKitThreeInOut(
                                        color: kPrimaryColor,
                                      )
                                    : Container(
                                        width: widthP(context, 0.9),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Color(0XFF223170),
                                              padding: EdgeInsets.all(13),
                                              shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        7.0),
                                              ),
                                            ),
                                            onPressed: () {
                                              if (widget.bookPrice == null ||
                                                  checkingIfBookInLibrary(
                                                      widget.bookTitle!)) {
                                                read();
                                              } else {
                                                buy();
                                              }
                                            },
                                            child: Text(
                                              widget.bookPrice == null ||
                                                      checkingIfBookInLibrary(
                                                          widget.bookTitle!)
                                                  ? "LIRE"
                                                  : "PAYER",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17),
                                            )),
                                      ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: widthP(context, 0.9),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Color(0XFF223170),
                                        padding: EdgeInsets.all(13),
                                        shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(7.0),
                                        ),
                                      ),
                                      onPressed: widget.bookPrice == null ||
                                              checkingIfBookInLibrary(
                                                  widget.bookTitle!)
                                          ? listen
                                          : null,
                                      child: Text(
                                        "ECOUTER",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      )),
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Text(
                      "Description:",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Text(widget.bookDescription!),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: KSecondaryColor,
                                borderRadius: BorderRadius.circular(7)),
                            child: RichText(
                              text: TextSpan(
                                  text: "Catégorie:  ",
                                  children: [
                                    TextSpan(
                                        text: widget.bookCategory,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor))
                                  ],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: KSecondaryColor,
                                borderRadius: BorderRadius.circular(7)),
                            child: RichText(
                              text: TextSpan(
                                  text: "Langue:  ",
                                  children: [
                                    TextSpan(
                                        text: widget.bookLanguage,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor))
                                  ],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: KSecondaryColor,
                                borderRadius: BorderRadius.circular(7)),
                            child: RichText(
                              maxLines: 1,
                              text: TextSpan(
                                  text: "Editeur:  ",
                                  children: [
                                    TextSpan(
                                        text: widget.bookEditor,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor))
                                  ],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ]),
                  )
                ],
              )),
        ));
  }
}
