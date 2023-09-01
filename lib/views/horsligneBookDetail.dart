import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shimmer/shimmer.dart';
import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';

import 'package:study_up/views/audioRead.dart';
import 'package:study_up/views/profilPage.dart';
import 'package:study_up/views/readerPage.dart';
import 'package:study_up/views/widgets/bottomBar.dart';

class HorsligneBookDetails extends StatefulWidget {
  final String? bookpicture;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookPrice;
  final String? bookDescription;
  final String? bookCategory;
  final String? bookLanguage;
  final String? bookEditor;
  final String? book;
  final List<dynamic> libraryBookList;
  final List<dynamic>? bookAddedList;
  final List<dynamic>? catList;
  final int? internet;

  final int? id;

  HorsligneBookDetails({
    Key? key,
    required this.libraryBookList,
    required this.bookAddedList,
    required this.catList,
    required this.internet,
    required this.id,
    required this.bookAuthor,
    required this.bookCategory,
    required this.book,
    required this.bookDescription,
    required this.bookEditor,
    required this.bookLanguage,
    required this.bookPrice,
    required this.bookTitle,
    required this.bookpicture,
  }) : super(key: key);

  @override
  State<HorsligneBookDetails> createState() => _HorsligneBookDetailsState();
}

class _HorsligneBookDetailsState extends State<HorsligneBookDetails> {
  var user_id = '';
  var book_id = '';
  var auth_token = '';
  bool _isAddToLibrary = false;
  bool _isPaid = false;
  bool _isInLibrary = false;
  bool _isLoadingPaying = false;
  bool _achatValidadted = true;
  List<int> libraryBookIdList = [];
  List<int> paidBooksIdList = [];

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
  }

  bool checkingIfBookInLibrary(int id) {
    if (libraryBookIdList.contains(id) == true) {
      setState(() {
        _isInLibrary = true;
      });
      return true;
    } else {
      if (paidBooksIdList.contains(id) == true) {
        setState(() {
          _isPaid = true;
        });
        return true;
      } else {
        return false;
      }
    }
  }

  void read() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReaderPage(widget.book!, widget.bookTitle!,
              widget.id!, widget.libraryBookList)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavBarWidget(
          index: 1,
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
                                  height: 90,
                                ),
                                (widget.bookPrice != null ||
                                            !checkingIfBookInLibrary(
                                                widget.id!)) &&
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
                                              read();
                                            },
                                            child: Text(
                                              "LIRE",
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
                                                  widget.id!)
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
