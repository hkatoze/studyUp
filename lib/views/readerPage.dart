import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_up/constants.dart';
import 'package:study_up/models/models.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Represents Homepage for Navigation
class ReaderPage extends StatefulWidget {
  final String book;
  final String bookTitle;
  final int id;
  final List<dynamic> libraryBookList;
  const ReaderPage(this.book, this.bookTitle, this.id, this.libraryBookList);

  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _isLoading = true;
  PDFDocument? document;
  List<String> libraryBookIdList = [];

  @override
  void initState() {
    super.initState();
    loadDocument();
    stockBookId();
    addToRecentlyOpen();
  }

  void stockBookId() {
    for (int i = 0; i < widget.libraryBookList.length; i++) {
      libraryBookIdList.add(widget.libraryBookList[i].bookModel.bookTitle);
    }
    print("Library books title:${libraryBookIdList}");
  }

  addToRecentlyOpen() async {
    List<String> recentlyBookOpen = [];
    final jsonKey = 'json_key_open_books';

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList(jsonKey) == null) {
      prefs.setStringList(jsonKey, []);
      print("recemment ouvert null");
    } else {
      recentlyBookOpen = prefs.getStringList(jsonKey)!;

      if (checkingIfBookInLibrary(widget.bookTitle) &&
          recentlyBookOpen.contains(widget.bookTitle) == false) {
        setState(() {
          recentlyBookOpen.add(widget.bookTitle);
        });

        prefs.setStringList(jsonKey, recentlyBookOpen);
      }

      print("Recently book opened :${recentlyBookOpen}");
    }
  }

  addToReadedBook(int page, int totalPage) async {
    List<String> bookFinishTitleList = [];
    final jsonKey = 'json_key_readed_books';

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getStringList(jsonKey) == null) {
      prefs.setStringList(jsonKey, []);
    } else {
      bookFinishTitleList = prefs.getStringList(jsonKey)!;

      if (page >= (totalPage - 3) &&
          checkingIfBookInLibrary(widget.bookTitle) &&
          bookFinishTitleList.contains(widget.bookTitle) == false) {
        setState(() {
          bookFinishTitleList.add(widget.bookTitle);
        });
        prefs.setStringList(jsonKey, bookFinishTitleList);
      }
    }
  }

  bool checkingIfBookInLibrary(String id) {
    if (libraryBookIdList.contains(id) == true) {
      return true;
    } else {
      return false;
    }
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(
      "https://bookstudy.smt-group.net/docs/${widget.book}",
      cacheManager: CacheManager(
        Config(
          "customCacheKey",
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 10,
        ),
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        title: Text(widget.bookTitle),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 25.0,
            color: KSecondaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              size: 25.0,
              color: KSecondaryColor,
            ),
            onPressed: () => {},
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? Center(
                child: SpinKitRotatingCircle(
                color: kPrimaryColor,
              ))
            : PDFViewer(
                document: document!,
                zoomSteps: 1,
                lazyLoad: false,
                scrollDirection: Axis.vertical,
                navigationBuilder:
                    (context, page, totalPages, jumpToPage, animateToPage) {
                  addToReadedBook(page!, totalPages!);
                  return ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.first_page),
                        onPressed: () {
                          jumpToPage(page: 0);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          animateToPage(page: page - 2);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          animateToPage(page: page);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.last_page),
                        onPressed: () {
                          jumpToPage(page: totalPages - 1);
                        },
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
