import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:html_editor_enhanced/html_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';

import 'package:study_up/views/horsligneBookDetail.dart';
import 'package:study_up/views/notificationsServices.dart';
import 'package:study_up/views/widgets/bottomBar.dart';
import 'package:study_up/views/widgets/widget.dart';

class MyLibraryPage extends StatefulWidget {
  MyLibraryPage({
    Key? key,
  }) : super(key: key);

  @override
  _MyLibraryPageState createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage> {
  var auth_token;
  bool _isAll = true;
  bool _isReading = false;
  bool _isHorsLigne = false;
  bool _isRecently = false;
  bool _isNote = false;
  bool _isNoteEditing = false;
  int bookLength = 0;
  int noteIndex = 0;
  bool isAddnote = false;
  TextEditingController _titleNoteController = TextEditingController();
  HtmlEditorController _noteEditingController = HtmlEditorController();
  List<String> noteTitleList = [];
  List<String> noteBodyList = [];

  @override
  void initState() {
    super.initState();

    readCredentials().then((String result) {
      setState(() {
        auth_token = result;
      });
    });

    readBookLength().then((int value) {
      setState(() {
        bookLength = value;
      });
    });
    noteTitleListRecup();
    noteBodyListRecup();
    print(auth_token);
  }

  void noteTitleListRecup() async {
    final jsonKey = 'json_key_noteTitle';

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(jsonKey) == null) {
      prefs.setStringList(jsonKey, []);
    } else {
      setState(() {
        noteTitleList = prefs.getStringList(jsonKey)!.reversed.toList();
      });
    }
  }

  void noteBodyListRecup() async {
    final jsonKey = 'json_key_noteBody';

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getStringList(jsonKey) == null) {
      prefs.setStringList(jsonKey, []);
    } else {
      setState(() {
        noteBodyList = prefs.getStringList(jsonKey)!.reversed.toList();
      });
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

  Stream<int> _internetStatus() async* {
    while (true) {
      final _internet = await internetCheck();
      await Future.delayed(Duration(seconds: 1));

      yield _internet;
    }
  }

  Stream<List<dynamic>> _getCat() async* {
    while (true) {
      final _cat = await getCategories(auth_token);
      await Future.delayed(Duration(seconds: 1));

      yield _cat;
    }
  }

  Stream<List<dynamic>> _getLibraryBook() async* {
    while (true) {
      final _favorisBook = await getFavorisBook(auth_token);
      await Future.delayed(Duration(seconds: 1));

      yield _favorisBook;
    }
  }

  void deleteNote(int index) async {
    final jsonKey1 = 'json_key_noteTitle';
    final jsonKey2 = 'json_key_noteBody';
    final prefs1 = await SharedPreferences.getInstance();
    final prefs2 = await SharedPreferences.getInstance();
    noteTitleList = prefs1.getStringList(jsonKey1)!;
    noteBodyList = prefs2.getStringList(jsonKey2)!;

    setState(() {
      noteTitleList.removeAt(index);
      noteBodyList.removeAt(index);
    });

    prefs1.setStringList(jsonKey1, noteTitleList);
    prefs2.setStringList(jsonKey2, noteBodyList);
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

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String text = "";
  addNote() async {
    final jsonKey1 = 'json_key_noteTitle';
    final jsonKey2 = 'json_key_noteBody';
    final prefs1 = await SharedPreferences.getInstance();
    final prefs2 = await SharedPreferences.getInstance();

    if (prefs1.getStringList(jsonKey1) == null) {
    } else {
      noteTitleList = prefs1.getStringList(jsonKey1)!;
      noteBodyList = prefs2.getStringList(jsonKey2)!;

      if (noteIndex != 1000) {
        if (noteTitleList.contains(noteTitleList[noteIndex]) == true) {
          noteBodyList[noteIndex] = text;
        }
      } else {
        noteTitleList.add(_titleNoteController.text);
        noteBodyList.add(text);
      }

      prefs1.setStringList(jsonKey1, noteTitleList);
      prefs2.setStringList(jsonKey2, noteBodyList);

      _titleNoteController.clear();
    }
  }

  Widget futureMethod() {
    return StreamBuilder(
      stream: _getBook(), // async work
      builder:
          (BuildContext context, AsyncSnapshot<List<dynamic>> bookAddedList) {
        return StreamBuilder(
            stream: _getLibraryBook(),
            builder: (BuildContext context,
                AsyncSnapshot<List<dynamic>> libraryBookList) {
              return StreamBuilder(
                  stream: _internetStatus(),
                  builder: (BuildContext context, AsyncSnapshot<int> internet) {
                    return StreamBuilder(
                        stream: _getCat(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<dynamic>> catList) {
                          return Scaffold(
                              floatingActionButtonLocation:
                                  FloatingActionButtonLocation.centerFloat,
                              floatingActionButton: _isAll == true &&
                                      _isRecently == false &&
                                      _isNote == true &&
                                      _isReading == false &&
                                      _isHorsLigne == false
                                  ? InkWell(
                                      onTap: () {
                                        AwesomeDialog(
                                          context: context,
                                          animType: AnimType.SCALE,
                                          dialogType: DialogType.NO_HEADER,
                                          body: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    "Nouvelle note",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  width: widthP(context, 0.95),
                                                  child: Theme(
                                                      data: Theme.of(context)
                                                          .copyWith(
                                                              splashColor: Colors
                                                                  .transparent),
                                                      child: TextFormField(
                                                        controller:
                                                            _titleNoteController,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.black),
                                                        onChanged: (value) {},
                                                        decoration:
                                                            InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.grey
                                                              .withOpacity(0.1),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .green,
                                                                    width: 2.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          hintText: "Titre",
                                                          hintStyle: TextStyle(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.6),
                                                              fontSize: 18),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide:
                                                                BorderSide(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          border:
                                                              OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color:
                                                                        kPrimaryColor,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0)),
                                                        ),
                                                      )),
                                                ),
                                              ]),
                                          title: "Connexion échouer!",
                                          btnOkColor: kPrimaryColor,
                                          onDissmissCallback: (value) {
                                            setState(() {
                                              isAddnote = false;
                                            });
                                          },
                                          btnOkText: "EDITER",
                                          btnOkOnPress: () {
                                            Navigator.canPop(context);
                                            setState(() {
                                              _isNoteEditing = true;
                                              isAddnote = true;
                                              noteIndex = 1000;
                                            });
                                          },
                                        )..show();
                                      },
                                      child: CircleAvatar(
                                        child: Icon(Icons.add,
                                            color: Colors.white),
                                        backgroundColor: KSecondaryColor,
                                      ),
                                    )
                                  : Container(),
                              bottomNavigationBar: BottomNavBarWidget(
                                index: 1,
                                bookAddedList: bookAddedList.data,
                                libraryBookList: libraryBookList.data,
                                catList: catList.data,
                                internet: internet.data,
                              ),
                              body: SingleChildScrollView(
                                physics: BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 13),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: heightP(context, 0.05)),
                                          child: Text(
                                            "Ma Librairie",
                                            style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black
                                                    .withOpacity(0.7)),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        SearchWidget(
                                          internet: internet.data == null
                                              ? 400
                                              : internet.data!,
                                          bookAddedList:
                                              bookAddedList.data == null
                                                  ? []
                                                  : bookAddedList.data!,
                                          catList: catList.data == null
                                              ? []
                                              : catList.data!,
                                          libraryBookList:
                                              libraryBookList.data == null
                                                  ? []
                                                  : libraryBookList.data!,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _isAll = true;
                                                      _isRecently = false;
                                                      _isNote = false;
                                                      _isReading = false;
                                                      _isHorsLigne = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    width:
                                                        widthP(context, 0.25),
                                                    decoration: BoxDecoration(
                                                        color: _isAll
                                                            ? kPrimaryColor
                                                            : KSecondaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.dashboard,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          Text(
                                                            "Tout",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ]),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _isAll = false;
                                                      _isReading = true;
                                                      _isHorsLigne = false;
                                                      isAddnote = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    width:
                                                        widthP(context, 0.25),
                                                    decoration: BoxDecoration(
                                                        color: _isReading
                                                            ? kPrimaryColor
                                                            : KSecondaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.auto_stories,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          Text(
                                                            "Lus",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ]),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _isAll = false;
                                                      _isReading = false;
                                                      _isHorsLigne = true;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                        color: _isHorsLigne
                                                            ? kPrimaryColor
                                                            : KSecondaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.cloud,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          Text(
                                                            "Hors ligne",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ]),
                                                  ),
                                                )
                                              ]),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        _isAll
                                            ? (_isRecently
                                                ? RecentlyOpen(
                                                    internet:
                                                        internet.data == null
                                                            ? 400
                                                            : internet.data!,
                                                    bookAddedList: bookAddedList
                                                                .data ==
                                                            null
                                                        ? []
                                                        : bookAddedList.data!,
                                                    libraryBooksList:
                                                        libraryBookList.data ==
                                                                null
                                                            ? []
                                                            : libraryBookList
                                                                .data!,
                                                    catList:
                                                        catList.data == null
                                                            ? []
                                                            : catList.data!,
                                                    auth_token: auth_token,
                                                  )
                                                : (_isNote
                                                    ? (_isNoteEditing
                                                        ? Column(
                                                            children: [
                                                              HtmlEditor(
                                                                controller:
                                                                    _noteEditingController, //required

                                                                htmlEditorOptions: HtmlEditorOptions(
                                                                    shouldEnsureVisible:
                                                                        true,
                                                                    hint:
                                                                        "Ecrivez votre note ici...",
                                                                    initialText: isAddnote ==
                                                                            false
                                                                        ? noteBodyList[
                                                                            noteIndex]
                                                                        : ""),
                                                                otherOptions:
                                                                    OtherOptions(
                                                                  height: heightP(
                                                                      context,
                                                                      0.55),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          primary:
                                                                              Color(0XFF223170),
                                                                          padding:
                                                                              EdgeInsets.all(10),
                                                                          shape:
                                                                              new RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                new BorderRadius.circular(10.0),
                                                                          ),
                                                                        ),
                                                                        onPressed: () {
                                                                          setState(
                                                                              () {
                                                                            _isNoteEditing =
                                                                                false;
                                                                            isAddnote =
                                                                                false;
                                                                            noteIndex =
                                                                                1000;
                                                                          });
                                                                        },
                                                                        child: Text(
                                                                          "Annuler",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 11),
                                                                        )),
                                                                  ),
                                                                  Container(
                                                                    child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          primary:
                                                                              Color(0XFF223170),
                                                                          padding:
                                                                              EdgeInsets.all(10),
                                                                          shape:
                                                                              new RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                new BorderRadius.circular(10.0),
                                                                          ),
                                                                        ),
                                                                        onPressed: () async {
                                                                          var txt =
                                                                              await _noteEditingController.getText();
                                                                          setState(
                                                                              () {
                                                                            text =
                                                                                txt;
                                                                          });
                                                                          print(
                                                                              text);

                                                                          addNote();

                                                                          setState(
                                                                              () {
                                                                            _isNoteEditing =
                                                                                false;
                                                                            isAddnote =
                                                                                false;
                                                                          });
                                                                        },
                                                                        child: Text(
                                                                          "Enregistrer",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 11),
                                                                        )),
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          )
                                                        : (noteTitleList
                                                                    .length ==
                                                                0
                                                            ? EmptyPage(
                                                                message:
                                                                    "Aucune note",
                                                                image:
                                                                    "empty_note.png") //NotePage space
                                                            : Column(
                                                                children: [
                                                                  AnimatedContainer(
                                                                    height: heightP(
                                                                        context,
                                                                        0.5),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            1),
                                                                    curve: Curves
                                                                        .fastOutSlowIn,
                                                                    child: GridView
                                                                        .builder(
                                                                      physics: BouncingScrollPhysics(
                                                                          parent:
                                                                              AlwaysScrollableScrollPhysics()),
                                                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                                                          maxCrossAxisExtent:
                                                                              200,
                                                                          childAspectRatio:
                                                                              0.65,
                                                                          mainAxisSpacing:
                                                                              0.0),
                                                                      itemCount:
                                                                          noteTitleList
                                                                              .length,
                                                                      itemBuilder:
                                                                          (context, index) =>
                                                                              InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            _isNoteEditing =
                                                                                true;
                                                                            noteIndex =
                                                                                index;
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          margin: EdgeInsets.symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 10),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            color:
                                                                                Colors.grey.withOpacity(0.1),
                                                                          ),
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                                                  child: Text(
                                                                                    noteTitleList[index],
                                                                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                                                    Expanded(
                                                                                        child: Container(
                                                                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                                                                      child: Text(
                                                                                        removeAllHtmlTags(noteBodyList[index]),
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        maxLines: 14,
                                                                                        style: TextStyle(),
                                                                                      ),
                                                                                    ))
                                                                                  ]),
                                                                                ),
                                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                  Container(),
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      deleteNote(index);
                                                                                    },
                                                                                    child: Container(
                                                                                        margin: EdgeInsets.symmetric(
                                                                                          horizontal: 5,
                                                                                        ),
                                                                                        child: Icon(Icons.delete, color: Colors.black)),
                                                                                  )
                                                                                ]),
                                                                                SizedBox(
                                                                                  height: 5,
                                                                                )
                                                                              ]),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          10),
                                                                  ShareAppWidget()
                                                                ],
                                                              )))
                                                    : (Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  Column(
                                                                    children: [
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            _isAll =
                                                                                true;
                                                                            _isRecently =
                                                                                true;
                                                                            _isNote =
                                                                                false;
                                                                            _isReading =
                                                                                false;
                                                                            _isHorsLigne =
                                                                                false;
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height: heightP(
                                                                              context,
                                                                              0.3),
                                                                          width: widthP(
                                                                              context,
                                                                              0.45),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            gradient:
                                                                                LinearGradient(colors: [
                                                                              Color(0xFFd8cdef),
                                                                              Color.fromARGB(255, 247, 245, 252),
                                                                            ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                                                                            image:
                                                                                DecorationImage(image: AssetImage("assets/images/current.png")),
                                                                          ),
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                Container(
                                                                                  margin: EdgeInsets.only(left: 10, bottom: 10),
                                                                                  child: Text(
                                                                                    "Récent",
                                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.black.withOpacity(0.7)),
                                                                                  ),
                                                                                )
                                                                              ]),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            _isAll =
                                                                                true;
                                                                            _isRecently =
                                                                                false;
                                                                            _isNote =
                                                                                true;
                                                                            _isReading =
                                                                                false;
                                                                            _isHorsLigne =
                                                                                false;
                                                                            _isNoteEditing =
                                                                                false;
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height: heightP(
                                                                              context,
                                                                              0.2),
                                                                          width: widthP(
                                                                              context,
                                                                              0.45),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(
                                                                                  10),
                                                                              image: DecorationImage(
                                                                                  image: AssetImage(
                                                                                      "assets/images/notes.png")),
                                                                              gradient: LinearGradient(colors: [
                                                                                Color(0xFFf2e8c8),
                                                                                Color.fromARGB(255, 255, 250, 236)
                                                                              ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                Container(
                                                                                  margin: EdgeInsets.only(left: 10, bottom: 10),
                                                                                  child: Text(
                                                                                    "Notes",
                                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.black.withOpacity(0.7)),
                                                                                  ),
                                                                                )
                                                                              ]),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  Column(
                                                                    children: [
                                                                      InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              _isAll = false;
                                                                              _isReading = true;
                                                                              _isHorsLigne = false;
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                heightP(context, 0.2),
                                                                            width:
                                                                                widthP(context, 0.45),
                                                                            decoration: BoxDecoration(
                                                                                image: DecorationImage(
                                                                                    image: AssetImage(
                                                                                        "assets/images/read.png")),
                                                                                borderRadius: BorderRadius.circular(
                                                                                    10),
                                                                                gradient: LinearGradient(colors: [
                                                                                  Color(0xFFffe29e),
                                                                                  Color(0xFFffe29e)
                                                                                ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                                                                            child:
                                                                                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                              Container(
                                                                                margin: EdgeInsets.only(left: 10, bottom: 10),
                                                                                child: Text(
                                                                                  "Lus",
                                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.black.withOpacity(0.7)),
                                                                                ),
                                                                              )
                                                                            ]),
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              _isAll = false;
                                                                              _isReading = false;
                                                                              _isHorsLigne = true;
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                heightP(context, 0.3),
                                                                            width:
                                                                                widthP(context, 0.45),
                                                                            decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                image: DecorationImage(image: AssetImage("assets/images/saved.png")),
                                                                                gradient: LinearGradient(colors: [
                                                                                  Color(0xFFcbe3d4),
                                                                                  Color.fromARGB(255, 235, 255, 242),
                                                                                ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                                                                            child:
                                                                                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                              Container(
                                                                                margin: EdgeInsets.only(left: 10, bottom: 10),
                                                                                child: Text(
                                                                                  "Hors ligne",
                                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.black.withOpacity(0.7)),
                                                                                ),
                                                                              )
                                                                            ]),
                                                                          ))
                                                                    ],
                                                                  )
                                                                ]),
                                                            SizedBox(
                                                                height: 10),
                                                            ShareAppWidget()
                                                          ]))))
                                            : (_isHorsLigne
                                                ? HorsLigneBooks(
                                                    internet:
                                                        internet.data == null
                                                            ? 400
                                                            : internet.data!,
                                                    catList:
                                                        catList.data == null
                                                            ? []
                                                            : catList.data!,
                                                    bookAddedList: bookAddedList
                                                                .data ==
                                                            null
                                                        ? []
                                                        : bookAddedList.data!,
                                                    libraryBookList:
                                                        libraryBookList.data ==
                                                                null
                                                            ? []
                                                            : libraryBookList
                                                                .data!,
                                                    auth_token: auth_token,
                                                  )
                                                : BookReadTerminated(
                                                    internet:
                                                        internet.data == null
                                                            ? 400
                                                            : internet.data!,
                                                    catList:
                                                        catList.data == null
                                                            ? []
                                                            : catList.data!,
                                                    bookAddedList: bookAddedList
                                                                .data ==
                                                            null
                                                        ? []
                                                        : bookAddedList.data!,
                                                    libraryBooksList:
                                                        libraryBookList.data ==
                                                                null
                                                            ? []
                                                            : libraryBookList
                                                                .data!,
                                                    auth_token: auth_token,
                                                  ))
                                      ],
                                    )),
                              ));
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

class HorsLigneBooks extends StatefulWidget {
  final List<dynamic> libraryBookList;
  final List<dynamic> bookAddedList;
  final List<dynamic> catList;
  final int internet;

  final String auth_token;

  const HorsLigneBooks({
    Key? key,
    required this.libraryBookList,
    required this.internet,
    required this.catList,
    required this.bookAddedList,
    required this.auth_token,
  }) : super(key: key);

  @override
  State<HorsLigneBooks> createState() => _HorsLigneBooksState();
}

class _HorsLigneBooksState extends State<HorsLigneBooks> {
  @override
  Widget build(BuildContext context) {
    return widget.libraryBookList.length == 0
        ? EmptyPage(
            message: "Aucun Livre dans votre librairie",
            image: "empty_books.png",
          )
        : Column(
            children: [
              AnimatedContainer(
                height: heightP(context, 0.5),
                duration: Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                child: GridView.builder(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 130,
                      childAspectRatio: 1 / 2.2,
                      mainAxisSpacing: 0.0),
                  itemCount: widget.libraryBookList.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HorsligneBookDetails(
                                  internet: widget.internet,
                                  catList: widget.catList,
                                  libraryBookList: widget.libraryBookList,
                                  bookAddedList: widget.bookAddedList,
                                  id: widget.libraryBookList.reversed
                                      .toList()[index]
                                      .id,
                                  bookpicture: widget.libraryBookList.reversed
                                      .toList()[index]
                                      .bookModel
                                      .bookPicture,
                                  bookTitle: widget.libraryBookList.reversed
                                      .toList()[index]
                                      .bookModel
                                      .bookTitle,
                                  bookAuthor: widget.libraryBookList.reversed
                                      .toList()[index]
                                      .bookModel
                                      .author!
                                      .author,
                                  bookPrice: widget.libraryBookList.reversed
                                      .toList()[index]
                                      .bookModel
                                      .price,
                                  bookDescription: widget
                                      .libraryBookList.reversed
                                      .toList()[index]
                                      .bookModel
                                      .description,
                                  bookCategory: widget.libraryBookList.reversed
                                      .toList()[index]
                                      .bookModel
                                      .category!
                                      .categ,
                                  bookLanguage: widget.libraryBookList.reversed
                                      .toList()[index]
                                      .bookModel
                                      .language!
                                      .lang,
                                  bookEditor: widget.libraryBookList.reversed
                                      .toList()[index]
                                      .bookModel
                                      .editor!
                                      .editor,
                                  book: widget.libraryBookList.reversed
                                      .toList()[index]
                                      .bookModel
                                      .book,
                                )),
                      );
                    },
                    child: HorsligneBookItem(
                      index: index,
                      libraryBookList: widget.libraryBookList,
                      auth_token: widget.auth_token,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ShareAppWidget()
            ],
          );
  }
}

class HorsligneBookItem extends StatefulWidget {
  final List<dynamic> libraryBookList;

  final String auth_token;
  final int index;

  const HorsligneBookItem({
    Key? key,
    required this.libraryBookList,
    required this.auth_token,
    required this.index,
  });

  @override
  State<HorsligneBookItem> createState() => _HorsligneBookItemState();
}

class _HorsligneBookItemState extends State<HorsligneBookItem> {
  bool loading = false;
  void deleteFromLibrary(int bookId) async {
    await deleteFromLib(widget.auth_token, bookId.toString());

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 7),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 7.0, color: kPrimaryColor.withOpacity(0.5))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: CachedNetworkImage(
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return Shimmer.fromColors(
                    child: Container(
                      height: 150,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(7)),
                      child: SpinKitFadingCircle(color: Colors.blue),
                    ),
                    baseColor: Color.fromARGB(255, 226, 224, 224),
                    highlightColor: Color.fromARGB(255, 250, 250, 250),
                    enabled: true,
                  );
                },
                imageUrl:
                    "https://bookstudy.smt-group.net/image/${widget.libraryBookList.reversed.toList()[widget.index].bookModel.bookPicture}"),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
            "${widget.libraryBookList.reversed.toList()[widget.index].bookModel.bookTitle}",
            style: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: kPrimaryColor,
                fontWeight: FontWeight.bold)),
        Container(
          width: double.infinity,
          child: loading
              ? SpinKitThreeInOut(
                  color: KSecondaryColor,
                  size: 25,
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      loading = true;
                    });
                    deleteFromLibrary(widget.libraryBookList.reversed
                        .toList()[widget.index]
                        .id);
                  },
                  child: Text(
                    "Retirer",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  )),
        ),
      ]),
    );
  }
}

class BookReadTerminated extends StatefulWidget {
  final List<dynamic> libraryBooksList;
  final String auth_token;

  final List<dynamic>? bookAddedList;
  final List<dynamic>? catList;
  final int? internet;
  BookReadTerminated(
      {Key? key,
      required this.libraryBooksList,
      required this.bookAddedList,
      required this.catList,
      required this.internet,
      required this.auth_token})
      : super(key: key);

  @override
  State<BookReadTerminated> createState() => _BookReadTerminatedState();
}

class _BookReadTerminatedState extends State<BookReadTerminated> {
  List<String> bookTerminated = [];
  List<String> bookFinishTitleList = [];
  List<String> libraryBookTitleList = [];

  void initState() {
    super.initState();
    stockBookTitle();
  }

  void stockBookTitle() async {
    final jsonKey = 'json_key_readed_books';

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(jsonKey) == null) {
      prefs.setStringList(jsonKey, []);
    } else {
      setState(() {
        bookFinishTitleList = prefs.getStringList(jsonKey)!.reversed.toList();
      });
    }
  }

  bool checkingIfBookIsFinish(int index, List<String> list) {
    if (list.contains(widget.libraryBooksList[index].bookModel.bookTitle) ==
        true) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return bookFinishTitleList.length == 0
        ? EmptyPage(
            message: "Vous n'avez terminé aucun livre pour le moment",
            image: "empty_books_1.png")
        : Column(
            children: [
              AnimatedContainer(
                height: heightP(context, 0.5),
                duration: Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                child: GridView.builder(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 130,
                      childAspectRatio: 1 / 2.2,
                      mainAxisSpacing: 0.0),
                  itemCount: widget.libraryBooksList.length,
                  itemBuilder: (context, index) => checkingIfBookIsFinish(
                          index, bookFinishTitleList)
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HorsligneBookDetails(
                                        internet: widget.internet,
                                        catList: widget.catList,
                                        bookAddedList: widget.bookAddedList,
                                        libraryBookList:
                                            widget.libraryBooksList,
                                        id: widget.libraryBooksList[index].id,
                                        bookpicture: widget
                                            .libraryBooksList[index]
                                            .bookModel
                                            .bookPicture,
                                        bookTitle: widget
                                            .libraryBooksList[index]
                                            .bookModel
                                            .bookTitle,
                                        bookAuthor: widget
                                            .libraryBooksList[index]
                                            .bookModel
                                            .author!
                                            .author,
                                        bookPrice: widget
                                            .libraryBooksList[index]
                                            .bookModel
                                            .price,
                                        bookDescription: widget
                                            .libraryBooksList[index]
                                            .bookModel
                                            .description,
                                        bookCategory: widget
                                            .libraryBooksList[index]
                                            .bookModel
                                            .category!
                                            .categ,
                                        bookLanguage: widget
                                            .libraryBooksList[index]
                                            .bookModel
                                            .language!
                                            .lang,
                                        bookEditor: widget
                                            .libraryBooksList[index]
                                            .bookModel
                                            .editor!
                                            .editor,
                                        book: widget.libraryBooksList[index]
                                            .bookModel.book,
                                      )),
                            );
                          },
                          child: BookTerminatedItem(
                            index: index,
                            libraryBookList: widget.libraryBooksList,
                            auth_token: widget.auth_token,
                          ),
                        )
                      : SizedBox(),
                ),
              ),
              SizedBox(height: 10),
              ShareAppWidget()
            ],
          );
  }
}

class BookTerminatedItem extends StatefulWidget {
  final List<dynamic> libraryBookList;

  final String auth_token;
  final int index;

  const BookTerminatedItem({
    Key? key,
    required this.libraryBookList,
    required this.auth_token,
    required this.index,
  });

  @override
  State<BookTerminatedItem> createState() => _BookTerminatedItemState();
}

class _BookTerminatedItemState extends State<BookTerminatedItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 7),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 7.0, color: kPrimaryColor.withOpacity(0.5))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: CachedNetworkImage(
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return Shimmer.fromColors(
                    child: Container(
                      height: 150,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(7)),
                      child: SpinKitFadingCircle(color: Colors.blue),
                    ),
                    baseColor: Color.fromARGB(255, 226, 224, 224),
                    highlightColor: Color.fromARGB(255, 250, 250, 250),
                    enabled: true,
                  );
                },
                imageUrl:
                    "https://bookstudy.smt-group.net/image/${widget.libraryBookList[widget.index].bookModel.bookPicture}"),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text("${widget.libraryBookList[widget.index].bookModel.bookTitle}",
            style: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: kPrimaryColor,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class RecentlyOpen extends StatefulWidget {
  final List<dynamic> libraryBooksList;
  final String auth_token;

  final List<dynamic>? bookAddedList;
  final List<dynamic>? catList;
  final int? internet;
  RecentlyOpen(
      {Key? key,
      required this.libraryBooksList,
      required this.bookAddedList,
      required this.catList,
      required this.internet,
      required this.auth_token})
      : super(key: key);

  @override
  State<RecentlyOpen> createState() => _RecentlyOpenState();
}

class _RecentlyOpenState extends State<RecentlyOpen> {
  List<String> recentlyBooks = [];
  List<String> bookOpenList = [];

  void initState() {
    super.initState();
    recentlyBookOpenTitle();
  }

  void recentlyBookOpenTitle() async {
    final jsonKey = 'json_key_open_books';

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(jsonKey) == null) {
      prefs.setStringList(jsonKey, []);
    } else {
      setState(() {
        bookOpenList = prefs.getStringList(jsonKey)!.reversed.toList();
      });
    }
  }

  bool checkingIfBookIsFinish(int index, List<String> list) {
    if (list.contains(widget.libraryBooksList[index].bookModel.bookTitle) ==
        true) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return bookOpenList.length == 0
        ? EmptyPage(
            message: "Aucun livre en cours de lecture",
            image: "empty_books_1.png")
        : Column(
            children: [
              AnimatedContainer(
                height: heightP(context, 0.5),
                duration: Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                child: GridView.builder(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 130,
                      childAspectRatio: 1 / 2.2,
                      mainAxisSpacing: 0.0),
                  itemCount: widget.libraryBooksList.length,
                  itemBuilder: (context, index) => checkingIfBookIsFinish(
                          index, bookOpenList)
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HorsligneBookDetails(
                                        internet: widget.internet,
                                        catList: widget.catList,
                                        bookAddedList: widget.bookAddedList,
                                        libraryBookList:
                                            widget.libraryBooksList,
                                        id: widget.libraryBooksList.reversed
                                            .toList()[index]
                                            .id,
                                        bookpicture: widget
                                            .libraryBooksList.reversed
                                            .toList()[index]
                                            .bookModel
                                            .bookPicture,
                                        bookTitle: widget
                                            .libraryBooksList.reversed
                                            .toList()[index]
                                            .bookModel
                                            .bookTitle,
                                        bookAuthor: widget
                                            .libraryBooksList.reversed
                                            .toList()[index]
                                            .bookModel
                                            .author!
                                            .author,
                                        bookPrice: widget
                                            .libraryBooksList.reversed
                                            .toList()[index]
                                            .bookModel
                                            .price,
                                        bookDescription: widget
                                            .libraryBooksList.reversed
                                            .toList()[index]
                                            .bookModel
                                            .description,
                                        bookCategory: widget
                                            .libraryBooksList.reversed
                                            .toList()[index]
                                            .bookModel
                                            .category!
                                            .categ,
                                        bookLanguage: widget
                                            .libraryBooksList.reversed
                                            .toList()[index]
                                            .bookModel
                                            .language!
                                            .lang,
                                        bookEditor: widget
                                            .libraryBooksList.reversed
                                            .toList()[index]
                                            .bookModel
                                            .editor!
                                            .editor,
                                        book: widget.libraryBooksList.reversed
                                            .toList()[index]
                                            .bookModel
                                            .book,
                                      )),
                            );
                          },
                          child: BookTerminatedItem(
                            index: index,
                            libraryBookList:
                                widget.libraryBooksList.reversed.toList(),
                            auth_token: widget.auth_token,
                          ),
                        )
                      : SizedBox(),
                ),
              ),
              SizedBox(height: 10),
              ShareAppWidget()
            ],
          );
  }
}
