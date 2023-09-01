import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:study_up/api_services/api_services.dart';
import 'package:study_up/constants.dart';

import 'package:study_up/views/bookDetails.dart';
import 'package:study_up/views/notificationsServices.dart';
import 'package:study_up/views/widgets/bottomBar.dart';
import 'package:study_up/views/widgets/widget.dart';

import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  final String auth_token;

  HomePage({Key? key, required this.auth_token}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  var auth_token;
  bool _seeAll = false;
  bool _indexSeeAll = false;
  ScrollController _firstScrollControler = ScrollController();
  CarouselController _carousselControler = CarouselController();

  int bookLength = 0;
  var internet;
  @override
  void initState() {
    super.initState();
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

  Stream<List<dynamic>> _getBook() async* {
    while (true) {
      final _bookAdded = await getBookRecentlyAdded(auth_token);
      notification(_bookAdded);
      await Future.delayed(Duration(seconds: 1));

      yield _bookAdded;
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

  Stream<String> _getAmount() async* {
    while (true) {
      final amount = await getAmount(widget.auth_token) == null
          ? "......."
          : await getAmount(widget.auth_token);
      await Future.delayed(Duration(seconds: 1));

      yield amount;
    }
  }

  Widget futureMethod() {
    return StreamBuilder(
        stream: _getBook(),
        builder:
            (BuildContext context, AsyncSnapshot<List<dynamic>> bookAddedList) {
          return StreamBuilder(
              stream: _getLibraryBook(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> libraryBooksList) {
                return StreamBuilder(
                    stream: _getCat(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<dynamic>> catList) {
                      return StreamBuilder(
                          stream: _getAmount(),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> amount) {
                            return Scaffold(
                              bottomNavigationBar: BottomNavBarWidget(
                                index: 0,
                                amount: amount.data,
                                bookAddedList: bookAddedList.data,
                                libraryBookList: libraryBooksList.data,
                                catList: catList.data,
                                internet: internet,
                              ),
                              body: SingleChildScrollView(
                                  controller: _firstScrollControler,
                                  physics: !_seeAll
                                      ? BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics())
                                      : NeverScrollableScrollPhysics(),
                                  child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 13),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                              onTap: () {
                                                NotificationService()
                                                    .showNotification(
                                                        1,
                                                        "Nouveau livre",
                                                        bookAddedList.data!.last
                                                            .bookTitle!,
                                                        5);
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top:
                                                        heightP(context, 0.05)),
                                                child: Text(
                                                  "Accueil",
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black
                                                          .withOpacity(0.7)),
                                                ),
                                              )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Center(
                                            child: AnimatedContainer(
                                              duration: Duration(seconds: 1),
                                              curve: Curves.fastOutSlowIn,
                                              height: internet == 200 ? 0 : 40,
                                              child: AnimatedTextKit(
                                                repeatForever: true,
                                                isRepeatingAnimation: true,
                                                pause:
                                                    Duration(milliseconds: 500),
                                                animatedTexts: [
                                                  FadeAnimatedText(
                                                      'Aucune connexion internet\nVous êtes hors ligne',
                                                      textAlign:
                                                          TextAlign.center,
                                                      textStyle: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  FadeAnimatedText(
                                                      'Aucune connexion internet\nVous êtes hors ligne',
                                                      textAlign:
                                                          TextAlign.center,
                                                      textStyle: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  FadeAnimatedText(
                                                      'Aucune connexion internet\nVous êtes hors ligne',
                                                      textAlign:
                                                          TextAlign.center,
                                                      textStyle: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                                onTap: () {
                                                  setState(() {
                                                    _seeAll = !_seeAll;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          SearchWidget(
                                            amount: amount.data,
                                            internet: internet,
                                            bookAddedList: bookAddedList.data,
                                            catList: catList.data,
                                            libraryBookList:
                                                libraryBooksList.data,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Card(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Récemment ajouté",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.4)),
                                                          ),
                                                          InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  _seeAll =
                                                                      !_seeAll;
                                                                });
                                                              },
                                                              child:
                                                                  AnimatedContainer(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                curve: Curves
                                                                    .fastOutSlowIn,
                                                                child: Row(
                                                                  children: [
                                                                    _indexSeeAll &&
                                                                            !_seeAll
                                                                        ? AnimatedTextKit(
                                                                            repeatForever:
                                                                                true,
                                                                            isRepeatingAnimation:
                                                                                true,
                                                                            pause:
                                                                                Duration(milliseconds: 500),
                                                                            animatedTexts: [
                                                                              FadeAnimatedText('Voir tout', textStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                                              FadeAnimatedText('Voir tout', textStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                                              FadeAnimatedText('Voir tout', textStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                                            ],
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                _seeAll = !_seeAll;
                                                                              });
                                                                            },
                                                                          )
                                                                        : Text(!_seeAll
                                                                            ? "Voir tout"
                                                                            : "Fermer"),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Icon(
                                                                      !_seeAll
                                                                          ? Icons
                                                                              .arrow_forward_ios
                                                                          : Icons
                                                                              .arrow_drop_down,
                                                                      size: !_seeAll
                                                                          ? 11
                                                                          : 25,
                                                                    )
                                                                  ],
                                                                ),
                                                              ))
                                                        ],
                                                      )),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: Text(
                                                      "Les derniers et meilleurs livres du moment",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                  0.8)),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ]),
                                          ),
                                          bookAddedList.data == null ||
                                                  bookAddedList.data!.length ==
                                                      0
                                              ? LoadingListPage(_seeAll)
                                              : AnimatedContainer(
                                                  height: _seeAll ? 0 : 300,
                                                  margin: EdgeInsets.only(
                                                      right: 5,
                                                      left: 5,
                                                      top: 10),
                                                  duration:
                                                      Duration(seconds: 1),
                                                  curve: Curves.fastOutSlowIn,
                                                  child: CarouselSlider.builder(
                                                      carouselController:
                                                          _carousselControler,
                                                      options: CarouselOptions(
                                                          onPageChanged:
                                                              (index, reason) {
                                                            if (index >= 4) {
                                                              setState(() {
                                                                _indexSeeAll =
                                                                    true;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                _indexSeeAll =
                                                                    false;
                                                              });
                                                            }
                                                          },
                                                          padEnds: false,
                                                          scrollPhysics:
                                                              BouncingScrollPhysics(
                                                                  parent:
                                                                      AlwaysScrollableScrollPhysics()),
                                                          enableInfiniteScroll:
                                                              false,
                                                          viewportFraction:
                                                              0.42,
                                                          height: 256),
                                                      itemCount:
                                                          bookAddedList.data ==
                                                                  null
                                                              ? 0
                                                              : bookAddedList
                                                                  .data!.length,
                                                      itemBuilder: (BuildContext
                                                              context,
                                                          int itemIndex,
                                                          int pageViewIndex) {
                                                        return InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          BookDetailsPage(
                                                                            catList: catList.data == null
                                                                                ? []
                                                                                : catList.data!,
                                                                            bookAddedList:
                                                                                bookAddedList.data!,
                                                                            internet:
                                                                                internet,
                                                                            amount: amount.data == null
                                                                                ? "........"
                                                                                : amount.data!,
                                                                            id: bookAddedList.data!.reversed.toList()[itemIndex].id,
                                                                            bookpicture:
                                                                                bookAddedList.data!.reversed.toList()[itemIndex].bookPicture,
                                                                            bookTitle:
                                                                                bookAddedList.data!.reversed.toList()[itemIndex].bookTitle,
                                                                            bookAuthor:
                                                                                bookAddedList.data!.reversed.toList()[itemIndex].author!.author,
                                                                            bookPrice:
                                                                                bookAddedList.data!.reversed.toList()[itemIndex].price,
                                                                            bookDescription:
                                                                                bookAddedList.data!.reversed.toList()[itemIndex].description,
                                                                            bookCategory:
                                                                                bookAddedList.data!.reversed.toList()[itemIndex].category!.categ,
                                                                            bookLanguage:
                                                                                bookAddedList.data!.reversed.toList()[itemIndex].language!.lang,
                                                                            bookEditor:
                                                                                bookAddedList.data!.reversed.toList()[itemIndex].editor!.editor,
                                                                            book:
                                                                                bookAddedList.data!.reversed.toList()[itemIndex].book,
                                                                            libraryBookList: libraryBooksList.data == null
                                                                                ? []
                                                                                : libraryBooksList.data!,
                                                                          )),
                                                            );
                                                          },
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        7),
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            blurRadius:
                                                                                7.0,
                                                                            color:
                                                                                kPrimaryColor.withOpacity(0.5))
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              7),
                                                                      child: CachedNetworkImage(
                                                                          height: 200,
                                                                          fit: BoxFit.cover,
                                                                          placeholder: (context, url) {
                                                                            return Shimmer.fromColors(
                                                                              child: Container(
                                                                                height: 200,
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
                                                                                child: SpinKitFadingCircle(color: Colors.blue),
                                                                              ),
                                                                              baseColor: Color.fromARGB(255, 226, 224, 224),
                                                                              highlightColor: Color.fromARGB(255, 250, 250, 250),
                                                                              enabled: true,
                                                                            );
                                                                          },
                                                                          imageUrl: "https://bookstudy.smt-group.net/image/${bookAddedList.data!.reversed.toList()[itemIndex].bookPicture}"),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Container(
                                                                    child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            child:
                                                                                Text(
                                                                              "${bookAddedList.data!.reversed.toList()[itemIndex].bookTitle}",
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            child:
                                                                                Text(bookAddedList.data!.reversed.toList()[itemIndex].price == null ? "Gratuit" : "${bookAddedList.data!.reversed.toList()[itemIndex].price}" + " Frs", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: bookAddedList.data!.reversed.toList()[itemIndex].price == null ? Colors.green : Colors.red)),
                                                                          ),
                                                                        ]),
                                                                  )
                                                                ]),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                          AnimatedContainer(
                                            height: _seeAll
                                                ? heightP(context, 0.67)
                                                : 0,
                                            duration: Duration(seconds: 1),
                                            curve: Curves.fastOutSlowIn,
                                            child: GridView.builder(
                                              physics: BouncingScrollPhysics(
                                                  parent:
                                                      AlwaysScrollableScrollPhysics()),
                                              gridDelegate:
                                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                                      maxCrossAxisExtent: 125,
                                                      childAspectRatio: 1 / 2,
                                                      mainAxisSpacing: 0.0),
                                              itemCount: bookAddedList.data ==
                                                      null
                                                  ? 0
                                                  : bookAddedList.data!.length,
                                              itemBuilder: (context, index) =>
                                                  InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                BookDetailsPage(
                                                                  catList:
                                                                      catList
                                                                          .data!,
                                                                  bookAddedList:
                                                                      bookAddedList
                                                                          .data!,
                                                                  internet:
                                                                      internet,
                                                                  amount: amount
                                                                              .data ==
                                                                          null
                                                                      ? "........"
                                                                      : amount
                                                                          .data!,
                                                                  id: bookAddedList
                                                                      .data!
                                                                      .reversed
                                                                      .toList()[
                                                                          index]
                                                                      .id,
                                                                  bookpicture: bookAddedList
                                                                      .data!
                                                                      .reversed
                                                                      .toList()[
                                                                          index]
                                                                      .bookPicture,
                                                                  bookTitle: bookAddedList
                                                                      .data!
                                                                      .reversed
                                                                      .toList()[
                                                                          index]
                                                                      .bookTitle,
                                                                  bookAuthor: bookAddedList
                                                                      .data!
                                                                      .reversed
                                                                      .toList()[
                                                                          index]
                                                                      .author!
                                                                      .author,
                                                                  bookPrice: bookAddedList
                                                                      .data!
                                                                      .reversed
                                                                      .toList()[
                                                                          index]
                                                                      .price,
                                                                  bookDescription: bookAddedList
                                                                      .data!
                                                                      .reversed
                                                                      .toList()[
                                                                          index]
                                                                      .description,
                                                                  bookCategory: bookAddedList
                                                                      .data!
                                                                      .reversed
                                                                      .toList()[
                                                                          index]
                                                                      .category!
                                                                      .categ,
                                                                  bookLanguage: bookAddedList
                                                                      .data!
                                                                      .reversed
                                                                      .toList()[
                                                                          index]
                                                                      .language!
                                                                      .lang,
                                                                  bookEditor: bookAddedList
                                                                      .data!
                                                                      .reversed
                                                                      .toList()[
                                                                          index]
                                                                      .editor!
                                                                      .editor,
                                                                  book: bookAddedList
                                                                      .data!
                                                                      .reversed
                                                                      .toList()[
                                                                          index]
                                                                      .book,
                                                                  libraryBookList:
                                                                      libraryBooksList
                                                                          .data!,
                                                                )),
                                                  );
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 7),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  blurRadius:
                                                                      7.0,
                                                                  color: kPrimaryColor
                                                                      .withOpacity(
                                                                          0.5))
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                            child:
                                                                CachedNetworkImage(
                                                                    height: 150,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                            url) {
                                                                      return Shimmer
                                                                          .fromColors(
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              150,
                                                                          decoration:
                                                                              BoxDecoration(borderRadius: BorderRadius.circular(7)),
                                                                          child:
                                                                              SpinKitFadingCircle(color: Colors.blue),
                                                                        ),
                                                                        baseColor: Color.fromARGB(
                                                                            255,
                                                                            226,
                                                                            224,
                                                                            224),
                                                                        highlightColor: Color.fromARGB(
                                                                            255,
                                                                            250,
                                                                            250,
                                                                            250),
                                                                        enabled:
                                                                            true,
                                                                      );
                                                                    },
                                                                    imageUrl:
                                                                        "https://bookstudy.smt-group.net/image/${bookAddedList.data!.reversed.toList()[index].bookPicture}"),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Container(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  child: Text(
                                                                    "${bookAddedList.data!.reversed.toList()[index].bookTitle}",
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        color:
                                                                            kPrimaryColor,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  child: Text(
                                                                      bookAddedList.data!.reversed.toList()[index].price == null
                                                                          ? "Gratuit"
                                                                          : "${bookAddedList.data!.reversed.toList()[index].price}" +
                                                                              " Frs",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: bookAddedList.data!.reversed.toList()[index].price == null
                                                                              ? Colors.green
                                                                              : Colors.red)),
                                                                ),
                                                              ]),
                                                        )
                                                      ]),
                                                ),
                                              ),
                                            ),
                                          ),
                                          bookAddedList.data == null ||
                                                  bookAddedList.data!.length ==
                                                      0
                                              ? AudioLoading()
                                              : BookAudioBanner(
                                                  bookAddedList:
                                                      bookAddedList.data!,
                                                ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          catList.data == null ||
                                                  catList.data!.length == 0
                                              ? CatLoading()
                                              : CategorySection(
                                                  amount: amount.data == null
                                                      ? "........"
                                                      : amount.data!,
                                                  internet: internet,
                                                  bookList:
                                                      bookAddedList.data == null
                                                          ? []
                                                          : bookAddedList.data!,
                                                  catList: catList.data!,
                                                  libraryBookList:
                                                      libraryBooksList.data ==
                                                              null
                                                          ? []
                                                          : libraryBooksList
                                                              .data!,
                                                ),
                                          SizedBox(height: 10),
                                          ShareAppWidget()
                                        ],
                                      ))),
                            );
                          });
                    });
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return futureMethod();
  }
}

class CategorySection extends StatefulWidget {
  final List<dynamic> catList;
  final List<dynamic> bookList;
  final List<dynamic> libraryBookList;
  final String amount;

  final int internet;
  const CategorySection(
      {Key? key,
      required this.amount,
      required this.internet,
      required this.bookList,
      required this.catList,
      required this.libraryBookList})
      : super(key: key);
  //final String categoryName;
  // final int categoryId;

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  int _isSelected = 0;
  ScrollController _scrollController = ScrollController();
  ScrollController _newsSectionController = ScrollController();
  List<dynamic> catListLocal = [];

  void initState() {
    super.initState();
    setState(() {
      catListLocal.addAll(widget.catList);
    });
  }

  void _scrollToIndex(int index) {
    _scrollController.animateTo(110.0 * index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  void _scrollToNewsIndex(int index) {
    _newsSectionController.animateTo(widthP(context, 0.93) * index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  void checkCatLength(int isSelected, index) {
    if (catListLocal[isSelected].categ! ==
        widget.bookList[index].category.categ) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            height: 35,
            child: ListView.builder(
                controller: _scrollController,
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                scrollDirection: Axis.horizontal,
                itemCount: widget.catList.length,
                itemBuilder: (BuildContext context, int itemIndex) {
                  return InkWell(
                    onTap: () {
                      _scrollToIndex(itemIndex);
                      _scrollToNewsIndex(itemIndex);
                      setState(() {
                        _isSelected = itemIndex;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                          color: _isSelected == itemIndex
                              ? kPrimaryColor
                              : KSecondaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        widget.catList[itemIndex].categ!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
          ),
        ),
        Container(
          height: heightP(context, 0.45),
          child: ListView.builder(
              controller: _newsSectionController,
              scrollDirection: Axis.horizontal,
              physics:
                  BouncingScrollPhysics(parent: NeverScrollableScrollPhysics()),
              itemCount: widget.catList.length,
              itemBuilder: (BuildContext context, int itemIndex) {
                return InkWell(
                  onTap: () {},
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.5),
                    width: widthP(context, 0.9),
                    decoration: BoxDecoration(),
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemCount: widget.bookList.length,
                        itemBuilder: (BuildContext context, int itemIndex) {
                          return catListLocal.isEmpty
                              ? SizedBox()
                              : (catListLocal[_isSelected].categ! ==
                                      widget.bookList[itemIndex].category!.categ
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BookDetailsPage(
                                                      catList: widget.catList,
                                                      bookAddedList:
                                                          widget.bookList,
                                                      internet: widget.internet,
                                                      amount: widget.amount,
                                                      id: widget
                                                          .bookList[itemIndex]
                                                          .id,
                                                      libraryBookList: widget
                                                          .libraryBookList,
                                                      bookpicture: widget
                                                          .bookList[itemIndex]
                                                          .bookPicture,
                                                      bookTitle: widget
                                                          .bookList[itemIndex]
                                                          .bookTitle,
                                                      bookAuthor: widget
                                                          .bookList[itemIndex]
                                                          .author!
                                                          .author,
                                                      bookPrice: widget
                                                          .bookList[itemIndex]
                                                          .price,
                                                      bookDescription: widget
                                                          .bookList[itemIndex]
                                                          .description,
                                                      bookCategory: widget
                                                          .bookList[itemIndex]
                                                          .category!
                                                          .categ,
                                                      bookLanguage: widget
                                                          .bookList[itemIndex]
                                                          .language!
                                                          .lang,
                                                      bookEditor:
                                                          widget
                                                              .bookList[
                                                                  itemIndex]
                                                              .editor!
                                                              .editor,
                                                      book: widget
                                                          .bookList[itemIndex]
                                                          .book)),
                                        );
                                      },
                                      child: BookItem(
                                          id: widget.bookList[itemIndex].id,
                                          bookpicture: widget
                                              .bookList[itemIndex].bookPicture,
                                          bookTitle: widget
                                              .bookList[itemIndex].bookTitle,
                                          bookAuthor: widget.bookList[itemIndex]
                                              .author!.author,
                                          bookPrice:
                                              widget.bookList[itemIndex].price,
                                          bookDescription: widget
                                              .bookList[itemIndex].description,
                                          bookCategory: widget
                                              .bookList[itemIndex]
                                              .category!
                                              .categ,
                                          bookLanguage: widget
                                              .bookList[itemIndex]
                                              .language!
                                              .lang,
                                          bookEditor: widget.bookList[itemIndex]
                                              .editor!.editor,
                                          book:
                                              widget.bookList[itemIndex].book),
                                    )
                                  : SizedBox());
                        }),
                  ),
                );
              }),
        ),
      ],
    );
  }
}

class CatLoading extends StatefulWidget {
  const CatLoading({Key? key}) : super(key: key);

  @override
  State<CatLoading> createState() => _CatLoadingState();
}

class _CatLoadingState extends State<CatLoading> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Color.fromARGB(255, 226, 224, 224),
        highlightColor: Color.fromARGB(255, 250, 250, 250),
        enabled: true,
        child: Container(
            height: 35,
            child: ListView.builder(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (BuildContext context, int itemIndex) {
                  return InkWell(
                    onTap: () {},
                    child: Container(
                      width: 100,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                })));
  }
}

class BookItemLoading extends StatefulWidget {
  const BookItemLoading({Key? key}) : super(key: key);

  @override
  State<BookItemLoading> createState() => _BookItemLoadingState();
}

class _BookItemLoadingState extends State<BookItemLoading> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
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
        ));
  }
}

class LoadingListPage extends StatefulWidget {
  final bool _seeAll;
  LoadingListPage(this._seeAll);
  @override
  _LoadingListPageState createState() => _LoadingListPageState();
}

class _LoadingListPageState extends State<LoadingListPage> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color.fromARGB(255, 226, 224, 224),
      highlightColor: Color.fromARGB(255, 250, 250, 250),
      enabled: true,
      child: widget._seeAll
          ? AnimatedContainer(
              height: widget._seeAll ? heightP(context, 0.64) : 0,
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              duration: Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              child: GridView.builder(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 125,
                    childAspectRatio: 1 / 2,
                    mainAxisSpacing: 0.0),
                itemCount: 6,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {},
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 7),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7)),
                          )
                        ]),
                  ),
                ),
              ))
          : CarouselSlider.builder(
              options: CarouselOptions(
                  padEnds: false,
                  scrollPhysics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  enableInfiniteScroll: false,
                  viewportFraction: 0.42,
                  height: 300),
              itemCount: 3,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) {
                return InkWell(
                  onTap: () {},
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 7),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7)),
                          )
                        ]),
                  ),
                );
              }),
    );
  }
}

class AudioLoading extends StatefulWidget {
  const AudioLoading({Key? key}) : super(key: key);

  @override
  State<AudioLoading> createState() => _AudioLoadingState();
}

class _AudioLoadingState extends State<AudioLoading> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Color.fromARGB(255, 226, 224, 224),
        highlightColor: Color.fromARGB(255, 250, 250, 250),
        enabled: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {},
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
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
                  width: widthP(context, 0.2),
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
        ));
  }
}
