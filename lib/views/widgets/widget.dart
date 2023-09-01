import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:shimmer/shimmer.dart';
import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';
import 'package:study_up/models/models.dart';
import 'package:study_up/views/bookDetails.dart';
import 'package:study_up/views/homePage.dart';
import 'package:study_up/views/myLibraryPage.dart';
import 'package:study_up/views/profilPage.dart';

class SearchWidget extends StatefulWidget {
  final List<dynamic>? libraryBookList;
  final List<dynamic>? bookAddedList;
  final List<dynamic>? catList;
  final String? amount;

  final int? internet;
  SearchWidget(
      {Key? key,
      required this.bookAddedList,
      this.amount,
      required this.catList,
      required this.internet,
      required this.libraryBookList})
      : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  bool _isSearching = false;
  List<dynamic> books = [];
  String query = '';

  void initState() {
    super.initState();
  }

  void searchBook(String query) {
    final books = widget.bookAddedList!.where((book) {
      final titleLower = book.bookTitle.toString().toLowerCase();
      final authorLower = book.author!.author.toString().toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower) ||
          authorLower.contains(searchLower);
    }).toList();

    setState(() {
      this.query = query;
      this.books = books;
    });
  }

  TextEditingController? _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.only(top: 2, right: 10, bottom: 1),
          child: TextField(
            controller: _textEditingController,
            onChanged: (value) {
              searchBook(_textEditingController!.text);
              if (value.length != 0) {
                setState(() {
                  _isSearching = true;
                });
              } else {
                setState(() {
                  _isSearching = false;
                });
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide(
                  width: 0,
                  color: Colors.white,
                  style: BorderStyle.none,
                ),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.search,
                color: kPrimaryColor,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
              fillColor: Colors.grey.withOpacity(0.1),
              hintStyle: new TextStyle(color: Color(0xFFd0cece), fontSize: 15),
              hintText: "Entrer le titre d'un livre ou un auteur",
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        AnimatedContainer(
          height: _isSearching ? heightP(context, 0.69) : 0,
          decoration: BoxDecoration(
              color: Color(0xFFeaeaea),
              borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
          child: books.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: heightP(context, 0.2),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                "assets/images/empty_notification.png")),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        "Aucun livre trouvé",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.grey.withOpacity(0.7)),
                      ),
                    )
                  ],
                )
              : GridView.builder(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 125,
                      childAspectRatio: 1 / 2,
                      mainAxisSpacing: 0.0),
                  itemCount: books.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookDetailsPage(
                                  catList: widget.catList,
                                  bookAddedList: widget.bookAddedList,
                                  internet: widget.internet,
                                  id: books[index].id,
                                  bookpicture: books[index].bookPicture,
                                  bookTitle: books[index].bookTitle,
                                  bookAuthor: books[index].author!.author,
                                  bookPrice: books[index].price,
                                  bookDescription: books[index].description,
                                  bookCategory: books[index].category!.categ,
                                  bookLanguage: books[index].language!.lang,
                                  bookEditor: books[index].editor!.editor,
                                  book: books[index].book,
                                  libraryBookList: widget.libraryBookList,
                                )),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 7),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                    height: 150,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) {
                                      return Shimmer.fromColors(
                                        child: Container(
                                          height: 150,
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
                                        "https://bookstudy.smt-group.net/image/${books[index].bookPicture}"),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: RichText(
                                text: TextSpan(
                                    text: "${books[index].bookTitle}" + "\n",
                                    children: [
                                      TextSpan(
                                          text: books[index].price == null
                                              ? "Gratuit"
                                              : "${books[index].price}" +
                                                  " Frs",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: books[index].price == null
                                                  ? Colors.green
                                                  : Colors.red))
                                    ],
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold)),
                              ),
                            )
                          ]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class ShareAppWidget extends StatefulWidget {
  const ShareAppWidget({Key? key}) : super(key: key);

  @override
  State<ShareAppWidget> createState() => _ShareAppWidgetState();
}

class _ShareAppWidgetState extends State<ShareAppWidget> {
  Future<void> share() async {
    await FlutterShare.share(
        title: 'StudyUp',
        text: 'Votre bibliothèque dans votre pôche',
        linkUrl: 'https://flutter.dev/',
        chooserTitle: 'Example Chooser Title');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthP(context, 0.95),
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFFeaeaea),
        image: DecorationImage(image: AssetImage("assets/images/invite.png")),
      ),
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  "Invite tes amis",
                  style: TextStyle(
                      fontSize: 19, color: Color.fromARGB(255, 58, 58, 58)),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Text(
                  'Gagner des points bonus',
                  style: TextStyle(fontSize: 16, color: Color(0xFF96979b)),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Container(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0XFF223170),
                      padding: EdgeInsets.all(10),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      await share();
                    },
                    child: Text(
                      "INVITER",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    )),
              )
            ],
          )),
    );
  }
}

class BookAudioBanner extends StatefulWidget {
  final List<dynamic> bookAddedList;
  const BookAudioBanner({Key? key, required this.bookAddedList})
      : super(key: key);

  @override
  State<BookAudioBanner> createState() => _BookAudioBannerState();
}

class _BookAudioBannerState extends State<BookAudioBanner> {
  List<dynamic> freeBooks = [];
  bool isReading = false;
  bool isSpeaking = false;

  String _text = "";
  PDFDoc? _pdfDoc;
  bool _isOk = false;

  void initState() {
    super.initState();
    getFreeBooks();
    initializeTts();
    extracText();
  }

  void getFreeBooks() {
    for (int i = 0; i < widget.bookAddedList.length; i++) {
      if (widget.bookAddedList[i].price == null) {
        setState(() {
          freeBooks.add(widget.bookAddedList[i]);
        });
      }
    }
    setState(() {
      freeBooks.shuffle();
    });
  }

  final _flutterr_tts = FlutterTts();
  void initializeTts() {
    _flutterr_tts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });
    _flutterr_tts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
    _flutterr_tts.awaitSpeakCompletion(true);
    _flutterr_tts.setErrorHandler((message) {
      setState(() {
        isSpeaking = false;
      });
    });

    _flutterr_tts.setLanguage("fr-FR");
    _flutterr_tts.setSpeechRate(0.5);
    _flutterr_tts.setPitch(1);
  }

  void speak(String text) async {
    var count = text.length;
    var max = 4000;
    var loopCount = count ~/ max;

    for (var i = 0; i <= loopCount; i++) {
      if (i != loopCount) {
        await _flutterr_tts.speak(text.substring(i * max, (i + 1) * max));
      } else {
        var end = (count - ((i * max)) + (i * max));
        await _flutterr_tts.speak(text.substring(i * max, end));
      }
    }
  }

  void stop() async {
    await _flutterr_tts.stop();
  }

  void pause() async {
    await _flutterr_tts.pause();
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
      r"/\r?\n|\r/g",
    );

    return htmlText.replaceAll(exp, '');
  }

  void extracText() async {
    _pdfDoc = await PDFDoc.fromURL(
        "https://bookstudy.smt-group.net/docs/${freeBooks[0].book}");

    String text = await _pdfDoc!.text;

    setState(() {
      _text = removeAllHtmlTags(text);
      _isOk = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _text == ""
        ? Shimmer.fromColors(
            baseColor: Color.fromARGB(255, 226, 224, 224),
            highlightColor: Color.fromARGB(255, 250, 250, 250),
            enabled: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {},
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: heightP(context, 0.11),
                      width: heightP(context, 0.11),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: heightP(context, 0.025),
                              width: widthP(context, 0.25),
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: heightP(context, 0.025),
                              width: widthP(context, 0.15),
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: heightP(context, 0.025),
                              width: widthP(context, 0.15),
                              color: Colors.white,
                            )
                          ]),
                    ),
                    SizedBox(
                      width: widthP(context, 0.3),
                    ),
                    Container(
                      height: heightP(context, 0.05),
                      width: heightP(context, 0.05),
                      margin: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ],
                ),
              ),
            ))
        : InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {},
            child: Container(
              padding: EdgeInsets.only(
                left: widthP(context, 0.01),
                right: widthP(context, 0.01),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15)),
                  gradient: LinearGradient(
                      colors: [kPrimaryColor, Colors.white],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight)),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: widthP(context, 0.01)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                                height: heightP(context, 0.11),
                                width: heightP(context, 0.11),
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return Shimmer.fromColors(
                                    child: Container(
                                      height: heightP(context, 0.11),
                                      width: heightP(context, 0.11),
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
                                    "https://bookstudy.smt-group.net/image/${freeBooks[0].bookPicture}"),
                          ),
                        ),
                        Expanded(
                            child: Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: heightP(context, 0.03),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(freeBooks[0].bookTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: heightP(context, 0.01),
                                    ),
                                    Text(
                                      freeBooks[0].author!.author,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 13),
                                    ),
                                    SizedBox(
                                      height: heightP(context, 0.01),
                                    ),
                                    Text(
                                      "10h:33",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 13),
                                    )
                                  ],
                                ))),
                        Container(
                          height: heightP(context, 0.02),
                          width: widthP(context, 0.02),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: widthP(context, 0.05),
                                vertical: heightP(context, 0.01)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isReading = !isReading;
                                      if (isReading == false) {
                                        stop();
                                      } else {
                                        speak(_text);
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: heightP(context, 0.06),
                                    width: heightP(context, 0.06),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0XFFdfe6fc)),
                                    child: Icon(
                                      isReading
                                          ? Icons.pause_circle
                                          : Icons.play_arrow,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: heightP(context, 0.02),
                                ),
                                Text(
                                  "",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13),
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class ProcessPage extends StatefulWidget {
  const ProcessPage({Key? key}) : super(key: key);

  @override
  State<ProcessPage> createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: kPrimaryColor),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50.0,
                        child: Image.asset("assets/images/logo.png"),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      Text(
                        "Study Up",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Developped by Smart Touch Group",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitCircle(
                      color: KSecondaryColor,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text(
                      "Place to get Study Up",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BookItem extends StatefulWidget {
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

  const BookItem(
      {Key? key,
      required this.id,
      required this.bookAuthor,
      required this.bookCategory,
      required this.book,
      required this.bookDescription,
      required this.bookEditor,
      required this.bookLanguage,
      required this.bookPrice,
      required this.bookTitle,
      required this.bookpicture})
      : super(key: key);

  @override
  State<BookItem> createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  bool isReading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: widthP(context, 0.01),
        right: widthP(context, 0.01),
      ),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
          gradient: LinearGradient(
              colors: [kPrimaryColor, Colors.white],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight)),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(right: widthP(context, 0.01)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                        height: heightP(context, 0.11),
                        width: heightP(context, 0.11),
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return Shimmer.fromColors(
                            child: Container(
                              height: heightP(context, 0.11),
                              width: heightP(context, 0.11),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7)),
                              child: SpinKitFadingCircle(color: Colors.blue),
                            ),
                            baseColor: Color.fromARGB(255, 226, 224, 224),
                            highlightColor: Color.fromARGB(255, 250, 250, 250),
                            enabled: true,
                          );
                        },
                        imageUrl:
                            "https://bookstudy.smt-group.net/image/${widget.bookpicture}"),
                  ),
                ),
                Expanded(
                    child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: heightP(context, 0.02),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.bookTitle}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: heightP(context, 0.01),
                            ),
                            Text(
                              "${widget.bookAuthor}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13),
                            ),
                            SizedBox(
                              height: heightP(context, 0.01),
                            ),
                            Text(
                              "Langue : ${widget.bookLanguage}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13),
                            )
                          ],
                        ))),
                Container(
                  height: heightP(context, 0.008),
                  width: widthP(context, 0.008),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(15)),
                ),
                Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: widthP(context, 0.03),
                        vertical: heightP(context, 0.01)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          child: Text(
                            widget.bookPrice == null
                                ? "Gratuit"
                                : "${widget.bookPrice}" + " Frs",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.bookPrice == null
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ),
                        SizedBox(
                          height: heightP(context, 0.02),
                        ),
                        Text(
                          "",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13),
                        )
                      ],
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilElement extends StatefulWidget {
  const ProfilElement({
    Key? key,
    this.title,
    this.icon,
    this.numOfItems = 0,
  }) : super(key: key);

  final IconData? icon;
  final String? title;

  final int numOfItems;

  @override
  State<ProfilElement> createState() => _ProfilElementState();
}

class _ProfilElementState extends State<ProfilElement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: 10, horizontal: widthP(context, 0.1)),
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(width: 1, color: kPrimaryColor),
      )),
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 30,
                width: 30,
                margin: EdgeInsets.only(right: 10),
                child: Icon(
                  widget.icon,
                  color: kPrimaryColor,
                ),
              ),
              Text(
                widget.title!,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: kPrimaryColor),
              ),
            ],
          ),
          if (widget.numOfItems != 0)
            Container(
              height: 20,
              width: 20,
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  color: Color(0xFFFF4848),
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.5, color: Colors.white)),
              child: Center(
                  child: Text(widget.numOfItems.toString(),
                      style: TextStyle(
                          fontSize: 10,
                          height: 1,
                          color: Colors.white,
                          fontWeight: FontWeight.w600))),
            ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatefulWidget {
  const NotificationItem(
      {Key? key,
      required this.title,
      required this.amount,
      required this.date,
      required this.type,
      required this.icon})
      : super(key: key);
  final String? type;
  final String? title;
  final String? date;
  final IconData? icon;
  final String? amount;
  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: KSecondaryColor,
        ),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: KSecondaryColor, spreadRadius: 1),
              ],
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Icon(
                    widget.type == "dépôt d'argent" ? Icons.money : Icons.book,
                    color: kPrimaryColor,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        widget.type!,
                        style: TextStyle(color: Colors.grey.withOpacity(0.7)),
                      )
                    ],
                  ),
                )),
                SizedBox(width: 30),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.date!),
                      Text(
                        widget.amount!,
                        style: TextStyle(
                            color: widget.amount == "Gratuit"
                                ? Colors.green
                                : Colors.red),
                      )
                    ],
                  ),
                )
              ],
            )));
  }
}

class EmptyPage extends StatefulWidget {
  final String message;
  final String image;
  const EmptyPage({Key? key, required this.message, required this.image})
      : super(key: key);

  @override
  State<EmptyPage> createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: heightP(context, 0.5),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/${widget.image}")),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10, bottom: 10),
          child: Text(
            widget.message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.grey.withOpacity(0.7)),
          ),
        )
      ],
    );
  }
}
